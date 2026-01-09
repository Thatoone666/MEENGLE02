// Modal Component - Reusable dialog system
class Modal {
  constructor(options = {}) {
    this.title = options.title || '';
    this.content = options.content || '';
    this.buttons = options.buttons || [];
    this.className = options.className || '';
    this.onClose = options.onClose || (() => {});
    this.element = null;
  }

  open() {
    this.createModal();
    document.body.appendChild(this.element);
    document.body.style.overflow = 'hidden';
    
    // Trigger animation
    setTimeout(() => {
      this.element.classList.add('active');
    }, 10);
  }

  close() {
    this.element.classList.remove('active');
    setTimeout(() => {
      this.element.remove();
      document.body.style.overflow = '';
      this.onClose();
    }, 300);
  }

  createModal() {
    const modal = document.createElement('div');
    modal.className = `modal ${this.className}`;
    
    const overlay = document.createElement('div');
    overlay.className = 'modal-overlay';
    overlay.addEventListener('click', () => this.close());

    const dialog = document.createElement('div');
    dialog.className = 'modal-dialog';

    let html = '';

    if (this.title) {
      html += `
        <div class="modal-header">
          <h2>${this.title}</h2>
          <button class="modal-close" aria-label="Close">&times;</button>
        </div>
      `;
    }

    html += `<div class="modal-body">${this.content}</div>`;

    if (this.buttons.length > 0) {
      html += '<div class="modal-footer">';
      this.buttons.forEach(btn => {
        html += `
          <button class="btn btn-${btn.type || 'secondary'}" data-action="${btn.action}">
            ${btn.label}
          </button>
        `;
      });
      html += '</div>';
    }

    dialog.innerHTML = html;

    // Close button
    const closeBtn = dialog.querySelector('.modal-close');
    if (closeBtn) {
      closeBtn.addEventListener('click', () => this.close());
    }

    // Action buttons
    dialog.querySelectorAll('[data-action]').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const action = btn.dataset.action;
        const buttonConfig = this.buttons.find(b => b.action === action);
        
        if (buttonConfig?.onClick) {
          buttonConfig.onClick();
        }
        
        if (buttonConfig?.closeOnClick !== false) {
          this.close();
        }
      });
    });

    modal.appendChild(overlay);
    modal.appendChild(dialog);
    this.element = modal;
  }

  static confirm(options = {}) {
    const modal = new Modal({
      title: options.title || 'Confirm',
      content: options.message || 'Are you sure?',
      buttons: [
        {
          label: 'Cancel',
          type: 'secondary',
          action: 'cancel'
        },
        {
          label: 'Confirm',
          type: 'primary',
          action: 'confirm',
          onClick: options.onConfirm || (() => {})
        }
      ]
    });
    
    modal.open();
    return modal;
  }

  static alert(options = {}) {
    const modal = new Modal({
      title: options.title || 'Alert',
      content: options.message || '',
      buttons: [
        {
          label: 'OK',
          type: 'primary',
          action: 'ok'
        }
      ]
    });
    
    modal.open();
    return modal;
  }

  static prompt(options = {}) {
    const inputId = `modal-input-${Date.now()}`;
    const modal = new Modal({
      title: options.title || 'Enter value',
      content: `<input type="text" id="${inputId}" class="form-control" placeholder="${options.placeholder || ''}">`,
      buttons: [
        {
          label: 'Cancel',
          type: 'secondary',
          action: 'cancel'
        },
        {
          label: 'OK',
          type: 'primary',
          action: 'ok',
          onClick: () => {
            const input = document.getElementById(inputId);
            if (input && options.onSubmit) {
              options.onSubmit(input.value);
            }
          }
        }
      ]
    });
    
    modal.open();
    
    // Focus input
    setTimeout(() => {
      const input = document.getElementById(inputId);
      if (input) input.focus();
    }, 100);
    
    return modal;
  }

  static payment(options = {}) {
    const modal = new Modal({
      title: options.title || 'Payment',
      className: 'modal-payment',
      content: `
        <div class="payment-form">
          <div class="amount-display">
            <span class="currency">$</span>
            <span class="amount">${(options.amount / 100).toFixed(2)}</span>
          </div>
          
          <div class="form-group">
            <label>Card Number</label>
            <input type="text" class="form-control" id="card-number" placeholder="1234 5678 9012 3456">
          </div>
          
          <div class="form-row">
            <div class="form-group">
              <label>Expiry</label>
              <input type="text" class="form-control" id="card-expiry" placeholder="MM/YY">
            </div>
            <div class="form-group">
              <label>CVC</label>
              <input type="text" class="form-control" id="card-cvc" placeholder="123">
            </div>
          </div>
          
          <div class="form-group">
            <label>
              <input type="checkbox" id="save-card"> Save this card
            </label>
          </div>
        </div>
      `,
      buttons: [
        {
          label: 'Cancel',
          type: 'secondary',
          action: 'cancel'
        },
        {
          label: 'Pay Now',
          type: 'primary',
          action: 'pay',
          onClick: options.onSubmit || (() => {})
        }
      ]
    });
    
    modal.open();
    return modal;
  }
}

// Global toast notification
class Toast {
  static show(message, duration = 3000, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.textContent = message;
    toast.style.animation = 'slideIn 0.3s ease-out';
    
    document.body.appendChild(toast);
    
    setTimeout(() => {
      toast.style.animation = 'slideOut 0.3s ease-out';
      setTimeout(() => toast.remove(), 300);
    }, duration);
  }

  static success(message) {
    this.show(message, 3000, 'success');
  }

  static error(message) {
    this.show(message, 4000, 'error');
  }

  static warning(message) {
    this.show(message, 3500, 'warning');
  }

  static info(message) {
    this.show(message, 3000, 'info');
  }
}

// Export components
window.Modal = Modal;
window.Toast = Toast;

export { Modal, Toast };
