(()=>{var s=class{static init(){window.addEventListener("error",e=>{this.handleError(e.error,"Uncaught Error")}),window.addEventListener("unhandledrejection",e=>{this.handleError(e.reason,"Unhandled Promise Rejection")})}static handleError(e,r="Error"){console.error(`${r}:`,e),window.Sentry&&window.Sentry.captureException(e,{tags:{source:r}}),this.showErrorUI(e)}static showErrorUI(e){let r=e?.message||"Something went wrong. Please try again.";if(document.querySelector(".error-boundary"))return;let t=document.createElement("div");t.className="error-boundary",t.innerHTML=`
      <div class="error-content">
        <h3>?? Something went wrong</h3>
        <p>${r}</p>
        <button class="btn btn-primary" onclick="this.parentElement.parentElement.remove()">
          Dismiss
        </button>
      </div>
    `,document.body.appendChild(t),setTimeout(()=>{t.remove()},1e4)}},d=class{static handle(e){return e.response?.status===401?(localStorage.removeItem("authToken"),window.location.href="/pages/login.html","Please log in again"):e.response?.status===403?"You do not have permission to do this":e.response?.status===404?"Resource not found":e.response?.status===429?"Too many requests. Please wait a moment.":e.response?.status===500?"Server error. Please try again later.":e.response?.data?.error?e.response.data.error:e.message==="Network Error"?"Network connection error. Check your internet.":e.message||"An error occurred. Please try again."}},c=class{static formatErrors(e){return typeof e=="string"?e:Array.isArray(e)?e.join(", "):typeof e=="object"?Object.values(e).flat().join(", "):"Validation failed"}static displayErrors(e,r){r&&(r.querySelectorAll(".error-message").forEach(o=>{o.remove()}),Object.entries(e).forEach(([o,t])=>{let a=r.querySelector(`[name="${o}"]`);if(!a)return;a.classList.add("error");let i=document.createElement("span");i.className="error-message",i.textContent=Array.isArray(t)?t[0]:t,a.parentElement.appendChild(i)}))}};s.init();var l=`
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
`;if(!document.getElementById("error-styles")){let n=document.createElement("style");n.id="error-styles",n.textContent=l,document.head.appendChild(n)}window.ErrorBoundary=s;window.APIErrorHandler=d;window.ValidationErrorHandler=c;})();
//# sourceMappingURL=error-handler.js.map
