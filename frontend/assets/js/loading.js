// Loading and Skeleton Components
class LoadingState {
  static createSpinner(size = 'medium') {
    const spinner = document.createElement('div');
    spinner.className = `spinner spinner-${size}`;
    spinner.innerHTML = `
      <div class="spinner-circle"></div>
      <p>Loading...</p>
    `;
    return spinner;
  }

  static createSkeleton(type = 'card') {
    const skeleton = document.createElement('div');
    skeleton.className = `skeleton skeleton-${type}`;
    
    switch (type) {
      case 'card':
        skeleton.innerHTML = `
          <div class="skeleton-image"></div>
          <div class="skeleton-text skeleton-title"></div>
          <div class="skeleton-text"></div>
          <div class="skeleton-text" style="width: 60%"></div>
        `;
        break;
      
      case 'line':
        skeleton.innerHTML = `<div class="skeleton-text"></div>`;
        break;
      
      case 'avatar':
        skeleton.innerHTML = `<div class="skeleton-avatar"></div>`;
        break;
      
      case 'list':
        skeleton.innerHTML = `
          ${Array(5).fill().map(() => `
            <div class="skeleton-item">
              <div class="skeleton-avatar"></div>
              <div class="skeleton-text"></div>
            </div>
          `).join('')}
        `;
        break;
    }
    
    return skeleton;
  }

  static replaceWithSkeleton(element, skeletonType = 'card', count = 1) {
    if (!element) return;
    
    const container = document.createElement('div');
    for (let i = 0; i < count; i++) {
      container.appendChild(this.createSkeleton(skeletonType));
    }
    
    element.innerHTML = container.innerHTML;
  }

  static replaceWithSpinner(element, size = 'medium') {
    if (!element) return;
    element.innerHTML = '';
    element.appendChild(this.createSpinner(size));
  }
}

// Progress Bar Component
class ProgressBar {
  constructor(options = {}) {
    this.container = options.container;
    this.value = options.value || 0;
    this.max = options.max || 100;
    this.label = options.label || '';
    this.color = options.color || '#4CAF50';
    this.element = null;
    this.create();
  }

  create() {
    this.element = document.createElement('div');
    this.element.className = 'progress-bar-container';
    
    this.element.innerHTML = `
      <div class="progress-bar-wrapper">
        <div class="progress-bar-fill" style="width: 0%; background-color: ${this.color}"></div>
      </div>
      <div class="progress-bar-label">${this.label} <span class="progress-value">0%</span></div>
    `;
    
    if (this.container) {
      this.container.appendChild(this.element);
    }
  }

  setValue(value) {
    this.value = Math.min(Math.max(value, 0), this.max);
    const percentage = (this.value / this.max) * 100;
    
    const fill = this.element?.querySelector('.progress-bar-fill');
    const valueText = this.element?.querySelector('.progress-value');
    
    if (fill) {
      fill.style.width = percentage + '%';
    }
    if (valueText) {
      valueText.textContent = Math.round(percentage) + '%';
    }
  }

  increment(amount = 1) {
    this.setValue(this.value + amount);
  }

  remove() {
    if (this.element) {
      this.element.remove();
    }
  }
}

// Shimmer/Pulse Effect for skeletons (via CSS)
class ShimmerEffect {
  static enable() {
    if (!document.getElementById('shimmer-style')) {
      const style = document.createElement('style');
      style.id = 'shimmer-style';
      style.textContent = `
        @keyframes shimmer {
          0% {
            background-position: -1000px 0;
          }
          100% {
            background-position: 1000px 0;
          }
        }
        
        .skeleton {
          background: linear-gradient(
            90deg,
            #f0f0f0 25%,
            #e0e0e0 50%,
            #f0f0f0 75%
          );
          background-size: 1000px 100%;
          animation: shimmer 2s infinite;
        }
      `;
      document.head.appendChild(style);
    }
  }
}

// Initialize shimmer effect
ShimmerEffect.enable();

// CSS Styles for loading states
const loadingStyles = `
.spinner {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 2rem;
}

.spinner-small .spinner-circle {
  width: 30px;
  height: 30px;
  border: 3px solid #f3f3f3;
  border-top: 3px solid #4CAF50;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

.spinner-medium .spinner-circle {
  width: 50px;
  height: 50px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #4CAF50;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

.spinner-large .spinner-circle {
  width: 70px;
  height: 70px;
  border: 5px solid #f3f3f3;
  border-top: 5px solid #4CAF50;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.skeleton {
  background-color: #f0f0f0;
  border-radius: 4px;
  margin-bottom: 1rem;
}

.skeleton-card {
  padding: 1rem;
}

.skeleton-image {
  width: 100%;
  height: 200px;
  border-radius: 4px;
  margin-bottom: 1rem;
}

.skeleton-avatar {
  width: 50px;
  height: 50px;
  border-radius: 50%;
}

.skeleton-title {
  height: 24px;
  width: 80%;
  margin-bottom: 0.5rem;
}

.skeleton-text {
  height: 16px;
  margin-bottom: 0.5rem;
}

.skeleton-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  border-bottom: 1px solid #eee;
}

.progress-bar-container {
  margin: 1rem 0;
}

.progress-bar-wrapper {
  width: 100%;
  height: 8px;
  background-color: #eee;
  border-radius: 4px;
  overflow: hidden;
}

.progress-bar-fill {
  height: 100%;
  transition: width 0.3s ease;
}

.progress-bar-label {
  margin-top: 0.5rem;
  font-size: 14px;
  color: #666;
  display: flex;
  justify-content: space-between;
}

.progress-value {
  font-weight: bold;
}
`;

// Inject styles
if (!document.getElementById('loading-styles')) {
  const style = document.createElement('style');
  style.id = 'loading-styles';
  style.textContent = loadingStyles;
  document.head.appendChild(style);
}

// Export components
window.LoadingState = LoadingState;
window.ProgressBar = ProgressBar;
window.ShimmerEffect = ShimmerEffect;

export { LoadingState, ProgressBar, ShimmerEffect };
