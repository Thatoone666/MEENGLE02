(()=>{var n=class{constructor(t={}){this.matchId=t.matchId,this.userId=t.userId,this.realtimeClient=window.realtimeClient,this.localStream=null,this.remoteStream=null,this.peerConnection=null,this.callState="idle",this.iceCandidates=[],this.setupPeerConnection(),this.setupEventListeners()}async setupPeerConnection(){let t={iceServers:[{urls:"stun:stun.l.google.com:19302"},{urls:"stun:stun1.l.google.com:19302"},{urls:"stun:stun2.l.google.com:19302"}]};this.peerConnection=new RTCPeerConnection(t),this.peerConnection.addEventListener("icecandidate",e=>{var a,i;e.candidate&&((i=(a=this.realtimeClient)==null?void 0:a.socket)==null||i.emit("ice-candidate",{to:this.matchId,candidate:e.candidate}))}),this.peerConnection.addEventListener("track",e=>{this.remoteStream=e.streams[0],this.handleRemoteStream(e.track)}),this.peerConnection.addEventListener("connectionstatechange",()=>{this.handleConnectionStateChange()})}async startCall(){var t,e;try{this.callState="ringing",this.localStream=await navigator.mediaDevices.getUserMedia({video:{width:{ideal:1280},height:{ideal:720}},audio:!0}),this.localStream.getTracks().forEach(i=>{this.peerConnection.addTrack(i,this.localStream)});let a=await this.peerConnection.createOffer();await this.peerConnection.setLocalDescription(a),(e=(t=this.realtimeClient)==null?void 0:t.socket)==null||e.emit("call-offer",{to:this.matchId,offer:a}),this.displayLocalVideo(this.localStream)}catch(a){console.error("Failed to start call:",a),this.handleCallError(a)}}async handleCallOffer(t){var e,a;try{this.callState="ringing",this.localStream||(this.localStream=await navigator.mediaDevices.getUserMedia({video:{width:{ideal:1280},height:{ideal:720}},audio:!0}),this.localStream.getTracks().forEach(o=>{this.peerConnection.addTrack(o,this.localStream)}),this.displayLocalVideo(this.localStream)),await this.peerConnection.setRemoteDescription(new RTCSessionDescription(t));let i=await this.peerConnection.createAnswer();await this.peerConnection.setLocalDescription(i),(a=(e=this.realtimeClient)==null?void 0:e.socket)==null||a.emit("call-answer",{to:this.matchId,answer:i}),this.showCallUI("incoming")}catch(i){console.error("Failed to handle offer:",i)}}async handleCallAnswer(t){try{await this.peerConnection.setRemoteDescription(new RTCSessionDescription(t)),this.callState="active",this.showCallUI("active")}catch(e){console.error("Failed to handle answer:",e)}}async handleIceCandidate(t){try{t&&await this.peerConnection.addIceCandidate(new RTCIceCandidate(t))}catch(e){console.error("Failed to add ICE candidate:",e)}}handleRemoteStream(t){let e=document.getElementById("remote-video");e&&this.remoteStream&&(e.srcObject=this.remoteStream)}handleConnectionStateChange(){switch(this.peerConnection.connectionState){case"connected":this.callState="active",console.log("Call connected");break;case"disconnected":console.log("Call disconnected");break;case"failed":this.handleCallError(new Error("Connection failed"));break;case"closed":this.handleCallEnded();break}}displayLocalVideo(t){let e=document.getElementById("local-video");e&&(e.srcObject=t)}toggleAudio(t){this.localStream&&this.localStream.getAudioTracks().forEach(e=>{e.enabled=t})}toggleVideo(t){this.localStream&&this.localStream.getVideoTracks().forEach(e=>{e.enabled=t})}async endCall(){var t,e;this.callState="ended",this.localStream&&this.localStream.getTracks().forEach(a=>a.stop()),this.peerConnection&&this.peerConnection.close(),(e=(t=this.realtimeClient)==null?void 0:t.socket)==null||e.emit("call-end",{to:this.matchId}),this.handleCallEnded()}handleCallError(t){var e;console.error("Call error:",t),this.endCall(),(e=window.Utils)==null||e.showToast("Call failed: "+t.message,3e3,"error")}handleCallEnded(){var t;this.callState="idle",(t=window.Utils)==null||t.showToast("Call ended",2e3,"info"),this.closeCallUI()}setupEventListeners(){var t;(t=this.realtimeClient)!=null&&t.socket&&(this.realtimeClient.socket.on("call-offer",e=>{this.handleCallOffer(e.offer)}),this.realtimeClient.socket.on("call-answer",e=>{this.handleCallAnswer(e.answer)}),this.realtimeClient.socket.on("ice-candidate",e=>{this.handleIceCandidate(e.candidate)}),this.realtimeClient.socket.on("call-end",()=>{this.handleCallEnded()}))}showCallUI(t){let e=document.createElement("div");e.className="video-call-ui",e.innerHTML=`
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
    `,document.body.appendChild(e),e.querySelector('[data-action="toggle-audio"]').addEventListener("click",()=>{var o,l;let i=!((l=(o=this.localStream)==null?void 0:o.getAudioTracks()[0])!=null&&l.enabled);this.toggleAudio(i),e.querySelector('[data-action="toggle-audio"]').classList.toggle("disabled")}),e.querySelector('[data-action="toggle-video"]').addEventListener("click",()=>{var o,l;let i=!((l=(o=this.localStream)==null?void 0:o.getVideoTracks()[0])!=null&&l.enabled);this.toggleVideo(i),e.querySelector('[data-action="toggle-video"]').classList.toggle("disabled")}),e.querySelector('[data-action="end-call"]').addEventListener("click",()=>{this.endCall()}),e.querySelector('[data-action="fullscreen"]').addEventListener("click",()=>{let i=e.querySelector("#remote-video");i.requestFullscreen&&i.requestFullscreen()});let a=0;setInterval(()=>{if(this.callState==="active"){a++;let i=Math.floor(a/3600),o=Math.floor(a%3600/60),l=a%60;e.querySelector(".call-duration").textContent=`${String(i).padStart(2,"0")}:${String(o).padStart(2,"0")}:${String(l).padStart(2,"0")}`}},1e3),this.injectStyles()}closeCallUI(){let t=document.querySelector(".video-call-ui");t&&(t.style.animation="fadeOut 0.3s",setTimeout(()=>t.remove(),300))}injectStyles(){if(document.getElementById("video-call-styles"))return;let t=`
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
    `,e=document.createElement("style");e.id="video-call-styles",e.textContent=t,document.head.appendChild(e)}};window.VideoCall=n;})();
//# sourceMappingURL=video-call.js.map
