// We need to configure order! and cs! require.js plugins to boot.
// @see: require-config.js
require.config({
  paths: {
    CoffeeScript: "libs/coffee-script",
    cs: "libs/require/cs"
  }
});

require(['cs!core/App'], function () {
  new Next.App();
});
