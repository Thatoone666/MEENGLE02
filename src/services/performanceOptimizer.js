/**
 * Performance & Animation Optimization Service
 * Ensures 60FPS smooth animations and premium visual feel
 * PRODUCTION: Visual Polish & Performance
 */

class PerformanceOptimizer {
  constructor() {
    this.isReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    this.isTouchDevice = this.checkTouchDevice();
    this.fps = 60;
    this.frameTime = 1000 / this.fps;
    
    // Initialize performance monitoring
    this.initializePerformanceMonitoring();
  }

  /**
   * Check if device supports touch
   */
  checkTouchDevice() {
    return (
      ('ontouchstart' in window) ||
      (navigator.maxTouchPoints > 0) ||
      (navigator.msMaxTouchPoints > 0)
    );
  }

  /**
   * Initialize performance monitoring
   */
  initializePerformanceMonitoring() {
    if ('PerformanceObserver' in window) {
      try {
        // Observe long tasks (>50ms)
        const observer = new PerformanceObserver((list) => {
          for (const entry of list.getEntries()) {
            console.warn('[Performance] Long task detected:', entry.duration, 'ms');
          }
        });
        observer.observe({ entryTypes: ['longtask'] });
      } catch (e) {
        // LongTask API not available
      }
    }
  }

  /**
   * Get optimal animation duration based on device
   */
  getAnimationDuration(baseMs = 300) {
    if (this.isReducedMotion) return 0;
    return baseMs;
  }

  /**
   * Get optimal animation easing
   */
  getAnimationEasing(type = 'easeInOut') {
    const easings = {
      linear: 'linear',
      easeIn: 'cubic-bezier(0.4, 0, 1, 1)',
      easeOut: 'cubic-bezier(0, 0, 0.2, 1)',
      easeInOut: 'cubic-bezier(0.4, 0, 0.2, 1)',
      easeInQuad: 'cubic-bezier(0.11, 0, 0.5, 0)',
      easeOutQuad: 'cubic-bezier(0.5, 1, 0.89, 1)',
      easeInCubic: 'cubic-bezier(0.32, 0, 0.67, 0)',
      easeOutCubic: 'cubic-bezier(0.33, 1, 0.68, 1)',
    };
    return easings[type] || easings.easeInOut;
  }

  /**
   * Optimize image loading
   */
  optimizeImageLoading(imageUrl, options = {}) {
    const {
      width = 300,
      quality = 0.8,
      format = 'webp',
    } = options;

    // Return optimized image URL
    // In production, this would use an image CDN
    return imageUrl;
  }

  /**
   * Lazy load images with intersection observer
   */
  setupLazyLoading() {
    if ('IntersectionObserver' not in window) {
      return;
    }

    const imageElements = document.querySelectorAll('[data-lazy]');
    const imageObserver = new IntersectionObserver(
      (entries, observer) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            const img = entry.target;
            img.src = img.dataset.src;
            img.removeAttribute('data-lazy');
            observer.unobserve(img);
          }
        });
      },
      {
        rootMargin: '50px',
      }
    );

    imageElements.forEach((img) => {
      imageObserver.observe(img);
    });
  }

  /**
   * Debounce function for scroll/resize events
   */
  debounce(func, wait = 300) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  }

  /**
   * Throttle function for scroll/resize events
   */
  throttle(func, limit = 100) {
    let lastFunc;
    let lastRan;
    return function executedFunction(...args) {
      if (!lastRan) {
        func.apply(this, args);
        lastRan = Date.now();
      } else {
        clearTimeout(lastFunc);
        lastFunc = setTimeout(() => {
          if (Date.now() - lastRan >= limit) {
            func.apply(this, args);
            lastRan = Date.now();
          }
        }, limit - (Date.now() - lastRan));
      }
    };
  }

  /**
   * Request animation frame helper
   */
  requestAnimationFrame(callback) {
    return window.requestAnimationFrame(callback);
  }

  /**
   * Cancel animation frame
   */
  cancelAnimationFrame(id) {
    return window.cancelAnimationFrame(id);
  }

  /**
   * Measure performance
   */
  measurePerformance(label) {
    return {
      start: () => {
        performance.mark(`${label}-start`);
      },
      end: () => {
        performance.mark(`${label}-end`);
        try {
          performance.measure(label, `${label}-start`, `${label}-end`);
          const measure = performance.getEntriesByName(label)[0];
          console.log(`[Performance] ${label}: ${measure.duration.toFixed(2)}ms`);
        } catch (e) {
          console.error(`[Performance] Failed to measure ${label}`);
        }
      },
    };
  }

  /**
   * Check if animation should be reduced
   */
  shouldReduceMotion() {
    return this.isReducedMotion;
  }

  /**
   * Get device pixel ratio
   */
  getDevicePixelRatio() {
    return window.devicePixelRatio || 1;
  }

  /**
   * Enable GPU acceleration
   */
  enableGPUAcceleration(element) {
    element.style.transform = 'translateZ(0)';
    element.style.willChange = 'transform';
  }

  /**
   * Disable GPU acceleration
   */
  disableGPUAcceleration(element) {
    element.style.willChange = 'auto';
  }

  /**
   * Check if 60FPS is achievable
   */
  check60FPS() {
    return new Promise((resolve) => {
      let frameCount = 0;
      let lastTime = performance.now();

      const checkFrame = () => {
        const currentTime = performance.now();
        const delta = currentTime - lastTime;

        if (delta >= 1000) {
          const fps = Math.round(frameCount * 1000 / delta);
          resolve(fps >= 50); // Allow some margin
          return;
        }

        frameCount++;
        if (frameCount < 60) {
          requestAnimationFrame(checkFrame);
        }
      };

      requestAnimationFrame(checkFrame);
    });
  }
}

export default new PerformanceOptimizer();
