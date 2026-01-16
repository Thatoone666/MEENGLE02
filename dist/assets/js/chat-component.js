(()=>{var c=class{constructor(t){this.matchId=t,this.apiClient=window.apiClient,this.realtimeClient=window.realtimeClient,this.store=window.appStore,this.messages=[],this.currentMatch=null,this.isTyping=!1,this.typingTimeout=null,this.init()}async init(){await this.loadMatch(),await this.loadMessages(),this.setupRealtimeListeners(),this.setupEventListeners(),this.render()}async loadMatch(){var t;try{let e=this.store.getState();if(this.currentMatch=(t=e.matches)==null?void 0:t.find(s=>s._id===this.matchId),!this.currentMatch){let s=await this.apiClient.getMatches();this.currentMatch=s.find(a=>a._id===this.matchId)}}catch(e){console.error("Failed to load match:",e)}}async loadMessages(){try{let t=await this.apiClient.getConversation(this.matchId,50);this.messages=t.messages||[],await this.apiClient.markMessagesAsRead(this.matchId)}catch(t){console.error("Failed to load messages:",t)}}setupRealtimeListeners(){this.realtimeClient&&(this.realtimeClient.joinChatRoom(this.matchId),this.realtimeClient.on("message-received",t=>{var e;(t.matchId===this.matchId||t.userId===((e=this.currentMatch)==null?void 0:e.id))&&this.addMessage({userId:t.userId,message:t.message,timestamp:new Date(t.timestamp),read:!0})}),this.realtimeClient.on("user-typing",t=>{var e;t.userId!==((e=this.store.getState().user)==null?void 0:e.id)&&this.showTypingIndicator()}),this.realtimeClient.on("user-stop-typing",t=>{this.hideTypingIndicator()}))}setupEventListeners(){let t=document.getElementById("chat-container");if(!t)return;let e=t.querySelector('[data-input="message"]'),s=t.querySelector('[data-action="send"]'),a=t.querySelector('[data-action="attach"]');e&&(e.addEventListener("input",i=>this.handleTyping(i)),e.addEventListener("keydown",i=>{i.key==="Enter"&&!i.shiftKey&&(i.preventDefault(),this.sendMessage())})),s&&s.addEventListener("click",()=>this.sendMessage()),a&&a.addEventListener("click",()=>this.attachFile())}handleTyping(t){var e;(e=this.realtimeClient)==null||e.startTyping(this.matchId),clearTimeout(this.typingTimeout),this.typingTimeout=setTimeout(()=>{var s;(s=this.realtimeClient)==null||s.stopTyping(this.matchId)},3e3)}async sendMessage(){var a,i;let t=document.getElementById("chat-container"),e=t==null?void 0:t.querySelector('[data-input="message"]');if(!e||!e.value.trim())return;let s=e.value.trim();e.value="";try{let n=this.store.getState();this.addMessage({userId:(a=n.user)==null?void 0:a.id,message:s,timestamp:new Date,read:!1,isOwn:!0}),await this.apiClient.sendMessage(this.matchId,s),(i=this.realtimeClient)==null||i.sendMessage(this.matchId,s)}catch(n){console.error("Failed to send message:",n),window.Utils.showToast("Failed to send message",3e3,"error")}}async attachFile(){let t=document.createElement("input");t.type="file",t.onchange=async e=>{let s=e.target.files[0];if(s)try{let a=new FileReader;a.onload=async i=>{let n=i.target.result,o=await this.apiClient.uploadMedia(s.name,n,s.type.startsWith("image")?"image":"file",s.size);await this.sendMessage(`[File: ${s.name}] ${o.media.url}`)},a.readAsDataURL(s)}catch(a){console.error("Failed to upload file:",a),window.Utils.showToast("Failed to upload file",3e3,"error")}},t.click()}addMessage(t){this.messages.push(t),this.render(),this.scrollToBottom()}showTypingIndicator(){let t=document.getElementById("chat-container");if(!t||t.querySelector(".typing-indicator"))return;let s=document.createElement("div");s.className="typing-indicator",s.innerHTML="<span>?</span><span>?</span><span>?</span>";let a=t.querySelector('[data-area="messages"]');a&&(a.appendChild(s),this.scrollToBottom())}hideTypingIndicator(){let t=document.getElementById("chat-container"),e=t==null?void 0:t.querySelector(".typing-indicator");e&&e.remove()}scrollToBottom(){let t=document.getElementById("chat-container"),e=t==null?void 0:t.querySelector('[data-area="messages"]');e&&(e.scrollTop=e.scrollHeight)}render(){var i,n,o,d,l,h,m,u;let t=document.getElementById("chat-container");if(!t)return;let e=this.store.getState(),s=e.user,a=`
      <div class="chat-header">
        <div class="match-info">
          <img src="${((n=(i=this.currentMatch)==null?void 0:i.photos)==null?void 0:n[0])||"/assets/default-avatar.png"}" alt="${(o=this.currentMatch)==null?void 0:o.name}">
          <div class="match-details">
            <h3>${((d=this.currentMatch)==null?void 0:d.name)||"Chat"}</h3>
            <span class="status ${((h=e.userStatus)==null?void 0:h[(l=this.currentMatch)==null?void 0:l.id])==="online"?"online":"offline"}">
              ${((u=e.userStatus)==null?void 0:u[(m=this.currentMatch)==null?void 0:m.id])==="online"?"? Online":"? Offline"}
            </span>
          </div>
        </div>
        <div class="chat-actions">
          <button class="icon-btn" title="Call">??</button>
          <button class="icon-btn" title="Video">??</button>
          <button class="icon-btn" title="Info">??</button>
        </div>
      </div>

      <div class="chat-messages" data-area="messages">
        ${this.messages.map((r,g)=>`
            <div class="message ${r.userId===(s==null?void 0:s.id)||r.isOwn?"own":"other"}">
              <div class="message-content">
                ${r.message}
              </div>
              <span class="message-time">${window.Utils.formatTime(r.timestamp)}</span>
            </div>
          `).join("")}
      </div>

      <div class="chat-input-area">
        <button class="icon-btn" data-action="attach" title="Attach file">??</button>
        <input 
          type="text" 
          class="chat-input" 
          data-input="message" 
          placeholder="Type a message..."
          autocomplete="off"
        >
        <button class="btn btn-primary btn-send" data-action="send">Send</button>
      </div>
    `;t.innerHTML=a,this.setupEventListeners(),this.scrollToBottom()}};document.addEventListener("DOMContentLoaded",()=>{let t=new URLSearchParams(window.location.search).get("match");t&&window.apiClient&&window.appStore.getState().isAuthenticated?new c(t):window.location.href="/pages/home.html"});})();
//# sourceMappingURL=chat-component.js.map
