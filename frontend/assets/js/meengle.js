// Example: Vanta.js, AOS, Feather, premium/diamond features
AOS.init({ duration: 1000, once: true });
feather.replace();
if (typeof VANTA !== 'undefined') {
    VANTA.NET({
        el: "#vanta-bg",
        mouseControls: true,
        touchControls: true,
        minHeight: 200.00,
        minWidth: 200.00,
        scale: 1.0,
        color: 0xff6b6b,
        backgroundColor: 0xf7fafc
    });
}
// Premium/Diamond feature: show exclusive content
if (localStorage.getItem('subscription') === 'diamond') {
    document.querySelectorAll('.diamond-only').forEach(el => el.style.display = 'block');
}
if (localStorage.getItem('subscription') === 'premium') {
    document.querySelectorAll('.premium-only').forEach(el => el.style.display = 'block');
}

document.addEventListener('DOMContentLoaded', () => {
    const profileId = new URLSearchParams(window.location.search).get('id');
    const API_BASE = window.API_BASE || '';
    const token = localStorage.getItem('token');

    const fetchProfile = async (id, authToken) => {
        try {
            const res = await fetch(`${API_BASE}/api/profile/${id}`, {
                headers: { 'Authorization': `Bearer ${authToken}` }
            });
            if (!res.ok) throw new Error('Could not fetch profile');
            
            const user = await res.json();
            displayProfile(user);
        } catch (error) {
            console.error('Error fetching profile:', error);
        }
    };

    if (profileId && token) {
        fetchProfile(profileId, token);
    }

    const displayProfile = (user) => {
        // ... (code to display other profile details)

        const gameContainer = document.getElementById('two-truths-and-a-lie');
        if (user.twoTruthsAndALie && user.twoTruthsAndALie.lie) {
            const statements = [
                user.twoTruthsAndALie.truth1,
                user.twoTruthsAndALie.truth2,
                user.twoTruthsAndALie.lie
            ].sort(() => Math.random() - 0.5); // Shuffle the statements

            const statementElements = gameContainer.querySelectorAll('[data-statement]');
            statementElements.forEach((el, index) => {
                el.textContent = statements[index];
                el.addEventListener('click', () => {
                    const guessResult = document.getElementById('guess-result');
                    if (statements[index] === user.twoTruthsAndALie.lie) {
                        guessResult.textContent = "You found the lie!";
                        guessResult.className = 'mt-4 text-center font-bold text-green-500';
                    } else {
                        guessResult.textContent = "That's a truth! Try again.";
                        guessResult.className = 'mt-4 text-center font-bold text-red-500';
                    }
                    // Disable further clicks
                    statementElements.forEach(btn => btn.style.pointerEvents = 'none');
                });
            });
        } else {
            gameContainer.style.display = 'none';
        }
        // Add Like button to profile card
        const likeContainer = document.getElementById('profile-like-container');
        if (likeContainer) {
            likeContainer.innerHTML = `<button id="like-btn-${user._id}" class="px-4 py-2 bg-pink-500 text-white rounded">Like</button>`;
            const likeBtn = document.getElementById(`like-btn-${user._id}`);
            if (likeBtn) {
                likeBtn.addEventListener('click', async () => {
                    try {
                        if (window.MeengleLike) {
                            await window.MeengleLike(user._id, 'regular');
                        } else {
                            // fallback: POST directly
                            const token = localStorage.getItem('token');
                            await fetch(`/api/matches/like/${encodeURIComponent(user._id)}`, { method: 'POST', headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` }, body: JSON.stringify({ context: 'regular' }) });
                            try { if (window.MeengleAnalytics && typeof window.MeengleAnalytics.likeSent === 'function') window.MeengleAnalytics.likeSent(localStorage.getItem('userId'), user._id, 'regular'); } catch(e){}
                        }
                    } catch (e) { console.error('Like failed', e); }
                });
            }
        }
    };
});

// Like helper: call this function when liking a user from UI
window.MeengleLike = async function(targetUserId, context = 'regular') {
    const token = localStorage.getItem('token');
    const userId = localStorage.getItem('userId');
    try {
        const res = await fetch(`/api/matches/like/${encodeURIComponent(targetUserId)}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
            body: JSON.stringify({ context })
        });
        if (!res.ok) throw new Error('Like failed');
        try { if (window.MeengleAnalytics && typeof window.MeengleAnalytics.likeSent === 'function') window.MeengleAnalytics.likeSent(userId, targetUserId, context); } catch (e) {}
        return await res.json();
    } catch (e) { console.error('Like error', e); throw e; }
};
