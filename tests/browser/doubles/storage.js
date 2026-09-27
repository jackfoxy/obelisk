'use strict';

const SESSION_KEY = 'urui-fixture.session.v1';

const defaultSession = {
  version: 1,
  source: 'fixture source',
  paneWidth: 62,
  view: {scale: 2, x: 20, y: 30},
  preferences: {autoRender: false}
};

// localStorage double backed by a plain Map, seeded with a session record.

function createStorage(session = defaultSession, key = SESSION_KEY) {
  const saved = new Map();
  if (session) saved.set(key, JSON.stringify(session));
  const localStorage = {
    getItem: (key) => saved.get(key) ?? null,
    setItem: (key, value) => saved.set(key, value)
  };
  return {saved, localStorage};
}

module.exports = {createStorage, defaultSession, SESSION_KEY};
