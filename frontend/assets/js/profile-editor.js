// Profile Editor - Complete user profile form
class ProfileEditor {
  constructor(userId = null) {
    this.apiClient = window.apiClient;
    this.store = window.appStore;
    this.userId = userId;
    this.formData = {};
    this.errors = {};
    this.init();
  }

  async init() {
    await this.loadProfile();
    this.setupForm();
    this.setupEventListeners();
  }

  async loadProfile() {
    try {
      const user = await this.apiClient.getProfile();
      this.formData = {
        name: user.name || '',
        email: user.email || '',
        age: user.age || '',
        gender: user.gender || '',
        genderPreference: user.genderPreference || 'Any',
        bio: user.bio || '',
        religion: user.religion || '',
        bodyType: user.bodyType || '',
        educationLevel: user.educationLevel || '',
        relationshipGoal: user.relationshipGoal || '',
        location: {
          city: user.location?.city || '',
          latitude: user.location?.coordinates?.[1] || '',
          longitude: user.location?.coordinates?.[0] || ''
        },
        ageRange: {
          min: user.ageRange?.min || 18,
          max: user.ageRange?.max || 99
        },
        filterPreferences: {
          maxDistance: user.filterPreferences?.maxDistance || 50,
          religions: user.filterPreferences?.religions || [],
          bodyTypes: user.filterPreferences?.bodyTypes || [],
          educationLevels: user.filterPreferences?.educationLevels || [],
          relationshipGoals: user.filterPreferences?.relationshipGoals || []
        }
      };
    } catch (error) {
      console.error('Failed to load profile:', error);
      window.Utils.showToast('Failed to load profile', 3000, 'error');
    }
  }

  setupForm() {
    const form = document.getElementById('profile-form');
    if (!form) return;

    form.innerHTML = this.renderForm();
  }

  setupEventListeners() {
    const form = document.getElementById('profile-form');
    if (!form) return;

    form.addEventListener('input', (e) => this.handleInput(e));
    form.addEventListener('change', (e) => this.handleChange(e));
    
    const submitBtn = form.querySelector('[type="submit"]');
    if (submitBtn) {
      submitBtn.addEventListener('click', (e) => this.handleSubmit(e));
    }

    const photoInput = form.querySelector('#photo-input');
    if (photoInput) {
      photoInput.addEventListener('change', (e) => this.handlePhotoUpload(e));
    }
  }

  handleInput(e) {
    const { name, value } = e.target;
    this.setFormValue(name, value);
    this.validateField(name);
  }

  handleChange(e) {
    const { name, value, type, checked } = e.target;
    
    if (type === 'checkbox') {
      this.toggleArrayValue(name, value, checked);
    } else {
      this.setFormValue(name, value);
    }
    
    this.validateField(name);
  }

  setFormValue(path, value) {
    const keys = path.split('.');
    let current = this.formData;
    
    for (let i = 0; i < keys.length - 1; i++) {
      const key = keys[i];
      if (!current[key]) current[key] = {};
      current = current[key];
    }
    
    current[keys[keys.length - 1]] = value;
  }

  toggleArrayValue(path, value, checked) {
    const keys = path.split('.');
    let current = this.formData;
    
    for (let i = 0; i < keys.length - 1; i++) {
      const key = keys[i];
      if (!current[key]) current[key] = [];
      current = current[key];
    }
    
    const arr = current[keys[keys.length - 1]];
    if (checked && !arr.includes(value)) {
      arr.push(value);
    } else if (!checked && arr.includes(value)) {
      arr.splice(arr.indexOf(value), 1);
    }
  }

  validateField(name) {
    this.errors = {};

    // Basic validations
    if (name === 'email' || !name) {
      if (this.formData.email && !window.Utils.isValidEmail(this.formData.email)) {
        this.errors.email = 'Invalid email address';
      }
    }

    if (name === 'name' || !name) {
      if (!this.formData.name || this.formData.name.trim().length < 2) {
        this.errors.name = 'Name must be at least 2 characters';
      }
    }

    if (name === 'age' || !name) {
      if (this.formData.age && (this.formData.age < 18 || this.formData.age > 100)) {
        this.errors.age = 'Age must be between 18 and 100';
      }
    }

    if (name === 'bio' || !name) {
      if (this.formData.bio && this.formData.bio.length > 500) {
        this.errors.bio = 'Bio must be less than 500 characters';
      }
    }

    if (name === 'ageRange.min' || name === 'ageRange.max' || !name) {
      const min = this.formData.ageRange?.min || 18;
      const max = this.formData.ageRange?.max || 99;
      
      if (min > max) {
        this.errors.ageRange = 'Minimum age cannot be greater than maximum';
      }
    }

    this.renderErrors();
  }

  renderErrors() {
    Object.entries(this.errors).forEach(([field, error]) => {
      const errorEl = document.querySelector(`[data-error="${field}"]`);
      if (errorEl) {
        errorEl.textContent = error;
        errorEl.style.display = 'block';
      }
    });
  }

  async handlePhotoUpload(e) {
    const file = e.target.files[0];
    if (!file) return;

    const maxSize = 5 * 1024 * 1024; // 5MB
    if (file.size > maxSize) {
      window.Utils.showToast('File too large (max 5MB)', 3000, 'error');
      return;
    }

    const reader = new FileReader();
    reader.onload = async (event) => {
      try {
        const base64 = event.target.result;
        const result = await this.apiClient.uploadMedia(
          file.name,
          base64,
          'image',
          file.size
        );
        
        if (!this.formData.photos) this.formData.photos = [];
        this.formData.photos.push(result.media.url);
        
        window.Utils.showToast('Photo uploaded!', 2000, 'success');
        this.setupForm();
      } catch (error) {
        window.Utils.showToast('Failed to upload photo', 3000, 'error');
      }
    };
    reader.readAsDataURL(file);
  }

  async handleSubmit(e) {
    e.preventDefault();

    // Final validation
    this.validateField('');
    
    if (Object.keys(this.errors).length > 0) {
      window.Utils.showToast('Please fix the errors', 3000, 'error');
      return;
    }

    try {
      this.store.setState({ loading: true });
      
      const updateData = {
        name: this.formData.name,
        age: parseInt(this.formData.age) || 0,
        gender: this.formData.gender,
        genderPreference: this.formData.genderPreference,
        bio: this.formData.bio,
        religion: this.formData.religion,
        bodyType: this.formData.bodyType,
        educationLevel: this.formData.educationLevel,
        relationshipGoal: this.formData.relationshipGoal,
        photos: this.formData.photos,
        location: {
          latitude: parseFloat(this.formData.location.latitude),
          longitude: parseFloat(this.formData.location.longitude),
          city: this.formData.location.city
        },
        ageRange: {
          min: parseInt(this.formData.ageRange.min),
          max: parseInt(this.formData.ageRange.max)
        },
        filterPreferences: this.formData.filterPreferences
      };

      await this.apiClient.updateProfile(updateData);
      
      this.store.setState({ loading: false });
      window.Utils.showToast('Profile updated!', 2000, 'success');
    } catch (error) {
      this.store.setState({ loading: false });
      window.Utils.showToast('Failed to update profile', 3000, 'error');
    }
  }

  renderForm() {
    const f = this.formData;

    return `
      <form class="profile-form">
        <!-- Basic Info -->
        <fieldset>
          <legend>Basic Information</legend>
          
          <div class="form-group">
            <label for="name">Name *</label>
            <input type="text" id="name" name="name" value="${f.name}" required>
            <span class="error" data-error="name"></span>
          </div>

          <div class="form-group">
            <label for="email">Email *</label>
            <input type="email" id="email" name="email" value="${f.email}" disabled>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="age">Age</label>
              <input type="number" id="age" name="age" min="18" max="100" value="${f.age}">
              <span class="error" data-error="age"></span>
            </div>

            <div class="form-group">
              <label for="gender">Gender</label>
              <select id="gender" name="gender">
                <option value="">Select</option>
                <option value="Male" ${f.gender === 'Male' ? 'selected' : ''}>Male</option>
                <option value="Female" ${f.gender === 'Female' ? 'selected' : ''}>Female</option>
                <option value="Other" ${f.gender === 'Other' ? 'selected' : ''}>Other</option>
              </select>
            </div>

            <div class="form-group">
              <label for="genderPreference">Looking For</label>
              <select id="genderPreference" name="genderPreference">
                <option value="Any" ${f.genderPreference === 'Any' ? 'selected' : ''}>Anyone</option>
                <option value="Male" ${f.genderPreference === 'Male' ? 'selected' : ''}>Males</option>
                <option value="Female" ${f.genderPreference === 'Female' ? 'selected' : ''}>Females</option>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label for="bio">Bio</label>
            <textarea id="bio" name="bio" maxlength="500" rows="4">${f.bio}</textarea>
            <small>${(f.bio || '').length}/500</small>
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
            ${(f.photos || []).map((photo, idx) => `
              <div class="photo-item">
                <img src="${photo}" alt="Photo ${idx + 1}">
              </div>
            `).join('')}
          </div>
        </fieldset>

        <!-- Details -->
        <fieldset>
          <legend>Personal Details</legend>
          
          <div class="form-row">
            <div class="form-group">
              <label for="religion">Religion</label>
              <input type="text" id="religion" name="religion" value="${f.religion}">
            </div>

            <div class="form-group">
              <label for="bodyType">Body Type</label>
              <select id="bodyType" name="bodyType">
                <option value="">Select</option>
                <option value="Slim" ${f.bodyType === 'Slim' ? 'selected' : ''}>Slim</option>
                <option value="Athletic" ${f.bodyType === 'Athletic' ? 'selected' : ''}>Athletic</option>
                <option value="Average" ${f.bodyType === 'Average' ? 'selected' : ''}>Average</option>
                <option value="Curvy" ${f.bodyType === 'Curvy' ? 'selected' : ''}>Curvy</option>
                <option value="Plus Size" ${f.bodyType === 'Plus Size' ? 'selected' : ''}>Plus Size</option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="educationLevel">Education</label>
              <select id="educationLevel" name="educationLevel">
                <option value="">Select</option>
                <option value="High School" ${f.educationLevel === 'High School' ? 'selected' : ''}>High School</option>
                <option value="Bachelor's" ${f.educationLevel === "Bachelor's" ? 'selected' : ''}>Bachelor's</option>
                <option value="Master's" ${f.educationLevel === "Master's" ? 'selected' : ''}>Master's</option>
                <option value="PhD" ${f.educationLevel === 'PhD' ? 'selected' : ''}>PhD</option>
              </select>
            </div>

            <div class="form-group">
              <label for="relationshipGoal">Relationship Goal</label>
              <select id="relationshipGoal" name="relationshipGoal">
                <option value="">Select</option>
                <option value="Casual" ${f.relationshipGoal === 'Casual' ? 'selected' : ''}>Casual</option>
                <option value="Dating" ${f.relationshipGoal === 'Dating' ? 'selected' : ''}>Dating</option>
                <option value="Serious" ${f.relationshipGoal === 'Serious' ? 'selected' : ''}>Serious</option>
                <option value="Marriage" ${f.relationshipGoal === 'Marriage' ? 'selected' : ''}>Marriage</option>
              </select>
            </div>
          </div>
        </fieldset>

        <!-- Location -->
        <fieldset>
          <legend>Location</legend>
          
          <div class="form-group">
            <label for="city">City</label>
            <input type="text" id="city" name="location.city" value="${f.location.city}">
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="latitude">Latitude</label>
              <input type="number" id="latitude" name="location.latitude" step="0.0001" value="${f.location.latitude}">
            </div>
            <div class="form-group">
              <label for="longitude">Longitude</label>
              <input type="number" id="longitude" name="location.longitude" step="0.0001" value="${f.location.longitude}">
            </div>
          </div>
        </fieldset>

        <!-- Preferences -->
        <fieldset>
          <legend>Match Preferences</legend>
          
          <div class="form-group">
            <label for="maxDistance">Max Distance (km)</label>
            <input type="number" id="maxDistance" name="filterPreferences.maxDistance" min="1" max="500" value="${f.filterPreferences.maxDistance}">
          </div>

          <div class="form-group">
            <label>Preferred Age Range</label>
            <div class="form-row">
              <input type="number" name="ageRange.min" min="18" max="100" value="${f.ageRange.min}" placeholder="Min">
              <input type="number" name="ageRange.max" min="18" max="100" value="${f.ageRange.max}" placeholder="Max">
            </div>
            <span class="error" data-error="ageRange"></span>
          </div>
        </fieldset>

        <div class="form-actions">
          <button type="submit" class="btn btn-primary">Save Profile</button>
          <button type="button" class="btn btn-secondary" onclick="history.back()">Cancel</button>
        </div>
      </form>
    `;
  }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  if (window.apiClient && window.appStore.getState().isAuthenticated) {
    new ProfileEditor();
  } else {
    window.location.href = '/pages/login.html';
  }
});

export { ProfileEditor };
