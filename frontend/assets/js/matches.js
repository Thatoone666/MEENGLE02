document.addEventListener('DOMContentLoaded', async () => {
    feather.replace();
    const matchesContainer = document.getElementById('matches-container');
    const token = localStorage.getItem('token');

    if (!token) {
        window.location.href = 'login.html';
        return;
    }

    try {
        const response = await fetch('/api/matches', {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });

        if (!response.ok) {
            throw new Error('Failed to fetch matches');
        }

        const matches = await response.json();
        matchesContainer.innerHTML = '';

        if (matches.length === 0) {
            matchesContainer.innerHTML = '<p class="col-span-full text-center text-gray-500">You have no matches yet. Keep swiping!</p>';
            return;
        }

        matches.forEach(match => {
            // Premium/Diamond feature: highlight premium matches
            const isPremium = match.subscription === 'diamond' || match.subscription === 'premium';
            const matchDiv = document.createElement('div');
            matchDiv.className = `bg-white rounded-lg shadow p-4 flex flex-col items-center ${isPremium ? 'border-2 border-yellow-400' : ''}`;
            matchDiv.innerHTML = `
                <img src="${match.profileImg || 'https://i.pravatar.cc/80'}" class="w-16 h-16 rounded-full mb-2">
                <span class="font-bold text-lg">${match.name}</span>
                ${isPremium ? '<span class="text-xs text-yellow-500 font-semibold mt-1">Premium</span>' : ''}
                <button id="chat-btn-${match._id}" class="mt-2 px-3 py-1 bg-pink-500 text-white rounded">Chat</button>
            `;
            matchesContainer.appendChild(matchDiv);
            // attach analytics handler
            const btn = document.getElementById(`chat-btn-${match._id}`);
            if (btn) {
                btn.addEventListener('click', (e) => {
                    try { if (window.MeengleAnalytics && typeof window.MeengleAnalytics.capture === 'function') window.MeengleAnalytics.capture('chat_opened', { matchId: match._id }); } catch(e){}
                    window.location.href = 'chat.html?matchId=' + match._id;
                });
            }
        });
    } catch (err) {
        matchesContainer.innerHTML = '<p class="col-span-full text-center text-red-500">Error loading matches.</p>';
    }
});
