(function(){
  // Frontend PostHog initializer - fetches posthog config from /config and initializes PostHog
  async function init() {
    try {
      const res = await fetch('/config');
      const cfg = await res.json();
      if (!cfg || !cfg.posthog) return;
      // Load PostHog dynamically from CDN
      const script = document.createElement('script');
      script.src = 'https://unpkg.com/posthog-js@1.15.0/dist/posthog.min.js';
      script.crossOrigin = 'anonymous';
      script.onload = () => {
        try {
          // eslint-disable-next-line no-undef
          posthog.init(cfg.posthog.key, { api_host: cfg.posthog.host });
          // expose minimal helper
          window.MeengleAnalytics = {
            capture: (event, props) => {
              try { posthog.capture(event, props || {}); } catch (e) { }
            },
            identify: (id, props) => { try { posthog.identify(id, props || {}); } catch(e){} },
            // helper to safely capture message events
            messageSent: (from, to, text, viaSuggestion) => {
              try { posthog.capture('message_sent', { from, to, textLength: (text||'').length, viaSuggestion: !!viaSuggestion }); } catch(e){}
            },
            // helper to capture likes (client should call this when performing like API calls)
            likeSent: (from, to, context) => {
              try { posthog.capture('like_sent', { from, to, context: context || 'regular' }); } catch(e){}
            }
          };
        } catch (e) { console.error('PostHog init error', e); }
      };
      script.onerror = (e) => console.error('Failed to load PostHog', e);
      document.head.appendChild(script);
    } catch (e) {
      console.error('PostHog init fetch error', e);
    }
  }
  init();
})();
