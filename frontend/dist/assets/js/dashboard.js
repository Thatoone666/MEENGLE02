(()=>{var e=class{constructor(){this.apiClient=window.apiClient,this.realtimeClient=window.realtimeClient,this.store=window.appStore,this.currentTab="discover",this.init()}async init(){this.setupEventListeners(),await this.loadInitialData(),this.render()}setupEventListeners(){document.addEventListener("click",t=>{t.target.matches("[data-tab]")&&this.switchTab(t.target.dataset.tab),t.target.matches("[data-action]")&&this.handleAction(t.target.dataset.action,t.target.dataset.id)}),this.realtimeClient&&this.realtimeClient.isConnected()&&(this.realtimeClient.on("user-status-changed",t=>this.handleStatusChange(t)),this.realtimeClient.on("message-received",t=>this.handleNewMessage(t)))}async loadInitialData(){try{this.store.setState({loading:!0});let t=await this.apiClient.getProfile();this.store.setState({user:t,loading:!1}),await this.loadMatches(),await this.loadNotifications()}catch(t){console.error("Failed to load dashboard:",t),this.store.setState({error:t.message,loading:!1})}}async loadMatches(){try{let t=await this.apiClient.getMatches();this.store.setState({matches:t})}catch(t){console.error("Failed to load matches:",t)}}async loadNotifications(){try{let t=await this.apiClient.getNotifications(10);this.store.setState({notifications:t})}catch(t){console.error("Failed to load notifications:",t)}}switchTab(t){this.currentTab=t,this.render()}async handleAction(t,s){switch(t){case"open-chat":this.openChat(s);break;case"like-user":await this.likeUser(s);break;case"pass-user":await this.passUser(s);break;case"view-profile":this.viewProfile(s);break;case"logout":await this.logout();break}}async likeUser(t){try{(await this.apiClient.likeUser(t)).mutualMatch?(window.Utils.showToast("It's a match! ??",5e3,"success"),await this.loadMatches()):window.Utils.showToast("Like sent!",2e3,"info"),this.render()}catch{window.Utils.showToast("Failed to like user",3e3,"error")}}async passUser(t){try{await this.apiClient.passUser(t),window.Utils.showToast("Passed",1500,"info"),this.render()}catch{window.Utils.showToast("Failed to pass user",3e3,"error")}}openChat(t){window.location.href=`/pages/chat.html?match=${t}`}viewProfile(t){window.location.href=`/pages/profile-details.html?user=${t}`}handleStatusChange(t){let{userId:s,status:a}=t;this.store.setState({userStatus:{...this.store.getState().userStatus,[s]:a}}),this.render()}handleNewMessage(t){let s=this.store.getState();this.store.setState({unreadCount:s.unreadCount+1}),window.Utils.showNotification("New Message",{body:t.message.substring(0,50),icon:"/assets/icon.png"})}async logout(){confirm("Are you sure you want to logout?")&&(await this.store.dispatch(window.authActions.logout,{}),window.location.href="/pages/login.html")}render(){let t=this.store.getState(),s=document.getElementById("app");if(!s)return;let a=this.renderHeader(t);switch(this.currentTab){case"discover":a+=this.renderDiscoverTab(t);break;case"matches":a+=this.renderMatchesTab(t);break;case"messages":a+=this.renderMessagesTab(t);break;case"notifications":a+=this.renderNotificationsTab(t);break;case"profile":a+=this.renderProfileTab(t);break}s.innerHTML=a}renderHeader(t){return`
      <header class="dashboard-header">
        <div class="header-content">
          <h1>Meengle</h1>
          <div class="header-actions">
            <button class="icon-btn" title="Messages">
              <span class="notification-badge">${t.unreadCount}</span>
              ??
            </button>
            <button class="icon-btn" title="Settings" data-tab="profile">??</button>
            <button class="icon-btn" title="Logout" data-action="logout">??</button>
          </div>
        </div>
        <nav class="tabs">
          <button class="tab ${this.currentTab==="discover"?"active":""}" data-tab="discover">
            Discover
          </button>
          <button class="tab ${this.currentTab==="matches"?"active":""}" data-tab="matches">
            Matches (${t.matches.length})
          </button>
          <button class="tab ${this.currentTab==="messages"?"active":""}" data-tab="messages">
            Messages
          </button>
          <button class="tab ${this.currentTab==="notifications"?"active":""}" data-tab="notifications">
            Notifications
          </button>
        </nav>
      </header>
    `}renderDiscoverTab(t){return t.loading?'<div class="loading">Loading matches...</div>':!t.matches||t.matches.length===0?'<div class="empty-state">No matches available. Check back soon!</div>':`
      <section class="discover-section">
        <div class="match-cards">
          ${t.matches.map(s=>`
            <div class="match-card">
              <div class="card-image">
                <img src="${s.photos?.[0]||"/assets/default-avatar.png"}" alt="${s.name}">
              </div>
              <div class="card-info">
                <h3>${s.name}, ${s.age||"?"}</h3>
                <p class="card-bio">${s.bio||"No bio"}</p>
                <p class="card-location">?? ${s.location?.city||"Unknown"}</p>
              </div>
              <div class="card-actions">
                <button class="btn btn-secondary" data-action="pass-user" data-id="${s._id}">
                  Pass
                </button>
                <button class="btn btn-primary" data-action="like-user" data-id="${s._id}">
                  Like ??
                </button>
              </div>
            </div>
          `).join("")}
        </div>
      </section>
    `}renderMatchesTab(t){return t.matches.length===0?'<div class="empty-state">You have no matches yet. Like some users!</div>':`
      <section class="matches-section">
        <div class="matches-grid">
          ${t.matches.map(s=>`
            <div class="match-item" data-id="${s._id}">
              <div class="match-thumbnail">
                <img src="${s.photos?.[0]||"/assets/default-avatar.png"}" alt="${s.name}">
                <span class="match-status ${t.userStatus?.[s._id]==="online"?"online":"offline"}"></span>
              </div>
              <div class="match-details">
                <h4>${s.name}, ${s.age||"?"}</h4>
                <button class="btn btn-small" data-action="open-chat" data-id="${s._id}">
                  Chat
                </button>
              </div>
            </div>
          `).join("")}
        </div>
      </section>
    `}renderMessagesTab(t){return!t.matches||t.matches.length===0?'<div class="empty-state">No messages yet.</div>':`
      <section class="messages-section">
        <div class="conversations-list">
          ${t.matches.map(s=>`
            <div class="conversation-item" data-action="open-chat" data-id="${s._id}">
              <img src="${s.photos?.[0]||"/assets/default-avatar.png"}" alt="${s.name}">
              <div class="conversation-info">
                <h4>${s.name}</h4>
                <p class="last-message">Tap to open chat...</p>
              </div>
            </div>
          `).join("")}
        </div>
      </section>
    `}renderNotificationsTab(t){return!t.notifications||t.notifications.length===0?'<div class="empty-state">No notifications.</div>':`
      <section class="notifications-section">
        <div class="notifications-list">
          ${t.notifications.map(s=>`
            <div class="notification-item">
              <h4>${s.title||"Notification"}</h4>
              <p>${s.message}</p>
              <span class="time">${window.Utils.formatTime(s.createdAt)}</span>
            </div>
          `).join("")}
        </div>
      </section>
    `}renderProfileTab(t){return`
      <section class="profile-section">
        <div class="profile-card">
          <img src="${t.user?.photos?.[0]||"/assets/default-avatar.png"}" alt="Profile">
          <h2>${t.user?.name||"User"}</h2>
          <p>${t.user?.bio||"No bio"}</p>
          <button class="btn btn-primary" onclick="window.location.href='/pages/profile-details.html'">
            Edit Profile
          </button>
          <button class="btn btn-secondary" onclick="window.location.href='/pages/settings.html'">
            Settings
          </button>
        </div>
      </section>
    `}};document.addEventListener("DOMContentLoaded",()=>{window.apiClient&&window.appStore.getState().isAuthenticated?new e:window.location.href="/pages/login.html"});})();
//# sourceMappingURL=dashboard.js.map
