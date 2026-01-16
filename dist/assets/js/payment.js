(()=>{var o=class{constructor(){this.apiClient=window.apiClient,this.store=window.appStore}async createPaymentIntent(t,e="USD"){try{this.store.setState({loading:!0});let a=await this.apiClient.createPaymentIntent(t,e);return this.store.setState({loading:!1}),a}catch(a){throw this.store.setState({loading:!1}),a}}async processPayment(t){let{amount:e,currency:a,description:i,metadata:n}=t;try{this.store.setState({loading:!0});let m={success:!0,paymentId:(await this.createPaymentIntent(e,a)).clientSecret||`pay_${Date.now()}`,amount:e,currency:a,status:"succeeded",metadata:n};return this.store.setState({loading:!1}),m}catch(u){throw this.store.setState({loading:!1}),u}}async verifyPayment(t){try{return await this.apiClient.verifyPayment(t)}catch(e){throw e}}async handleSubscription(t){let a={premium:{amount:999,name:"Premium Monthly",interval:"month"},elite:{amount:2499,name:"Elite Monthly",interval:"month"},annual:{amount:9999,name:"Premium Annual",interval:"year"}}[t];if(!a)throw new Error("Invalid tier");return this.processPayment({amount:a.amount,currency:"USD",description:a.name,metadata:{tier:t,interval:a.interval}})}async handleBoostPurchase(t="standard"){let a={standard:{amount:499,name:"Standard Boost",duration:24},premium:{amount:999,name:"Premium Boost",duration:72},mega:{amount:1999,name:"Mega Boost",duration:168}}[t];if(!a)throw new Error("Invalid boost type");return this.processPayment({amount:a.amount,currency:"USD",description:a.name,metadata:{type:"boost",boostType:t,duration:a.duration}})}},s=class{static showSubscriptionModal(){let t=[{id:"premium",name:"Premium",price:"$9.99/month",features:["Unlimited likes","Advanced filters","See who liked you"]},{id:"elite",name:"Elite",price:"$24.99/month",features:["Everything in Premium","Verified badge","Priority support"]},{id:"annual",name:"Annual Plan",price:"$99.99/year",features:["Everything in Elite","Save 17%","Yearly discount"]}],e='<div class="subscription-tiers">';t.forEach(a=>{e+=`
        <div class="tier-card">
          <h3>${a.name}</h3>
          <p class="price">${a.price}</p>
          <ul class="features">
            ${a.features.map(i=>`<li>? ${i}</li>`).join("")}
          </ul>
          <button class="btn btn-primary" data-tier="${a.id}" onclick="window.paymentProcessor.handleSubscription('${a.id}')">
            Subscribe
          </button>
        </div>
      `}),e+="</div>",new window.Modal({title:"Upgrade to Premium",content:e,className:"modal-payment"}).open()}static showBoostModal(){let t=[{id:"standard",name:"Standard Boost",price:"$4.99",duration:"24 hours"},{id:"premium",name:"Premium Boost",price:"$9.99",duration:"3 days"},{id:"mega",name:"Mega Boost",price:"$19.99",duration:"1 week"}],e='<div class="boost-options">';t.forEach(a=>{e+=`
        <div class="boost-card">
          <h3>${a.name}</h3>
          <p class="price">${a.price}</p>
          <p class="duration">${a.duration}</p>
          <p class="description">Get maximum visibility</p>
          <button class="btn btn-primary" onclick="window.paymentProcessor.handleBoostPurchase('${a.id}')">
            Boost Now
          </button>
        </div>
      `}),e+="</div>",new window.Modal({title:"Boost Your Profile",content:e,className:"modal-payment"}).open()}},d=class{static check(t){var i,n;let e=(n=(i=window.appStore)==null?void 0:i.getState())==null?void 0:n.user;return{"unlimited-likes":(e==null?void 0:e.tier)!=="free","advanced-filters":(e==null?void 0:e.tier)!=="free","see-who-liked":(e==null?void 0:e.tier)==="premium"||(e==null?void 0:e.tier)==="elite","verified-badge":(e==null?void 0:e.tier)==="elite","priority-support":(e==null?void 0:e.tier)==="elite",boost:!0,"export-data":(e==null?void 0:e.tier)!=="free"}[t]||!1}static require(t,e=null){return this.check(t)?!0:(this.showPaywall(t,e),!1)}static showPaywall(t,e){let a={"unlimited-likes":"Upgrade to Premium to get unlimited likes","advanced-filters":"Upgrade to Premium to use advanced filters","see-who-liked":"Upgrade to Premium to see who liked you","verified-badge":"Upgrade to Elite for a verified badge","priority-support":"Upgrade to Elite for priority support","export-data":"Upgrade to Premium to export your data"};new window.Modal({title:"Premium Feature",content:`<p>${a[t]||"Upgrade to unlock this feature"}</p>`,buttons:[{label:"Cancel",type:"secondary",action:"cancel"},{label:"Upgrade",type:"primary",action:"upgrade",onClick:()=>s.showSubscriptionModal()}]}).open()}},c=class{constructor(){this.apiClient=window.apiClient,this.store=window.appStore}async getBalance(){let t=this.store.getState().user;return(t==null?void 0:t.credits)||0}async addCredits(t,e=""){var a;try{let i=await this.apiClient.createPaymentIntent(t,"USD");if(i.success)return this.store.setState({user:{...this.store.getState().user,credits:(((a=this.store.getState().user)==null?void 0:a.credits)||0)+t}}),i}catch(i){throw i}}async spendCredits(t,e=""){let a=await this.getBalance();if(a<t)throw new Error("Insufficient credits");this.store.setState({user:{...this.store.getState().user,credits:a-t}})}async getTransactions(t=20){return[]}},l=class{static generate(t){let e=new Date;return{id:`RCP-${Date.now()}`,date:e.toISOString(),amount:t.amount,currency:t.currency,description:t.description,status:"completed",paymentId:t.paymentId,metadata:t.metadata}}static download(t){let e=`
Receipt #${t.id}
Date: ${new Date(t.date).toLocaleDateString()}
---
${t.description}
Amount: ${(t.amount/100).toFixed(2)} ${t.currency}
Status: ${t.status}
---
Payment ID: ${t.paymentId}
    `,a=new Blob([e],{type:"text/plain"}),i=URL.createObjectURL(a),n=document.createElement("a");n.href=i,n.download=`receipt-${t.id}.txt`,n.click(),URL.revokeObjectURL(i)}static email(t,e){return fetch("/api/payments/send-receipt",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({receipt:t,email:e})})}};window.PaymentProcessor=o;window.PaymentModal=s;window.Paywall=d;window.Wallet=c;window.Receipt=l;window.paymentProcessor=new o;window.wallet=new c;})();
//# sourceMappingURL=payment.js.map
