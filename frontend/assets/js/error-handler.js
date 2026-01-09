// Error Boundary - Global error handling
class ErrorBoundary {
  static init() {
    // Catch uncaught errors
    window.addEventListener('error', (event) => {
      this.handleError(event.error, 'Uncaught Error');
    });

    // Catch unhandled promise rejections
    window.addEventListener('unhandledrejection', (event) => {
      this.handleError(event.reason, 'Unhandled Promise Rejection');
    });
  }

  static handleError(error, source = 'Error') {
    console.error(`${source}:`, error);

    // Log to error tracking service
    if (window.Sentry) {
      window.Sentry.captureException(error, {
        tags: { source }
      });
    }

    // Show user-friendly error
    this.showErrorUI(error);
  }

  static showErrorUI(error) {
    const message = error?.message || 'Something went wrong. Please try again.';
    
    // Avoid showing too many error messages
    const existingError = document.querySelector('.error-boundary');
    if (existingError) return;

    const errorElement = document.createElement('div');
    errorElement.className = 'error-boundary';
    errorElement.innerHTML = `
      <div class="error-content">
        <h3>?? Something went wrong</h3>
        <p>${message}</p>
        <button class="btn btn-primary" onclick="this.parentElement.parentElement.remove()">
          Dismiss
        </button>
      </div>
    `;

    document.body.appendChild(errorElement);

    // Auto-remove after 10 seconds
    setTimeout(() => {
      errorElement.remove();
    }, 10000);
  }
}

// Error handling for API calls
class APIErrorHandler {
  static handle(error) {
    if (error.response?.status === 401) {
      // Unauthorized - redirect to login
      localStorage.removeItem('authToken');
      window.location.href = '/pages/login.html';
      return 'Please log in again';
    }

    if (error.response?.status === 403) {
      return 'You do not have permission to do this';
    }

    if (error.response?.status === 404) {
      return 'Resource not found';
    }

    if (error.response?.status === 429) {
      return 'Too many requests. Please wait a moment.';
    }

    if (error.response?.status === 500) {
      return 'Server error. Please try again later.';
    }

    if (error.response?.data?.error) {
      return error.response.data.error;
    }

    if (error.message === 'Network Error') {
      return 'Network connection error. Check your internet.';
    }

    return error.message || 'An error occurred. Please try again.';
  }
}

// Validation error handler
class ValidationErrorHandler {
  static formatErrors(errors) {
    if (typeof errors === 'string') {
      return errors;
    }

    if (Array.isArray(errors)) {
      return errors.join(', ');
    }

    if (typeof errors === 'object') {
      return Object.values(errors)
        .flat()
        .join(', ');
    }

    return 'Validation failed';
  }

  static displayErrors(errors, formElement) {
    if (!formElement) return;

    // Clear previous errors
    formElement.querySelectorAll('.error-message').forEach(el => {
      el.remove();
    });

    Object.entries(errors).forEach(([field, message]) => {
      const input = formElement.querySelector(`[name="${field}"]`);
      if (!input) return;

      input.classList.add('error');

      const errorMsg = document.createElement('span');
      errorMsg.className = 'error-message';
      errorMsg.textContent = Array.isArray(message) ? message[0] : message;

      input.parentElement.appendChild(errorMsg);
    });
  }
}

// Global error handler setup
ErrorBoundary.init();

// CSS for error UI
const errorStyles = `
.error-boundary {
  position: fixed;
  top: 20px;
  right: 20px;
  background: #fff;
  border: 1px solid #f44336;
  border-radius: 4px;
  padding: 1rem;
  box-shadow: 0 2px 8px rgba(244, 67, 54, 0.2);
  z-index: 9999;
  max-width: 400px;
  animation: slideIn 0.3s ease-out;
}

.error-content {
  color: #f44336;
}

.error-content h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1rem;
}

.error-content p {
  margin: 0 0 1rem 0;
  font-size: 0.9rem;
}

.error-content button {
  width: 100%;
}

.error-message {
  display: block;
  color: #f44336;
  font-size: 0.85rem;
  margin-top: 0.25rem;
}

input.error,
textarea.error,
select.error {
  border-color: #f44336 !important;
  background-color: #ffebee !important;
}

@keyframes slideIn {
  from {
    transform: translateX(400px);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}
`;

if (!document.getElementById('error-styles')) {
  const style = document.createElement('style');
  style.id = 'error-styles';
  style.textContent = errorStyles;
  document.head.appendChild(style);
}

// Export error handlers
window.ErrorBoundary = ErrorBoundary;
window.APIErrorHandler = APIErrorHandler;
window.ValidationErrorHandler = ValidationErrorHandler;

export { ErrorBoundary, APIErrorHandler, ValidationErrorHandler };
