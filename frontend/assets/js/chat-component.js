// Chat Component - Real-time messaging interface
class ChatComponent {
  constructor(matchId) {
    this.matchId = matchId;
    this.apiClient = window.apiClient;
    this.realtimeClient = window.realtimeClient;
    this.store = window.appStore;
    this.messages = [];
    this.currentMatch = null;
    this.isTyping = false;
    this.typingTimeout = null;
    this.init();
  }

  async init() {
    await this.loadMatch();
    await this.loadMessages();
    this.setupRealtimeListeners();
    this.setupEventListeners();
    this.render();
  }

  async loadMatch() {
    try {
      const state = this.store.getState();
      this.currentMatch = state.matches?.find(m => m._id === this.matchId);
      
      if (!this.currentMatch) {
        // Try to load from API
        const matches = await this.apiClient.getMatches();
        this.currentMatch = matches.find(m => m._id === this.matchId);
      }
    } catch (error) {
      console.error('Failed to load match:', error);
    }
  }

  async loadMessages() {
    try {
      const conversation = await this.apiClient.getConversation(this.matchId, 50);
      this.messages = conversation.messages || [];
      
      // Mark messages as read
      await this.apiClient.markMessagesAsRead(this.matchId);
    } catch (error) {
      console.error('Failed to load messages:', error);
    }
  }

  setupRealtimeListeners() {
    if (!this.realtimeClient) return;

    // Join the chat room
    this.realtimeClient.joinChatRoom(this.matchId);

    // Listen for new messages
    this.realtimeClient.on('message-received', (data) => {
      if (data.matchId === this.matchId || data.userId === this.currentMatch?.id) {
        this.addMessage({
          userId: data.userId,
          message: data.message,
          timestamp: new Date(data.timestamp),
          read: true
        });
      }
    });

    // Listen for typing indicators
    this.realtimeClient.on('user-typing', (data) => {
      if (data.userId !== this.store.getState().user?.id) {
        this.showTypingIndicator();
      }
    });

    this.realtimeClient.on('user-stop-typing', (data) => {
      this.hideTypingIndicator();
    });
  }

  setupEventListeners() {
    const container = document.getElementById('chat-container');
    if (!container) return;

    const messageInput = container.querySelector('[data-input="message"]');
    const sendBtn = container.querySelector('[data-action="send"]');
    const attachBtn = container.querySelector('[data-action="attach"]');

    if (messageInput) {
      messageInput.addEventListener('input', (e) => this.handleTyping(e));
      messageInput.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
          e.preventDefault();
          this.sendMessage();
        }
      });
    }

    if (sendBtn) {
      sendBtn.addEventListener('click', () => this.sendMessage());
    }

    if (attachBtn) {
      attachBtn.addEventListener('click', () => this.attachFile());
    }
  }

  handleTyping(e) {
    this.realtimeClient?.startTyping(this.matchId);

    clearTimeout(this.typingTimeout);
    this.typingTimeout = setTimeout(() => {
      this.realtimeClient?.stopTyping(this.matchId);
    }, 3000);
  }

  async sendMessage() {
    const container = document.getElementById('chat-container');
    const input = container?.querySelector('[data-input="message"]');
    
    if (!input || !input.value.trim()) return;

    const messageText = input.value.trim();
    input.value = '';

    try {
      const state = this.store.getState();
      
      // Add to local messages immediately
      this.addMessage({
        userId: state.user?.id,
        message: messageText,
        timestamp: new Date(),
        read: false,
        isOwn: true
      });

      // Send via API
      await this.apiClient.sendMessage(this.matchId, messageText);

      // Send via socket
      this.realtimeClient?.sendMessage(this.matchId, messageText);
    } catch (error) {
      console.error('Failed to send message:', error);
      window.Utils.showToast('Failed to send message', 3000, 'error');
    }
  }

  async attachFile() {
    const input = document.createElement('input');
    input.type = 'file';
    input.onchange = async (e) => {
      const file = e.target.files[0];
      if (!file) return;

      try {
        const reader = new FileReader();
        reader.onload = async (event) => {
          const base64 = event.target.result;
          const result = await this.apiClient.uploadMedia(
            file.name,
            base64,
            file.type.startsWith('image') ? 'image' : 'file',
            file.size
          );

          await this.sendMessage(`[File: ${file.name}] ${result.media.url}`);
        };
        reader.readAsDataURL(file);
      } catch (error) {
        console.error('Failed to upload file:', error);
        window.Utils.showToast('Failed to upload file', 3000, 'error');
      }
    };
    input.click();
  }

  addMessage(message) {
    this.messages.push(message);
    this.render();
    this.scrollToBottom();
  }

  showTypingIndicator() {
    const container = document.getElementById('chat-container');
    if (!container) return;

    const existing = container.querySelector('.typing-indicator');
    if (existing) return;

    const indicator = document.createElement('div');
    indicator.className = 'typing-indicator';
    indicator.innerHTML = '<span>?</span><span>?</span><span>?</span>';
    
    const messagesArea = container.querySelector('[data-area="messages"]');
    if (messagesArea) {
      messagesArea.appendChild(indicator);
      this.scrollToBottom();
    }
  }

  hideTypingIndicator() {
    const container = document.getElementById('chat-container');
    const indicator = container?.querySelector('.typing-indicator');
    if (indicator) indicator.remove();
  }

  scrollToBottom() {
    const container = document.getElementById('chat-container');
    const messagesArea = container?.querySelector('[data-area="messages"]');
    if (messagesArea) {
      messagesArea.scrollTop = messagesArea.scrollHeight;
    }
  }

  render() {
    const container = document.getElementById('chat-container');
    if (!container) return;

    const state = this.store.getState();
    const currentUser = state.user;

    let html = `
      <div class="chat-header">
        <div class="match-info">
          <img src="${this.currentMatch?.photos?.[0] || '/assets/default-avatar.png'}" alt="${this.currentMatch?.name}">
          <div class="match-details">
            <h3>${this.currentMatch?.name || 'Chat'}</h3>
            <span class="status ${state.userStatus?.[this.currentMatch?.id] === 'online' ? 'online' : 'offline'}">
              ${state.userStatus?.[this.currentMatch?.id] === 'online' ? '? Online' : '? Offline'}
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
        ${this.messages.map((msg, idx) => {
          const isOwn = msg.userId === currentUser?.id || msg.isOwn;
          return `
            <div class="message ${isOwn ? 'own' : 'other'}">
              <div class="message-content">
                ${msg.message}
              </div>
              <span class="message-time">${window.Utils.formatTime(msg.timestamp)}</span>
            </div>
          `;
        }).join('')}
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
    `;

    container.innerHTML = html;
    this.setupEventListeners();
    this.scrollToBottom();
  }
}

// Initialize chat when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  const params = new URLSearchParams(window.location.search);
  const matchId = params.get('match');

  if (matchId && window.apiClient && window.appStore.getState().isAuthenticated) {
    new ChatComponent(matchId);
  } else {
    window.location.href = '/pages/home.html';
  }
});

export { ChatComponent };
