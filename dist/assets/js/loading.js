(()=>{var l=class{static createSpinner(e="medium"){let t=document.createElement("div");return t.className=`spinner spinner-${e}`,t.innerHTML=`
      <div class="spinner-circle"></div>
      <p>Loading...</p>
    `,t}static createSkeleton(e="card"){let t=document.createElement("div");switch(t.className=`skeleton skeleton-${e}`,e){case"card":t.innerHTML=`
          <div class="skeleton-image"></div>
          <div class="skeleton-text skeleton-title"></div>
          <div class="skeleton-text"></div>
          <div class="skeleton-text" style="width: 60%"></div>
        `;break;case"line":t.innerHTML='<div class="skeleton-text"></div>';break;case"avatar":t.innerHTML='<div class="skeleton-avatar"></div>';break;case"list":t.innerHTML=`
          ${Array(5).fill().map(()=>`
            <div class="skeleton-item">
              <div class="skeleton-avatar"></div>
              <div class="skeleton-text"></div>
            </div>
          `).join("")}
        `;break}return t}static replaceWithSkeleton(e,t="card",s=1){if(!e)return;let n=document.createElement("div");for(let r=0;r<s;r++)n.appendChild(this.createSkeleton(t));e.innerHTML=n.innerHTML}static replaceWithSpinner(e,t="medium"){e&&(e.innerHTML="",e.appendChild(this.createSpinner(t)))}},o=class{constructor(e={}){this.container=e.container,this.value=e.value||0,this.max=e.max||100,this.label=e.label||"",this.color=e.color||"#4CAF50",this.element=null,this.create()}create(){this.element=document.createElement("div"),this.element.className="progress-bar-container",this.element.innerHTML=`
      <div class="progress-bar-wrapper">
        <div class="progress-bar-fill" style="width: 0%; background-color: ${this.color}"></div>
      </div>
      <div class="progress-bar-label">${this.label} <span class="progress-value">0%</span></div>
    `,this.container&&this.container.appendChild(this.element)}setValue(e){var r,d;this.value=Math.min(Math.max(e,0),this.max);let t=this.value/this.max*100,s=(r=this.element)==null?void 0:r.querySelector(".progress-bar-fill"),n=(d=this.element)==null?void 0:d.querySelector(".progress-value");s&&(s.style.width=t+"%"),n&&(n.textContent=Math.round(t)+"%")}increment(e=1){this.setValue(this.value+e)}remove(){this.element&&this.element.remove()}},a=class{static enable(){if(!document.getElementById("shimmer-style")){let e=document.createElement("style");e.id="shimmer-style",e.textContent=`
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
      `,document.head.appendChild(e)}}};a.enable();var c=`
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
`;if(!document.getElementById("loading-styles")){let i=document.createElement("style");i.id="loading-styles",i.textContent=c,document.head.appendChild(i)}window.LoadingState=l;window.ProgressBar=o;window.ShimmerEffect=a;})();
//# sourceMappingURL=loading.js.map
