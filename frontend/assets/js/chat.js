// Replace with actual user/match IDs from your app logic
const userId = localStorage.getItem('userId');
const matchId = localStorage.getItem('matchId');
const socket = io('http://localhost:3000');
socket.emit('join', { userId, matchId });
socket.on('message', ({ from, text }) => {
    const chatWindow = document.getElementById('chatWindow');
    const msgDiv = document.createElement('div');
    msgDiv.textContent = (from === userId ? 'You: ' : 'Match: ') + text;
    msgDiv.className = 'mb-2';
    chatWindow.appendChild(msgDiv);
    chatWindow.scrollTop = chatWindow.scrollHeight;
});
// Load chat history
socket.on('history', (messages) => {
    const chatWindow = document.getElementById('chatWindow');
    chatWindow.innerHTML = '';
    messages.forEach(msg => {
        const msgDiv = document.createElement('div');
        msgDiv.textContent = (msg.from === userId ? 'You: ' : 'Match: ') + msg.text;
        msgDiv.className = 'mb-2';
        chatWindow.appendChild(msgDiv);
    });
    chatWindow.scrollTop = chatWindow.scrollHeight;
});
// Typing indicator
socket.on('typing', ({ from }) => {
    const chatWindow = document.getElementById('chatWindow');
    let typingDiv = document.getElementById('typing-indicator');
    if (!typingDiv) {
        typingDiv = document.createElement('div');
        typingDiv.id = 'typing-indicator';
        typingDiv.className = 'text-xs text-gray-400 mb-2';
        chatWindow.appendChild(typingDiv);
    }
    typingDiv.textContent = 'Match is typing...';
    setTimeout(() => { typingDiv.textContent = ''; }, 1500);
});
// Read receipts
socket.on('read', ({ from }) => {
    // Optionally show read status in UI
});

document.getElementById('chatForm').addEventListener('submit', function(e) {
    e.preventDefault();
    const chatInput = document.getElementById('chatInput');
    const text = chatInput.value;
    if (text.trim() !== '') {
        socket.emit('message', { from: userId, to: matchId, text });
        try { if (window.MeengleAnalytics && typeof window.MeengleAnalytics.messageSent === 'function') window.MeengleAnalytics.messageSent(userId, matchId, text, false); } catch(e){}
        chatInput.value = '';
    }
});

document.getElementById('chatInput').addEventListener('input', function() {
    socket.emit('typing', { from: userId, to: matchId });
});
