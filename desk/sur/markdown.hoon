=>  |%
      ++  ln
        |%
          ::
          ::  Url: optionally enclosed in triangle brackets
          ::  A link destination consists of either
          ::    - a sequence of zero or more characters between an opening < and a closing > that
          ::      contains no line breaks or unescaped < or > characters, or
          ::    - a nonempty sequence of characters that does not start with <, does not include
          ::      ASCII space or control characters, and includes parentheses only if (a) they are
          ::      backslash-escaped or (b) they are part of a balanced pair of unescaped parentheses.
          ::      (Implementations may impose limits on parentheses nesting to avoid performance
          ::      issues, but at least three levels of nesting should be supported.)
          +$  url   [text=@t has-triangle-brackets=?]
          ::
          ::  Url with optional title-text
          +$  urlt  [=url title-text=(unit @t)]
          ::
          ::  Link target: the part of a link after the display text. can be direct or reference
          ::  A reference link is in square brackets, and refers to a named link elsewhere.
          ::    - full =>      [Display][foo]
          ::    - collapsed => [Display][]
          ::    - shortcut =>  [Display]
          ::  Collapsed and shortcut links have a `label` equal to the display text.
          +$  target  $%  [%direct =urlt]
                          [%ref type=?(%full %collapsed %shortcut) label=@t]
                      ==
        --
    --
::
|%
  ::
  ::  Markdown document or fragment: a list of nodes
  ++  markdown  =<  $+  markdown
                    (list node)
                |%
                  +$  node  $+  markdown-node
                            $@  ~                   :: `$@  ~` is magic that makes recursive structures work
                            $%  [%leaf node:leaf]
                                [%container node:container]
                            ==
                --
  ::
  ++  inline
    |%
      ::  A single inline element
      ++  element   $+  inline-element
                    $@  ~
                    $%(escape entity user code hardbrk softbrk text emphasis strong strikethru link image autolink html)
      ::
      ::  Any amount of elements
      ++  contents  (list element)
      ::
      ::  -----------------------
      ::  List of inline elements
      ::  -----------------------
      ::
      ::  Backslash-escaped character
      +$  escape      [%escape char=@t]
      ::
      ::  ship literal reference
      +$  user  [%user =ship]
      ::
      ::  HTML-entity
      +$  entity      [%entity code=@t]
      ::
      ::  Code span (inline code).  Interpreted literally, cannot have nested elements.
      ::  Can be enclosed by any amount of backticks on each side, >= 1.  Must be balanced.
      +$  code        [%code-span num-backticks=@ text=@t]
      ::
      ::  Line break
      +$  hardbrk     [%line-break ~]
      ::
      ::  Soft line break: a newline in the source code, will be rendered as a single space
      +$  softbrk     [%soft-line-break ~]
      ::
      ::  Text: Just text
      +$  text        [%text text=@t]
      ::
      ::  Emphasis and strong emphasis
      ::  Can use either tar "*" or cab "_" as the emphasis character.
      ::  Can have nested inline elements.
      +$  emphasis    [%emphasis emphasis-char=@t =contents]
      +$  strong      [%strong emphasis-char=@t =contents]
      :: Likewise, strikethru.  Can be enclosed in either 1 or 2 sigs ('~')
      +$  strikethru  [%strikethru sig-count=@ =contents]
      ::
      ::  Link
      +$  link        [%link =contents =target:ln]
      ::
      ::  Images
      +$  image       [%image alt-text=@t =target:ln]
      ::
      ::  Autolink: a link that's just itself, surrounded by "<...>"
      +$  autolink    [%autolink text=@t]
      ::
      ::  HTML
      +$  html        [%html =manx]
    --
  ::
  ::  Leaf nodes: non-nested (i.e., terminal) nodes
  ++  leaf
    |%
      ++  node  $+  leaf-node
                $@  ~
                $%(heading break codeblk-indent codeblk-fenced html link-ref-def table paragraph blank-line)
      ::
      ::  Heading, either setext or ATX style
      +$  heading         [%heading style=?(%setext %atx) level=@ =contents:inline]
      ::
      ::  Thematic break (horizontal line)
      ::  Consists of at least 3 repetitions of either hep '-', cab '_', or tar '*'
      +$  break           [%break char=@t char-count=@]
      ::
      ::  Indentation-based code block: indented 4 spaces.  Can include newlines and blank lines.
      +$  codeblk-indent  [%indent-codeblock text=@t]
      ::
      ::  Fenced code block: begins and ends with 3+ repetitions of tic (`) or sig (~).
      ::  Can be indented up to 3 spaces.
      +$  codeblk-fenced  [%fenced-codeblock char=@t char-count=@ info-string=@t indent-level=@ text=@t]
      ::
      ::  HTML
      +$  html            [%html text=@t]
      ::
      ::  Link reference definition (defines a named link which can be referenced elsewhere)
      +$  link-ref-def    [%link-ref-definition label=@t =urlt:ln]
      ::
      ::  Paragraph
      +$  paragraph       [%paragraph =contents:inline]
      ::
      ::  Blank lines (not rendered, but lets user control aethetic layout of the source code)
      +$  blank-line      [%blank-line ~]
      ::
      ::  Table (alignments: [l]eft, [r]ight, [c]enter, [n]one)
      +$  table           [%table widths=(list @) head=(list contents:inline) align=(list ?(%l %c %r %n)) rows=(list (list contents:inline))]
    --
  ::
  ::  Container node: can contain other nodes (either container or leaf).
  ++  container
    |%
      ++  node  $+  container-node
                $@  ~
                $%(block-quote ol ul tl)
      ::
      ::  Block quote.  Can be nested.
      +$  block-quote  [%block-quote =markdown]
      ::
      ::  Ordered list: numbered based on first list item marker.
      ::  Marker char can be either dot '1. asdf' or par '1) asdf'
      ::  Can be indented up to 3 spaces
      +$  ol  [%ol indent-level=@ marker-char=@t start-num=@ contents=(list markdown)] :: is-tight=?
      ::
      ::  Unordered list: bullet point list
      ::  Marker char can be either hep (-), lus (+) or tar (*)
      ::  Can be indented up to 3 spaces
      +$  ul  [%ul indent-level=@ marker-char=@t contents=(list markdown)] :: is-tight=?
      ::
      ::  Task list: unordered list of tasks
      ::  Can be indented up to 3 spaces
      +$  tl  [%tl indent-level=@ marker-char=@t contents=(list [is-checked=? =markdown])] :: is-tight=?
    --
--

