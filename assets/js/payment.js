(()=>{var s=class{constructor(){this.apiClient=window.apiClient,this.store=window.appStore}async createPaymentIntent(t,a="USD"){try{this.store.setState({loading:!0});let e=await this.apiClient.createPaymentIntent(t,a);return this.store.setState({loading:!1}),e}catch(e){throw this.store.setState({loading:!1}),e}}async processPayment(t){let{amount:a,currency:e,description:r,metadata:i}=t;try{this.store.setState({loading:!0});let m={success:!0,paymentId:(await this.createPaymentIntent(a,e)).clientSecret||`pay_${Date.now()}`,amount:a,currency:e,status:"succeeded",metadata:i};return this.store.setState({loading:!1}),m}catch(u){throw this.store.setState({loading:!1}),u}}async verifyPayment(t){try{return await this.apiClient.verifyPayment(t)}catch(a){throw a}}async handleSubscription(t){let e={premium:{amount:999,name:"Premium Monthly",interval:"month"},elite:{amount:2499,name:"Elite Monthly",interval:"month"},annual:{amount:9999,name:"Premium Annual",interval:"year"}}[t];if(!e)throw new Error("Invalid tier");return this.processPayment({amount:e.amount,currency:"USD",description:e.name,metadata:{tier:t,interval:e.interval}})}async handleBoostPurchase(t="standard"){let e={standard:{amount:499,name:"Standard Boost",duration:24},premium:{amount:999,name:"Premium Boost",duration:72},mega:{amount:1999,name:"Mega Boost",duration:168}}[t];if(!e)throw new Error("Invalid boost type");return this.processPayment({amount:e.amount,currency:"USD",description:e.name,metadata:{type:"boost",boostType:t,duration:e.duration}})}},o=class{static showSubscriptionModal(){let t=[{id:"premium",name:"Premium",price:"$9.99/month",features:["Unlimited likes","Advanced filters","See who liked you"]},{id:"elite",name:"Elite",price:"$24.99/month",features:["Everything in Premium","Verified badge","Priority support"]},{id:"annual",name:"Annual Plan",price:"$99.99/year",features:["Everything in Elite","Save 17%","Yearly discount"]}],a='<div class="subscription-tiers">';t.forEach(e=>{a+=`
        <div class="tier-card">
          <h3>${e.name}</h3>
          <p class="price">${e.price}</p>
          <ul class="features">
            ${e.features.map(r=>`<li>? ${r}</li>`).join("")}
          </ul>
          <button class="btn btn-primary" data-tier="${e.id}" onclick="window.paymentProcessor.handleSubscription('${e.id}')">
            Subscribe
          </button>
        </div>
      `}),a+="</div>",new window.Modal({title:"Upgrade to Premium",content:a,className:"modal-payment"}).open()}static showBoostModal(){let t=[{id:"standard",name:"Standard Boost",price:"$4.99",duration:"24 hours"},{id:"premium",name:"Premium Boost",price:"$9.99",duration:"3 days"},{id:"mega",name:"Mega Boost",price:"$19.99",duration:"1 week"}],a='<div class="boost-options">';t.forEach(e=>{a+=`
        <div class="boost-card">
          <h3>${e.name}</h3>
          <p class="price">${e.price}</p>
          <p class="duration">${e.duration}</p>
          <p class="description">Get maximum visibility</p>
          <button class="btn btn-primary" onclick="window.paymentProcessor.handleBoostPurchase('${e.id}')">
            Boost Now
          </button>
        </div>
      `}),a+="</div>",new window.Modal({title:"Boost Your Profile",content:a,className:"modal-payment"}).open()}},d=class{static check(t){let a=window.appStore?.getState()?.user;return{"unlimited-likes":a?.tier!=="free","advanced-filters":a?.tier!=="free","see-who-liked":a?.tier==="premium"||a?.tier==="elite","verified-badge":a?.tier==="elite","priority-support":a?.tier==="elite",boost:!0,"export-data":a?.tier!=="free"}[t]||!1}static require(t,a=null){return this.check(t)?!0:(this.showPaywall(t,a),!1)}static showPaywall(t,a){let e={"unlimited-likes":"Upgrade to Premium to get unlimited likes","advanced-filters":"Upgrade to Premium to use advanced filters","see-who-liked":"Upgrade to Premium to see who liked you","verified-badge":"Upgrade to Elite for a verified badge","priority-support":"Upgrade to Elite for priority support","export-data":"Upgrade to Premium to export your data"};new window.Modal({title:"Premium Feature",content:`<p>${e[t]||"Upgrade to unlock this feature"}</p>`,buttons:[{label:"Cancel",type:"secondary",action:"cancel"},{label:"Upgrade",type:"primary",action:"upgrade",onClick:()=>o.showSubscriptionModal()}]}).open()}},c=class{constructor(){this.apiClient=window.apiClient,this.store=window.appStore}async getBalance(){return this.store.getState().user?.credits||0}async addCredits(t,a=""){try{let e=await this.apiClient.createPaymentIntent(t,"USD");if(e.success)return this.store.setState({user:{...this.store.getState().user,credits:(this.store.getState().user?.credits||0)+t}}),e}catch(e){throw e}}async spendCredits(t,a=""){let e=await this.getBalance();if(e<t)throw new Error("Insufficient credits");this.store.setState({user:{...this.store.getState().user,credits:e-t}})}async getTransactions(t=20){return[]}},l=class{static generate(t){let a=new Date;return{id:`RCP-${Date.now()}`,date:a.toISOString(),amount:t.amount,currency:t.currency,description:t.description,status:"completed",paymentId:t.paymentId,metadata:t.metadata}}static download(t){let a=`
Receipt #${t.id}
Date: ${new Date(t.date).toLocaleDateString()}
---
${t.description}
Amount: ${(t.amount/100).toFixed(2)} ${t.currency}
Status: ${t.status}
---
Payment ID: ${t.paymentId}
    `,e=new Blob([a],{type:"text/plain"}),r=URL.createObjectURL(e),i=document.createElement("a");i.href=r,i.download=`receipt-${t.id}.txt`,i.click(),URL.revokeObjectURL(r)}static email(t,a){return fetch("/api/payments/send-receipt",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({receipt:t,email:a})})}};window.PaymentProcessor=s;window.PaymentModal=o;window.Paywall=d;window.Wallet=c;window.Receipt=l;window.paymentProcessor=new s;window.wallet=new c;})();
//# sourceMappingURL=payment.js.map
