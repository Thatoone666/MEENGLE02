// Advanced Search & Filter System
class SearchFilter {
  constructor(options = {}) {
    this.apiClient = window.apiClient;
    this.store = window.appStore;
    this.searchTerm = '';
    this.filters = options.filters || {};
    this.results = [];
    this.onResultsChange = options.onResultsChange || (() => {});
  }

  async search(term) {
    this.searchTerm = term;
    return this.execute();
  }

  setFilter(filterName, value) {
    this.filters[filterName] = value;
    return this;
  }

  setFilters(filters) {
    this.filters = { ...this.filters, ...filters };
    return this;
  }

  async execute() {
    try {
      this.store.setState({ loading: true });

      const params = new URLSearchParams({
        q: this.searchTerm,
        ...this.filters
      });

      const response = await this.apiClient.getDiscovery(Object.fromEntries(params));
      this.results = response.results || [];

      this.store.setState({ loading: false });
      this.onResultsChange(this.results);

      return this.results;
    } catch (error) {
      this.store.setState({ loading: false });
      throw error;
    }
  }

  clearFilters() {
    this.filters = {};
    return this;
  }

  getResults() {
    return this.results;
  }

  getFiltersState() {
    return {
      searchTerm: this.searchTerm,
      filters: { ...this.filters },
      resultCount: this.results.length
    };
  }
}

// Advanced Filter Builder UI
class FilterBuilder {
  constructor(options = {}) {
    this.container = options.container;
    this.searchFilter = options.searchFilter;
    this.filters = options.filterSchema || {};
    this.render();
  }

  render() {
    if (!this.container) return;

    let html = '<div class="filter-builder">';

    // Search box
    html += `
      <div class="search-box">
        <input 
          type="text" 
          class="search-input" 
          placeholder="Search..."
          data-action="search"
        >
        <button class="btn btn-primary" data-action="search-btn">Search</button>
        <button class="btn btn-secondary" data-action="clear-filters">Clear All</button>
      </div>
    `;

    // Filters
    html += '<div class="filters-container">';

    Object.entries(this.filters).forEach(([filterKey, filterConfig]) => {
      html += this.renderFilter(filterKey, filterConfig);
    });

    html += '</div>';
    html += '</div>';

    this.container.innerHTML = html;
    this.setupEventListeners();
    this.injectStyles();
  }

  renderFilter(filterKey, filterConfig) {
    const { type, label, options, min, max, placeholder } = filterConfig;

    let html = `<div class="filter-group filter-${type}">`;
    
    if (label) {
      html += `<label>${label}</label>`;
    }

    switch (type) {
      case 'text':
        html += `
          <input 
            type="text" 
            class="filter-input"
            data-filter="${filterKey}"
            placeholder="${placeholder || ''}"
          >
        `;
        break;

      case 'select':
        html += `
          <select class="filter-select" data-filter="${filterKey}">
            <option value="">-- Select --</option>
            ${options.map(opt => `
              <option value="${opt.value}">${opt.label}</option>
            `).join('')}
          </select>
        `;
        break;

      case 'checkbox':
        html += `
          <div class="filter-checkboxes">
            ${options.map(opt => `
              <label class="checkbox">
                <input 
                  type="checkbox" 
                  class="filter-checkbox"
                  data-filter="${filterKey}"
                  value="${opt.value}"
                >
                ${opt.label}
              </label>
            `).join('')}
          </div>
        `;
        break;

      case 'range':
        html += `
          <div class="filter-range">
            <input 
              type="range" 
              class="filter-range-input"
              data-filter="${filterKey}"
              min="${min || 0}"
              max="${max || 100}"
              value="${min || 0}"
            >
            <div class="range-display">
              <span class="range-value">${min || 0}</span>
              <span>-</span>
              <span class="range-value">${max || 100}</span>
            </div>
          </div>
        `;
        break;

      case 'date':
        html += `
          <input 
            type="date"
            class="filter-date"
            data-filter="${filterKey}"
          >
        `;
        break;

      case 'multiselect':
        html += `
          <select class="filter-multiselect" multiple data-filter="${filterKey}">
            ${options.map(opt => `
              <option value="${opt.value}">${opt.label}</option>
            `).join('')}
          </select>
        `;
        break;
    }

    html += '</div>';
    return html;
  }

  setupEventListeners() {
    if (!this.container) return;

    // Search
    const searchInput = this.container.querySelector('.search-input');
    const searchBtn = this.container.querySelector('[data-action="search-btn"]');

    if (searchBtn) {
      searchBtn.addEventListener('click', () => {
        if (this.searchFilter) {
          this.searchFilter.search(searchInput?.value || '').then(() => {
            this.updateResults();
          });
        }
      });
    }

    // Filter changes
    this.container.querySelectorAll('[data-filter]').forEach(el => {
      el.addEventListener('change', () => this.handleFilterChange());
    });

    // Clear filters
    const clearBtn = this.container.querySelector('[data-action="clear-filters"]');
    if (clearBtn) {
      clearBtn.addEventListener('click', () => {
        this.searchFilter?.clearFilters();
        this.render();
      });
    }

    // Enter key to search
    if (searchInput) {
      searchInput.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') searchBtn?.click();
      });
    }
  }

  handleFilterChange() {
    const filters = {};

    this.container.querySelectorAll('[data-filter]').forEach(el => {
      const filterKey = el.dataset.filter;
      const type = el.type;

      if (type === 'checkbox') {
        const checked = this.container.querySelectorAll(`[data-filter="${filterKey}"]:checked`);
        filters[filterKey] = Array.from(checked).map(c => c.value);
      } else if (type === 'range') {
        filters[filterKey] = el.value;
      } else {
        if (el.value) filters[filterKey] = el.value;
      }
    });

    if (this.searchFilter) {
      this.searchFilter.setFilters(filters).execute().then(() => {
        this.updateResults();
      });
    }
  }

  updateResults() {
    // Results would be displayed elsewhere
    const results = this.searchFilter?.getResults() || [];
    console.log(`Found ${results.length} results`);
  }

  injectStyles() {
    if (document.getElementById('filter-styles')) return;

    const styles = `
      .filter-builder {
        padding: 1.5rem;
        background: #f9f9f9;
        border-radius: 8px;
        margin-bottom: 2rem;
      }

      .search-box {
        display: flex;
        gap: 1rem;
        margin-bottom: 1.5rem;
      }

      .search-input {
        flex: 1;
        padding: 0.75rem;
        border: 1px solid #ddd;
        border-radius: 4px;
        font-size: 1rem;
      }

      .filters-container {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: 1.5rem;
      }

      .filter-group {
        display: flex;
        flex-direction: column;
        gap: 0.5rem;
      }

      .filter-group label {
        font-weight: 600;
        font-size: 0.9rem;
        color: #333;
      }

      .filter-input,
      .filter-select,
      .filter-date {
        padding: 0.75rem;
        border: 1px solid #ddd;
        border-radius: 4px;
        font-size: 0.95rem;
      }

      .filter-checkboxes {
        display: flex;
        flex-direction: column;
        gap: 0.5rem;
      }

      .checkbox {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        cursor: pointer;
      }

      .checkbox input {
        cursor: pointer;
      }

      .filter-range {
        display: flex;
        flex-direction: column;
        gap: 0.5rem;
      }

      .filter-range-input {
        width: 100%;
      }

      .range-display {
        display: flex;
        justify-content: space-between;
        font-size: 0.9rem;
        color: #666;
      }

      .filter-multiselect {
        padding: 0.5rem;
        border: 1px solid #ddd;
        border-radius: 4px;
      }

      @media (max-width: 768px) {
        .search-box {
          flex-direction: column;
        }

        .filters-container {
          grid-template-columns: 1fr;
        }
      }
    `;

    const style = document.createElement('style');
    style.id = 'filter-styles';
    style.textContent = styles;
    document.head.appendChild(style);
  }
}

// Results Display Component
class SearchResults {
  constructor(options = {}) {
    this.container = options.container;
    this.results = options.results || [];
    this.renderItem = options.renderItem || this.defaultRenderItem;
    this.emptyMessage = options.emptyMessage || 'No results found';
    this.layout = options.layout || 'grid'; // grid, list
  }

  render() {
    if (!this.container) return;

    if (this.results.length === 0) {
      this.container.innerHTML = `<div class="empty-results">${this.emptyMessage}</div>`;
      return;
    }

    let html = `<div class="search-results search-results-${this.layout}">`;

    this.results.forEach((item, idx) => {
      html += this.renderItem(item, idx);
    });

    html += '</div>';

    this.container.innerHTML = html;
    this.injectStyles();
  }

  defaultRenderItem(item) {
    return `
      <div class="result-item">
        <h3>${item.name || 'Item'}</h3>
        <p>${item.description || ''}</p>
      </div>
    `;
  }

  setResults(results) {
    this.results = results;
    this.render();
  }

  injectStyles() {
    if (document.getElementById('results-styles')) return;

    const styles = `
      .search-results {
        margin-top: 2rem;
      }

      .search-results-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
        gap: 1.5rem;
      }

      .search-results-list {
        display: flex;
        flex-direction: column;
        gap: 1rem;
      }

      .result-item {
        padding: 1rem;
        border: 1px solid #eee;
        border-radius: 8px;
        transition: all 0.3s;
      }

      .result-item:hover {
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
      }

      .empty-results {
        text-align: center;
        padding: 3rem 1rem;
        color: #999;
        font-size: 1.1rem;
      }
    `;

    const style = document.createElement('style');
    style.id = 'results-styles';
    style.textContent = styles;
    document.head.appendChild(style);
  }
}

// Export search components
window.SearchFilter = SearchFilter;
window.FilterBuilder = FilterBuilder;
window.SearchResults = SearchResults;

export { SearchFilter, FilterBuilder, SearchResults };
