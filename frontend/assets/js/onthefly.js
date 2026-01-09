document.addEventListener('DOMContentLoaded', () => {
    const postForm = document.getElementById('post-form');
    const activityInput = document.getElementById('activity-input');
    const locationInput = document.getElementById('location-input');
    const feedContainer = document.getElementById('feed-container');
    const token = localStorage.getItem('token');

    if (!token) {
        window.location.href = 'login.html';
        return;
    }

    const fetchPosts = async () => {
        try {
            const res = await fetch('http://localhost:3000/api/onthefly', {
                headers: {
                    'Authorization': `Bearer ${token}`
                }
            });

            if (!res.ok) {
                throw new Error('Failed to fetch posts');
            }

            const posts = await res.json();
            renderPosts(posts);
        } catch (error) {
            console.error('Error fetching posts:', error);
            feedContainer.innerHTML = '<p class="text-red-500">Could not load the feed. Please try again later.</p>';
        }
    };

    const renderPosts = (posts) => {
        feedContainer.innerHTML = '';
        if (posts.length === 0) {
            feedContainer.innerHTML = '<p class="text-gray-500">Nothing happening right now. Why not post something?</p>';
            return;
        }

        posts.forEach(post => {
            const postElement = document.createElement('div');
            postElement.className = 'bg-white rounded-xl shadow-lg p-6 flex flex-col';
            
            const user = post.userId;
            const photoUrl = user.profile && user.profile.photos.length > 0 ? user.profile.photos[0] : 'https://i.pravatar.cc/150';

            postElement.innerHTML = `
                <div class="flex items-center mb-4">
                    <img src="${photoUrl}" alt="${user.username}" class="w-12 h-12 rounded-full mr-4">
                    <div>
                        <h4 class="font-bold text-lg">${user.username}, ${user.profile ? user.profile.age : ''}</h4>
                        <p class="text-sm text-gray-500">${post.location || 'Somewhere exciting'}</p>
                    </div>
                </div>
                <p class="text-gray-800 flex-grow">${post.activity}</p>
                <div class="mt-4 text-xs text-gray-400">
                    Posted: ${new Date(post.createdAt).toLocaleTimeString()}
                </div>
                <button class="btn-secondary mt-4">Message</button>
            `;
            feedContainer.appendChild(postElement);
        });
    };

    postForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const activity = activityInput.value.trim();
        const location = locationInput.value.trim();

        if (!activity) {
            alert('Please enter an activity.');
            return;
        }

        try {
            const res = await fetch('http://localhost:3000/api/onthefly', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                },
                body: JSON.stringify({ activity, location })
            });

            if (!res.ok) {
                throw new Error('Failed to create post');
            }

            activityInput.value = '';
            locationInput.value = '';
            fetchPosts(); // Refresh the feed
        } catch (error) {
            console.error('Error creating post:', error);
            alert('Could not create post. Please try again.');
        }
    });

    // Initial fetch
    fetchPosts();
});
