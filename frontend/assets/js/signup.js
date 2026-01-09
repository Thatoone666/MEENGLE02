AOS.init({
    duration: 800,
    easing: 'ease-in-out',
    once: true
});

document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('create-profile-form');
    if (form) {
        form.addEventListener('submit', async (e) => {
            e.preventDefault();
            const token = localStorage.getItem('token');
            if (!token) {
                window.location.href = 'login.html';
                return;
            }

            const formData = new FormData(form);
            const data = Object.fromEntries(formData.entries());

            // Structure the data for the backend
            const profileData = {
                name: data.name,
                age: data.age,
                gender: data.gender,
                bio: data.bio,
                interests: data.interests ? data.interests.split(',').map(i => i.trim()) : [],
                twoTruthsAndALie: {
                    truth1: data.truth1,
                    truth2: data.truth2,
                    lie: data.lie
                }
            };

            try {
                const res = await fetch('http://localhost:3000/api/profile', {
                    method: 'PUT',
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': `Bearer ${token}`
                    },
                    body: JSON.stringify(profileData)
                });

                if (res.ok) {
                    // Send profile_updated and onboarding_complete events if analytics available
                    try {
                        if (window.MeengleAnalytics && typeof window.MeengleAnalytics.capture === 'function') {
                            window.MeengleAnalytics.capture('profile_updated', { fieldsUpdated: Object.keys(profileData) });
                            window.MeengleAnalytics.capture('onboarding_complete', { profileCompleteness: 100 });
                        }
                    } catch (e) {}
                    window.location.href = 'home.html';
                } else {
                    const errorData = await res.json();
                    alert(`Profile update failed: ${errorData.message}`);
                }
            } catch (error) {
                console.error('Error updating profile:', error);
                alert('An error occurred. Please try again.');
            }
        });
    }
});