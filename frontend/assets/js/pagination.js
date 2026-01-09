// Infinite Scroll and Pagination Components
class InfiniteScroll {
  constructor(options = {}) {
    this.container = options.container;
    this.loadMore = options.loadMore;
    this.threshold = options.threshold || 200; // pixels from bottom
    this.loading = false;
    this.hasMore = true;
    this.page = 1;

    this.init();
  }

  init() {
    window.addEventListener('scroll', () => this.handleScroll());
  }

  handleScroll() {
    if (this.loading || !this.hasMore) return;

    const scrollPosition = window.innerHeight + window.scrollY;
    const documentHeight = document.documentElement.scrollHeight;

    if (documentHeight - scrollPosition <= this.threshold) {
      this.fetchMore();
    }
  }

  async fetchMore() {
    this.loading = true;
    
    try {
      const result = await this.loadMore(this.page);
      
      if (result.items && result.items.length > 0) {
        this.page++;
        this.hasMore = result.hasMore !== false;
      } else {
        this.hasMore = false;
      }
    } catch (error) {
      console.error('Failed to load more items:', error);
    }

    this.loading = false;
  }

  reset() {
    this.page = 1;
    this.hasMore = true;
    this.loading = false;
  }
}

// Pagination Component
class Pagination {
  constructor(options = {}) {
    this.currentPage = options.currentPage || 1;
    this.totalPages = options.totalPages || 1;
    this.totalItems = options.totalItems || 0;
    this.itemsPerPage = options.itemsPerPage || 10;
    this.onPageChange = options.onPageChange || (() => {});
    this.container = options.container;
  }

  render() {
    if (!this.container) return;

    let html = '<div class="pagination">';

    // Previous button
    html += `
      <button class="pagination-btn prev" ${this.currentPage === 1 ? 'disabled' : ''}>
        Previous
      </button>
    `;

    // Page numbers
    const maxButtons = 7;
    let startPage = Math.max(1, this.currentPage - Math.floor(maxButtons / 2));
    let endPage = Math.min(this.totalPages, startPage + maxButtons - 1);

    if (endPage - startPage < maxButtons - 1) {
      startPage = Math.max(1, endPage - maxButtons + 1);
    }

    if (startPage > 1) {
      html += '<button class="pagination-btn page" data-page="1">1</button>';
      if (startPage > 2) {
        html += '<span class="pagination-dots">...</span>';
      }
    }

    for (let i = startPage; i <= endPage; i++) {
      html += `
        <button class="pagination-btn page ${i === this.currentPage ? 'active' : ''}" data-page="${i}">
          ${i}
        </button>
      `;
    }

    if (endPage < this.totalPages) {
      if (endPage < this.totalPages - 1) {
        html += '<span class="pagination-dots">...</span>';
      }
      html += `
        <button class="pagination-btn page" data-page="${this.totalPages}">
          ${this.totalPages}
        </button>
      `;
    }

    // Next button
    html += `
      <button class="pagination-btn next" ${this.currentPage === this.totalPages ? 'disabled' : ''}>
        Next
      </button>
    `;

    html += `
      <div class="pagination-info">
        Page ${this.currentPage} of ${this.totalPages} (${this.totalItems} total)
      </div>
    </div>
    `;

    this.container.innerHTML = html;
    this.setupEventListeners();
    this.injectStyles();
  }

  setupEventListeners() {
    if (!this.container) return;

    this.container.querySelector('.prev').addEventListener('click', () => {
      if (this.currentPage > 1) this.goToPage(this.currentPage - 1);
    });

    this.container.querySelector('.next').addEventListener('click', () => {
      if (this.currentPage < this.totalPages) this.goToPage(this.currentPage + 1);
    });

    this.container.querySelectorAll('.page').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const page = parseInt(e.target.dataset.page);
        this.goToPage(page);
      });
    });
  }

  goToPage(page) {
    if (page < 1 || page > this.totalPages) return;

    this.currentPage = page;
    this.onPageChange(page);
    this.render();
  }

  setTotal(total) {
    this.totalItems = total;
    this.totalPages = Math.ceil(total / this.itemsPerPage);
    this.currentPage = 1;
    this.render();
  }

  injectStyles() {
    if (document.getElementById('pagination-styles')) return;

    const styles = `
      .pagination {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 0.5rem;
        margin: 2rem 0;
        flex-wrap: wrap;
      }

      .pagination-btn,
      .pagination-dots {
        padding: 0.5rem 0.75rem;
        border: 1px solid #ddd;
        background: white;
        border-radius: 4px;
        cursor: pointer;
        transition: all 0.3s;
      }

      .pagination-btn:hover:not(:disabled) {
        background: #f5f5f5;
        border-color: #999;
      }

      .pagination-btn.active {
        background: #007bff;
        color: white;
        border-color: #007bff;
      }

      .pagination-btn:disabled {
        opacity: 0.5;
        cursor: not-allowed;
      }

      .pagination-dots {
        border: none;
        cursor: default;
        padding: 0.5rem 0.25rem;
      }

      .pagination-info {
        margin-left: 1rem;
        font-size: 0.9rem;
        color: #666;
      }

      @media (max-width: 768px) {
        .pagination {
          gap: 0.25rem;
        }

        .pagination-btn {
          padding: 0.4rem 0.5rem;
          font-size: 0.9rem;
        }

        .pagination-info {
          width: 100%;
          text-align: center;
          margin-left: 0;
          margin-top: 0.5rem;
        }
      }
    `;

    const style = document.createElement('style');
    style.id = 'pagination-styles';
    style.textContent = styles;
    document.head.appendChild(style);
  }
}

// Lazy Loading Component
class LazyLoader {
  constructor(options = {}) {
    this.images = document.querySelectorAll('[data-lazy]');
    this.placeholder = options.placeholder || 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 300"%3E%3Crect fill="%23f0f0f0" width="400" height="300"/%3E%3C/svg%3E';
    this.fadeInClass = options.fadeInClass || 'loaded';

    this.init();
  }

  init() {
    if ('IntersectionObserver' in window) {
      this.initIntersectionObserver();
    } else {
      this.loadAllImages();
    }
  }

  initIntersectionObserver() {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.loadImage(entry.target);
          observer.unobserve(entry.target);
        }
      });
    }, { rootMargin: '50px' });

    this.images.forEach(img => observer.observe(img));
  }

  loadImage(img) {
    const src = img.dataset.lazy;
    
    img.onload = () => {
      img.classList.add(this.fadeInClass);
    };

    img.onerror = () => {
      console.error(`Failed to load image: ${src}`);
    };

    img.src = src;
  }

  loadAllImages() {
    this.images.forEach(img => this.loadImage(img));
  }
}

// Virtual Scrolling Component (for very large lists)
class VirtualScroller {
  constructor(options = {}) {
    this.container = options.container;
    this.items = options.items || [];
    this.itemHeight = options.itemHeight || 50;
    this.renderItem = options.renderItem;
    this.bufferSize = options.bufferSize || 5;

    this.init();
  }

  init() {
    this.container.addEventListener('scroll', () => this.handleScroll());
    this.render();
  }

  handleScroll() {
    this.render();
  }

  render() {
    const scrollTop = this.container.scrollTop;
    const containerHeight = this.container.clientHeight;

    const startIndex = Math.max(0, Math.floor(scrollTop / this.itemHeight) - this.bufferSize);
    const endIndex = Math.min(
      this.items.length,
      Math.ceil((scrollTop + containerHeight) / this.itemHeight) + this.bufferSize
    );

    // Set container height
    this.container.style.height = `${this.items.length * this.itemHeight}px`;

    // Render only visible items
    let html = '';
    for (let i = startIndex; i < endIndex; i++) {
      const offset = i * this.itemHeight;
      const item = this.items[i];

      html += `
        <div style="position: absolute; top: ${offset}px; height: ${this.itemHeight}px; width: 100%;">
          ${this.renderItem(item, i)}
        </div>
      `;
    }

    this.container.innerHTML = html;
  }

  setItems(items) {
    this.items = items;
    this.render();
  }
}

// Export components
window.InfiniteScroll = InfiniteScroll;
window.Pagination = Pagination;
window.LazyLoader = LazyLoader;
window.VirtualScroller = VirtualScroller;

export { InfiniteScroll, Pagination, LazyLoader, VirtualScroller };
