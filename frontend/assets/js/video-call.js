// Video Call Component - WebRTC Integration
class VideoCall {
  constructor(options = {}) {
    this.matchId = options.matchId;
    this.userId = options.userId;
    this.realtimeClient = window.realtimeClient;
    this.localStream = null;
    this.remoteStream = null;
    this.peerConnection = null;
    this.callState = 'idle'; // idle, ringing, active, ended
    this.iceCandidates = [];

    this.setupPeerConnection();
    this.setupEventListeners();
  }

  async setupPeerConnection() {
    const configuration = {
      iceServers: [
        { urls: 'stun:stun.l.google.com:19302' },
        { urls: 'stun:stun1.l.google.com:19302' },
        { urls: 'stun:stun2.l.google.com:19302' }
      ]
    };

    this.peerConnection = new RTCPeerConnection(configuration);

    // Handle ICE candidates
    this.peerConnection.addEventListener('icecandidate', (event) => {
      if (event.candidate) {
        this.realtimeClient?.socket?.emit('ice-candidate', {
          to: this.matchId,
          candidate: event.candidate
        });
      }
    });

    // Handle remote stream
    this.peerConnection.addEventListener('track', (event) => {
      this.remoteStream = event.streams[0];
      this.handleRemoteStream(event.track);
    });

    // Connection state changes
    this.peerConnection.addEventListener('connectionstatechange', () => {
      this.handleConnectionStateChange();
    });
  }

  async startCall() {
    try {
      this.callState = 'ringing';

      // Get local media
      this.localStream = await navigator.mediaDevices.getUserMedia({
        video: { width: { ideal: 1280 }, height: { ideal: 720 } },
        audio: true
      });

      // Add local tracks to peer connection
      this.localStream.getTracks().forEach(track => {
        this.peerConnection.addTrack(track, this.localStream);
      });

      // Create offer
      const offer = await this.peerConnection.createOffer();
      await this.peerConnection.setLocalDescription(offer);

      // Send offer to remote peer
      this.realtimeClient?.socket?.emit('call-offer', {
        to: this.matchId,
        offer: offer
      });

      this.displayLocalVideo(this.localStream);
    } catch (error) {
      console.error('Failed to start call:', error);
      this.handleCallError(error);
    }
  }

  async handleCallOffer(offer) {
    try {
      this.callState = 'ringing';

      // Get local media if not already obtained
      if (!this.localStream) {
        this.localStream = await navigator.mediaDevices.getUserMedia({
          video: { width: { ideal: 1280 }, height: { ideal: 720 } },
          audio: true
        });

        this.localStream.getTracks().forEach(track => {
          this.peerConnection.addTrack(track, this.localStream);
        });

        this.displayLocalVideo(this.localStream);
      }

      // Set remote description
      await this.peerConnection.setRemoteDescription(new RTCSessionDescription(offer));

      // Create answer
      const answer = await this.peerConnection.createAnswer();
      await this.peerConnection.setLocalDescription(answer);

      // Send answer
      this.realtimeClient?.socket?.emit('call-answer', {
        to: this.matchId,
        answer: answer
      });

      this.showCallUI('incoming');
    } catch (error) {
      console.error('Failed to handle offer:', error);
    }
  }

  async handleCallAnswer(answer) {
    try {
      await this.peerConnection.setRemoteDescription(
        new RTCSessionDescription(answer)
      );
      this.callState = 'active';
      this.showCallUI('active');
    } catch (error) {
      console.error('Failed to handle answer:', error);
    }
  }

  async handleIceCandidate(candidate) {
    try {
      if (candidate) {
        await this.peerConnection.addIceCandidate(
          new RTCIceCandidate(candidate)
        );
      }
    } catch (error) {
      console.error('Failed to add ICE candidate:', error);
    }
  }

  handleRemoteStream(track) {
    // Update remote video element
    const remoteVideo = document.getElementById('remote-video');
    if (remoteVideo && this.remoteStream) {
      remoteVideo.srcObject = this.remoteStream;
    }
  }

  handleConnectionStateChange() {
    const state = this.peerConnection.connectionState;

    switch (state) {
      case 'connected':
        this.callState = 'active';
        console.log('Call connected');
        break;
      case 'disconnected':
        console.log('Call disconnected');
        break;
      case 'failed':
        this.handleCallError(new Error('Connection failed'));
        break;
      case 'closed':
        this.handleCallEnded();
        break;
    }
  }

  displayLocalVideo(stream) {
    const localVideo = document.getElementById('local-video');
    if (localVideo) {
      localVideo.srcObject = stream;
    }
  }

  toggleAudio(enabled) {
    if (this.localStream) {
      this.localStream.getAudioTracks().forEach(track => {
        track.enabled = enabled;
      });
    }
  }

  toggleVideo(enabled) {
    if (this.localStream) {
      this.localStream.getVideoTracks().forEach(track => {
        track.enabled = enabled;
      });
    }
  }

  async endCall() {
    this.callState = 'ended';

    // Stop local tracks
    if (this.localStream) {
      this.localStream.getTracks().forEach(track => track.stop());
    }

    // Close peer connection
    if (this.peerConnection) {
      this.peerConnection.close();
    }

    // Notify remote peer
    this.realtimeClient?.socket?.emit('call-end', { to: this.matchId });

    this.handleCallEnded();
  }

  handleCallError(error) {
    console.error('Call error:', error);
    this.endCall();
    window.Utils?.showToast('Call failed: ' + error.message, 3000, 'error');
  }

  handleCallEnded() {
    this.callState = 'idle';
    window.Utils?.showToast('Call ended', 2000, 'info');
    this.closeCallUI();
  }

  setupEventListeners() {
    if (this.realtimeClient?.socket) {
      this.realtimeClient.socket.on('call-offer', (data) => {
        this.handleCallOffer(data.offer);
      });

      this.realtimeClient.socket.on('call-answer', (data) => {
        this.handleCallAnswer(data.answer);
      });

      this.realtimeClient.socket.on('ice-candidate', (data) => {
        this.handleIceCandidate(data.candidate);
      });

      this.realtimeClient.socket.on('call-end', () => {
        this.handleCallEnded();
      });
    }
  }

  showCallUI(state) {
    const callUI = document.createElement('div');
    callUI.className = 'video-call-ui';
    callUI.innerHTML = `
      <div class="call-container">
        <div class="video-wrapper">
          <video id="remote-video" autoplay playsinline></video>
          <div class="local-video-container">
            <video id="local-video" autoplay playsinline muted></video>
          </div>
        </div>
        <div class="call-controls">
          <button class="call-btn call-btn-audio" data-action="toggle-audio" title="Toggle Audio">
            ??
          </button>
          <button class="call-btn call-btn-video" data-action="toggle-video" title="Toggle Video">
            ??
          </button>
          <button class="call-btn call-btn-end" data-action="end-call" title="End Call">
            ??
          </button>
          <button class="call-btn call-btn-fullscreen" data-action="fullscreen" title="Fullscreen">
            ?
          </button>
        </div>
        <div class="call-info">
          <span class="call-duration">00:00</span>
        </div>
      </div>
    `;

    document.body.appendChild(callUI);

    // Setup control buttons
    callUI.querySelector('[data-action="toggle-audio"]').addEventListener('click', () => {
      const enabled = !this.localStream?.getAudioTracks()[0]?.enabled;
      this.toggleAudio(enabled);
      callUI.querySelector('[data-action="toggle-audio"]').classList.toggle('disabled');
    });

    callUI.querySelector('[data-action="toggle-video"]').addEventListener('click', () => {
      const enabled = !this.localStream?.getVideoTracks()[0]?.enabled;
      this.toggleVideo(enabled);
      callUI.querySelector('[data-action="toggle-video"]').classList.toggle('disabled');
    });

    callUI.querySelector('[data-action="end-call"]').addEventListener('click', () => {
      this.endCall();
    });

    callUI.querySelector('[data-action="fullscreen"]').addEventListener('click', () => {
      const video = callUI.querySelector('#remote-video');
      if (video.requestFullscreen) {
        video.requestFullscreen();
      }
    });

    // Start call duration timer
    let seconds = 0;
    setInterval(() => {
      if (this.callState === 'active') {
        seconds++;
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        const secs = seconds % 60;
        callUI.querySelector('.call-duration').textContent = 
          `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
      }
    }, 1000);

    this.injectStyles();
  }

  closeCallUI() {
    const callUI = document.querySelector('.video-call-ui');
    if (callUI) {
      callUI.style.animation = 'fadeOut 0.3s';
      setTimeout(() => callUI.remove(), 300);
    }
  }

  injectStyles() {
    if (document.getElementById('video-call-styles')) return;

    const styles = `
      .video-call-ui {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: #000;
        z-index: 10000;
        display: flex;
        align-items: center;
        justify-content: center;
        animation: fadeIn 0.3s;
      }

      .call-container {
        width: 100%;
        height: 100%;
        display: flex;
        flex-direction: column;
        position: relative;
      }

      .video-wrapper {
        flex: 1;
        position: relative;
        overflow: hidden;
      }

      #remote-video {
        width: 100%;
        height: 100%;
        object-fit: cover;
      }

      .local-video-container {
        position: absolute;
        bottom: 1rem;
        right: 1rem;
        width: 150px;
        height: 200px;
        border-radius: 8px;
        overflow: hidden;
        border: 3px solid white;
        background: #000;
      }

      #local-video {
        width: 100%;
        height: 100%;
        object-fit: cover;
        transform: scaleX(-1);
      }

      .call-controls {
        position: absolute;
        bottom: 2rem;
        left: 50%;
        transform: translateX(-50%);
        display: flex;
        gap: 1rem;
        z-index: 100;
      }

      .call-btn {
        width: 50px;
        height: 50px;
        border-radius: 50%;
        border: none;
        font-size: 1.5rem;
        cursor: pointer;
        transition: all 0.3s;
        background: rgba(255, 255, 255, 0.2);
        color: white;
      }

      .call-btn:hover {
        background: rgba(255, 255, 255, 0.3);
        transform: scale(1.1);
      }

      .call-btn-end {
        background: #ff4444;
      }

      .call-btn-end:hover {
        background: #ff0000;
      }

      .call-btn.disabled {
        opacity: 0.5;
      }

      .call-info {
        position: absolute;
        top: 1rem;
        left: 1rem;
        color: white;
        font-size: 1.2rem;
        font-weight: bold;
      }

      @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
      }

      @keyframes fadeOut {
        from { opacity: 1; }
        to { opacity: 0; }
      }
    `;

    const style = document.createElement('style');
    style.id = 'video-call-styles';
    style.textContent = styles;
    document.head.appendChild(style);
  }
}

// Export video call component
window.VideoCall = VideoCall;

export { VideoCall };
