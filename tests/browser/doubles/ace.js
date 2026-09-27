'use strict';

const assert = require('node:assert/strict');

// Fake Ace editor: offset-addressable document, selection, annotations,
// markers, and the command surface the adapter binds against.

class FakeAceRange {
  constructor(startRow, startColumn, endRow, endColumn) {
    this.start = {row: startRow, column: startColumn};
    this.end = {row: endRow, column: endColumn};
  }
}

function fakePositionToIndex(source, position) {
  const lines = source.split('\n');
  const row = Math.max(0, Math.min(lines.length - 1, position.row));
  const column = Math.max(0, Math.min(lines[row].length, position.column));
  return lines.slice(0, row).reduce((total, line) => {
    return total + line.length + 1;
  }, column);
}

function fakeIndexToPosition(source, offset) {
  const next = Math.max(0, Math.min(source.length, offset));
  const before = source.slice(0, next);
  const lines = before.split('\n');
  return {row: lines.length - 1, column: lines.at(-1).length};
}

function createFakeAceEditor(host) {
  const changeListeners = [];
  const state = {source: '', anchorOffset: 0, leadOffset: 0};
  let nextMarker = 1;
  const undoManager = {
    reset() {},
    startNewGroup() {}
  };
  const session = {
    doc: {
      indexToPosition(offset) {
        return fakeIndexToPosition(state.source, offset);
      },
      positionToIndex(position) {
        return fakePositionToIndex(state.source, position);
      }
    },
    setValue(source) {
      state.source = source;
      state.anchorOffset = source.length;
      state.leadOffset = source.length;
      for (const listener of changeListeners) listener({action: 'setValue'});
    },
    replace(range, replacement) {
      const start = fakePositionToIndex(state.source, range.start);
      const end = fakePositionToIndex(state.source, range.end);
      state.source = state.source.slice(0, start) + replacement
        + state.source.slice(end);
      for (const listener of changeListeners) listener({action: 'replace'});
    },
    insert(position, source) {
      const offset = fakePositionToIndex(state.source, position);
      state.source = state.source.slice(0, offset) + source
        + state.source.slice(offset);
      state.anchorOffset = offset + source.length;
      state.leadOffset = state.anchorOffset;
      for (const listener of changeListeners) listener({action: 'insert'});
    },
    on(name, listener) {
      if (name === 'change') changeListeners.push(listener);
    },
    getUndoManager() { return undoManager; },
    setMode(mode) { this.mode = mode; },
    setUseWorker(worker) { this.worker = worker; },
    setAnnotations(annotations) { this.annotations = annotations; },
    clearAnnotations() { this.annotations = []; },
    addMarker(range, name, type) {
      const id = nextMarker++;
      this.marker = {id, range, name, type};
      return id;
    },
    removeMarker(id) {
      if (this.marker?.id === id) this.marker = undefined;
    }
  };
  const selection = {
    getRange() {
      const start = fakeIndexToPosition(state.source, state.anchorOffset);
      const end = fakeIndexToPosition(state.source, state.leadOffset);
      return new FakeAceRange(start.row, start.column, end.row, end.column);
    },
    setSelectionRange(range) {
      state.anchorOffset = fakePositionToIndex(state.source, range.start);
      state.leadOffset = fakePositionToIndex(state.source, range.end);
    },
    moveCursorTo(row, column) {
      const offset = fakePositionToIndex(state.source, {row, column});
      state.anchorOffset = offset;
      state.leadOffset = offset;
    }
  };
  host.aceSession = session;
  return {
    session,
    selection,
    commands: {
      platform: 'win',
      addCommands(commands) { this.addedCommands = commands; },
      bindKey(key, command) { this.boundKey = {key, command}; }
    },
    textInput: {getElement: () => host},
    getValue: () => state.source,
    setOptions(options) { this.options = options; },
    setTheme(theme) { this.theme = theme; host.aceTheme = theme; },
    setKeyboardHandler(handler) { this.keyboardHandler = handler || null; },
    getKeyboardHandler() { return this.keyboardHandler || null; },
    focus: () => host.focus(),
    clearSelection() {
      state.anchorOffset = state.leadOffset;
    },
    scrollToLine(line) { host.scrollLine = line; },
    resize() { host.resizeCount = (host.resizeCount || 0) + 1; }
  };
}

function createAce(mode = 'ace/mode/text') {
  const fakeAceEditors = new WeakMap();
  const ace = {
    edit: (host) => {
      if (!fakeAceEditors.has(host)) {
        fakeAceEditors.set(host, createFakeAceEditor(host));
      }
      return fakeAceEditors.get(host);
    },
    require: (name) => {
      if (name === 'ace/range') return {Range: FakeAceRange};
      assert.equal(name, 'ace/ext/beautify');
      return {commands: [{name: 'beautify'}]};
    }
  };
  const aceAssets = {
    mode,
    lightTheme: 'ace/theme/github',
    darkTheme: 'ace/theme/monokai',
    useWorker: false
  };
  return {ace, aceAssets, FakeAceRange, fakeAceEditors};
}

module.exports = {
  createAce, createFakeAceEditor, FakeAceRange,
  fakePositionToIndex, fakeIndexToPosition
};
