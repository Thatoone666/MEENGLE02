AOS.init();
feather.replace();

const radiusSlider = document.getElementById('distance-radius');
const radiusValue = document.getElementById('radius-value');
radiusSlider.addEventListener('input', (event) => {
    radiusValue.textContent = `${event.target.value} km`;
});

const ageSlider = document.getElementById('age-range-slider');
const ageMinValue = document.getElementById('age-min-value');
const ageMaxValue = document.getElementById('age-max-value');

noUiSlider.create(ageSlider, {
    start: [18, 35],
    connect: true,
    step: 1,
    range: {
        'min': 18,
        'max': 80
    },
    format: {
        to: function (value) {
            return Math.round(value);
        },
        from: function (value) {
            return Number(value);
        }
    }
});

ageSlider.noUiSlider.on('update', function (values, handle) {
    if (handle === 0) {
        ageMinValue.innerHTML = values[0];
    } else {
        ageMaxValue.innerHTML = values[1];
    }
});

const interestsContainer = document.getElementById('interests-container');
const interestInput = document.getElementById('interest-input');
let interests = [];

function renderInterests() {
    interestsContainer.innerHTML = '';
    interests.forEach((interest, index) => {
        const tag = document.createElement('span');
        tag.className = 'px-3 py-1 bg-pink-100 text-pink-800 rounded-full text-sm flex items-center';
        tag.innerHTML = `${interest} <button onclick="removeInterest(${index})" class="ml-2 text-pink-800">&times;</button>`;
        interestsContainer.appendChild(tag);
    });
}

window.removeInterest = function(index) {
    interests.splice(index, 1);
    renderInterests();
}

interestInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter' && interestInput.value.trim() !== '') {
        e.preventDefault();
        interests.push(interestInput.value.trim());
        interestInput.value = '';
        renderInterests();
    }
});

document.querySelector('form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const ageRange = ageSlider.noUiSlider.get();
    const preferences = {
        genderPreference: document.querySelector('input[name="gender-preference"]:checked').value,
        ageRange: {
            min: ageRange[0],
            max: ageRange[1]
        },
        interests: interests
        // location and distance radius would be handled here too
    };

    await fetch('http://localhost:3000/api/profile', {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + localStorage.getItem('token')
        },
        body: JSON.stringify(preferences)
    });

    alert('Settings saved!');
});

// Load existing settings
async function loadSettings() {
    const res = await fetch('http://localhost:3000/api/profile', {
        headers: { 'Authorization': 'Bearer ' + localStorage.getItem('token') }
    });
    const user = await res.json();
    if (user.genderPreference) {
        document.querySelector(`input[name="gender-preference"][value="${user.genderPreference}"]`).checked = true;
    }
    if (user.ageRange) {
        ageSlider.noUiSlider.set([user.ageRange.min, user.ageRange.max]);
    }
    if (user.interests) {
        interests = user.interests;
        renderInterests();
    }
}

loadSettings();

// --- Voice & Video Prompts ---
const promptsContainer = document.getElementById('prompts-container');
const prompts = [
    "What's your go-to karaoke song?",
    "Describe your perfect first date.",
    "What's something you're passionate about?"
];

const loadPrompts = async () => {
    const userRes = await fetch('http://localhost:3000/api/profile', {
        headers: { 'Authorization': 'Bearer ' + localStorage.getItem('token') }
    });
    const userData = await userRes.json();
    const userPrompts = userData.prompts || [];

    promptsContainer.innerHTML = '';
    prompts.forEach((promptText, index) => {
        const userResponse = userPrompts.find(p => p.promptText === promptText);
        const promptEl = document.createElement('div');
        promptEl.className = 'p-4 border rounded-lg';
        promptEl.innerHTML = `
            <p class="font-semibold">${promptText}</p>
            <div id="prompt-controls-${index}" class="mt-2">
                ${userResponse ? `
                    <div class="flex items-center">
                        <p class="text-green-600 mr-2">Response recorded!</p>
                        <button class="btn-secondary-sm" onclick="playResponse('${userResponse.responseUrl}')">Play</button>
                        <button class="btn-danger-sm ml-2" onclick="deleteResponse('${promptText}')">Delete</button>
                    </div>
                ` : `
                    <button class="btn-secondary-sm" onclick="recordResponse('${promptText}', 'audio', ${index})">Record Audio</button>
                    <button class="btn-secondary-sm ml-2" onclick="recordResponse('${promptText}', 'video', ${index})">Record Video</button>
                `}
            </div>
        `;
        promptsContainer.appendChild(promptEl);
    });
};

window.recordResponse = async (promptText, type, index) => {
    // Recording logic will go here
    alert(`Recording ${type} for: "${promptText}"`);
    // This would involve MediaRecorder API, creating a blob, and uploading it.
    // For now, we'll simulate an upload and update.
    const dummyUrl = `https://example.com/uploads/${type}_${Date.now()}.webm`;
    await saveResponse(promptText, dummyUrl, type);
    loadPrompts(); // Refresh prompts UI
};

window.deleteResponse = async (promptText) => {
    await saveResponse(promptText, null, null, true);
    loadPrompts();
};

async function saveResponse(promptText, responseUrl, responseType, isDelete = false) {
    const token = localStorage.getItem('token');
    let userPrompts = [];
    
    // Fetch current prompts
    try {
        const res = await fetch('http://localhost:3000/api/profile', { headers: { 'Authorization': `Bearer ${token}` } });
        const userData = await res.json();
        userPrompts = userData.prompts || [];
    } catch (e) { console.error("Failed to fetch user prompts"); }

    const existingPromptIndex = userPrompts.findIndex(p => p.promptText === promptText);

    if (isDelete) {
        if (existingPromptIndex > -1) {
            userPrompts.splice(existingPromptIndex, 1);
        }
    } else {
        if (existingPromptIndex > -1) {
            userPrompts[existingPromptIndex] = { promptText, responseUrl, responseType };
        } else {
            userPrompts.push({ promptText, responseUrl, responseType });
        }
    }

    await fetch('http://localhost:3000/api/profile', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
        body: JSON.stringify({ prompts: userPrompts })
    });
}

loadPrompts();
