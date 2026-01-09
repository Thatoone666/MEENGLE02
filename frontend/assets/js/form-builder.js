// Form Builder - Create and manage dynamic forms
class FormBuilder {
  constructor(formId, schema = {}) {
    this.formId = formId;
    this.schema = schema;
    this.formElement = null;
    this.values = {};
    this.errors = {};
    this.validators = {};
    this.listeners = {};
  }

  addField(name, field) {
    this.schema[name] = field;
    return this;
  }

  addValidator(fieldName, validator) {
    this.validators[fieldName] = validator;
    return this;
  }

  onSubmit(callback) {
    this.listeners.submit = callback;
    return this;
  }

  onChange(fieldName, callback) {
    if (!this.listeners.change) {
      this.listeners.change = {};
    }
    this.listeners.change[fieldName] = callback;
    return this;
  }

  render(container = null) {
    const html = this.buildHTML();
    
    if (container) {
      container.innerHTML = html;
    } else if (this.formId) {
      const el = document.getElementById(this.formId);
      if (el) {
        el.innerHTML = html;
      }
    }

    this.setupEventListeners();
    return this;
  }

  buildHTML() {
    let html = '<form class="dynamic-form">';

    Object.entries(this.schema).forEach(([name, field]) => {
      html += this.buildField(name, field);
    });

    html += `
      <div class="form-actions">
        <button type="submit" class="btn btn-primary">Submit</button>
        <button type="reset" class="btn btn-secondary">Reset</button>
      </div>
    </form>
    `;

    return html;
  }

  buildField(name, field) {
    const {
      type = 'text',
      label = '',
      placeholder = '',
      required = false,
      options = [],
      value = '',
      min = null,
      max = null,
      step = null,
      rows = 4,
      helper = '',
      validation = null
    } = field;

    let fieldHTML = `<div class="form-group">`;

    if (label) {
      fieldHTML += `
        <label for="${name}">
          ${label}
          ${required ? '<span class="required">*</span>' : ''}
        </label>
      `;
    }

    switch (type) {
      case 'text':
      case 'email':
      case 'password':
      case 'url':
      case 'tel':
        fieldHTML += `
          <input 
            type="${type}" 
            id="${name}" 
            name="${name}" 
            value="${value}" 
            placeholder="${placeholder}"
            ${required ? 'required' : ''}
            ${min !== null ? `min="${min}"` : ''}
            ${max !== null ? `max="${max}"` : ''}
          >
        `;
        break;

      case 'number':
        fieldHTML += `
          <input 
            type="number" 
            id="${name}" 
            name="${name}" 
            value="${value}" 
            placeholder="${placeholder}"
            ${required ? 'required' : ''}
            ${min !== null ? `min="${min}"` : ''}
            ${max !== null ? `max="${max}"` : ''}
            ${step !== null ? `step="${step}"` : ''}
          >
        `;
        break;

      case 'textarea':
        fieldHTML += `
          <textarea 
            id="${name}" 
            name="${name}" 
            rows="${rows}" 
            placeholder="${placeholder}"
            ${required ? 'required' : ''}
          >${value}</textarea>
        `;
        break;

      case 'select':
        fieldHTML += `
          <select id="${name}" name="${name}" ${required ? 'required' : ''}>
            <option value="">-- Select --</option>
            ${options.map(opt => `
              <option value="${opt.value}" ${opt.value === value ? 'selected' : ''}>
                ${opt.label}
              </option>
            `).join('')}
          </select>
        `;
        break;

      case 'checkbox':
        fieldHTML += `
          <div class="checkbox-group">
            ${options.map(opt => `
              <label class="checkbox-label">
                <input 
                  type="checkbox" 
                  name="${name}" 
                  value="${opt.value}"
                  ${Array.isArray(value) && value.includes(opt.value) ? 'checked' : ''}
                >
                ${opt.label}
              </label>
            `).join('')}
          </div>
        `;
        break;

      case 'radio':
        fieldHTML += `
          <div class="radio-group">
            ${options.map(opt => `
              <label class="radio-label">
                <input 
                  type="radio" 
                  name="${name}" 
                  value="${opt.value}"
                  ${opt.value === value ? 'checked' : ''}
                >
                ${opt.label}
              </label>
            `).join('')}
          </div>
        `;
        break;

      case 'date':
        fieldHTML += `
          <input 
            type="date" 
            id="${name}" 
            name="${name}" 
            value="${value}"
            ${required ? 'required' : ''}
          >
        `;
        break;

      case 'file':
        fieldHTML += `
          <input 
            type="file" 
            id="${name}" 
            name="${name}"
            ${required ? 'required' : ''}
          >
        `;
        break;
    }

    fieldHTML += `<span class="error" data-error="${name}"></span>`;

    if (helper) {
      fieldHTML += `<small class="helper">${helper}</small>`;
    }

    fieldHTML += '</div>';

    return fieldHTML;
  }

  setupEventListeners() {
    const form = document.querySelector('.dynamic-form');
    if (!form) return;

    // Form submit
    form.addEventListener('submit', (e) => {
      e.preventDefault();
      this.handleSubmit();
    });

    // Field changes
    form.querySelectorAll('input, textarea, select').forEach(field => {
      field.addEventListener('change', (e) => {
        this.handleFieldChange(e);
      });

      field.addEventListener('blur', (e) => {
        this.validateField(e.target.name);
      });
    });
  }

  handleFieldChange(e) {
    const { name, type, value, checked } = e.target;

    if (type === 'checkbox') {
      if (!this.values[name]) this.values[name] = [];
      if (checked) {
        this.values[name].push(value);
      } else {
        this.values[name] = this.values[name].filter(v => v !== value);
      }
    } else {
      this.values[name] = value;
    }

    // Call change listener
    if (this.listeners.change && this.listeners.change[name]) {
      this.listeners.change[name](this.values[name], this.values);
    }
  }

  validateField(fieldName) {
    this.errors[fieldName] = [];

    const field = this.schema[fieldName];
    const value = this.values[fieldName];

    // Required validation
    if (field.required && (!value || value.length === 0)) {
      this.errors[fieldName].push(`${field.label} is required`);
    }

    // Custom validator
    if (this.validators[fieldName]) {
      const result = this.validators[fieldName](value);
      if (result !== true) {
        this.errors[fieldName].push(result);
      }
    }

    // Display error
    const errorEl = document.querySelector(`[data-error="${fieldName}"]`);
    if (errorEl) {
      if (this.errors[fieldName].length > 0) {
        errorEl.textContent = this.errors[fieldName][0];
        errorEl.style.display = 'block';
      } else {
        errorEl.textContent = '';
        errorEl.style.display = 'none';
      }
    }

    return this.errors[fieldName].length === 0;
  }

  validate() {
    let isValid = true;

    Object.keys(this.schema).forEach(fieldName => {
      if (!this.validateField(fieldName)) {
        isValid = false;
      }
    });

    return isValid;
  }

  handleSubmit() {
    if (!this.validate()) {
      window.Utils?.showToast('Please fix the errors', 3000, 'error');
      return;
    }

    if (this.listeners.submit) {
      this.listeners.submit(this.values);
    }
  }

  getValues() {
    return { ...this.values };
  }

  setValues(values) {
    this.values = { ...values };
    this.updateFormFields();
    return this;
  }

  updateFormFields() {
    const form = document.querySelector('.dynamic-form');
    if (!form) return;

    Object.entries(this.values).forEach(([name, value]) => {
      const field = form.querySelector(`[name="${name}"]`);
      if (!field) return;

      if (field.type === 'checkbox') {
        field.checked = Array.isArray(value) && value.includes(field.value);
      } else if (field.type === 'radio') {
        field.checked = field.value === value;
      } else {
        field.value = value;
      }
    });
  }

  reset() {
    this.values = {};
    this.errors = {};
    const form = document.querySelector('.dynamic-form');
    if (form) form.reset();
    return this;
  }
}

// Export form builder
window.FormBuilder = FormBuilder;

export { FormBuilder };
