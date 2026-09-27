'use strict';

const vm = require('node:vm');

const {createDom} = require('./dom.js');
const {createAce} = require('./ace.js');
const {createFetch, response, docsResponse, tocResponse} =
  require('./fetch.js');
const {createStorage, defaultSession} = require('./storage.js');
const {createMedia} = require('./media.js');

const tick = () => new Promise((resolve) => setTimeout(resolve, 0));

// Install one scenario's doubles as process globals.  One environment per
// process: the application is a plain script and owns the global scope.

function createEnvironment(options = {}) {
  const profile = options.profile || 'fixture';
  const dom = createDom();
  const graphViz = profile === 'graph-viz';
  const graphVizSession = {
    version: 1,
    source: 'digraph saved { Alpha -> Beta }',
    paneWidth: 62,
    view: {scale: 2, x: 20, y: 30},
    preferences: {autoRender: false}
  };
  const session = Object.hasOwn(options, 'session')
    ? options.session
    : (graphViz ? graphVizSession : defaultSession);
  const aceGlobal = graphViz ? 'graphVizAceAssets' : 'uruiFixtureAceAssets';
  const sessionKey = graphViz
    ? 'graph-viz.session.v1' : 'urui-fixture.session.v1';
  const {ace, aceAssets} = createAce(
    graphViz ? 'ace/mode/dot' : 'ace/mode/text'
  );
  const {requests, fetch} = createFetch();
  const {saved, localStorage} = createStorage(session, sessionKey);
  const {themeMedia, matchMedia} = createMedia();

  const documentListeners = dom.documentListeners;
  const windowListeners = {};
  const prompts = [];
  const confirmations = [];
  const confirmationAnswers = [];
  const clipboardWrites = [];

  const window = {
    innerWidth: 1_024,
    innerHeight: 768,
    location: {
      href: graphViz
        ? 'http://localhost:18080/apps/graph-viz/'
        : 'http://localhost:18080/apps/urui-fixture/',
      origin: 'http://localhost:18080'
    },
    addEventListener: (name, callback) => { windowListeners[name] = callback; },
    prompt: () => prompts.shift(),
    confirm: (message) => {
      confirmations.push(message);
      return confirmationAnswers.shift();
    }
  };
  window.ace = ace;
  window.__URUI_DOUBLES_TEST__ = true;
  window[aceGlobal] = aceAssets;
  if (graphViz) {
    window.__GVIZ_BROWSER_TEST__ = {
      acePlatform: 'win', keyboardLayout: 'en-US'
    };
  }

  global.document = dom.document;
  global.DOMParser = dom.DOMParser;
  global.matchMedia = matchMedia;
  Object.defineProperty(global, 'navigator', {
    configurable: true,
    value: {
      clipboard: {
        writeText: async (source) => { clipboardWrites.push(source); }
      }
    }
  });
  global.getComputedStyle = (element) => ({
    lineHeight: '22px',
    paddingTop: '16px',
    getPropertyValue: (name) => element.values[name] ||
      (name === '--explorer-width' ? '288px' : '44%')
  });
  global.requestAnimationFrame = (callback) => callback();
  URL.createObjectURL = () => 'blob:test';
  URL.revokeObjectURL = () => {};
  global.localStorage = localStorage;
  global.window = window;
  global.fetch = fetch;

  const env = {
    Element: dom.Element,
    elements: dom.elements,
    document: dom.document,
    descendants: dom.descendants,
    group: dom.group,
    svgDocument: dom.svgDocument,
    documentListeners,
    windowListeners,
    window,
    themeMedia,
    requests,
    saved,
    prompts,
    confirmations,
    confirmationAnswers,
    clipboardWrites,
    sessionKey,
    aceAssets,
    response,
    docsResponse,
    tocResponse,
    tick
  };

  return env;
}

// Run the application against an installed environment.

function bootApplication(env, applicationSource, filename) {
  vm.runInThisContext(applicationSource, {filename});
  env.api = global.window.urui;
  env.fixture = global.window.uruiFixture;
  return env;
}

module.exports = {createEnvironment, bootApplication, tick};
