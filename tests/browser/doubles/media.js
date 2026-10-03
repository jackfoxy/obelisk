'use strict';

// matchMedia double; scenarios drive `matches` and fire `listeners.change`.

function createMedia() {
  const themeMedia = {
    matches: false,
    listeners: {},
    addEventListener(name, callback) { this.listeners[name] = callback; },
    addListener(callback) { this.listeners.change = callback; }
  };
  const matchMedia = (query) => query === '(prefers-color-scheme: dark)'
    ? themeMedia
    : {matches: false};
  return {themeMedia, matchMedia};
}

module.exports = {createMedia};
