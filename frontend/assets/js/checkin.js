document.addEventListener('DOMContentLoaded', () => {
    const checkinForm = document.getElementById('checkin-form');
    const locationInput = document.getElementById('location-input');
    const checkoutBtn = document.getElementById('checkout-btn');
    const usersContainer = document.getElementById('users-container');
    const token = localStorage.getItem('token');

    if (!token) {
        window.location.href = 'login.html';
        return;
    }

    let currentCheckIn = null;

    const fetchUsers = async (locationName) => {
        try {
            const res = await fetch(`http://localhost:3000/api/checkin/${encodeURIComponent(locationName)}`, {
                headers: { 'Authorization': `Bearer ${token}` }
            });
            if (!res.ok) throw new Error('Failed to fetch users');
            
            const users = await res.json();
            renderUsers(users);
        } catch (error) {
            console.error('Error fetching users:', error);
            usersContainer.innerHTML = '<p class="text-red-500">Could not load users for this location.</p>';
        }
    };

    const renderUsers = (users) => {
        usersContainer.innerHTML = '';
        if (users.length === 0) {
            usersContainer.innerHTML = '<p class="text-gray-500">No one else is here... yet!</p>';
            return;
        }

        users.forEach(user => {
            const userCard = document.createElement('div');
            userCard.className = 'bg-white rounded-xl shadow-lg p-6 transform hover:scale-105 transition-transform';
            const photoUrl = user.profile && user.profile.photos.length > 0 ? user.profile.photos[0] : 'https://i.pravatar.cc/150';

            let messageBtn = '';
            if (isDiamond) {
                messageBtn = `<button class="btn-secondary mt-4 w-full" onclick="window.location.href='chat.html?user=${user._id}'">Message</button>`;
            } else {
                messageBtn = `<button class="btn-secondary mt-4 w-full" disabled title="Diamond members only">Message (Diamond only)</button>`;
            }

            userCard.innerHTML = `
                <div class="flex flex-col items-center text-center">
                    <img src="${photoUrl}" alt="${user.username}" class="w-24 h-24 rounded-full mb-4 shadow-md">
                    <h4 class="font-bold text-xl">${user.username}, ${user.profile ? user.profile.age : ''}</h4>
                    <p class="text-gray-600 mt-2 text-sm">${user.bio || 'No bio yet.'}</p>
                    ${messageBtn}
                </div>
            `;
            usersContainer.appendChild(userCard);
        });
    };

    // --- Vibe Check UI ---
    const vibeInput = document.createElement('input');
    vibeInput.type = 'text';
    vibeInput.id = 'vibe-input';
    vibeInput.className = 'flex-grow p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-purple-500 mt-3';
    vibeInput.placeholder = "What's your vibe? (e.g. Down for dinner, Exploring, Chilling by the pool)";
    checkinForm.insertBefore(vibeInput, checkinForm.querySelector('button'));

    // --- Location Group Chat UI ---
    const isDiamond = localStorage.getItem('subscription') === 'diamond';
    let chatContainer = null;
    if (isDiamond) {
        chatContainer = document.createElement('div');
        chatContainer.className = 'bg-white rounded-xl shadow-lg p-6 mt-8';
        chatContainer.innerHTML = `
            <h3 class="text-xl font-bold mb-4">Location Group Chat</h3>
            <div id="chat-messages" class="h-48 overflow-y-auto border rounded-lg p-4 mb-4 bg-gray-100"></div>
            <form id="chat-form" class="flex">
                <input type="text" id="chat-input" class="flex-1 px-4 py-2 border rounded-l-lg focus:outline-none" placeholder="Type a message..." required>
                <button type="submit" class="px-4 py-2 bg-purple-500 text-white font-bold rounded-r-lg">Send</button>
            </form>
        `;
        document.querySelector('.container').appendChild(chatContainer);
    } else {
        chatContainer = document.createElement('div');
        chatContainer.className = 'bg-white rounded-xl shadow-lg p-6 mt-8 text-center';
        chatContainer.innerHTML = `<h3 class="text-xl font-bold mb-4">Location Group Chat</h3><p class="text-pink-500 font-semibold">Diamond members only. <a href='payment.html' class='underline'>Upgrade now</a> to join group chats!</p>`;
        document.querySelector('.container').appendChild(chatContainer);
    }

    // --- Chat Logic ---
    if (isDiamond) {
        const chatMessages = chatContainer.querySelector('#chat-messages');
        const chatForm = chatContainer.querySelector('#chat-form');
        const chatInput = chatContainer.querySelector('#chat-input');

        let currentLocation = null;

        const fetchChat = async (locationName) => {
            try {
                const res = await fetch(`http://localhost:3000/api/locationchat/${encodeURIComponent(locationName)}`, {
                    headers: { 'Authorization': `Bearer ${token}` }
                });
                if (!res.ok) throw new Error('Failed to fetch chat');
                const messages = await res.json();
                renderChat(messages);
            } catch (error) {
                chatMessages.innerHTML = '<p class="text-red-500">Could not load chat.</p>';
            }
        };

        const renderChat = (messages) => {
            chatMessages.innerHTML = '';
            messages.forEach(msg => {
                const msgDiv = document.createElement('div');
                msgDiv.className = 'mb-2';
                msgDiv.innerHTML = `<span class="font-bold">${msg.userId.username || 'User'}:</span> <span>${msg.text}</span>`;
                chatMessages.appendChild(msgDiv);
            });
            chatMessages.scrollTop = chatMessages.scrollHeight;
        };

        chatForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            const text = chatInput.value;
            if (!text || !currentLocation) return;
            await fetch(`http://localhost:3000/api/locationchat/${encodeURIComponent(currentLocation)}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify({ text })
            });
            try { if (window.MeengleAnalytics && typeof window.MeengleAnalytics.messageSent === 'function') window.MeengleAnalytics.messageSent(localStorage.getItem('userId'), `location:${currentLocation}`, text, false); } catch(e){}
            chatInput.value = '';
            fetchChat(currentLocation);
        });

        // --- Enhanced Check-in ---
        checkinForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            const locationName = locationInput.value.trim();
            const vibe = vibeInput.value.trim();
            if (!locationName) return;

            try {
                const res = await fetch('http://localhost:3000/api/checkin', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${token}`
                    },
                    body: JSON.stringify({ locationName, vibe })
                });
                if (!res.ok) throw new Error('Check-in failed');

                currentCheckIn = await res.json();
                currentLocation = locationName;
                updateUIForCheckIn(currentCheckIn.locationName);
                fetchChat(currentLocation);
            } catch (error) {
                alert('Could not check in. Please try again.');
            }
        });

        checkoutBtn.addEventListener('click', async () => {
            try {
                await fetch('http://localhost:3000/api/checkin', {
                    method: 'DELETE',
                    headers: { 'Authorization': `Bearer ${token}` }
                });
                currentCheckIn = null;
                currentLocation = null;
                updateUIForCheckOut();
                chatMessages.innerHTML = '';
            } catch (error) {}
        });
    }

    const updateUIForCheckIn = (locationName) => {
        locationInput.value = locationName;
        locationInput.disabled = true;
        checkinForm.querySelector('button').classList.add('hidden');
        checkoutBtn.classList.remove('hidden');
        fetchUsers(locationName);
    };

    const updateUIForCheckOut = () => {
        locationInput.value = '';
        locationInput.disabled = false;
        checkinForm.querySelector('button').classList.remove('hidden');
        checkoutBtn.classList.add('hidden');
        usersContainer.innerHTML = '<p class="text-gray-500">Check in to a location to see who is around.</p>';
    };

    // Check if user is already checked in on page load
    const verifyInitialCheckIn = async () => {
        // This would ideally be a single endpoint `GET /api/checkin/status`
        // For now, we'll leave it as starting fresh on each page load.
        updateUIForCheckOut();
    };

    // --- Flash Event Simulation ---
    function showFlashEvent(message) {
        const flashDiv = document.createElement('div');
        flashDiv.className = 'fixed top-4 right-4 bg-pink-500 text-white px-4 py-2 rounded shadow-lg z-50';
        flashDiv.textContent = message;
        document.body.appendChild(flashDiv);
        setTimeout(() => flashDiv.remove(), 5000);
    }
    // Example: trigger a flash event every 2 minutes
    setInterval(() => {
        if (currentLocation) {
            showFlashEvent(`Flash Event: Happy Hour at ${currentLocation}!`);
        }
    }, 120000);

    // --- Streaks & Badges Simulation ---
    // This would be handled server-side, but we can show a badge UI
    const badgeContainer = document.createElement('div');
    badgeContainer.className = 'flex gap-2 mt-4';
    badgeContainer.innerHTML = `
        <span class="px-3 py-1 bg-yellow-300 text-yellow-900 rounded-full text-sm">Globetrotter</span>
        <span class="px-3 py-1 bg-blue-300 text-blue-900 rounded-full text-sm">Resort Regular</span>
        <span class="px-3 py-1 bg-green-300 text-green-900 rounded-full text-sm">Socialite</span>
    `;
    document.querySelector('.container').appendChild(badgeContainer);

    // --- Map View Simulation ---
    // For demo, just show a placeholder
    const mapContainer = document.createElement('div');
    mapContainer.className = 'bg-white rounded-xl shadow-lg p-6 mt-8 mb-8';
    mapContainer.innerHTML = `<h3 class="text-xl font-bold mb-4">Live Map View</h3><div class="h-64 flex items-center justify-center text-gray-400">[Map would appear here]</div>`;
    document.querySelector('.container').prepend(mapContainer);

    // --- Initial State ---
    verifyInitialCheckIn();

    // Show diamond perks UI
    if (localStorage.getItem('subscription') === 'diamond') {
        // Profile Boost Button
        const boostBtn = document.createElement('button');
        boostBtn.className = 'btn-primary w-full mb-4';
        boostBtn.textContent = 'Boost My Profile';
        boostBtn.onclick = async () => {
            await fetch('http://localhost:3000/api/profile/boost', {
                method: 'POST',
                headers: { 'Authorization': `Bearer ${localStorage.getItem('token')}` }
            });
            boostBtn.textContent = 'Boosted!';
        };
        document.querySelector('.container').prepend(boostBtn);

        // Custom Theme Selector
        const themeSelector = document.createElement('select');
        themeSelector.className = 'w-full mb-4 p-2 border rounded';
        themeSelector.innerHTML = `
            <option value="default">Default</option>
            <option value="diamond">Diamond</option>
            <option value="animated">Animated</option>
        `;
        themeSelector.onchange = async () => {
            await fetch('http://localhost:3000/api/profile/theme', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${localStorage.getItem('token')}` },
                body: JSON.stringify({ theme: themeSelector.value })
            });
        };
        document.querySelector('.container').prepend(themeSelector);

        // Flash Event Banner
        const flashBanner = document.createElement('div');
        flashBanner.className = 'bg-pink-500 text-white px-4 py-2 rounded shadow-lg mb-4';
        flashBanner.textContent = 'Diamond Flash Event: Exclusive Happy Hour!';
        document.querySelector('.container').prepend(flashBanner);
    }
});
