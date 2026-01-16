(()=>{var s=class{constructor(e=null){this.apiClient=window.apiClient,this.store=window.appStore,this.userId=e,this.formData={},this.errors={},this.init()}async init(){await this.loadProfile(),this.setupForm(),this.setupEventListeners()}async loadProfile(){try{let e=await this.apiClient.getProfile();this.formData={name:e.name||"",email:e.email||"",age:e.age||"",gender:e.gender||"",genderPreference:e.genderPreference||"Any",bio:e.bio||"",religion:e.religion||"",bodyType:e.bodyType||"",educationLevel:e.educationLevel||"",relationshipGoal:e.relationshipGoal||"",location:{city:e.location?.city||"",latitude:e.location?.coordinates?.[1]||"",longitude:e.location?.coordinates?.[0]||""},ageRange:{min:e.ageRange?.min||18,max:e.ageRange?.max||99},filterPreferences:{maxDistance:e.filterPreferences?.maxDistance||50,religions:e.filterPreferences?.religions||[],bodyTypes:e.filterPreferences?.bodyTypes||[],educationLevels:e.filterPreferences?.educationLevels||[],relationshipGoals:e.filterPreferences?.relationshipGoals||[]}}}catch(e){console.error("Failed to load profile:",e),window.Utils.showToast("Failed to load profile",3e3,"error")}}setupForm(){let e=document.getElementById("profile-form");e&&(e.innerHTML=this.renderForm())}setupEventListeners(){let e=document.getElementById("profile-form");if(!e)return;e.addEventListener("input",i=>this.handleInput(i)),e.addEventListener("change",i=>this.handleChange(i));let t=e.querySelector('[type="submit"]');t&&t.addEventListener("click",i=>this.handleSubmit(i));let a=e.querySelector("#photo-input");a&&a.addEventListener("change",i=>this.handlePhotoUpload(i))}handleInput(e){let{name:t,value:a}=e.target;this.setFormValue(t,a),this.validateField(t)}handleChange(e){let{name:t,value:a,type:i,checked:o}=e.target;i==="checkbox"?this.toggleArrayValue(t,a,o):this.setFormValue(t,a),this.validateField(t)}setFormValue(e,t){let a=e.split("."),i=this.formData;for(let o=0;o<a.length-1;o++){let l=a[o];i[l]||(i[l]={}),i=i[l]}i[a[a.length-1]]=t}toggleArrayValue(e,t,a){let i=e.split("."),o=this.formData;for(let r=0;r<i.length-1;r++){let n=i[r];o[n]||(o[n]=[]),o=o[n]}let l=o[i[i.length-1]];a&&!l.includes(t)?l.push(t):!a&&l.includes(t)&&l.splice(l.indexOf(t),1)}validateField(e){if(this.errors={},(e==="email"||!e)&&this.formData.email&&!window.Utils.isValidEmail(this.formData.email)&&(this.errors.email="Invalid email address"),(e==="name"||!e)&&(!this.formData.name||this.formData.name.trim().length<2)&&(this.errors.name="Name must be at least 2 characters"),(e==="age"||!e)&&this.formData.age&&(this.formData.age<18||this.formData.age>100)&&(this.errors.age="Age must be between 18 and 100"),(e==="bio"||!e)&&this.formData.bio&&this.formData.bio.length>500&&(this.errors.bio="Bio must be less than 500 characters"),e==="ageRange.min"||e==="ageRange.max"||!e){let t=this.formData.ageRange?.min||18,a=this.formData.ageRange?.max||99;t>a&&(this.errors.ageRange="Minimum age cannot be greater than maximum")}this.renderErrors()}renderErrors(){Object.entries(this.errors).forEach(([e,t])=>{let a=document.querySelector(`[data-error="${e}"]`);a&&(a.textContent=t,a.style.display="block")})}async handlePhotoUpload(e){let t=e.target.files[0];if(!t)return;let a=5*1024*1024;if(t.size>a){window.Utils.showToast("File too large (max 5MB)",3e3,"error");return}let i=new FileReader;i.onload=async o=>{try{let l=o.target.result,r=await this.apiClient.uploadMedia(t.name,l,"image",t.size);this.formData.photos||(this.formData.photos=[]),this.formData.photos.push(r.media.url),window.Utils.showToast("Photo uploaded!",2e3,"success"),this.setupForm()}catch{window.Utils.showToast("Failed to upload photo",3e3,"error")}},i.readAsDataURL(t)}async handleSubmit(e){if(e.preventDefault(),this.validateField(""),Object.keys(this.errors).length>0){window.Utils.showToast("Please fix the errors",3e3,"error");return}try{this.store.setState({loading:!0});let t={name:this.formData.name,age:parseInt(this.formData.age)||0,gender:this.formData.gender,genderPreference:this.formData.genderPreference,bio:this.formData.bio,religion:this.formData.religion,bodyType:this.formData.bodyType,educationLevel:this.formData.educationLevel,relationshipGoal:this.formData.relationshipGoal,photos:this.formData.photos,location:{latitude:parseFloat(this.formData.location.latitude),longitude:parseFloat(this.formData.location.longitude),city:this.formData.location.city},ageRange:{min:parseInt(this.formData.ageRange.min),max:parseInt(this.formData.ageRange.max)},filterPreferences:this.formData.filterPreferences};await this.apiClient.updateProfile(t),this.store.setState({loading:!1}),window.Utils.showToast("Profile updated!",2e3,"success")}catch{this.store.setState({loading:!1}),window.Utils.showToast("Failed to update profile",3e3,"error")}}renderForm(){let e=this.formData;return`
      <form class="profile-form">
        <!-- Basic Info -->
        <fieldset>
          <legend>Basic Information</legend>
          
          <div class="form-group">
            <label for="name">Name *</label>
            <input type="text" id="name" name="name" value="${e.name}" required>
            <span class="error" data-error="name"></span>
          </div>

          <div class="form-group">
            <label for="email">Email *</label>
            <input type="email" id="email" name="email" value="${e.email}" disabled>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="age">Age</label>
              <input type="number" id="age" name="age" min="18" max="100" value="${e.age}">
              <span class="error" data-error="age"></span>
            </div>

            <div class="form-group">
              <label for="gender">Gender</label>
              <select id="gender" name="gender">
                <option value="">Select</option>
                <option value="Male" ${e.gender==="Male"?"selected":""}>Male</option>
                <option value="Female" ${e.gender==="Female"?"selected":""}>Female</option>
                <option value="Other" ${e.gender==="Other"?"selected":""}>Other</option>
              </select>
            </div>

            <div class="form-group">
              <label for="genderPreference">Looking For</label>
              <select id="genderPreference" name="genderPreference">
                <option value="Any" ${e.genderPreference==="Any"?"selected":""}>Anyone</option>
                <option value="Male" ${e.genderPreference==="Male"?"selected":""}>Males</option>
                <option value="Female" ${e.genderPreference==="Female"?"selected":""}>Females</option>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label for="bio">Bio</label>
            <textarea id="bio" name="bio" maxlength="500" rows="4">${e.bio}</textarea>
            <small>${(e.bio||"").length}/500</small>
            <span class="error" data-error="bio"></span>
          </div>
        </fieldset>

        <!-- Photos -->
        <fieldset>
          <legend>Photos</legend>
          <div class="form-group">
            <label for="photo-input">Upload Photo</label>
            <input type="file" id="photo-input" accept="image/*">
          </div>
          <div class="photos-gallery">
            ${(e.photos||[]).map((t,a)=>`
              <div class="photo-item">
                <img src="${t}" alt="Photo ${a+1}">
              </div>
            `).join("")}
          </div>
        </fieldset>

        <!-- Details -->
        <fieldset>
          <legend>Personal Details</legend>
          
          <div class="form-row">
            <div class="form-group">
              <label for="religion">Religion</label>
              <input type="text" id="religion" name="religion" value="${e.religion}">
            </div>

            <div class="form-group">
              <label for="bodyType">Body Type</label>
              <select id="bodyType" name="bodyType">
                <option value="">Select</option>
                <option value="Slim" ${e.bodyType==="Slim"?"selected":""}>Slim</option>
                <option value="Athletic" ${e.bodyType==="Athletic"?"selected":""}>Athletic</option>
                <option value="Average" ${e.bodyType==="Average"?"selected":""}>Average</option>
                <option value="Curvy" ${e.bodyType==="Curvy"?"selected":""}>Curvy</option>
                <option value="Plus Size" ${e.bodyType==="Plus Size"?"selected":""}>Plus Size</option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="educationLevel">Education</label>
              <select id="educationLevel" name="educationLevel">
                <option value="">Select</option>
                <option value="High School" ${e.educationLevel==="High School"?"selected":""}>High School</option>
                <option value="Bachelor's" ${e.educationLevel==="Bachelor's"?"selected":""}>Bachelor's</option>
                <option value="Master's" ${e.educationLevel==="Master's"?"selected":""}>Master's</option>
                <option value="PhD" ${e.educationLevel==="PhD"?"selected":""}>PhD</option>
              </select>
            </div>

            <div class="form-group">
              <label for="relationshipGoal">Relationship Goal</label>
              <select id="relationshipGoal" name="relationshipGoal">
                <option value="">Select</option>
                <option value="Casual" ${e.relationshipGoal==="Casual"?"selected":""}>Casual</option>
                <option value="Dating" ${e.relationshipGoal==="Dating"?"selected":""}>Dating</option>
                <option value="Serious" ${e.relationshipGoal==="Serious"?"selected":""}>Serious</option>
                <option value="Marriage" ${e.relationshipGoal==="Marriage"?"selected":""}>Marriage</option>
              </select>
            </div>
          </div>
        </fieldset>

        <!-- Location -->
        <fieldset>
          <legend>Location</legend>
          
          <div class="form-group">
            <label for="city">City</label>
            <input type="text" id="city" name="location.city" value="${e.location.city}">
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="latitude">Latitude</label>
              <input type="number" id="latitude" name="location.latitude" step="0.0001" value="${e.location.latitude}">
            </div>
            <div class="form-group">
              <label for="longitude">Longitude</label>
              <input type="number" id="longitude" name="location.longitude" step="0.0001" value="${e.location.longitude}">
            </div>
          </div>
        </fieldset>

        <!-- Preferences -->
        <fieldset>
          <legend>Match Preferences</legend>
          
          <div class="form-group">
            <label for="maxDistance">Max Distance (km)</label>
            <input type="number" id="maxDistance" name="filterPreferences.maxDistance" min="1" max="500" value="${e.filterPreferences.maxDistance}">
          </div>

          <div class="form-group">
            <label>Preferred Age Range</label>
            <div class="form-row">
              <input type="number" name="ageRange.min" min="18" max="100" value="${e.ageRange.min}" placeholder="Min">
              <input type="number" name="ageRange.max" min="18" max="100" value="${e.ageRange.max}" placeholder="Max">
            </div>
            <span class="error" data-error="ageRange"></span>
          </div>
        </fieldset>

        <div class="form-actions">
          <button type="submit" class="btn btn-primary">Save Profile</button>
          <button type="button" class="btn btn-secondary" onclick="history.back()">Cancel</button>
        </div>
      </form>
    `}};document.addEventListener("DOMContentLoaded",()=>{window.apiClient&&window.appStore.getState().isAuthenticated?new s:window.location.href="/pages/login.html"});})();
//# sourceMappingURL=profile-editor.js.map
