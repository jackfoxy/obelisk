::  Tests for /lib/urui-css.
::
/+  *test, ucss=urui-css
|%
::
++  test-compose-preserves-order
  =/  all=(list section:ucss)
    :~  %tokens  %controls  %shell  %explorer
        %tabs  %dialogs  %responsive
    ==
  =/  expected=@t
    %+  rap  3
    :~  tokens:ucss  controls:ucss  shell:ucss  explorer:ucss
        tabs:ucss  dialogs:ucss  responsive:ucss
    ==
  =/  repeated=@t  (rap 3 ~[tabs:ucss tokens:ucss tabs:ucss])
  ;:  weld
    (expect-eq !>('') !>((compose:ucss ~)))
    (expect-eq !>(expected) !>((compose:ucss all)))
    %+  expect-eq  !>(repeated)
    !>((compose:ucss ~[%tabs %tokens %tabs]))
  ==
::
++  test-sections-cover-shared-rules
  =/  cases=(list [name=section:ucss needle=@t])
    :~  [%tokens '--surface-alt:']
        [%shell '.workbench {']
        [%explorer '.explorer-file-tree {']
        [%tabs '.document-tab-control {']
        [%dialogs '.help-panel {']
        [%controls '.icon-button {']
    ==
  %-  zing
  %+  turn  cases
  |=  [name=section:ucss needle=@t]
  =/  style  (trip (compose:ucss ~[name]))
  (expect !>(?=(^ (find (trip needle) style))))
::
++  test-theme-tokens
  =/  style  (trip tokens:ucss)
  =/  needles=(list @t)
    :~  'color-scheme: light'  'color-scheme: dark'
        ':root[data-effective-theme=\'dark\']'
        '--surface-alt: #fafafa'  '--surface-alt: #22221f'
        '--preview-background: #ffffff'
        '--preview-background: #11110f'
        '--inspector-background: #fffbeb'
        '--inspector-background: #33270e'
        '--background:'  '--surface:'  '--border:'  '--ink:'
        '--muted:'  '--accent:'  '--accent-text:'  '--focus:'
        '--danger:'  '--danger-background:'  '--danger-border:'
        '--editor-error:'  '--preview-grid:'  '--floating-control:'
        '--selection-hover:'  '--selection-active:'  '--spinner-track:'
        '--state-ink:'  '--state-title:'  '--inspector-border:'
        '--inspector-ink:'  '--editor-width:'
    ==
  %-  zing
  %+  turn  needles
  |=  needle=@t
  (expect !>(?=(^ (find (trip needle) style))))
::
++  test-theme-rules-avoid-fixed-backgrounds
  =/  style  (trip (compose:ucss ~[%tokens %shell %explorer %tabs]))
  =/  forbidden=(list tape)
    :~  "  background: #ffffff"
        "  background: #fafafa"
        "  background: #f4f4f5"
    ==
  %-  zing
  %+  turn  forbidden
  |=  needle=tape
  (expect !>(?=(~ (find needle style))))
::
++  test-docs-help
  =/  style  (trip (compose:ucss ~[%explorer %dialogs]))
  =/  needles=(list tape)
    :~  ".docs-help-content"
        ".docs-help-group[open]"
        ".docs-explorer-frame"
    ==
  %-  zing
  %+  turn  needles
  |=  needle=tape
  (expect !>(?=(^ (find needle style))))
::
++  test-responsive-shell
  =/  style  (trip (compose:ucss ~[%shell %tabs %responsive]))
  =/  needles=(list tape)
    :~  "@media (max-width: 760px)"
        "explorer-collapsed"
        "scrollbar-width: thin"
        "::-webkit-scrollbar-thumb"
    ==
  %-  zing
  %+  turn  needles
  |=  needle=tape
  (expect !>(?=(^ (find needle style))))
::
++  test-pane-band-rules
  =/  style  (trip shell:ucss)
  =/  needles=(list @t)
    :~  '.pane-band {'
        '.pane-band-label {'
        '.pane-band[hidden]'
        '.band-toggle {'
        '.band-toggle[aria-expanded=\'true\']::before'
    ==
  %-  zing
  %+  turn  needles
  |=  needle=@t
  (expect !>(?=(^ (find (trip needle) style))))
::
++  test-tab-depth-rules
  =/  style  (trip tabs:ucss)
  =/  needles=(list @t)
    :~  '.tab-strip[data-depth=\'0\']'
        '.tab-strip[data-depth=\'1\']'
        '.tab-strip[data-depth=\'2\']'
        '--tab-strip-height: 2.55rem'
        '--tab-strip-height: 2.3rem'
        '--tab-strip-height: 2.05rem'
        'border-top: 1px solid var(--border)'
        '.document-tab-add {'
    ==
  %-  zing
  %+  turn  needles
  |=  needle=@t
  (expect !>(?=(^ (find (trip needle) style))))
::
++  test-add-control-belongs-to-tabs
  =/  tabs-style  (trip tabs:ucss)
  =/  controls-style  (trip controls:ucss)
  ;:  weld
    (expect !>(?=(^ (find ".document-tab-add" tabs-style))))
    (expect !>(?=(~ (find ".document-tab-add" controls-style))))
  ==
::
++  test-shared-sections-exclude-app-rules
  =/  style
    %-  trip
    %-  compose:ucss
    :~  %tokens  %controls  %shell  %explorer
        %tabs  %dialogs  %responsive
    ==
  =/  selectors=(list @t)
    :~  '#dot'  '.preview'  '.inspector'  '.zoom-'  '.fullscreen'
        '.visual-tools'  '.attribute-form'  '#shape-control'
        '#svg-source'  'filter: invert(1)'
    ==
  %-  zing
  %+  turn  selectors
  |=  selector=@t
  (expect !>(?=(~ (find (trip selector) style))))
--
