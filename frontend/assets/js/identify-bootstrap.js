(function(){
  // If a user is logged in with token and userId available in localStorage,
  // call MeengleAnalytics.identify to tie client-side events to the server user id.
  try {
    const token = localStorage.getItem('token');
    let userId = localStorage.getItem('userId');
    const identifyIfReady = (id) => {
      try {
        if (window.MeengleAnalytics && typeof window.MeengleAnalytics.identify === 'function') {
          window.MeengleAnalytics.identify(id, { authenticated: true });
        }
      } catch (e) {}
    };
    if (token && userId) {
      identifyIfReady(userId);
    } else if (token && !userId) {
      // Try to fetch profile to obtain user id (safe, silent)
      (async function(){
        try {
          const res = await fetch('/api/profile', { headers: { 'Authorization': `Bearer ${token}` } });
          if (!res.ok) return;
          const profile = await res.json();
          if (profile && profile._id) {
            localStorage.setItem('userId', profile._id);
            identifyIfReady(profile._id);
          }
        } catch (e) {}
      })();
    }
  } catch (e) {
    // ignore
  }
})();
