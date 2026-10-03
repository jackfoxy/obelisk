'use strict';

// Minimal DOM double: enough of Element/document for the application to
// build its shell, register listeners, and mutate nodes under test.

function descendants(element) {
  return (element.children || []).flatMap((child) => {
    return [child, ...descendants(child)];
  });
}

const selectors = [
  '#dot', '#editor', '#result-editor', '#editor-load-error', '#template',
  '#render', '#echo', '#error', '#preview', '#fixture-result',
  '#dot-document-tabs', '#svg-document-tabs',
  //  pane strips are `{pane}-{level}-tabs`; graph-viz's land with W10.1
  '#editor-pane-document-tabs', '#result-pane-document-tabs',
  //  the panel each pane's generated levels are built under
  '#explorer-body', '#editor-body', '#result-body',
  //  a revealable band and the toggle urui-shell draws beside it
  '#editor-pane-controls', '#editor-pane-controls-toggle',
  '#zoom-out', '#zoom-in', '#fullscreen-zoom-out', '#fullscreen-zoom-in',
  '#svg-source', '#toggle-svg-source', '#copy-svg', '#fullscreen-svg',
  '#preview-shell', '#render-status', '#source-status', '#result-status',
  '#reset-view',
  '#add-dot-ref', '#browse-dot', '#load-dot', '#save-dot',
  '#add-svg-ref', '#browse-svg', '#load-svg', '#save-svg', '#fit',
  '#auto-render', '#theme', '#help',
  '#help-panel', '#editor-help-card', '#close-help',
  '#settings', '#settings-modal', '#close-settings',
  '#fallback-help-content', '#docs-help-content', '#docs-help-nav',
  '#workbench', '#explorer', '#explorer-pane', '#editor-pane',
  '#preview-pane', '#result-pane',
  '#explorer-tabs', '#explorer-view-tabs', '#explorer-resizer',
  '#explorer-collapse',
  '#dot-files-tab', '#svg-files-tab',
  '#text-files-tab', '#note-files-tab',
  '#text-files-panel', '#note-files-panel',
  '#text-files-tree', '#note-files-tree',
  '#dot-files-panel', '#svg-files-panel',
  '#dot-files-tree', '#svg-files-tree',
  '#file-context-menu', '#file-context-open', '#file-context-delete',
  '#workspace', '#splitter',
  '#inspector',
  '#selection-kind', '#selection-id', '#clear-selection',
  '#delete-selection', '#attribute-form', '#shape-control', '#fill-control',
  '#node-controls', '#edge-controls',
  '#attr-label', '#attr-shape', '#attr-color', '#attr-fillcolor',
  '#attr-style', '#attr-penwidth', '#attr-arrowhead', '#attr-arrowtail',
  '#attr-arrowsize', '#attr-dir', '#attr-minlen', '#attr-weight',
  '#attr-fontname', '#attr-fontsize', '#attr-fontcolor',
  '#attr-change-all', '#attr-use-default',
  '#new-node-name', '#new-node-category', '#new-node-shape', '#add-node',
  '#draw-edge',
  //  urui-fixture-web: two stores, `text` and `note`
  '#text-open', '#text-save', '#text-save-as', '#text-ref', '#text-browse',
  '#note-open', '#note-save', '#note-save-as', '#note-copy', '#note-ref',
  '#note-browse', '#note-display', '#note-preview',
  '#result-editor-load-error',
  //  urui-fixture-docs: one store, `page`, and the document dialogs
  '#page-editor', '#page-editor-load-error', '#page-preview',
  '#page-open', '#page-save', '#page-save-as', '#page-copy', '#page-ref',
  '#page-browse', '#page-display',
  '#page-files-tab', '#page-files-panel', '#page-files-tree',
  '#memo-editor', '#memo-editor-load-error', '#memo-preview', '#memo-display',
  //  urui-fixture-web: the result pane's fullscreen toggle
  '#result-fullscreen',
  '#urui-file-dialog', '#urui-file-dialog-title', '#urui-file-dialog-help',
  '#urui-file-dialog-root-field', '#urui-file-dialog-root',
  '#urui-file-dialog-list', '#urui-file-dialog-path-field',
  '#urui-file-dialog-path', '#urui-file-dialog-mark-field',
  '#urui-file-dialog-mark', '#urui-file-dialog-extra',
  '#urui-file-dialog-error', '#urui-file-dialog-cancel',
  '#urui-file-dialog-confirm',
  '#urui-confirm', '#urui-confirm-message', '#urui-confirm-cancel',
  '#urui-confirm-ok',
  '#urui-toast', '#urui-toast-message', '#urui-toast-details',
  '#urui-toast-close',
  //  graph-viz on urui's store module: `dot` and `svg`
  '#dot-load-error', '#svg-source-load-error', '#svg-preview', '#svg-display',
  '#dot-open', '#dot-save', '#dot-save-as', '#dot-ref', '#dot-browse',
  '#svg-open', '#svg-save', '#svg-save-as', '#svg-copy', '#svg-ref',
  '#svg-browse'
];

function createDom() {
  const documentListeners = {};

  class Element {
    constructor(localName = 'div') {
      this.localName = localName;
      this.dataset = {};
      this.listeners = {};
      this.values = {};
      this.style = {
        setProperty: (name, value) => { this.values[name] = value; }
      };
      this.classes = new Set();
      this.classList = {
        add: (name) => this.classes.add(name),
        remove: (name) => this.classes.delete(name),
        contains: (name) => this.classes.has(name),
        toggle: (name, force) => force
          ? this.classes.add(name)
          : this.classes.delete(name)
      };
      this.children = [];
      this.hidden = false;
      this.disabled = false;
      this.textContent = '';
      this.value = '';
      this.scrollTop = 0;
      this.captured = new Set();
    }

    addEventListener(name, callback) { this.listeners[name] = callback; }
    removeEventListener(name, callback) {
      if (this.listeners[name] === callback) delete this.listeners[name];
    }
    getAttribute(name) { return this[name] ?? null; }
    setAttribute(name, value) { this[name] = value; }
    removeAttribute(name) { delete this[name]; }
    focus() {
      this.focused = true;
      if (document) document.activeElement = this;
    }
    click() { this.clicked = true; }
    append(...children) {
      for (const child of children) {
        if (child.parent) {
          child.parent.children = child.parent.children.filter((item) => {
            return item !== child;
          });
        }
        child.parent = this;
        this.children.push(child);
      }
    }
    after(...siblings) {
      if (!this.parent) return;
      const index = this.parent.children.indexOf(this);
      this.parent.children.splice(index + 1, 0, ...siblings);
      for (const sibling of siblings) sibling.parent = this.parent;
    }
    remove() {
      if (!this.parent) return;
      this.parent.children = this.parent.children.filter((item) => {
        return item !== this;
      });
      this.parent = undefined;
    }
    get parentElement() { return this.parent; }
    setPointerCapture(id) { this.captured.add(id); }
    releasePointerCapture(id) { this.captured.delete(id); }
    hasPointerCapture(id) { return this.captured.has(id); }
    getBoundingClientRect() {
      return {
        left: 0, top: 0, right: 800, bottom: 600,
        width: 800, height: 600
      };
    }
    replaceChildren(...children) {
      this.children = children.length === 1 && children[0].fragment
        ? children[0].children
        : children;
      for (const child of this.children) child.parent = this;
    }
    contains(item) {
      return item === this || this.children.some((child) => {
        return child === item || child.contains?.(item);
      });
    }
    closest(selector) {
      if (selector === '.node, .edge'
        && (this.classes.has('node') || this.classes.has('edge'))) return this;
      return this.parent?.closest?.(selector);
    }
    matches(selector) {
      return selector.split(',').some((name) => {
        return name.trim().toLowerCase() === this.localName?.toLowerCase();
      });
    }
    querySelector(selector) {
      return this.querySelectorAll(selector)[0] || null;
    }
    querySelectorAll(selector) {
      const all = descendants(this);
      if (selector === '[role="tab"]') {
        return all.filter((item) => item.role === 'tab');
      }
      if (selector === '[data-docs-tab]') {
        return all.filter((item) => item.dataset.docsTab);
      }
      if (selector === '[data-ref-tab]') {
        return all.filter((item) => item.dataset.refTab);
      }
      if (selector === '.docs-explorer-panel') {
        return all.filter((item) => {
          return item.className === 'explorer-panel docs-explorer-panel';
        });
      }
      if (selector === '.ref-explorer-panel') {
        return all.filter((item) => {
          return item.className === 'explorer-panel ref-explorer-panel';
        });
      }
      if (selector === 'svg') {
        return all.filter((item) => item.localName === 'svg');
      }
      const view = selector.match(/^\[data-explorer-view="([^"]+)"\]$/);
      if (view) {
        return all.filter((item) => item.dataset.explorerView === view[1]);
      }
      const documentTab = selector.match(
        /^\[data-document-tab="([^"]+)"\]$/
      );
      if (documentTab) {
        return all.filter((item) => {
          return item.dataset.documentTab === documentTab[1];
        });
      }
      const panelFrame = selector.match(/^#([^ ]+) iframe$/);
      if (panelFrame) {
        const panel = all.find((item) => item.id === panelFrame[1]);
        return panel ? descendants(panel).filter((item) => {
          return item.localName === 'iframe';
        }) : [];
      }
      return [];
    }
    async requestFullscreen() {
      document.fullscreenElement = this;
      documentListeners.fullscreenchange?.({});
    }
  }

  function group(kind, identity) {
    const item = new Element();
    const title = {
      localName: 'title', textContent: identity, attributes: []
    };
    const shape = new Element();
    shape.localName = kind === 'node' ? 'ellipse' : 'path';
    shape.attributes = [];
    item.localName = 'g';
    item.attributes = [];
    item.classList.add(kind);
    item.children = [title, shape];
    title.parent = item;
    shape.parent = item;
    item.querySelector = (selector) => {
      return selector === ':scope > title' ? title : null;
    };
    return item;
  }

  function svgDocument(source) {
    const title = {
      localName: 'title', id: '', textContent: source, attributes: []
    };
    const groups = [
      group('node', 'Alpha'),
      group('node', 'Beta'),
      group('node', 'Gamma'),
      group('edge', 'Alpha->Beta'),
      group('edge', 'Beta->Gamma')
    ];
    const svg = new Element();
    svg.localName = 'svg';
    svg.namespaceURI = 'http://www.w3.org/2000/svg';
    svg.attributes = [];
    svg.viewBox = {baseVal: {width: 200, height: 100}};
    svg.renderSource = source;
    svg.children = groups;
    svg.groups = groups;
    for (const item of groups) item.parent = svg;
    svg.querySelector = (selector) => {
      return selector === ':scope > title' ? title : null;
    };
    svg.querySelectorAll = (selector) => {
      if (selector === '.node, .edge') return groups;
      if (selector === '*') {
        return [title, ...groups, ...groups.flatMap((item) => item.children)];
      }
      return [];
    };
    return {documentElement: svg, querySelector: () => null};
  }

  const elements = Object.fromEntries(selectors.map((name) => {
    return [name, new Element()];
  }));
  elements['#auto-render'].checked = true;
  elements['#help-panel'].hidden = true;
  elements['#settings-modal'].hidden = true;
  elements['#docs-help-content'].hidden = true;
  elements['#file-context-menu'].hidden = true;
  elements['#editor-load-error'].hidden = true;
  //  the document Sail's own starting state
  for (const name of [
    '#page-editor-load-error', '#page-preview', '#page-display',
    '#memo-editor-load-error', '#memo-preview', '#memo-display',
    '#note-display', '#note-preview', '#result-editor-load-error',
    '#dot-load-error', '#svg-source-load-error', '#svg-preview',
    '#svg-display',
    '#urui-file-dialog', '#urui-confirm', '#urui-toast',
    '#urui-file-dialog-error', '#urui-toast-details'
  ]) {
    elements[name].hidden = true;
  }
  for (const [name, tag] of [
    ['#urui-file-dialog-root', 'select'], ['#urui-file-dialog-mark', 'select'],
    ['#urui-file-dialog-path', 'input'], ['#urui-file-dialog-cancel', 'button'],
    ['#urui-file-dialog-confirm', 'button'], ['#urui-confirm-ok', 'button'],
    ['#urui-confirm-cancel', 'button'], ['#close-help', 'button'],
    ['#close-settings', 'button'], ['#file-context-open', 'button'],
    ['#file-context-delete', 'button']
  ]) {
    elements[name].localName = tag;
  }
  //  fullscreen toggles, as ++fullscreen-toggle:urui-shell draws them:
  //  the fixture's expands its result pane, graph-viz's its preview
  for (const [name, target, label] of [
    ['#result-fullscreen', 'result-pane', 'result'],
    ['#fullscreen-svg', 'preview-shell', 'SVG']
  ]) {
    const toggle = elements[name];
    toggle.localName = 'button';
    toggle.id = name.slice(1);
    toggle.dataset.fullscreenTarget = target;
    toggle.dataset.fullscreenLabel = label;
  }
  for (const toggle of [
    '#page-display', '#svg-display', '#note-display', '#memo-display'
  ]) {
    for (const display of ['source', 'preview']) {
      const button = new Element('button');
      button.dataset.display = display;
      elements[toggle].append(button);
    }
  }
  elements['#urui-file-dialog'].append(
    elements['#urui-file-dialog-root'], elements['#urui-file-dialog-path'],
    elements['#urui-file-dialog-mark'], elements['#urui-file-dialog-cancel'],
    elements['#urui-file-dialog-confirm']
  );
  elements['#urui-confirm'].append(
    elements['#urui-confirm-cancel'], elements['#urui-confirm-ok']
  );
  elements['#settings-modal'].append(elements['#close-settings']);
  elements['#file-context-menu'].setAttribute('role', 'menu');
  for (const name of ['#file-context-open', '#file-context-delete']) {
    elements[name].setAttribute('role', 'menuitem');
    elements['#file-context-menu'].append(elements[name]);
  }
  elements['#urui-toast'].setAttribute('aria-live', 'polite');

  //  Each consumer seeds its own explorer strip: graph-viz's two file
  //  trees in `#explorer-tabs`, the fixture's in `#explorer-view-tabs`.
  //  Only one of the two is the strip a booted application finds.
  for (const [strip, seeded] of [
    ['#explorer-tabs', [
      ['#dot-files-tab', 'dot-files', '#dot-files-panel'],
      ['#svg-files-tab', 'svg-files', '#svg-files-panel']
    ]],
    ['#explorer-view-tabs', [
      ['#text-files-tab', 'text-files', '#text-files-panel'],
      ['#note-files-tab', 'note-files', '#note-files-panel']
    ]]
  ]) {
    for (const [name, view, panel] of seeded) {
      const wrapper = new Element();
      const tab = elements[name];
      tab.dataset.explorerView = view;
      tab.setAttribute('role', 'tab');
      tab.setAttribute('aria-controls', panel.slice(1));
      wrapper.append(tab);
      elements[strip].append(wrapper);
    }
  }
  elements['#explorer-pane'].append(
    elements['#explorer-tabs'],
    elements['#explorer-view-tabs'],
    elements['#dot-files-panel'],
    elements['#svg-files-panel'],
    elements['#text-files-panel'],
    elements['#note-files-panel'],
    elements['#page-files-panel'],
    elements['#explorer-body']
  );

  function documentDescendants() {
    return Object.values(elements).flatMap((element) => {
      return [element, ...descendants(element)];
    });
  }

  //  <body>'s direct children, as urui-shell's full frame lays them out:
  //  the modals go inert around each other, the toast never does
  const body = new Element('body');
  body.append(
    elements['#workbench'], elements['#settings-modal'],
    elements['#help-panel'], elements['#urui-file-dialog'],
    elements['#urui-confirm'], elements['#urui-toast']
  );

  const document = {
    fullscreenElement: null,
    documentElement: new Element('html'),
    body,
    querySelector: (selector) => {
      if (elements[selector]) return elements[selector];
      const panelFrame = selector.match(/^#([^ ]+) iframe$/);
      if (panelFrame) {
        const panel = documentDescendants().find((item) => {
          return item.id === panelFrame[1];
        });
        return panel ? descendants(panel).find((item) => {
          return item.localName === 'iframe';
        }) : null;
      }
      if (selector.startsWith('#')) {
        return documentDescendants().find((item) => {
          return item.id === selector.slice(1);
        }) || null;
      }
      const docs = selector.match(/^\[data-docs-tab="([^"]+)"\]$/);
      if (docs) {
        return documentDescendants().find((item) => {
          return item.dataset?.docsTab === docs[1];
        });
      }
      const ref = selector.match(/^\[data-ref-tab="([^"]+)"\]$/);
      if (ref) {
        return documentDescendants().find((item) => {
          return item.dataset?.refTab === ref[1];
        });
      }
      return null;
    },
    querySelectorAll: (selector) => {
      if (selector !== '[data-fullscreen-target]') return [];
      return [...new Set(documentDescendants())].filter((item) => {
        return item.dataset?.fullscreenTarget;
      });
    },
    getElementById: (id) => elements[`#${id}`] ||
      documentDescendants().find((item) => item.id === id) || null,
    importNode: (node) => node,
    createDocumentFragment: () => ({
      fragment: true,
      children: [],
      append(item) { this.children.push(item); }
    }),
    createElement: (name) => new Element(name),
    createTextNode: (text) => {
      const node = new Element('#text');
      node.textContent = String(text);
      return node;
    },
    addEventListener: (name, callback) => {
      // Chain, do not replace: urui's own document listeners and a
      // consumer's coexist in a real browser, so they must here too.
      const existing = documentListeners[name];
      documentListeners[name] = existing
        ? (event) => { existing(event); callback(event); }
        : callback;
    },
    exitFullscreen: async () => {
      document.fullscreenElement = null;
      documentListeners.fullscreenchange?.({});
    }
  };

  const DOMParser = class {
    parseFromString(source) { return svgDocument(source); }
  };

  return {
    Element, descendants, documentListeners, elements, document, DOMParser,
    group, svgDocument, selectors
  };
}

module.exports = {createDom, descendants, selectors};
