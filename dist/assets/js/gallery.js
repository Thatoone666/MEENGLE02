(()=>{var a=class{constructor(t,e={}){this.container=typeof t=="string"?document.querySelector(t):t,this.images=e.images||[],this.currentIndex=0,this.autoplay=e.autoplay||!1,this.autoplayInterval=e.autoplayInterval||5e3,this.showThumbnails=e.showThumbnails!==!1,this.showControls=e.showControls!==!1,this.thumbnailPosition=e.thumbnailPosition||"bottom",this.onImageChange=e.onImageChange||(()=>{}),this.intervalId=null,this.init()}init(){this.container&&(this.render(),this.setupEventListeners(),this.autoplay&&this.startAutoplay())}render(){var e,n;let t='<div class="gallery-wrapper">';t+=`
      <div class="gallery-main">
        <img src="${((e=this.images[this.currentIndex])==null?void 0:e.src)||""}" 
             alt="${((n=this.images[this.currentIndex])==null?void 0:n.alt)||""}"
             class="gallery-image">
        ${this.showControls?`
          <button class="gallery-prev" aria-label="Previous">?</button>
          <button class="gallery-next" aria-label="Next">?</button>
          <div class="gallery-counter">${this.currentIndex+1} / ${this.images.length}</div>
        `:""}
      </div>
    `,this.showThumbnails&&this.images.length>1&&(t+=`
        <div class="gallery-thumbnails gallery-thumbnails-${this.thumbnailPosition}">
          ${this.images.map((r,i)=>`
            <div class="thumbnail ${i===this.currentIndex?"active":""}" data-index="${i}">
              <img src="${r.thumbnail||r.src}" alt="${r.alt||""}">
            </div>
          `).join("")}
        </div>
      `),t+="</div>",this.container.innerHTML=t,this.injectStyles()}setupEventListeners(){if(!this.container)return;let t=this.container.querySelector(".gallery-prev"),e=this.container.querySelector(".gallery-next");t&&t.addEventListener("click",()=>this.prev()),e&&e.addEventListener("click",()=>this.next()),this.container.querySelectorAll(".thumbnail").forEach(i=>{i.addEventListener("click",s=>{let h=parseInt(s.currentTarget.dataset.index);this.goToSlide(h)})}),document.addEventListener("keydown",i=>{i.key==="ArrowLeft"&&this.prev(),i.key==="ArrowRight"&&this.next()});let n=0,r=this.container.querySelector(".gallery-main");r&&(r.addEventListener("touchstart",i=>{n=i.touches[0].clientX}),r.addEventListener("touchend",i=>{let s=i.changedTouches[0].clientX;n-s>50&&this.next(),s-n>50&&this.prev()}))}next(){this.currentIndex=(this.currentIndex+1)%this.images.length,this.update()}prev(){this.currentIndex=(this.currentIndex-1+this.images.length)%this.images.length,this.update()}goToSlide(t){this.currentIndex=Math.max(0,Math.min(t,this.images.length-1)),this.update()}update(){this.render(),this.setupEventListeners(),this.onImageChange(this.currentIndex,this.images[this.currentIndex])}addImage(t){this.images.push(t),this.update()}removeImage(t){this.images.splice(t,1),this.currentIndex>=this.images.length&&(this.currentIndex=Math.max(0,this.images.length-1)),this.update()}setImages(t){this.images=t,this.currentIndex=0,this.update()}startAutoplay(){this.intervalId=setInterval(()=>this.next(),this.autoplayInterval)}stopAutoplay(){this.intervalId&&(clearInterval(this.intervalId),this.intervalId=null)}injectStyles(){if(document.getElementById("gallery-styles"))return;let t=`
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
    `,e=document.createElement("style");e.id="gallery-styles",e.textContent=t,document.head.appendChild(e)}},l=class{constructor(t={}){this.images=t.images||[],this.currentIndex=0,this.onClose=t.onClose||(()=>{})}open(t=0){this.currentIndex=t,this.render()}render(){var r;let t=document.querySelector(".lightbox");t&&t.remove();let e=document.createElement("div");e.className="lightbox active",e.innerHTML=`
      <div class="lightbox-overlay"></div>
      <div class="lightbox-content">
        <button class="lightbox-close">&times;</button>
        <button class="lightbox-prev">?</button>
        <img src="${((r=this.images[this.currentIndex])==null?void 0:r.src)||""}" alt="" class="lightbox-image">
        <button class="lightbox-next">?</button>
        <div class="lightbox-counter">${this.currentIndex+1} / ${this.images.length}</div>
      </div>
    `,document.body.appendChild(e),e.querySelector(".lightbox-close").addEventListener("click",()=>this.close()),e.querySelector(".lightbox-overlay").addEventListener("click",()=>this.close()),e.querySelector(".lightbox-prev").addEventListener("click",()=>this.prev()),e.querySelector(".lightbox-next").addEventListener("click",()=>this.next());let n=i=>{i.key==="Escape"&&this.close(),i.key==="ArrowLeft"&&this.prev(),i.key==="ArrowRight"&&this.next()};document.addEventListener("keydown",n),this.injectStyles()}next(){this.currentIndex=(this.currentIndex+1)%this.images.length,this.render()}prev(){this.currentIndex=(this.currentIndex-1+this.images.length)%this.images.length,this.render()}close(){let t=document.querySelector(".lightbox");t&&t.remove(),this.onClose()}injectStyles(){if(document.getElementById("lightbox-styles"))return;let t=`
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
    `,e=document.createElement("style");e.id="lightbox-styles",e.textContent=t,document.head.appendChild(e)}};window.ImageGallery=a;window.Lightbox=l;})();
//# sourceMappingURL=gallery.js.map
