(()=>{var c=class n{constructor(t={}){this.title=t.title||"",this.content=t.content||"",this.buttons=t.buttons||[],this.className=t.className||"",this.onClose=t.onClose||(()=>{}),this.element=null}open(){this.createModal(),document.body.appendChild(this.element),document.body.style.overflow="hidden",setTimeout(()=>{this.element.classList.add("active")},10)}close(){this.element.classList.remove("active"),setTimeout(()=>{this.element.remove(),document.body.style.overflow="",this.onClose()},300)}createModal(){let t=document.createElement("div");t.className=`modal ${this.className}`;let a=document.createElement("div");a.className="modal-overlay",a.addEventListener("click",()=>this.close());let l=document.createElement("div");l.className="modal-dialog";let e="";this.title&&(e+=`
        <div class="modal-header">
          <h2>${this.title}</h2>
          <button class="modal-close" aria-label="Close">&times;</button>
        </div>
      `),e+=`<div class="modal-body">${this.content}</div>`,this.buttons.length>0&&(e+='<div class="modal-footer">',this.buttons.forEach(o=>{e+=`
          <button class="btn btn-${o.type||"secondary"}" data-action="${o.action}">
            ${o.label}
          </button>
        `}),e+="</div>"),l.innerHTML=e;let d=l.querySelector(".modal-close");d&&d.addEventListener("click",()=>this.close()),l.querySelectorAll("[data-action]").forEach(o=>{o.addEventListener("click",u=>{let r=o.dataset.action,s=this.buttons.find(m=>m.action===r);s!=null&&s.onClick&&s.onClick(),(s==null?void 0:s.closeOnClick)!==!1&&this.close()})}),t.appendChild(a),t.appendChild(l),this.element=t}static confirm(t={}){let a=new n({title:t.title||"Confirm",content:t.message||"Are you sure?",buttons:[{label:"Cancel",type:"secondary",action:"cancel"},{label:"Confirm",type:"primary",action:"confirm",onClick:t.onConfirm||(()=>{})}]});return a.open(),a}static alert(t={}){let a=new n({title:t.title||"Alert",content:t.message||"",buttons:[{label:"OK",type:"primary",action:"ok"}]});return a.open(),a}static prompt(t={}){let a=`modal-input-${Date.now()}`,l=new n({title:t.title||"Enter value",content:`<input type="text" id="${a}" class="form-control" placeholder="${t.placeholder||""}">`,buttons:[{label:"Cancel",type:"secondary",action:"cancel"},{label:"OK",type:"primary",action:"ok",onClick:()=>{let e=document.getElementById(a);e&&t.onSubmit&&t.onSubmit(e.value)}}]});return l.open(),setTimeout(()=>{let e=document.getElementById(a);e&&e.focus()},100),l}static payment(t={}){let a=new n({title:t.title||"Payment",className:"modal-payment",content:`
        <div class="payment-form">
          <div class="amount-display">
            <span class="currency">$</span>
            <span class="amount">${(t.amount/100).toFixed(2)}</span>
          </div>
          
          <div class="form-group">
            <label>Card Number</label>
            <input type="text" class="form-control" id="card-number" placeholder="1234 5678 9012 3456">
          </div>
          
          <div class="form-row">
            <div class="form-group">
              <label>Expiry</label>
              <input type="text" class="form-control" id="card-expiry" placeholder="MM/YY">
            </div>
            <div class="form-group">
              <label>CVC</label>
              <input type="text" class="form-control" id="card-cvc" placeholder="123">
            </div>
          </div>
          
          <div class="form-group">
            <label>
              <input type="checkbox" id="save-card"> Save this card
            </label>
          </div>
        </div>
      `,buttons:[{label:"Cancel",type:"secondary",action:"cancel"},{label:"Pay Now",type:"primary",action:"pay",onClick:t.onSubmit||(()=>{})}]});return a.open(),a}},i=class{static show(t,a=3e3,l="info"){let e=document.createElement("div");e.className=`toast toast-${l}`,e.textContent=t,e.style.animation="slideIn 0.3s ease-out",document.body.appendChild(e),setTimeout(()=>{e.style.animation="slideOut 0.3s ease-out",setTimeout(()=>e.remove(),300)},a)}static success(t){this.show(t,3e3,"success")}static error(t){this.show(t,4e3,"error")}static warning(t){this.show(t,3500,"warning")}static info(t){this.show(t,3e3,"info")}};window.Modal=c;window.Toast=i;})();
//# sourceMappingURL=modal.js.map
