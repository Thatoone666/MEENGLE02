let clientMetrics = null;
try {
  clientMetrics = require('prom-client');
} catch (e) {
  clientMetrics = null;
}

if (clientMetrics) {
  clientMetrics.collectDefaultMetrics();
  const matchesCounter = new clientMetrics.Counter({ name: 'matches_created_total', help: 'Total matches created' });
  const messagesCounter = new clientMetrics.Counter({ name: 'messages_sent_total', help: 'Total messages sent' });
  const likesCounter = new clientMetrics.Counter({ name: 'likes_sent_total', help: 'Total likes sent' });

  module.exports = {
    register: clientMetrics.register,
    incMatch: () => matchesCounter.inc(),
    incMessage: () => messagesCounter.inc(),
    incLike: () => likesCounter.inc(),
    client: clientMetrics
  };
} else {
  // noop stubs for test/dev environments
  module.exports = {
    register: { contentType: 'text/plain; version=0.0.4', async metrics() { return ''; } },
    incMatch: () => {},
    incMessage: () => {},
    incLike: () => {},
    client: null
  };
}
