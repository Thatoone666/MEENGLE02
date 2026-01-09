let posthog = null;
module.exports = {
  init: (ph) => { posthog = ph; },
  capture: (distinctId, event, properties) => {
    if (!posthog) return;
    try { posthog.capture({ distinctId, event, properties }); } catch (e) { /* ignore */ }
  }
};
