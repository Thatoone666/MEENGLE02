(()=>{var o=class{constructor(t={}){this.container=t.container,this.loadMore=t.loadMore,this.threshold=t.threshold||200,this.loading=!1,this.hasMore=!0,this.page=1,this.init()}init(){window.addEventListener("scroll",()=>this.handleScroll())}handleScroll(){if(this.loading||!this.hasMore)return;let t=window.innerHeight+window.scrollY;document.documentElement.scrollHeight-t<=this.threshold&&this.fetchMore()}async fetchMore(){this.loading=!0;try{let t=await this.loadMore(this.page);t.items&&t.items.length>0?(this.page++,this.hasMore=t.hasMore!==!1):this.hasMore=!1}catch(t){console.error("Failed to load more items:",t)}this.loading=!1}reset(){this.page=1,this.hasMore=!0,this.loading=!1}},h=class{constructor(t={}){this.currentPage=t.currentPage||1,this.totalPages=t.totalPages||1,this.totalItems=t.totalItems||0,this.itemsPerPage=t.itemsPerPage||10,this.onPageChange=t.onPageChange||(()=>{}),this.container=t.container}render(){if(!this.container)return;let t='<div class="pagination">';t+=`
      <button class="pagination-btn prev" ${this.currentPage===1?"disabled":""}>
        Previous
      </button>
    `;let e=7,i=Math.max(1,this.currentPage-Math.floor(e/2)),a=Math.min(this.totalPages,i+e-1);a-i<e-1&&(i=Math.max(1,a-e+1)),i>1&&(t+='<button class="pagination-btn page" data-page="1">1</button>',i>2&&(t+='<span class="pagination-dots">...</span>'));for(let s=i;s<=a;s++)t+=`
        <button class="pagination-btn page ${s===this.currentPage?"active":""}" data-page="${s}">
          ${s}
        </button>
      `;a<this.totalPages&&(a<this.totalPages-1&&(t+='<span class="pagination-dots">...</span>'),t+=`
        <button class="pagination-btn page" data-page="${this.totalPages}">
          ${this.totalPages}
        </button>
      `),t+=`
      <button class="pagination-btn next" ${this.currentPage===this.totalPages?"disabled":""}>
        Next
      </button>
    `,t+=`
      <div class="pagination-info">
        Page ${this.currentPage} of ${this.totalPages} (${this.totalItems} total)
      </div>
    </div>
    `,this.container.innerHTML=t,this.setupEventListeners(),this.injectStyles()}setupEventListeners(){this.container&&(this.container.querySelector(".prev").addEventListener("click",()=>{this.currentPage>1&&this.goToPage(this.currentPage-1)}),this.container.querySelector(".next").addEventListener("click",()=>{this.currentPage<this.totalPages&&this.goToPage(this.currentPage+1)}),this.container.querySelectorAll(".page").forEach(t=>{t.addEventListener("click",e=>{let i=parseInt(e.target.dataset.page);this.goToPage(i)})}))}goToPage(t){t<1||t>this.totalPages||(this.currentPage=t,this.onPageChange(t),this.render())}setTotal(t){this.totalItems=t,this.totalPages=Math.ceil(t/this.itemsPerPage),this.currentPage=1,this.render()}injectStyles(){if(document.getElementById("pagination-styles"))return;let t=`
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
    `,e=document.createElement("style");e.id="pagination-styles",e.textContent=t,document.head.appendChild(e)}},l=class{constructor(t={}){this.images=document.querySelectorAll("[data-lazy]"),this.placeholder=t.placeholder||'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 300"%3E%3Crect fill="%23f0f0f0" width="400" height="300"/%3E%3C/svg%3E',this.fadeInClass=t.fadeInClass||"loaded",this.init()}init(){"IntersectionObserver"in window?this.initIntersectionObserver():this.loadAllImages()}initIntersectionObserver(){let t=new IntersectionObserver(e=>{e.forEach(i=>{i.isIntersecting&&(this.loadImage(i.target),t.unobserve(i.target))})},{rootMargin:"50px"});this.images.forEach(e=>t.observe(e))}loadImage(t){let e=t.dataset.lazy;t.onload=()=>{t.classList.add(this.fadeInClass)},t.onerror=()=>{console.error(`Failed to load image: ${e}`)},t.src=e}loadAllImages(){this.images.forEach(t=>this.loadImage(t))}},c=class{constructor(t={}){this.container=t.container,this.items=t.items||[],this.itemHeight=t.itemHeight||50,this.renderItem=t.renderItem,this.bufferSize=t.bufferSize||5,this.init()}init(){this.container.addEventListener("scroll",()=>this.handleScroll()),this.render()}handleScroll(){this.render()}render(){let t=this.container.scrollTop,e=this.container.clientHeight,i=Math.max(0,Math.floor(t/this.itemHeight)-this.bufferSize),a=Math.min(this.items.length,Math.ceil((t+e)/this.itemHeight)+this.bufferSize);this.container.style.height=`${this.items.length*this.itemHeight}px`;let s="";for(let n=i;n<a;n++){let g=n*this.itemHeight,d=this.items[n];s+=`
        <div style="position: absolute; top: ${g}px; height: ${this.itemHeight}px; width: 100%;">
          ${this.renderItem(d,n)}
        </div>
      `}this.container.innerHTML=s}setItems(t){this.items=t,this.render()}};window.InfiniteScroll=o;window.Pagination=h;window.LazyLoader=l;window.VirtualScroller=c;})();
//# sourceMappingURL=pagination.js.map
