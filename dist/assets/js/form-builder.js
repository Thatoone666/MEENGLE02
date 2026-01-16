(()=>{var d=class{constructor(e,t={}){this.formId=e,this.schema=t,this.formElement=null,this.values={},this.errors={},this.validators={},this.listeners={}}addField(e,t){return this.schema[e]=t,this}addValidator(e,t){return this.validators[e]=t,this}onSubmit(e){return this.listeners.submit=e,this}onChange(e,t){return this.listeners.change||(this.listeners.change={}),this.listeners.change[e]=t,this}render(e=null){let t=this.buildHTML();if(e)e.innerHTML=t;else if(this.formId){let s=document.getElementById(this.formId);s&&(s.innerHTML=t)}return this.setupEventListeners(),this}buildHTML(){let e='<form class="dynamic-form">';return Object.entries(this.schema).forEach(([t,s])=>{e+=this.buildField(t,s)}),e+=`
      <div class="form-actions">
        <button type="submit" class="btn btn-primary">Submit</button>
        <button type="reset" class="btn btn-secondary">Reset</button>
      </div>
    </form>
    `,e}buildField(e,t){let{type:s="text",label:r="",placeholder:n="",required:a=!1,options:c=[],value:u="",min:h=null,max:o=null,step:$=null,rows:v=4,helper:b="",validation:m=null}=t,i='<div class="form-group">';switch(r&&(i+=`
        <label for="${e}">
          ${r}
          ${a?'<span class="required">*</span>':""}
        </label>
      `),s){case"text":case"email":case"password":case"url":case"tel":i+=`
          <input 
            type="${s}" 
            id="${e}" 
            name="${e}" 
            value="${u}" 
            placeholder="${n}"
            ${a?"required":""}
            ${h!==null?`min="${h}"`:""}
            ${o!==null?`max="${o}"`:""}
          >
        `;break;case"number":i+=`
          <input 
            type="number" 
            id="${e}" 
            name="${e}" 
            value="${u}" 
            placeholder="${n}"
            ${a?"required":""}
            ${h!==null?`min="${h}"`:""}
            ${o!==null?`max="${o}"`:""}
            ${$!==null?`step="${$}"`:""}
          >
        `;break;case"textarea":i+=`
          <textarea 
            id="${e}" 
            name="${e}" 
            rows="${v}" 
            placeholder="${n}"
            ${a?"required":""}
          >${u}</textarea>
        `;break;case"select":i+=`
          <select id="${e}" name="${e}" ${a?"required":""}>
            <option value="">-- Select --</option>
            ${c.map(l=>`
              <option value="${l.value}" ${l.value===u?"selected":""}>
                ${l.label}
              </option>
            `).join("")}
          </select>
        `;break;case"checkbox":i+=`
          <div class="checkbox-group">
            ${c.map(l=>`
              <label class="checkbox-label">
                <input 
                  type="checkbox" 
                  name="${e}" 
                  value="${l.value}"
                  ${Array.isArray(u)&&u.includes(l.value)?"checked":""}
                >
                ${l.label}
              </label>
            `).join("")}
          </div>
        `;break;case"radio":i+=`
          <div class="radio-group">
            ${c.map(l=>`
              <label class="radio-label">
                <input 
                  type="radio" 
                  name="${e}" 
                  value="${l.value}"
                  ${l.value===u?"checked":""}
                >
                ${l.label}
              </label>
            `).join("")}
          </div>
        `;break;case"date":i+=`
          <input 
            type="date" 
            id="${e}" 
            name="${e}" 
            value="${u}"
            ${a?"required":""}
          >
        `;break;case"file":i+=`
          <input 
            type="file" 
            id="${e}" 
            name="${e}"
            ${a?"required":""}
          >
        `;break}return i+=`<span class="error" data-error="${e}"></span>`,b&&(i+=`<small class="helper">${b}</small>`),i+="</div>",i}setupEventListeners(){let e=document.querySelector(".dynamic-form");e&&(e.addEventListener("submit",t=>{t.preventDefault(),this.handleSubmit()}),e.querySelectorAll("input, textarea, select").forEach(t=>{t.addEventListener("change",s=>{this.handleFieldChange(s)}),t.addEventListener("blur",s=>{this.validateField(s.target.name)})}))}handleFieldChange(e){let{name:t,type:s,value:r,checked:n}=e.target;s==="checkbox"?(this.values[t]||(this.values[t]=[]),n?this.values[t].push(r):this.values[t]=this.values[t].filter(a=>a!==r)):this.values[t]=r,this.listeners.change&&this.listeners.change[t]&&this.listeners.change[t](this.values[t],this.values)}validateField(e){this.errors[e]=[];let t=this.schema[e],s=this.values[e];if(t.required&&(!s||s.length===0)&&this.errors[e].push(`${t.label} is required`),this.validators[e]){let n=this.validators[e](s);n!==!0&&this.errors[e].push(n)}let r=document.querySelector(`[data-error="${e}"]`);return r&&(this.errors[e].length>0?(r.textContent=this.errors[e][0],r.style.display="block"):(r.textContent="",r.style.display="none")),this.errors[e].length===0}validate(){let e=!0;return Object.keys(this.schema).forEach(t=>{this.validateField(t)||(e=!1)}),e}handleSubmit(){var e;if(!this.validate()){(e=window.Utils)==null||e.showToast("Please fix the errors",3e3,"error");return}this.listeners.submit&&this.listeners.submit(this.values)}getValues(){return{...this.values}}setValues(e){return this.values={...e},this.updateFormFields(),this}updateFormFields(){let e=document.querySelector(".dynamic-form");e&&Object.entries(this.values).forEach(([t,s])=>{let r=e.querySelector(`[name="${t}"]`);r&&(r.type==="checkbox"?r.checked=Array.isArray(s)&&s.includes(r.value):r.type==="radio"?r.checked=r.value===s:r.value=s)})}reset(){this.values={},this.errors={};let e=document.querySelector(".dynamic-form");return e&&e.reset(),this}};window.FormBuilder=d;})();
//# sourceMappingURL=form-builder.js.map
