(()=>{var o=class{constructor(e={}){this.matchId=e.matchId,this.userId=e.userId,this.realtimeClient=window.realtimeClient,this.localStream=null,this.remoteStream=null,this.peerConnection=null,this.callState="idle",this.iceCandidates=[],this.setupPeerConnection(),this.setupEventListeners()}async setupPeerConnection(){let e={iceServers:[{urls:"stun:stun.l.google.com:19302"},{urls:"stun:stun1.l.google.com:19302"},{urls:"stun:stun2.l.google.com:19302"}]};this.peerConnection=new RTCPeerConnection(e),this.peerConnection.addEventListener("icecandidate",t=>{t.candidate&&this.realtimeClient?.socket?.emit("ice-candidate",{to:this.matchId,candidate:t.candidate})}),this.peerConnection.addEventListener("track",t=>{this.remoteStream=t.streams[0],this.handleRemoteStream(t.track)}),this.peerConnection.addEventListener("connectionstatechange",()=>{this.handleConnectionStateChange()})}async startCall(){try{this.callState="ringing",this.localStream=await navigator.mediaDevices.getUserMedia({video:{width:{ideal:1280},height:{ideal:720}},audio:!0}),this.localStream.getTracks().forEach(t=>{this.peerConnection.addTrack(t,this.localStream)});let e=await this.peerConnection.createOffer();await this.peerConnection.setLocalDescription(e),this.realtimeClient?.socket?.emit("call-offer",{to:this.matchId,offer:e}),this.displayLocalVideo(this.localStream)}catch(e){console.error("Failed to start call:",e),this.handleCallError(e)}}async handleCallOffer(e){try{this.callState="ringing",this.localStream||(this.localStream=await navigator.mediaDevices.getUserMedia({video:{width:{ideal:1280},height:{ideal:720}},audio:!0}),this.localStream.getTracks().forEach(i=>{this.peerConnection.addTrack(i,this.localStream)}),this.displayLocalVideo(this.localStream)),await this.peerConnection.setRemoteDescription(new RTCSessionDescription(e));let t=await this.peerConnection.createAnswer();await this.peerConnection.setLocalDescription(t),this.realtimeClient?.socket?.emit("call-answer",{to:this.matchId,answer:t}),this.showCallUI("incoming")}catch(t){console.error("Failed to handle offer:",t)}}async handleCallAnswer(e){try{await this.peerConnection.setRemoteDescription(new RTCSessionDescription(e)),this.callState="active",this.showCallUI("active")}catch(t){console.error("Failed to handle answer:",t)}}async handleIceCandidate(e){try{e&&await this.peerConnection.addIceCandidate(new RTCIceCandidate(e))}catch(t){console.error("Failed to add ICE candidate:",t)}}handleRemoteStream(e){let t=document.getElementById("remote-video");t&&this.remoteStream&&(t.srcObject=this.remoteStream)}handleConnectionStateChange(){switch(this.peerConnection.connectionState){case"connected":this.callState="active",console.log("Call connected");break;case"disconnected":console.log("Call disconnected");break;case"failed":this.handleCallError(new Error("Connection failed"));break;case"closed":this.handleCallEnded();break}}displayLocalVideo(e){let t=document.getElementById("local-video");t&&(t.srcObject=e)}toggleAudio(e){this.localStream&&this.localStream.getAudioTracks().forEach(t=>{t.enabled=e})}toggleVideo(e){this.localStream&&this.localStream.getVideoTracks().forEach(t=>{t.enabled=e})}async endCall(){this.callState="ended",this.localStream&&this.localStream.getTracks().forEach(e=>e.stop()),this.peerConnection&&this.peerConnection.close(),this.realtimeClient?.socket?.emit("call-end",{to:this.matchId}),this.handleCallEnded()}handleCallError(e){console.error("Call error:",e),this.endCall(),window.Utils?.showToast("Call failed: "+e.message,3e3,"error")}handleCallEnded(){this.callState="idle",window.Utils?.showToast("Call ended",2e3,"info"),this.closeCallUI()}setupEventListeners(){this.realtimeClient?.socket&&(this.realtimeClient.socket.on("call-offer",e=>{this.handleCallOffer(e.offer)}),this.realtimeClient.socket.on("call-answer",e=>{this.handleCallAnswer(e.answer)}),this.realtimeClient.socket.on("ice-candidate",e=>{this.handleIceCandidate(e.candidate)}),this.realtimeClient.socket.on("call-end",()=>{this.handleCallEnded()}))}showCallUI(e){let t=document.createElement("div");t.className="video-call-ui",t.innerHTML=`
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
    `,document.body.appendChild(t),t.querySelector('[data-action="toggle-audio"]').addEventListener("click",()=>{let a=!this.localStream?.getAudioTracks()[0]?.enabled;this.toggleAudio(a),t.querySelector('[data-action="toggle-audio"]').classList.toggle("disabled")}),t.querySelector('[data-action="toggle-video"]').addEventListener("click",()=>{let a=!this.localStream?.getVideoTracks()[0]?.enabled;this.toggleVideo(a),t.querySelector('[data-action="toggle-video"]').classList.toggle("disabled")}),t.querySelector('[data-action="end-call"]').addEventListener("click",()=>{this.endCall()}),t.querySelector('[data-action="fullscreen"]').addEventListener("click",()=>{let a=t.querySelector("#remote-video");a.requestFullscreen&&a.requestFullscreen()});let i=0;setInterval(()=>{if(this.callState==="active"){i++;let a=Math.floor(i/3600),l=Math.floor(i%3600/60),n=i%60;t.querySelector(".call-duration").textContent=`${String(a).padStart(2,"0")}:${String(l).padStart(2,"0")}:${String(n).padStart(2,"0")}`}},1e3),this.injectStyles()}closeCallUI(){let e=document.querySelector(".video-call-ui");e&&(e.style.animation="fadeOut 0.3s",setTimeout(()=>e.remove(),300))}injectStyles(){if(document.getElementById("video-call-styles"))return;let e=`
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
    `,t=document.createElement("style");t.id="video-call-styles",t.textContent=e,document.head.appendChild(t)}};window.VideoCall=o;})();
//# sourceMappingURL=video-call.js.map
