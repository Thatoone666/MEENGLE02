(()=>{var o=class{constructor(t={}){this.apiClient=window.apiClient,this.store=window.appStore,this.notifications=[],this.unreadCount=0,this.pollInterval=t.pollInterval||3e4,this.allowPushNotifications=t.allowPushNotifications!==!1,this.init()}async init(){await this.requestPermissions(),await this.loadNotifications(),this.startPolling(),this.setupEventListeners()}async requestPermissions(){"Notification"in window&&Notification.permission==="default"&&await Notification.requestPermission()}async loadNotifications(){try{let t=await this.apiClient.getNotifications(20);this.notifications=t.notifications||[],this.unreadCount=this.notifications.filter(i=>!i.read).length,this.store.setState({notifications:this.notifications,unreadCount:this.unreadCount})}catch(t){console.error("Failed to load notifications:",t)}}startPolling(){this.pollInterval=setInterval(()=>this.loadNotifications(),this.pollInterval)}stopPolling(){this.pollInterval&&clearInterval(this.pollInterval)}async markAsRead(t){try{await this.apiClient.markNotificationAsRead(t);let i=this.notifications.find(e=>e.id===t);i&&(i.read=!0),this.unreadCount=this.notifications.filter(e=>!e.read).length,this.store.setState({notifications:this.notifications,unreadCount:this.unreadCount})}catch(i){console.error("Failed to mark notification as read:",i)}}async markAllAsRead(){try{await Promise.all(this.notifications.filter(t=>!t.read).map(t=>this.markAsRead(t.id)))}catch(t){console.error("Failed to mark all notifications as read:",t)}}async deleteNotification(t){try{this.notifications=this.notifications.filter(i=>i.id!==t),this.store.setState({notifications:this.notifications})}catch(i){console.error("Failed to delete notification:",i)}}async deleteAllNotifications(){try{this.notifications=[],this.unreadCount=0,this.store.setState({notifications:[],unreadCount:0})}catch(t){console.error("Failed to delete all notifications:",t)}}sendPushNotification(t,i={}){!this.allowPushNotifications||!("Notification"in window)||Notification.permission==="granted"&&new Notification(t,{icon:"/assets/icon.png",tag:i.tag||"notification",badge:"/assets/badge.png",...i})}setupEventListeners(){window.realtimeClient&&window.realtimeClient.on("notification",t=>{this.addNotification(t)})}addNotification(t){this.notifications.unshift(t),this.unreadCount++,this.store.setState({notifications:this.notifications,unreadCount:this.unreadCount}),this.sendPushNotification(t.title,{body:t.message,tag:t.id})}getNotifications(){return this.notifications}getUnreadCount(){return this.unreadCount}},r=class{constructor(t={}){this.container=t.container,this.manager=t.manager,this.store=window.appStore,this.store.watch("unreadCount",i=>this.updateBadge(i)),this.render(),this.setupEventListeners()}render(){if(!this.container)return;let t=this.store.getState().unreadCount;this.container.innerHTML=`
      <button class="notification-bell" title="Notifications">
        ??
        ${t>0?`<span class="notification-badge">${Math.min(t,99)}${t>99?"+":""}</span>`:""}
      </button>
    `,this.setupEventListeners()}updateBadge(t){var e;let i=(e=this.container)==null?void 0:e.querySelector(".notification-badge");i&&(t>0?(i.textContent=`${Math.min(t,99)}${t>99?"+":""}`,i.style.display="block"):i.style.display="none")}setupEventListeners(){var i;let t=(i=this.container)==null?void 0:i.querySelector(".notification-bell");t&&t.addEventListener("click",()=>this.openPanel())}openPanel(){new a({manager:this.manager}).show()}injectStyles(){if(document.getElementById("notification-bell-styles"))return;let t=`
      .notification-bell {
        position: relative;
        background: none;
        border: none;
        font-size: 1.5rem;
        cursor: pointer;
        padding: 0.5rem;
        transition: transform 0.3s;
      }

      .notification-bell:hover {
        transform: scale(1.1);
      }

      .notification-badge {
        position: absolute;
        top: 0;
        right: 0;
        background: #ff4444;
        color: white;
        border-radius: 50%;
        width: 20px;
        height: 20px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 0.75rem;
        font-weight: bold;
      }
    `,i=document.createElement("style");i.id="notification-bell-styles",i.textContent=t,document.head.appendChild(i)}},a=class{constructor(t={}){this.manager=t.manager,this.store=window.appStore}show(){new window.Modal({title:"Notifications",content:this.renderContent(),className:"modal-notifications"}).open()}renderContent(){let t=this.store.getState().notifications||[];return t.length===0?'<p class="empty-state">No notifications</p>':`
      <div class="notifications-list">
        <button class="btn btn-sm btn-secondary" onclick="window.notificationManager.markAllAsRead()">
          Mark all as read
        </button>
        ${t.map(i=>this.renderNotification(i)).join("")}
        <button class="btn btn-sm btn-danger" onclick="window.notificationManager.deleteAllNotifications()">
          Clear all
        </button>
      </div>
    `}renderNotification(t){return`
      <div class="notification-item ${t.read?"read":"unread"}">
        <div class="notification-content">
          <h4>${t.title||"Notification"}</h4>
          <p>${t.message}</p>
          <span class="notification-time">${window.Utils.formatTime(t.createdAt)}</span>
        </div>
        <div class="notification-actions">
          ${t.read?"":`
            <button class="icon-btn" onclick="window.notificationManager.markAsRead('${t.id}')" title="Mark as read">
              ?
            </button>
          `}
          <button class="icon-btn" onclick="window.notificationManager.deleteNotification('${t.id}')" title="Delete">
            ?
          </button>
        </div>
      </div>
    `}},n={MATCH:"match",MESSAGE:"message",LIKE:"like",COMMENT:"comment",FOLLOW:"follow",PROMOTION:"promotion",SYSTEM:"system"},c=class{static createMatch(t,i){return{type:n.MATCH,title:"It's a Match! ??",message:`You matched with ${i}`,link:`/pages/chat.html?match=${t}`,icon:"??",priority:"high"}}static createMessage(t,i,e){return{type:n.MESSAGE,title:"New Message",message:`${i}: ${e}`,link:`/pages/chat.html?match=${t}`,icon:"??",priority:"high"}}static createLike(t,i){return{type:n.LIKE,title:"Someone Liked You ??",message:`${i} liked your profile`,link:`/pages/profile-details.html?user=${t}`,icon:"??",priority:"medium"}}static createComment(t,i,e){return{type:n.COMMENT,title:"New Comment",message:`${i} commented: ${e}`,link:`/pages/moments.html?post=${t}`,icon:"??",priority:"medium"}}static createPromotion(t,i,e){return{type:n.PROMOTION,title:t,message:i,code:e,icon:"??",priority:"low"}}static createSystem(t,i){return{type:n.SYSTEM,title:t,message:i,icon:"??",priority:"low"}}};window.NotificationManager=o;window.NotificationBell=r;window.NotificationPanel=a;window.NotificationType=n;window.NotificationFactory=c;window.notificationManager=new o;})();
//# sourceMappingURL=notifications.js.map
