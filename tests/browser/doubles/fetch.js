'use strict';

// Fetch double: every call parks a deferred request the scenario resolves.

function response(ok, body, status = ok ? 200 : 422) {
  return {
    ok,
    status,
    headers: {get: () => ok ? 'image/svg+xml' : 'application/json'},
    text: async () => body
  };
}

function docsResponse(url = 'http://localhost:18080/docs') {
  return {
    ok: true,
    status: 200,
    url,
    headers: {get: () => 'text/html; charset=utf-8'},
    text: async () => '<html></html>'
  };
}

function tocResponse() {
  return {
    ok: true,
    status: 200,
    headers: {get: () => 'text/plain; charset=utf-8'},
    text: async () => [
      '/keyboard-shortcuts/md  Keyboard Shortcuts',
      '/users-guide/md         Users Guide',
      '/dot-language/md        DOT Language',
      '/dot-language           DOT Language Reference',
      '  /attributes/md          Attributes',
      '  /attributes             Attributes Reference',
      '    /arrowhead/md            arrowhead',
      '/reference/md           Reference'
    ].join('\n')
  };
}

function createFetch() {
  const requests = [];
  const fetch = (url, options) => new Promise((resolve, reject) => {
    requests.push({url, options, resolve, reject});
  });
  return {requests, fetch};
}

module.exports = {createFetch, response, docsResponse, tocResponse};
