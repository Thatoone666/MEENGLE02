(()=>{var c=class{constructor(e={}){this.apiClient=window.apiClient,this.store=window.appStore,this.searchTerm="",this.filters=e.filters||{},this.results=[],this.onResultsChange=e.onResultsChange||(()=>{})}async search(e){return this.searchTerm=e,this.execute()}setFilter(e,t){return this.filters[e]=t,this}setFilters(e){return this.filters={...this.filters,...e},this}async execute(){try{this.store.setState({loading:!0});let e=new URLSearchParams({q:this.searchTerm,...this.filters}),t=await this.apiClient.getDiscovery(Object.fromEntries(e));return this.results=t.results||[],this.store.setState({loading:!1}),this.onResultsChange(this.results),this.results}catch(e){throw this.store.setState({loading:!1}),e}}clearFilters(){return this.filters={},this}getResults(){return this.results}getFiltersState(){return{searchTerm:this.searchTerm,filters:{...this.filters},resultCount:this.results.length}}},o=class{constructor(e={}){this.container=e.container,this.searchFilter=e.searchFilter,this.filters=e.filterSchema||{},this.render()}render(){if(!this.container)return;let e='<div class="filter-builder">';e+=`
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
    `,e+='<div class="filters-container">',Object.entries(this.filters).forEach(([t,s])=>{e+=this.renderFilter(t,s)}),e+="</div>",e+="</div>",this.container.innerHTML=e,this.setupEventListeners(),this.injectStyles()}renderFilter(e,t){let{type:s,label:r,options:a,min:n,max:u,placeholder:p}=t,i=`<div class="filter-group filter-${s}">`;switch(r&&(i+=`<label>${r}</label>`),s){case"text":i+=`
          <input 
            type="text" 
            class="filter-input"
            data-filter="${e}"
            placeholder="${p||""}"
          >
        `;break;case"select":i+=`
          <select class="filter-select" data-filter="${e}">
            <option value="">-- Select --</option>
            ${a.map(l=>`
              <option value="${l.value}">${l.label}</option>
            `).join("")}
          </select>
        `;break;case"checkbox":i+=`
          <div class="filter-checkboxes">
            ${a.map(l=>`
              <label class="checkbox">
                <input 
                  type="checkbox" 
                  class="filter-checkbox"
                  data-filter="${e}"
                  value="${l.value}"
                >
                ${l.label}
              </label>
            `).join("")}
          </div>
        `;break;case"range":i+=`
          <div class="filter-range">
            <input 
              type="range" 
              class="filter-range-input"
              data-filter="${e}"
              min="${n||0}"
              max="${u||100}"
              value="${n||0}"
            >
            <div class="range-display">
              <span class="range-value">${n||0}</span>
              <span>-</span>
              <span class="range-value">${u||100}</span>
            </div>
          </div>
        `;break;case"date":i+=`
          <input 
            type="date"
            class="filter-date"
            data-filter="${e}"
          >
        `;break;case"multiselect":i+=`
          <select class="filter-multiselect" multiple data-filter="${e}">
            ${a.map(l=>`
              <option value="${l.value}">${l.label}</option>
            `).join("")}
          </select>
        `;break}return i+="</div>",i}setupEventListeners(){if(!this.container)return;let e=this.container.querySelector(".search-input"),t=this.container.querySelector('[data-action="search-btn"]');t&&t.addEventListener("click",()=>{this.searchFilter&&this.searchFilter.search(e?.value||"").then(()=>{this.updateResults()})}),this.container.querySelectorAll("[data-filter]").forEach(r=>{r.addEventListener("change",()=>this.handleFilterChange())});let s=this.container.querySelector('[data-action="clear-filters"]');s&&s.addEventListener("click",()=>{this.searchFilter?.clearFilters(),this.render()}),e&&e.addEventListener("keydown",r=>{r.key==="Enter"&&t?.click()})}handleFilterChange(){let e={};this.container.querySelectorAll("[data-filter]").forEach(t=>{let s=t.dataset.filter,r=t.type;if(r==="checkbox"){let a=this.container.querySelectorAll(`[data-filter="${s}"]:checked`);e[s]=Array.from(a).map(n=>n.value)}else(r==="range"||t.value)&&(e[s]=t.value)}),this.searchFilter&&this.searchFilter.setFilters(e).execute().then(()=>{this.updateResults()})}updateResults(){let e=this.searchFilter?.getResults()||[];console.log(`Found ${e.length} results`)}injectStyles(){if(document.getElementById("filter-styles"))return;let e=`
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
    `,t=document.createElement("style");t.id="filter-styles",t.textContent=e,document.head.appendChild(t)}},d=class{constructor(e={}){this.container=e.container,this.results=e.results||[],this.renderItem=e.renderItem||this.defaultRenderItem,this.emptyMessage=e.emptyMessage||"No results found",this.layout=e.layout||"grid"}render(){if(!this.container)return;if(this.results.length===0){this.container.innerHTML=`<div class="empty-results">${this.emptyMessage}</div>`;return}let e=`<div class="search-results search-results-${this.layout}">`;this.results.forEach((t,s)=>{e+=this.renderItem(t,s)}),e+="</div>",this.container.innerHTML=e,this.injectStyles()}defaultRenderItem(e){return`
      <div class="result-item">
        <h3>${e.name||"Item"}</h3>
        <p>${e.description||""}</p>
      </div>
    `}setResults(e){this.results=e,this.render()}injectStyles(){if(document.getElementById("results-styles"))return;let e=`
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
    `,t=document.createElement("style");t.id="results-styles",t.textContent=e,document.head.appendChild(t)}};window.SearchFilter=c;window.FilterBuilder=o;window.SearchResults=d;})();
//# sourceMappingURL=search.js.map
