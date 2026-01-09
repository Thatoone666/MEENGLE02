// Frontend Sentry initializer - fetches DSN from /config and initializes Sentry
(async function() {
  try {
    const res = await fetch('/config');
    const cfg = await res.json();
    if (!cfg || !cfg.sentryDsn) return;
    // Load Sentry dynamically
    const script = document.createElement('script');
    script.src = 'https://browser.sentry-cdn.com/7.64.0/bundle.min.js';
    script.crossOrigin = 'anonymous';
    script.onload = () => {
      // eslint-disable-next-line no-undef
      Sentry.init({ dsn: cfg.sentryDsn, tracesSampleRate: 0.02 });
    };
    document.head.appendChild(script);
  } catch (e) {
    // fail silently
    console.error('Sentry init error', e);
  }
})();
