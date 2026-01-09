// Image Gallery/Carousel Component
class ImageGallery {
  constructor(container, options = {}) {
    this.container = typeof container === 'string' ? document.querySelector(container) : container;
    this.images = options.images || [];
    this.currentIndex = 0;
    this.autoplay = options.autoplay || false;
    this.autoplayInterval = options.autoplayInterval || 5000;
    this.showThumbnails = options.showThumbnails !== false;
    this.showControls = options.showControls !== false;
    this.thumbnailPosition = options.thumbnailPosition || 'bottom';
    this.onImageChange = options.onImageChange || (() => {});
    this.intervalId = null;

    this.init();
  }

  init() {
    if (!this.container) return;
    this.render();
    this.setupEventListeners();
    if (this.autoplay) this.startAutoplay();
  }

  render() {
    let html = '<div class="gallery-wrapper">';

    // Main image
    html += `
      <div class="gallery-main">
        <img src="${this.images[this.currentIndex]?.src || ''}" 
             alt="${this.images[this.currentIndex]?.alt || ''}"
             class="gallery-image">
        ${this.showControls ? `
          <button class="gallery-prev" aria-label="Previous">?</button>
          <button class="gallery-next" aria-label="Next">?</button>
          <div class="gallery-counter">${this.currentIndex + 1} / ${this.images.length}</div>
        ` : ''}
      </div>
    `;

    // Thumbnails
    if (this.showThumbnails && this.images.length > 1) {
      html += `
        <div class="gallery-thumbnails gallery-thumbnails-${this.thumbnailPosition}">
          ${this.images.map((img, idx) => `
            <div class="thumbnail ${idx === this.currentIndex ? 'active' : ''}" data-index="${idx}">
              <img src="${img.thumbnail || img.src}" alt="${img.alt || ''}">
            </div>
          `).join('')}
        </div>
      `;
    }

    html += '</div>';

    this.container.innerHTML = html;

    // Inject CSS
    this.injectStyles();
  }

  setupEventListeners() {
    if (!this.container) return;

    const prevBtn = this.container.querySelector('.gallery-prev');
    const nextBtn = this.container.querySelector('.gallery-next');

    if (prevBtn) prevBtn.addEventListener('click', () => this.prev());
    if (nextBtn) nextBtn.addEventListener('click', () => this.next());

    // Thumbnail clicks
    this.container.querySelectorAll('.thumbnail').forEach(thumb => {
      thumb.addEventListener('click', (e) => {
        const idx = parseInt(e.currentTarget.dataset.index);
        this.goToSlide(idx);
      });
    });

    // Keyboard navigation
    document.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowLeft') this.prev();
      if (e.key === 'ArrowRight') this.next();
    });

    // Touch/swipe support
    let touchStartX = 0;
    const main = this.container.querySelector('.gallery-main');
    if (main) {
      main.addEventListener('touchstart', (e) => {
        touchStartX = e.touches[0].clientX;
      });

      main.addEventListener('touchend', (e) => {
        const touchEndX = e.changedTouches[0].clientX;
        if (touchStartX - touchEndX > 50) this.next();
        if (touchEndX - touchStartX > 50) this.prev();
      });
    }
  }

  next() {
    this.currentIndex = (this.currentIndex + 1) % this.images.length;
    this.update();
  }

  prev() {
    this.currentIndex = (this.currentIndex - 1 + this.images.length) % this.images.length;
    this.update();
  }

  goToSlide(index) {
    this.currentIndex = Math.max(0, Math.min(index, this.images.length - 1));
    this.update();
  }

  update() {
    this.render();
    this.setupEventListeners();
    this.onImageChange(this.currentIndex, this.images[this.currentIndex]);
  }

  addImage(image) {
    this.images.push(image);
    this.update();
  }

  removeImage(index) {
    this.images.splice(index, 1);
    if (this.currentIndex >= this.images.length) {
      this.currentIndex = Math.max(0, this.images.length - 1);
    }
    this.update();
  }

  setImages(images) {
    this.images = images;
    this.currentIndex = 0;
    this.update();
  }

  startAutoplay() {
    this.intervalId = setInterval(() => this.next(), this.autoplayInterval);
  }

  stopAutoplay() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }

  injectStyles() {
    if (document.getElementById('gallery-styles')) return;

    const styles = `
      .gallery-wrapper {
        position: relative;
        width: 100%;
        max-width: 100%;
      }

      .gallery-main {
        position: relative;
        width: 100%;
        overflow: hidden;
        border-radius: 8px;
        background: #000;
      }

      .gallery-image {
        width: 100%;
        height: auto;
        display: block;
        object-fit: cover;
        max-height: 600px;
      }

      .gallery-prev,
      .gallery-next {
        position: absolute;
        top: 50%;
        transform: translateY(-50%);
        background: rgba(0, 0, 0, 0.5);
        color: white;
        border: none;
        padding: 1rem;
        cursor: pointer;
        font-size: 1.5rem;
        z-index: 10;
        transition: background 0.3s;
      }

      .gallery-prev:hover,
      .gallery-next:hover {
        background: rgba(0, 0, 0, 0.8);
      }

      .gallery-prev {
        left: 0;
      }

      .gallery-next {
        right: 0;
      }

      .gallery-counter {
        position: absolute;
        bottom: 1rem;
        right: 1rem;
        background: rgba(0, 0, 0, 0.7);
        color: white;
        padding: 0.5rem 1rem;
        border-radius: 4px;
        font-size: 0.9rem;
      }

      .gallery-thumbnails {
        display: flex;
        gap: 0.5rem;
        padding: 1rem 0;
        overflow-x: auto;
      }

      .gallery-thumbnails-bottom {
        flex-direction: row;
      }

      .gallery-thumbnails-side {
        flex-direction: column;
        max-width: 100px;
        padding: 0 1rem;
      }

      .thumbnail {
        flex-shrink: 0;
        width: 80px;
        height: 80px;
        border: 2px solid transparent;
        border-radius: 4px;
        overflow: hidden;
        cursor: pointer;
        transition: all 0.3s;
      }

      .thumbnail:hover {
        opacity: 0.8;
      }

      .thumbnail.active {
        border-color: #007bff;
      }

      .thumbnail img {
        width: 100%;
        height: 100%;
        object-fit: cover;
      }
    `;

    const style = document.createElement('style');
    style.id = 'gallery-styles';
    style.textContent = styles;
    document.head.appendChild(style);
  }
}

// Lightbox Component
class Lightbox {
  constructor(options = {}) {
    this.images = options.images || [];
    this.currentIndex = 0;
    this.onClose = options.onClose || (() => {});
  }

  open(imageIndex = 0) {
    this.currentIndex = imageIndex;
    this.render();
  }

  render() {
    const existing = document.querySelector('.lightbox');
    if (existing) existing.remove();

    const lightbox = document.createElement('div');
    lightbox.className = 'lightbox active';

    lightbox.innerHTML = `
      <div class="lightbox-overlay"></div>
      <div class="lightbox-content">
        <button class="lightbox-close">&times;</button>
        <button class="lightbox-prev">?</button>
        <img src="${this.images[this.currentIndex]?.src || ''}" alt="" class="lightbox-image">
        <button class="lightbox-next">?</button>
        <div class="lightbox-counter">${this.currentIndex + 1} / ${this.images.length}</div>
      </div>
    `;

    document.body.appendChild(lightbox);

    // Event listeners
    lightbox.querySelector('.lightbox-close').addEventListener('click', () => this.close());
    lightbox.querySelector('.lightbox-overlay').addEventListener('click', () => this.close());
    lightbox.querySelector('.lightbox-prev').addEventListener('click', () => this.prev());
    lightbox.querySelector('.lightbox-next').addEventListener('click', () => this.next());

    // Keyboard
    const handleKey = (e) => {
      if (e.key === 'Escape') this.close();
      if (e.key === 'ArrowLeft') this.prev();
      if (e.key === 'ArrowRight') this.next();
    };
    document.addEventListener('keydown', handleKey);

    this.injectStyles();
  }

  next() {
    this.currentIndex = (this.currentIndex + 1) % this.images.length;
    this.render();
  }

  prev() {
    this.currentIndex = (this.currentIndex - 1 + this.images.length) % this.images.length;
    this.render();
  }

  close() {
    const lightbox = document.querySelector('.lightbox');
    if (lightbox) lightbox.remove();
    this.onClose();
  }

  injectStyles() {
    if (document.getElementById('lightbox-styles')) return;

    const styles = `
      .lightbox {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        z-index: 9999;
        display: flex;
        align-items: center;
        justify-content: center;
        opacity: 0;
        transition: opacity 0.3s;
      }

      .lightbox.active {
        opacity: 1;
      }

      .lightbox-overlay {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.9);
      }

      .lightbox-content {
        position: relative;
        z-index: 1;
        max-width: 90vw;
        max-height: 90vh;
      }

      .lightbox-image {
        max-width: 100%;
        max-height: 100%;
        display: block;
      }

      .lightbox-close,
      .lightbox-prev,
      .lightbox-next {
        position: absolute;
        background: rgba(0, 0, 0, 0.5);
        color: white;
        border: none;
        padding: 1rem;
        cursor: pointer;
        font-size: 1.5rem;
        transition: background 0.3s;
      }

      .lightbox-close:hover,
      .lightbox-prev:hover,
      .lightbox-next:hover {
        background: rgba(0, 0, 0, 0.8);
      }

      .lightbox-close {
        top: 1rem;
        right: 1rem;
        font-size: 2rem;
      }

      .lightbox-prev {
        left: 1rem;
        top: 50%;
        transform: translateY(-50%);
      }

      .lightbox-next {
        right: 1rem;
        top: 50%;
        transform: translateY(-50%);
      }

      .lightbox-counter {
        position: absolute;
        bottom: 1rem;
        left: 50%;
        transform: translateX(-50%);
        background: rgba(0, 0, 0, 0.7);
        color: white;
        padding: 0.5rem 1rem;
        border-radius: 4px;
      }
    `;

    const style = document.createElement('style');
    style.id = 'lightbox-styles';
    style.textContent = styles;
    document.head.appendChild(style);
  }
}

// Export gallery components
window.ImageGallery = ImageGallery;
window.Lightbox = Lightbox;

export { ImageGallery, Lightbox };
