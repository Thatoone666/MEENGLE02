(()=>{document.addEventListener("DOMContentLoaded",()=>{let l=document.getElementById("post-form"),s=document.getElementById("activity-input"),i=document.getElementById("location-input"),r=document.getElementById("feed-container"),a=localStorage.getItem("token");if(!a){window.location.href="login.html";return}let c=async()=>{try{let e=await fetch("http://localhost:3000/api/onthefly",{headers:{Authorization:`Bearer ${a}`}});if(!e.ok)throw new Error("Failed to fetch posts");let o=await e.json();d(o)}catch(e){console.error("Error fetching posts:",e),r.innerHTML='<p class="text-red-500">Could not load the feed. Please try again later.</p>'}},d=e=>{if(r.innerHTML="",e.length===0){r.innerHTML='<p class="text-gray-500">Nothing happening right now. Why not post something?</p>';return}e.forEach(o=>{let n=document.createElement("div");n.className="bg-white rounded-xl shadow-lg p-6 flex flex-col";let t=o.userId,h=t.profile&&t.profile.photos.length>0?t.profile.photos[0]:"https://i.pravatar.cc/150";n.innerHTML=`
                <div class="flex items-center mb-4">
                    <img src="${h}" alt="${t.username}" class="w-12 h-12 rounded-full mr-4">
                    <div>
                        <h4 class="font-bold text-lg">${t.username}, ${t.profile?t.profile.age:""}</h4>
                        <p class="text-sm text-gray-500">${o.location||"Somewhere exciting"}</p>
                    </div>
                </div>
                <p class="text-gray-800 flex-grow">${o.activity}</p>
                <div class="mt-4 text-xs text-gray-400">
                    Posted: ${new Date(o.createdAt).toLocaleTimeString()}
                </div>
                <button class="btn-secondary mt-4">Message</button>
            `,r.appendChild(n)})};l.addEventListener("submit",async e=>{e.preventDefault();let o=s.value.trim(),n=i.value.trim();if(!o){alert("Please enter an activity.");return}try{if(!(await fetch("http://localhost:3000/api/onthefly",{method:"POST",headers:{"Content-Type":"application/json",Authorization:`Bearer ${a}`},body:JSON.stringify({activity:o,location:n})})).ok)throw new Error("Failed to create post");s.value="",i.value="",c()}catch(t){console.error("Error creating post:",t),alert("Could not create post. Please try again.")}}),c()});})();
//# sourceMappingURL=onthefly.js.map
