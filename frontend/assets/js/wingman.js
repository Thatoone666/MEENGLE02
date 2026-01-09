document.addEventListener('DOMContentLoaded', () => {
    const token = localStorage.getItem('token');
    if (!token) {
        window.location.href = 'login.html';
        return;
    }

    // UI for sending wingman requests
    const wingmanRequestBtn = document.createElement('button');
    wingmanRequestBtn.className = 'btn-primary w-full mb-4';
    wingmanRequestBtn.textContent = 'Send Wingman Request';
    wingmanRequestBtn.onclick = async () => {
        const targetUserId = prompt('Enter the user ID to send a wingman request to:');
        if (!targetUserId) return;
        await fetch(`http://localhost:3000/api/profile/wingman/request/${targetUserId}`, {
            method: 'POST',
            headers: { 'Authorization': token }
        });
        alert('Wingman request sent!');
    };
    document.body.appendChild(wingmanRequestBtn);

    // UI for accepting wingman requests
    const acceptWingmanBtn = document.createElement('button');
    acceptWingmanBtn.className = 'btn-secondary w-full mb-4';
    acceptWingmanBtn.textContent = 'Accept Wingman Request';
    acceptWingmanBtn.onclick = async () => {
        const requesterId = prompt('Enter the user ID of the requester:');
        if (!requesterId) return;
        await fetch(`http://localhost:3000/api/profile/wingman/accept/${requesterId}`, {
            method: 'POST',
            headers: { 'Authorization': token }
        });
        alert('Wingman request accepted!');
    };
    document.body.appendChild(acceptWingmanBtn);

    // UI for removing wingman
    const removeWingmanBtn = document.createElement('button');
    removeWingmanBtn.className = 'btn-danger w-full mb-4';
    removeWingmanBtn.textContent = 'Remove Wingman';
    removeWingmanBtn.onclick = async () => {
        await fetch('http://localhost:3000/api/profile/wingman/remove', {
            method: 'POST',
            headers: { 'Authorization': token }
        });
        alert('Wingman removed!');
    };
    document.body.appendChild(removeWingmanBtn);
});
