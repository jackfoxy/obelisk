::  Unit testing set operation query execution on a Gall agent with %obelisk.
::
/-  ast=obelisk-ast
/+  *test-helpers
|%
::
++  create-same-a
  "CREATE TABLE same-a (id @ud, label @t) PRIMARY KEY (id);"
++  create-same-b
  "CREATE TABLE same-b (id @ud, label @t) PRIMARY KEY (id);"
++  create-same-c
  "CREATE TABLE same-c (id @ud, label @t) PRIMARY KEY (id);"
++  create-same-d
  "CREATE TABLE same-d (id @ud, label @t) PRIMARY KEY (id);"
++  create-diff-name
  "CREATE TABLE diff-name (other-id @ud, other-label @t) ".
  "PRIMARY KEY (other-id);"
++  create-diff-order
  "CREATE TABLE diff-order (label @t, id @ud) PRIMARY KEY (label);"
++  create-diff-type
  "CREATE TABLE diff-type (id @ux, label @t) PRIMARY KEY (id);"
++  create-dup-a
  "CREATE TABLE dup-a (id @ud, label @t, label-alt @t) PRIMARY KEY (id);"
++  create-dup-b
  "CREATE TABLE dup-b (id @ud, label @t, label-alt @t) PRIMARY KEY (id);"
::
++  insert-same-a
  "INSERT INTO same-a VALUES ".
  "(1, 'alpha') ".
  "(2, 'beta') ".
  "(3, 'gamma');"
++  insert-same-b
  "INSERT INTO same-b VALUES ".
  "(2, 'beta') ".
  "(3, 'gamma') ".
  "(4, 'delta');"
++  insert-same-c
  "INSERT INTO same-c VALUES ".
  "(3, 'gamma') ".
  "(4, 'delta') ".
  "(5, 'epsilon');"
++  insert-same-d
  "INSERT INTO same-d VALUES ".
  "(2, 'beta') ".
  "(4, 'delta') ".
  "(6, 'zeta');"
++  insert-diff-name
  "INSERT INTO diff-name VALUES (1, 'alpha');"
++  insert-diff-order
  "INSERT INTO diff-order VALUES ('alpha', 1);"
++  insert-diff-type
  "INSERT INTO diff-type VALUES (0x1, 'alpha');"
++  insert-dup-a
  "INSERT INTO dup-a VALUES ".
  "(1, 'alpha', 'one') ".
  "(2, 'beta', 'two') ".
  "(3, 'gamma', 'three');"
++  insert-dup-b
  "INSERT INTO dup-b VALUES ".
  "(2, 'beta', 'two') ".
  "(3, 'gamma', 'zzz') ".
  "(4, 'delta', 'four');"
::
++  setup
  %-  zing
  :~  "CREATE DATABASE db1;"
      create-same-a
      create-same-b
      create-same-c
      create-same-d
      create-diff-name
      create-diff-order
      create-diff-type
      create-dup-a
      create-dup-b
      insert-same-a
      insert-same-b
      insert-same-c
      insert-same-d
      insert-diff-name
      insert-diff-order
      insert-diff-type
      insert-dup-a
      insert-dup-b
      ==
::
++  row-alpha
  :-  %vector
      :~  [%id [~.ud 1]]
          [%label [~.t 'alpha']]
          ==
++  row-beta
  :-  %vector
      :~  [%id [~.ud 2]]
          [%label [~.t 'beta']]
          ==
++  row-gamma
  :-  %vector
      :~  [%id [~.ud 3]]
          [%label [~.t 'gamma']]
          ==
++  row-delta
  :-  %vector
      :~  [%id [~.ud 4]]
          [%label [~.t 'delta']]
          ==
++  row-epsilon
  :-  %vector
      :~  [%id [~.ud 5]]
          [%label [~.t 'epsilon']]
          ==
++  row-zeta
  :-  %vector
      :~  [%id [~.ud 6]]
          [%label [~.t 'zeta']]
          ==
++  row-alpha-diff-name
  :-  %vector
      :~  [%other-id [~.ud 1]]
          [%other-label [~.t 'alpha']]
          ==
++  row-alpha-diff-order
  :-  %vector
      :~  [%label [~.t 'alpha']]
          [%id [~.ud 1]]
          ==
++  row-alpha-diff-type
  :-  %vector
      :~  [%id [~.ux 0x1]]
          [%label [~.t 'alpha']]
          ==
++  row-id-1-twice
  :-  %vector
      :~  [%id [~.ud 1]]
          [%id [~.ud 1]]
          ==
++  row-id-2-twice
  :-  %vector
      :~  [%id [~.ud 2]]
          [%id [~.ud 2]]
          ==
++  row-id-3-twice
  :-  %vector
      :~  [%id [~.ud 3]]
          [%id [~.ud 3]]
          ==
++  row-dup-alpha
  :-  %vector
      :~  [%label [~.t 'alpha']]
          [%label [~.t 'one']]
          ==
++  row-dup-beta
  :-  %vector
      :~  [%label [~.t 'beta']]
          [%label [~.t 'two']]
          ==
++  row-dup-gamma
  :-  %vector
      :~  [%label [~.t 'gamma']]
          [%label [~.t 'three']]
          ==
::
++  rows-a       :~  row-alpha  row-beta  row-gamma  ==
++  rows-b       :~  row-beta  row-gamma  row-delta  ==
++  rows-union-ab
  :~  row-alpha  row-beta  row-gamma  row-delta  ==
++  rows-except-ab
  :~  row-alpha  ==
++  rows-intersect-ab
  :~  row-beta  row-gamma  ==
++  rows-union-abd
  :~  row-alpha  row-beta  row-gamma  row-delta  row-zeta  ==
++  rows-union-ab-except-c
  :~  row-alpha  row-beta  ==
++  rows-chain-final
  :~  row-beta  ==
++  rows-d-union-except
  :~  row-alpha  row-beta  row-delta  row-zeta  ==
++  rows-row-type-union
  :~  row-alpha
      row-alpha-diff-name
      row-alpha-diff-order
      row-alpha-diff-type
      ==
++  rows-id-id-except
  :~  row-id-1-twice  ==
++  rows-id-id-intersect
  :~  row-id-2-twice  row-id-3-twice  ==
++  rows-dup-rename-except
  :~  row-dup-alpha  row-dup-gamma  ==
++  rows-dup-rename-intersect
  :~  row-dup-beta  ==
::
++  result-ab-union
  :-  %results
      :~  [%action 'SELECT']
          [%result-set rows-union-ab]
          [%server-time ~2012.5.3]
          [%relation-name 'db1.dbo.same-a']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation-name 'db1.dbo.same-b']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%vector-count 4]
          ==
++  result-ab-except
  :-  %results
      :~  [%action 'SELECT']
          [%result-set rows-except-ab]
          [%server-time ~2012.5.3]
          [%relation-name 'db1.dbo.same-a']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation-name 'db1.dbo.same-b']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%vector-count 1]
          ==
++  result-ab-intersect
  :-  %results
      :~  [%action 'SELECT']
          [%result-set rows-intersect-ab]
          [%server-time ~2012.5.3]
          [%relation-name 'db1.dbo.same-a']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation-name 'db1.dbo.same-b']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%vector-count 2]
          ==
++  result-abd-union
  :-  %results
      :~  [%action 'SELECT']
          [%result-set rows-union-abd]
          [%server-time ~2012.5.3]
          [%relation-name 'db1.dbo.same-a']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation-name 'db1.dbo.same-b']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation-name 'db1.dbo.same-d']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%vector-count 5]
          ==
++  result-abc-chain
  :-  %results
      :~  [%action 'SELECT']
          [%result-set rows-union-ab-except-c]
          [%server-time ~2012.5.3]
          [%relation-name 'db1.dbo.same-a']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation-name 'db1.dbo.same-b']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation-name 'db1.dbo.same-c']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%vector-count 2]
          ==
++  result-abcd-chain
  :-  %results
      :~  [%action 'SELECT']
          [%result-set rows-chain-final]
          [%server-time ~2012.5.3]
          [%relation-name 'db1.dbo.same-a']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation-name 'db1.dbo.same-b']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation-name 'db1.dbo.same-c']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation-name 'db1.dbo.same-d']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%vector-count 1]
          ==
++  result-ab-empty
  :-  %results
      :~  [%action 'SELECT']
          [%result-set ~]
          [%server-time ~2012.5.3]
          [%relation-name 'db1.dbo.same-a']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation-name 'db1.dbo.same-b']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%vector-count 0]
          ==
::
::  <query> UNION <query>; duplicate rows from both operands appear once.
++  test-set-op-union-00
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "FROM same-a ".
          "SELECT id, label ".
          "UNION ".
          "FROM same-b ".
          "SELECT id, label"
      ::
      result-ab-union
      ==
::
::  UNION removes a row duplicated exactly by both operands.
++  test-set-op-union-01
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "FROM same-a ".
          "WHERE id = 2 ".
          "SELECT id, label ".
          "UNION ".
          "FROM same-b ".
          "WHERE id = 2 ".
          "SELECT id, label"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  row-beta  ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.same-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation-name 'db1.dbo.same-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
::  <query> EXCEPT <query>; matching rows are removed from the left set.
++  test-set-op-except-00
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "FROM same-a ".
          "SELECT id, label ".
          "EXCEPT ".
          "FROM same-b ".
          "SELECT id, label"
      ::
      result-ab-except
      ==
::
::  <query> INTERSECT <query>; only rows present in both operands remain.
++  test-set-op-intersect-00
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "FROM same-a ".
          "SELECT id, label ".
          "INTERSECT ".
          "FROM same-b ".
          "SELECT id, label"
      ::
      result-ab-intersect
      ==
::
::  Chained UNION remains distinct even when a row appears in every operand.
++  test-set-op-chain-00
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "FROM same-a ".
          "SELECT id, label ".
          "UNION ".
          "FROM same-b ".
          "SELECT id, label ".
          "UNION ".
          "FROM same-d ".
          "SELECT id, label"
      ::
      result-abd-union
      ==
::
::  UNION then EXCEPT is evaluated left-to-right.
++  test-set-op-chain-01
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "FROM same-a ".
          "SELECT id, label ".
          "UNION ".
          "FROM same-b ".
          "SELECT id, label ".
          "EXCEPT ".
          "FROM same-c ".
          "SELECT id, label"
      ::
      result-abc-chain
      ==
::
::  UNION, EXCEPT, then INTERSECT is also evaluated left-to-right.
++  test-set-op-chain-02
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "FROM same-a ".
          "SELECT id, label ".
          "UNION ".
          "FROM same-b ".
          "SELECT id, label ".
          "EXCEPT ".
          "FROM same-c ".
          "SELECT id, label ".
          "INTERSECT ".
          "FROM same-d ".
          "SELECT id, label"
      ::
      result-abcd-chain
      ==
::
++  test-set-op-cte-union-00
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM same-a ".
          "      SELECT id, label ".
          "      UNION ".
          "      FROM same-b ".
          "      SELECT id, label) AS u ".
          "FROM u ".
          "SELECT *"
      ::
      result-ab-union
      ==
::
++  test-set-op-cte-except-00
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM same-a ".
          "      SELECT id, label ".
          "      EXCEPT ".
          "      FROM same-b ".
          "      SELECT id, label) AS e ".
          "FROM e ".
          "SELECT *"
      ::
      result-ab-except
      ==
::
++  test-set-op-cte-intersect-00
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM same-a ".
          "      SELECT id, label ".
          "      INTERSECT ".
          "      FROM same-b ".
          "      SELECT id, label) AS i ".
          "FROM i ".
          "SELECT *"
      ::
      result-ab-intersect
      ==
::
::  Outer set ops can consume CTE aliases whose bodies are also set ops.
++  test-set-op-cte-outer-00
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM same-a ".
          "      SELECT id, label ".
          "      UNION ".
          "      FROM same-b ".
          "      SELECT id, label) AS u, ".
          "     (FROM same-c ".
          "      SELECT id, label ".
          "      INTERSECT ".
          "      FROM same-d ".
          "      SELECT id, label) AS e ".
          "FROM u ".
          "SELECT * ".
          "EXCEPT ".
          "FROM e ".
          "SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  row-alpha  row-beta  row-gamma  ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.same-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation-name 'db1.dbo.same-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation-name 'db1.dbo.same-c']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation-name 'db1.dbo.same-d']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 3]
              ==
      ==
::
::  Mixed CTE/table outer set operation.
++  test-set-op-cte-outer-01
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM same-a ".
          "      SELECT id, label ".
          "      UNION ".
          "      FROM same-b ".
          "      SELECT id, label) AS u ".
          "FROM u ".
          "SELECT * ".
          "EXCEPT ".
          "FROM same-c ".
          "SELECT id, label"
      ::
      result-abc-chain
      ==
::
::  A set-op operand can reference a CTE whose body is itself a set-op query.
++  test-set-op-cte-outer-02
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM same-a ".
          "      SELECT id, label ".
          "      EXCEPT ".
          "      FROM same-b ".
          "      SELECT id, label) AS e ".
          "FROM same-d ".
          "SELECT id, label ".
          "UNION ".
          "FROM e ".
          "SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set rows-d-union-except]
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.same-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation-name 'db1.dbo.same-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation-name 'db1.dbo.same-d']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 4]
              ==
      ==
::
++  test-set-op-cte-chain-00
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM same-a ".
          "      SELECT id, label ".
          "      UNION ".
          "      FROM same-b ".
          "      SELECT id, label ".
          "      EXCEPT ".
          "      FROM same-c ".
          "      SELECT id, label ".
          "      INTERSECT ".
          "      FROM same-d ".
          "      SELECT id, label) AS final ".
          "FROM final ".
          "SELECT *"
      ::
      result-abcd-chain
      ==
::
++  test-set-op-empty-00
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "FROM same-a ".
          "WHERE id = 999 ".
          "SELECT id, label ".
          "UNION ".
          "FROM same-b ".
          "SELECT id, label"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set rows-b]
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.same-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation-name 'db1.dbo.same-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 3]
              ==
      ==
::
++  test-set-op-empty-01
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "FROM same-a ".
          "SELECT id, label ".
          "UNION ".
          "FROM same-b ".
          "WHERE id = 999 ".
          "SELECT id, label"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set rows-a]
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.same-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation-name 'db1.dbo.same-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 3]
              ==
      ==
::
++  test-set-op-empty-02
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "FROM same-a ".
          "SELECT id, label ".
          "EXCEPT ".
          "FROM same-b ".
          "WHERE id = 999 ".
          "SELECT id, label"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set rows-a]
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.same-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation-name 'db1.dbo.same-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 3]
              ==
      ==
::
++  test-set-op-empty-03
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "FROM same-a ".
          "WHERE id = 999 ".
          "SELECT id, label ".
          "EXCEPT ".
          "FROM same-b ".
          "SELECT id, label"
      ::
      result-ab-empty
      ==
::
++  test-set-op-empty-04
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "FROM same-a ".
          "WHERE id = 999 ".
          "SELECT id, label ".
          "INTERSECT ".
          "FROM same-b ".
          "SELECT id, label"
      ::
      result-ab-empty
      ==
::
++  test-set-op-empty-05
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "FROM same-a ".
          "SELECT id, label ".
          "INTERSECT ".
          "FROM same-b ".
          "WHERE id = 999 ".
          "SELECT id, label"
      ::
      result-ab-empty
      ==
::
++  test-set-op-row-type-00
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "FROM same-a ".
          "WHERE id = 1 ".
          "SELECT id, label ".
          "UNION ".
          "FROM diff-name ".
          "SELECT other-id, other-label ".
          "UNION ".
          "FROM diff-order ".
          "SELECT * ".
          "UNION ".
          "FROM diff-type ".
          "SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set rows-row-type-union]
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.diff-name']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation-name 'db1.dbo.diff-order']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation-name 'db1.dbo.diff-type']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation-name 'db1.dbo.same-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 4]
              ==
      ==
::
++  test-set-op-row-type-01
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "FROM same-a ".
          "WHERE id = 1 ".
          "SELECT id, label ".
          "EXCEPT ".
          "FROM diff-name ".
          "SELECT other-id, other-label ".
          "EXCEPT ".
          "FROM diff-order ".
          "SELECT * ".
          "EXCEPT ".
          "FROM diff-type ".
          "SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              :-  %result-set
                  :~  row-alpha  ==
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.diff-name']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation-name 'db1.dbo.diff-order']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation-name 'db1.dbo.diff-type']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation-name 'db1.dbo.same-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
++  test-set-op-row-type-02
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "FROM same-a ".
          "WHERE id = 1 ".
          "SELECT id, label ".
          "INTERSECT ".
          "FROM diff-name ".
          "SELECT other-id, other-label"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.diff-name']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation-name 'db1.dbo.same-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 0]
              ==
      ==
::
++  test-set-op-row-type-03
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "FROM same-a ".
          "WHERE id = 1 ".
          "SELECT id, label ".
          "INTERSECT ".
          "FROM diff-order ".
          "SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.diff-order']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation-name 'db1.dbo.same-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 0]
              ==
      ==
::
++  test-set-op-row-type-04
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "FROM same-a ".
          "WHERE id = 1 ".
          "SELECT id, label ".
          "INTERSECT ".
          "FROM diff-type ".
          "SELECT *"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set ~]
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.diff-type']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation-name 'db1.dbo.same-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 0]
              ==
      ==
::
::  Duplicate output names are allowed for EXCEPT when no UNION is present.
++  test-set-op-duplicate-except-00
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "FROM same-a ".
          "SELECT id, id ".
          "EXCEPT ".
          "FROM same-b ".
          "SELECT id, id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set rows-id-id-except]
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.same-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation-name 'db1.dbo.same-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
::  Duplicate output names are allowed for INTERSECT when no UNION is present.
++  test-set-op-duplicate-intersect-00
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "FROM same-a ".
          "SELECT id, id ".
          "INTERSECT ".
          "FROM same-b ".
          "SELECT id, id"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set rows-id-id-intersect]
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.same-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation-name 'db1.dbo.same-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::
::  Duplicate names via AS alias are allowed for EXCEPT without UNION.
++  test-set-op-duplicate-except-01
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "FROM dup-a ".
          "SELECT label, label-alt AS label ".
          "EXCEPT ".
          "FROM dup-b ".
          "SELECT label, label-alt AS label"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set rows-dup-rename-except]
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.dup-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation-name 'db1.dbo.dup-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 2]
              ==
      ==
::
::  Duplicate names via AS alias are allowed for INTERSECT without UNION.
++  test-set-op-duplicate-intersect-01
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "FROM dup-a ".
          "SELECT label, label-alt AS label ".
          "INTERSECT ".
          "FROM dup-b ".
          "SELECT label, label-alt AS label"
      ::
      :-  %results
          :~  [%action 'SELECT']
              [%result-set rows-dup-rename-intersect]
              [%server-time ~2012.5.3]
              [%relation-name 'db1.dbo.dup-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation-name 'db1.dbo.dup-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 1]
              ==
      ==
::
::  UNION in a WITH body rejects selecting the same column twice.
++  test-fail-set-op-union-duplicate-cte-00
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM same-a ".
          "      SELECT id, id ".
          "      UNION ".
          "      FROM same-b ".
          "      SELECT id, id) AS u ".
          "FROM u SELECT *"
      ::
      'SET-QUERY UNION: duplicate output column %id in SELECT'
      ==
::
::  Outer UNION rejects selecting the same column twice.
++  test-fail-set-op-union-duplicate-outer-00
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "FROM same-a ".
          "SELECT id, id ".
          "UNION ".
          "FROM same-b ".
          "SELECT id, id"
      ::
      'SET-QUERY UNION: duplicate output column %id in SELECT'
      ==
::
::  UNION in a WITH body rejects duplicate names introduced by AS alias.
++  test-fail-set-op-union-duplicate-cte-01
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "WITH (FROM dup-a ".
          "      SELECT label, label-alt AS label ".
          "      UNION ".
          "      FROM dup-b ".
          "      SELECT label, label-alt AS label) AS u ".
          "FROM u SELECT *"
      ::
      'SET-QUERY UNION: duplicate output column %label in SELECT'
      ==
::
::  Outer UNION rejects duplicate names introduced by AS alias.
++  test-fail-set-op-union-duplicate-outer-01
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %db1 setup]
      ::
      :+  ~2012.5.3
          %db1
          "FROM dup-a ".
          "SELECT label, label-alt AS label ".
          "UNION ".
          "FROM dup-b ".
          "SELECT label, label-alt AS label"
      ::
      'SET-QUERY UNION: duplicate output column %label in SELECT'
      ==
::
::  relational division
::
::  one-time copies of animal-shelter tables, subset of rows
::
++  shelter-species-vaccines
  "CREATE TABLE reference.species-vaccines (species @t, vaccine @t) ".
  "PRIMARY KEY (species, vaccine);".
  "INSERT INTO reference.species-vaccines VALUES ".
  "('Dog', 'Rabies') ('Dog', 'Parvovirus') ('Dog', 'Distemper Virus') ".
  "('Dog', 'Adenovirus') ('Cat', 'Rabies') ('Cat', 'Herpesvirus') ".
  "('Cat', 'Calicivirus') ('Cat', 'Panleukopenia Virus') ".
  "('Cat', 'Leukemia Virus') ('Rabbit', 'Rabies') ".
  "('Rabbit', 'Myxomatosis') ('Rabbit', 'Viral Haemorrhagic Disease');"
++  shelter-vaccinations
  "CREATE TABLE vaccinations ".
  "(name @t, species @t, vaccination-time @da, vaccine @t, batch @t, ".
  "comments @t, email @t) ".
  "PRIMARY KEY (name, species, vaccine, vaccination-time);".
  "INSERT INTO vaccinations VALUES ".
  "('Abby', 'Dog', ~2017.4.19..9.1.0, 'Distemper Virus', 'N.178784096', ".
  "'no comment', 'ashley.flores@animalshelter.com') ".
  "('Abby', 'Dog', ~2018.4.19..10.44.0, 'Distemper Virus', 'L.107687717', ".
  "'no comment', 'wanda.myers@animalshelter.com') ".
  "('Archie', 'Cat', ~2017.11.20..9.35.0, 'Calicivirus', 'J.460970834', ".
  "'no comment', 'ashley.flores@animalshelter.com') ".
  "('Archie', 'Cat', ~2017.11.20..13.25.0, 'Panleukopenia Virus', ".
  "'F.164759480', 'no comment', 'ashley.flores@animalshelter.com') ".
  "('Aspen', 'Dog', ~2016.9.28..7.36.0, 'Adenovirus', 'M.471677500', ".
  "'no comment', 'wanda.myers@animalshelter.com') ".
  "('Aspen', 'Dog', ~2017.9.29..12.35.0, 'Adenovirus', 'V.256362103', ".
  "'no comment', 'wanda.myers@animalshelter.com') ".
  "('Aspen', 'Dog', ~2016.9.28..10.1.0, 'Distemper Virus', 'N.147820695', ".
  "'no comment', 'ashley.flores@animalshelter.com') ".
  "('Aspen', 'Dog', ~2016.9.28..7.41.0, 'Rabies', 'K.430117096', ".
  "'no comment', 'wanda.myers@animalshelter.com') ".
  "('Aspen', 'Dog', ~2017.9.29..7.32.0, 'Rabies', 'B.384980558', ".
  "'no comment', 'ashley.flores@animalshelter.com') ".
  "('Baloo', 'Rabbit', ~2016.9.1..7.0.0, 'Rabies', 'V.411899194', ".
  "'no comment', 'wanda.myers@animalshelter.com') ".
  "('Benny', 'Dog', ~2019.1.2..9.44.0, 'Adenovirus', 'D.237655965', ".
  "'no comment', 'ashley.flores@animalshelter.com') ".
  "('Benny', 'Dog', ~2019.1.2..13.19.0, 'Rabies', 'H.405534627', ".
  "'no comment', 'robin.murphy@animalshelter.com') ".
  "('Bon bon', 'Rabbit', ~2018.12.27..13.39.0, 'Myxomatosis', ".
  "'I.176340730', 'no comment', 'dennis.hill@animalshelter.com') ".
  "('Bon bon', 'Rabbit', ~2019.12.27..13.32.0, 'Myxomatosis', ".
  "'O.237649828', 'no comment', 'ashley.flores@animalshelter.com') ".
  "('Bon bon', 'Rabbit', ~2016.12.26..12.8.0, 'Rabies', 'N.100666243', ".
  "'no comment', 'wanda.myers@animalshelter.com') ".
  "('Bon bon', 'Rabbit', ~2017.12.27..10.9.0, 'Rabies', 'Z.365201947', ".
  "'no comment', 'wanda.myers@animalshelter.com') ".
  "('Bon bon', 'Rabbit', ~2018.12.27..11.9.0, 'Rabies', 'O.282699517', ".
  "'no comment', 'robin.murphy@animalshelter.com') ".
  "('Bon bon', 'Rabbit', ~2019.12.27..9.23.0, 'Rabies', 'C.219506249', ".
  "'no comment', 'gerald.reyes@animalshelter.com') ".
  "('Boomer', 'Dog', ~2019.9.3..11.58.0, 'Rabies', 'D.353567999', ".
  "'no comment', 'gerald.reyes@animalshelter.com') ".
  "('Dolly', 'Dog', ~2018.9.27..8.16.0, 'Adenovirus', 'F.202325284', ".
  "'no comment', 'ashley.flores@animalshelter.com') ".
  "('Dolly', 'Dog', ~2019.9.27..10.29.0, 'Adenovirus', 'O.402995062', ".
  "'no comment', 'wayne.carter@animalshelter.com') ".
  "('Dolly', 'Dog', ~2018.9.27..14.45.0, 'Rabies', 'T.302536393', ".
  "'no comment', 'robin.murphy@animalshelter.com') ".
  "('Fiona', 'Cat', ~2017.12.18..11.15.0, 'Calicivirus', 'C.259489422', ".
  "'no comment', 'wanda.myers@animalshelter.com') ".
  "('Fiona', 'Cat', ~2017.12.18..14.17.0, 'Panleukopenia Virus', ".
  "'Y.412311976', 'no comment', 'wanda.myers@animalshelter.com') ".
  "('Hobbes', 'Cat', ~2016.12.26..12.54.0, 'Panleukopenia Virus', ".
  "'X.224232315', 'no comment', 'ashley.flores@animalshelter.com') ".
  "('Humphrey', 'Rabbit', ~2018.8.28..8.9.0, 'Myxomatosis', 'H.250858054', ".
  "'no comment', 'gerald.reyes@animalshelter.com') ".
  "('Humphrey', 'Rabbit', ~2018.8.28..9.41.0, 'Rabies', 'U.255625602', ".
  "'no comment', 'robin.murphy@animalshelter.com') ".
  "('Humphrey', 'Rabbit', ~2018.8.28..10.8.0, ".
  "'Viral Haemorrhagic Disease', 'I.404631209', 'no comment', ".
  "'gerald.reyes@animalshelter.com') ".
  "('Nova', 'Cat', ~2018.8.13..14.32.0, 'Leukemia Virus', 'E.489987614', ".
  "'no comment', 'ashley.flores@animalshelter.com') ".
  "('Nova', 'Cat', ~2018.8.13..11.35.0, 'Rabies', 'C.386537135', ".
  "'no comment', 'ashley.flores@animalshelter.com');"
++  shelter-adoptions
  "CREATE TABLE adoptions ".
  "(name @t, species @t, adopter-email @t, adoption-date @da, ".
  "adoption-fee @ud) PRIMARY KEY (name, species, adopter-email);".
  "INSERT INTO adoptions VALUES ".
  "('Abby', 'Dog', 'patrick.hughes@animalshelter.com', ~2018.8.30, 58) ".
  "('Archie', 'Cat', 'patrick.hughes@animalshelter.com', ~2018.8.30, 82) ".
  "('Baloo', 'Rabbit', 'jesse.cox@yahoo.com', ~2017.12.16, 58) ".
  "('Dolly', 'Dog', 'laura.young@gmail.com', ~2019.12.30, 93) ".
  "('Fiona', 'Cat', 'jerry.mitchell@icloud.com', ~2018.2.23, 96) ".
  "('Hobbes', 'Cat', 'timothy.anderson@gmail.com', ~2017.11.8, 73) ".
  "('Humphrey', 'Rabbit', 'kelly.allen@hotmail.com', ~2019.1.17, 85) ".
  "('Nova', 'Cat', 'walter.edwards@icloud.com', ~2018.9.3, 98);"
++  shelter-staff-roles
  "CREATE TABLE staff-roles (role @t) PRIMARY KEY (role);".
  "INSERT INTO staff-roles VALUES ".
  "('Receptionist') ('Veterinarian') ('Assistant') ('Manager') ('Janitor');"
::
::  test-only row: sharon.davis is also a Veterinarian
++  shelter-staff-assignments
  "CREATE TABLE staff-assignments (email @t, role @t, assigned @da) ".
  "PRIMARY KEY (email, role);".
  "INSERT INTO staff-assignments VALUES ".
  "('ashley.flores@animalshelter.com', 'Veterinarian', ~2016.1.1) ".
  "('dennis.hill@animalshelter.com', 'Veterinarian', ~2018.10.7) ".
  "('frances.hill@animalshelter.com', 'Receptionist', ~2016.1.1) ".
  "('gerald.reyes@animalshelter.com', 'Assistant', ~2018.3.20) ".
  "('patrick.hughes@animalshelter.com', 'Receptionist', ~2018.12.15) ".
  "('robin.murphy@animalshelter.com', 'Assistant', ~2018.8.15) ".
  "('sharon.davis@animalshelter.com', 'Manager', ~2016.1.1) ".
  "('sharon.davis@animalshelter.com', 'Veterinarian', ~2016.1.1) ".
  "('wanda.myers@animalshelter.com', 'Assistant', ~2016.1.1) ".
  "('wayne.carter@animalshelter.com', 'Assistant', ~2018.4.2);"
::
++  shelter-setup
  %-  zing
  :~  "CREATE DATABASE animal-shelter;"
      "CREATE NAMESPACE reference;"
      shelter-species-vaccines
      shelter-vaccinations
      shelter-adoptions
      shelter-staff-roles
      shelter-staff-assignments
      ==
::
++  rel-adoptions          'animal-shelter.dbo.adoptions'
++  rel-staff-assignments  'animal-shelter.dbo.staff-assignments'
++  rel-staff-roles        'animal-shelter.dbo.staff-roles'
++  rel-vaccinations       'animal-shelter.dbo.vaccinations'
++  rel-species-vaccines   'animal-shelter.reference.species-vaccines'
::
++  name-row
  |=  name=@t
  ^-  vector:ast
  [%vector ~[[%name [~.t name]]]]
++  email-row
  |=  email=@t
  ^-  vector:ast
  [%vector ~[[%email [~.t email]]]]
++  name-species-row
  |=  [name=@t species=@t]
  ^-  vector:ast
  [%vector ~[[%name [~.t name]] [%species [~.t species]]]]
++  name-vaccine-row
  |=  [name=@t vaccine=@t]
  ^-  vector:ast
  [%vector ~[[%name [~.t name]] [%vaccine [~.t vaccine]]]]
::
++  shelter-result
  ::  SELECT result over animal-shelter; tables in result metadata order
  |=  [tables=(list @t) rows=(list vector:ast)]
  ^-  cmd-result:ast
  =/  metas=(list result:ast)
    %-  zing
    %+  turn  tables
    |=  table=@t
    ^-  (list result:ast)
    :~  [%relation-name table]
        [%schema-time ~2012.4.30]
        [%data-time ~2012.4.30]
        ==
  =/  out=(list result:ast)
    :*  [%action 'SELECT']
        [%result-set rows]
        [%server-time ~2012.5.3]
        metas
        ==
  [%results (snoc out [%vector-count (lent rows)])]
::
++  rows-rabbit-myxo-rabies
  (turn `(list @t)`~['Bon bon' 'Humphrey'] name-row)
++  rows-dog-adeno-rabies
  (turn `(list @t)`~['Aspen' 'Benny' 'Dolly'] name-row)
++  rows-dog-adeno-rabies-exact
  (turn `(list @t)`~['Benny' 'Dolly'] name-row)
++  rows-rabies-names
  =/  names=(list @t)
    ~['Aspen' 'Baloo' 'Benny' 'Bon bon' 'Boomer' 'Dolly' 'Humphrey' 'Nova']
  (turn names name-row)
++  rows-rabies-names-exact
  (turn `(list @t)`~['Baloo' 'Boomer'] name-row)
++  rows-rabbit-names
  (turn `(list @t)`~['Baloo' 'Bon bon' 'Humphrey'] name-row)
++  rows-rabies-name-species
  =/  pairs=(list [@t @t])
    :~  ['Aspen' 'Dog']  ['Baloo' 'Rabbit']  ['Benny' 'Dog']
        ['Bon bon' 'Rabbit']  ['Boomer' 'Dog']  ['Dolly' 'Dog']
        ['Humphrey' 'Rabbit']  ['Nova' 'Cat']
        ==
  (turn pairs name-species-row)
++  rows-adopted-name-species
  =/  pairs=(list [@t @t])
    :~  ['Abby' 'Dog']  ['Archie' 'Cat']  ['Baloo' 'Rabbit']  ['Dolly' 'Dog']
        ['Fiona' 'Cat']  ['Hobbes' 'Cat']  ['Humphrey' 'Rabbit']  ['Nova' 'Cat']
        ==
  (turn pairs name-species-row)
++  rows-unadopted-name-species
  =/  pairs=(list [@t @t])
    ~[['Aspen' 'Dog'] ['Benny' 'Dog'] ['Bon bon' 'Rabbit'] ['Boomer' 'Dog']]
  (turn pairs name-species-row)
++  rows-rabies-name-species-exact
  =/  pairs=(list [@t @t])  ~[['Baloo' 'Rabbit'] ['Boomer' 'Dog']]
  (turn pairs name-species-row)
::
::  exact: rabbits vaccinated against exactly Myxomatosis and Rabies
++  test-set-op-divided-by-00
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "DIVIDED BY ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Rabbit' ".
          "  AND vaccine <> 'Viral Haemorrhagic Disease' ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          ~[(name-row 'Bon bon')]
      ==
::
::  remainder: rabbits vaccinated against at least Myxomatosis and Rabies
++  test-set-op-divide-with-remainder-00
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Rabbit' ".
          "  AND vaccine <> 'Viral Haemorrhagic Disease' ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          rows-rabbit-myxo-rabies
      ==
::
::  exact: rabbits vaccinated against every rabbit vaccine, no others
++  test-set-op-divided-by-01
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "DIVIDED BY ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Rabbit' ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          ~[(name-row 'Humphrey')]
      ==
::
::  remainder: rabbits vaccinated against every rabbit vaccine
++  test-set-op-divide-with-remainder-01
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Rabbit' ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          ~[(name-row 'Humphrey')]
      ==
::
::  exact: two-column quotient around the divisor column; the divisor
::  projection has duplicate rows
++  test-set-op-divided-by-02
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "SELECT name, vaccine, species ".
          "DIVIDED BY ".
          "FROM reference.species-vaccines ".
          "WHERE vaccine = 'Rabies' ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          rows-rabies-name-species-exact
      ==
::
::  remainder: two-column quotient around the divisor column; the divisor
::  projection has duplicate rows
++  test-set-op-divide-with-remainder-02
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "SELECT name, vaccine, species ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM reference.species-vaccines ".
          "WHERE vaccine = 'Rabies' ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          rows-rabies-name-species
      ==
::
::  exact: two-column divisor in a different column order than the dividend
++  test-set-op-divided-by-03
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "SELECT name, species, vaccine ".
          "DIVIDED BY ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Dog' ".
          "  AND vaccine IN ('Adenovirus', 'Rabies') ".
          "SELECT vaccine, species"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          rows-dog-adeno-rabies-exact
      ==
::
::  remainder: two-column divisor in a different column order than the
::  dividend
++  test-set-op-divide-with-remainder-03
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "SELECT name, species, vaccine ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Dog' ".
          "  AND vaccine IN ('Adenovirus', 'Rabies') ".
          "SELECT vaccine, species"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          rows-dog-adeno-rabies
      ==
::
::  exact: quotient column follows the divisor column in the dividend
++  test-set-op-divided-by-04
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Dog' ".
          "SELECT vaccine, name ".
          "DIVIDED BY ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Dog' ".
          "  AND vaccine IN ('Adenovirus', 'Rabies') ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          rows-dog-adeno-rabies-exact
      ==
::
::  remainder: quotient column follows the divisor column in the dividend
++  test-set-op-divide-with-remainder-04
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Dog' ".
          "SELECT vaccine, name ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Dog' ".
          "  AND vaccine IN ('Adenovirus', 'Rabies') ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          rows-dog-adeno-rabies
      ==
::
::  exact: divisor from the dividend's table, with duplicate rows
++  test-set-op-divided-by-05
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "DIVIDED BY ".
          "FROM vaccinations ".
          "WHERE name = 'Bon bon' ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations]
                          ~[(name-row 'Bon bon')]
      ==
::
::  remainder: divisor from the dividend's table, with duplicate rows
++  test-set-op-divide-with-remainder-05
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM vaccinations ".
          "WHERE name = 'Bon bon' ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations]
                          rows-rabbit-myxo-rabies
      ==
::
::  exact: a divisor value no dividend row has
++  test-set-op-divided-by-06
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Dog' ".
          "SELECT name, vaccine ".
          "DIVIDED BY ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Dog' ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          ~
      ==
::
::  remainder: a divisor value no dividend row has
++  test-set-op-divide-with-remainder-06
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Dog' ".
          "SELECT name, vaccine ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Dog' ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          ~
      ==
::
::  exact: literal divisor column; several source rows project to one
::  divisor row
++  test-set-op-divided-by-07
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "SELECT name, vaccine ".
          "DIVIDED BY ".
          "FROM reference.species-vaccines ".
          "WHERE vaccine = 'Rabies' ".
          "SELECT 'Rabies' AS vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          rows-rabies-names-exact
      ==
::
::  remainder: literal divisor column; several source rows project to one
::  divisor row
++  test-set-op-divide-with-remainder-07
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "SELECT name, vaccine ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM reference.species-vaccines ".
          "WHERE vaccine = 'Rabies' ".
          "SELECT 'Rabies' AS vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          rows-rabies-names
      ==
::
::  exact: empty divisor returns an empty result
++  test-set-op-empty-06
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "DIVIDED BY ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Bird' ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          ~
      ==
::
::  remainder: empty divisor returns every distinct quotient row
++  test-set-op-empty-07
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Bird' ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          rows-rabbit-names
      ==
::
::  exact: empty dividend returns an empty result
++  test-set-op-empty-08
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Bird' ".
          "SELECT name, vaccine ".
          "DIVIDED BY ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Rabbit' ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          ~
      ==
::
::  remainder: empty dividend returns an empty result
++  test-set-op-empty-09
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Bird' ".
          "SELECT name, vaccine ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Rabbit' ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          ~
      ==
::
::  exact: empty dividend and divisor
++  test-set-op-empty-10
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Bird' ".
          "SELECT name, vaccine ".
          "DIVIDED BY ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Bird' ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          ~
      ==
::
::  remainder: empty dividend and divisor
++  test-set-op-empty-11
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Bird' ".
          "SELECT name, vaccine ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Bird' ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          ~
      ==
::
::  <query> DIVIDED BY WITH REMAINDER <query> INTERSECT <query>
++  test-set-op-chain-03
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Rabbit' ".
          "  AND vaccine <> 'Viral Haemorrhagic Disease' ".
          "SELECT vaccine ".
          "INTERSECT ".
          "FROM adoptions ".
          "SELECT name"
      ::
      %+  shelter-result  ~[rel-adoptions rel-vaccinations rel-species-vaccines]
                          ~[(name-row 'Humphrey')]
      ==
::
::  <query> DIVIDED BY WITH REMAINDER <query> EXCEPT <query>
++  test-set-op-chain-04
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM vaccinations ".
          "WHERE name = 'Bon bon' ".
          "SELECT vaccine ".
          "EXCEPT ".
          "FROM adoptions ".
          "SELECT name"
      ::
      %+  shelter-result  ~[rel-adoptions rel-vaccinations]
                          ~[(name-row 'Bon bon')]
      ==
::
::  <query> UNION <query> DIVIDED BY WITH REMAINDER <query>
++  test-set-op-chain-05
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "UNION ".
          "FROM vaccinations ".
          "WHERE species = 'Cat' ".
          "SELECT name, vaccine ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Cat' ".
          "  AND vaccine = 'Rabies' ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          :~  (name-row 'Baloo')  (name-row 'Bon bon')
                              (name-row 'Humphrey')  (name-row 'Nova')
                              ==
      ==
::
::  <query> UNION <query> DIVIDED BY <query>
++  test-set-op-chain-06
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "UNION ".
          "FROM vaccinations ".
          "WHERE species = 'Cat' ".
          "SELECT name, vaccine ".
          "DIVIDED BY ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Cat' ".
          "  AND vaccine = 'Rabies' ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          ~[(name-row 'Baloo')]
      ==
::
::  <query> DIVIDED BY WITH REMAINDER <query> DIVIDED BY <query>;
::  the first quotient is the second dividend
++  test-set-op-chain-07
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "SELECT name, species, vaccine ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM reference.species-vaccines ".
          "WHERE vaccine = 'Rabies' ".
          "SELECT vaccine ".
          "DIVIDED BY ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Rabbit' ".
          "  AND vaccine = 'Rabies' ".
          "SELECT species"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          rows-rabbit-names
      ==
::
::  <query> DIVIDED BY <query> UNION <query>
++  test-set-op-chain-08
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "DIVIDED BY ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Rabbit' ".
          "  AND vaccine <> 'Viral Haemorrhagic Disease' ".
          "SELECT vaccine ".
          "UNION ".
          "FROM adoptions ".
          "WHERE species = 'Rabbit' ".
          "SELECT name"
      ::
      %+  shelter-result  ~[rel-adoptions rel-vaccinations rel-species-vaccines]
                          rows-rabbit-names
      ==
::
::  DIVIDED BY in a WITH body
++  test-set-op-cte-divided-by-00
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "WITH (FROM vaccinations ".
          "      WHERE species = 'Rabbit' ".
          "      SELECT name, vaccine ".
          "      DIVIDED BY ".
          "      FROM reference.species-vaccines ".
          "      WHERE species = 'Rabbit' ".
          "      SELECT vaccine) AS fully-vaccinated ".
          "FROM fully-vaccinated ".
          "SELECT *"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          ~[(name-row 'Humphrey')]
      ==
::
::  DIVIDED BY WITH REMAINDER in a WITH body
++  test-set-op-cte-divide-with-remainder-00
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "WITH (FROM vaccinations ".
          "      WHERE species = 'Dog' ".
          "      SELECT name, vaccine ".
          "      DIVIDED BY WITH REMAINDER ".
          "      FROM reference.species-vaccines ".
          "      WHERE species = 'Dog' ".
          "        AND vaccine IN ('Adenovirus', 'Rabies') ".
          "      SELECT vaccine) AS protected ".
          "FROM protected ".
          "SELECT *"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          rows-dog-adeno-rabies
      ==
::
::  CTE divisor
++  test-set-op-cte-divided-by-01
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "WITH (FROM reference.species-vaccines ".
          "      WHERE species = 'Dog' ".
          "        AND vaccine IN ('Adenovirus', 'Rabies') ".
          "      SELECT vaccine) AS required ".
          "FROM vaccinations ".
          "WHERE species = 'Dog' ".
          "SELECT name, vaccine ".
          "DIVIDED BY ".
          "FROM required ".
          "SELECT *"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          rows-dog-adeno-rabies-exact
      ==
::
::  CTE dividend
++  test-set-op-cte-divide-with-remainder-01
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "WITH (FROM vaccinations ".
          "      WHERE species = 'Dog' ".
          "      SELECT name, vaccine) AS dog-vaccines ".
          "FROM dog-vaccines ".
          "SELECT * ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Dog' ".
          "  AND vaccine IN ('Adenovirus', 'Rabies') ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          rows-dog-adeno-rabies
      ==
::
::  exact: each dividend row type is divided by the divisor row type
::  it contains
++  test-set-op-row-type-05
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "WITH (FROM reference.species-vaccines ".
          "      WHERE species = 'Rabbit' ".
          "        AND vaccine <> 'Viral Haemorrhagic Disease' ".
          "      SELECT vaccine ".
          "      UNION ".
          "      FROM staff-roles ".
          "      WHERE role IN ('Manager', 'Veterinarian') ".
          "      SELECT role) AS requirements ".
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "UNION ".
          "FROM staff-assignments ".
          "SELECT email, role ".
          "DIVIDED BY ".
          "FROM requirements ".
          "SELECT *"
      ::
      %+  shelter-result  :~  rel-staff-assignments
                              rel-staff-roles
                              rel-vaccinations
                              rel-species-vaccines
                              ==
                          :~  (name-row 'Bon bon')
                              (email-row 'sharon.davis@animalshelter.com')
                              ==
      ==
::
::  remainder: each dividend row type is divided by the divisor row type
::  it contains
++  test-set-op-row-type-06
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "WITH (FROM reference.species-vaccines ".
          "      WHERE species = 'Rabbit' ".
          "        AND vaccine <> 'Viral Haemorrhagic Disease' ".
          "      SELECT vaccine ".
          "      UNION ".
          "      FROM staff-roles ".
          "      WHERE role IN ('Manager', 'Veterinarian') ".
          "      SELECT role) AS requirements ".
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "UNION ".
          "FROM staff-assignments ".
          "SELECT email, role ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM requirements ".
          "SELECT *"
      ::
      %+  shelter-result  :~  rel-staff-assignments
                              rel-staff-roles
                              rel-vaccinations
                              rel-species-vaccines
                              ==
                          :~  (name-row 'Bon bon')
                              (name-row 'Humphrey')
                              (email-row 'sharon.davis@animalshelter.com')
                              ==
      ==
::
::  exact: one dividend row type divided by two divisor row types
++  test-set-op-row-type-07
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "WITH (FROM reference.species-vaccines ".
          "      WHERE species = 'Rabbit' ".
          "        AND vaccine = 'Rabies' ".
          "      SELECT vaccine ".
          "      UNION ".
          "      FROM reference.species-vaccines ".
          "      WHERE species = 'Rabbit' ".
          "        AND vaccine = 'Rabies' ".
          "      SELECT species) AS requirements ".
          "FROM vaccinations ".
          "SELECT name, species, vaccine ".
          "DIVIDED BY ".
          "FROM requirements ".
          "SELECT *"
      ::
      %+  shelter-result  ~[rel-vaccinations rel-species-vaccines]
                          :~  (name-species-row 'Baloo' 'Rabbit')
                              (name-species-row 'Boomer' 'Dog')
                              (name-vaccine-row 'Baloo' 'Rabies')
                              (name-vaccine-row 'Bon bon' 'Myxomatosis')
                              (name-vaccine-row 'Bon bon' 'Rabies')
                              (name-vaccine-row 'Humphrey' 'Myxomatosis')
                              (name-vaccine-row 'Humphrey' 'Rabies')
                              %+  name-vaccine-row  'Humphrey'
                                                    'Viral Haemorrhagic Disease'
                              ==
      ==
::
::  divisor column not in dividend
++  test-fail-set-op-divided-by-00
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "DIVIDED BY ".
          "FROM reference.species-vaccines ".
          "SELECT species"
      ::
      'SET-QUERY DIVIDED BY: divisor columns ~[%species] not in dividend'
      ==
::
::  divisor columns only partly in dividend
++  test-fail-set-op-divided-by-01
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "DIVIDED BY ".
          "FROM reference.species-vaccines ".
          "SELECT species, vaccine"
      ::
      %-  crip
      "SET-QUERY DIVIDED BY: divisor columns ~[%species %vaccine] ".
      "not in dividend"
      ==
::
::  divisor column aura differs from dividend column aura
++  test-fail-set-op-divided-by-02
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "DIVIDED BY ".
          "FROM vaccinations ".
          "SELECT vaccination-time AS vaccine"
      ::
      'SET-QUERY DIVIDED BY: column %vaccine is @da in divisor, @t in dividend'
      ==
::
::  divisor covers every dividend column
++  test-fail-set-op-divided-by-03
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "SELECT vaccine ".
          "DIVIDED BY ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Rabbit' ".
          "SELECT vaccine"
      ::
      %-  crip
      "SET-QUERY DIVIDED BY: divisor columns ~[%vaccine] leave no ".
      "quotient columns"
      ==
::
::  duplicate output column in dividend
++  test-fail-set-op-divided-by-04
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "SELECT name, vaccine, name ".
          "DIVIDED BY ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Rabbit' ".
          "SELECT vaccine"
      ::
      'SET-QUERY DIVIDED BY: duplicate output column %name in SELECT'
      ==
::
::  duplicate output column in divisor via AS
++  test-fail-set-op-divided-by-05
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "DIVIDED BY ".
          "FROM reference.species-vaccines ".
          "SELECT vaccine, species AS vaccine"
      ::
      'SET-QUERY DIVIDED BY: duplicate output column %vaccine in SELECT'
      ==
::
::  empty dividend is still validated
++  test-fail-set-op-divided-by-06
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Bird' ".
          "SELECT name, vaccine ".
          "DIVIDED BY ".
          "FROM reference.species-vaccines ".
          "SELECT species"
      ::
      'SET-QUERY DIVIDED BY: divisor columns ~[%species] not in dividend'
      ==
::
::  empty divisor is still validated
++  test-fail-set-op-divided-by-07
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "DIVIDED BY ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Bird' ".
          "SELECT species"
      ::
      'SET-QUERY DIVIDED BY: divisor columns ~[%species] not in dividend'
      ==
::
::  dividend row type contains no divisor row type
++  test-fail-set-op-divided-by-08
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "UNION ".
          "FROM staff-assignments ".
          "SELECT email, role ".
          "DIVIDED BY ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Rabbit' ".
          "SELECT vaccine"
      ::
      'SET-QUERY DIVIDED BY: no divisor for dividend columns ~[%email %role]'
      ==
::
::  divisor row type in no dividend row type
++  test-fail-set-op-divided-by-09
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "WITH (FROM reference.species-vaccines ".
          "      WHERE species = 'Rabbit' ".
          "        AND vaccine <> 'Viral Haemorrhagic Disease' ".
          "      SELECT vaccine ".
          "      UNION ".
          "      FROM staff-roles ".
          "      WHERE role IN ('Manager', 'Veterinarian') ".
          "      SELECT role) AS requirements ".
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "DIVIDED BY ".
          "FROM requirements ".
          "SELECT *"
      ::
      'SET-QUERY DIVIDED BY: divisor columns ~[%role] not in dividend'
      ==
::
::  aura differs in one of several dividend row types
++  test-fail-set-op-divided-by-10
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "UNION ".
          "FROM vaccinations ".
          "WHERE species = 'Cat' ".
          "SELECT name, vaccination-time AS vaccine ".
          "DIVIDED BY ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Rabbit' ".
          "SELECT vaccine"
      ::
      'SET-QUERY DIVIDED BY: column %vaccine is @t in divisor, @da in dividend'
      ==
::
::  rejected in a WITH body
++  test-fail-set-op-divided-by-11
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "WITH (FROM vaccinations ".
          "      SELECT name, vaccine ".
          "      DIVIDED BY ".
          "      FROM reference.species-vaccines ".
          "      SELECT species) AS q ".
          "FROM q ".
          "SELECT *"
      ::
      'SET-QUERY DIVIDED BY: divisor columns ~[%species] not in dividend'
      ==
::
::  divisor column not in dividend
++  test-fail-set-op-divide-with-remainder-00
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM reference.species-vaccines ".
          "SELECT species"
      ::
      %-  crip
      "SET-QUERY DIVIDED BY WITH REMAINDER: divisor columns ".
      "~[%species] not in dividend"
      ==
::
::  divisor column aura differs from dividend column aura
++  test-fail-set-op-divide-with-remainder-01
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM vaccinations ".
          "SELECT vaccination-time AS vaccine"
      ::
      %-  crip
      "SET-QUERY DIVIDED BY WITH REMAINDER: column %vaccine is @da ".
      "in divisor, @t in dividend"
      ==
::
::  divisor covers every dividend column
++  test-fail-set-op-divide-with-remainder-02
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "SELECT vaccine ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Rabbit' ".
          "SELECT vaccine"
      ::
      %-  crip
      "SET-QUERY DIVIDED BY WITH REMAINDER: divisor columns ".
      "~[%vaccine] leave no quotient columns"
      ==
::
::  duplicate output column in dividend
++  test-fail-set-op-divide-with-remainder-03
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "SELECT name, vaccine, name ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Rabbit' ".
          "SELECT vaccine"
      ::
      %-  crip
      "SET-QUERY DIVIDED BY WITH REMAINDER: duplicate output ".
      "column %name in SELECT"
      ==
::
::  dividend row type contains no divisor row type
++  test-fail-set-op-divide-with-remainder-04
  =|  run=@ud
  %-  failon-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE species = 'Rabbit' ".
          "SELECT name, vaccine ".
          "UNION ".
          "FROM staff-assignments ".
          "SELECT email, role ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM reference.species-vaccines ".
          "WHERE species = 'Rabbit' ".
          "SELECT vaccine"
      ::
      %-  crip
      "SET-QUERY DIVIDED BY WITH REMAINDER: no divisor for ".
      "dividend columns ~[%email %role]"
      ==
::
::  Set operation rows are identified by row type and data, not by source
::  primary key.
::
::  INTERSECT of sources with different primary keys
++  test-set-op-intersect-01
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM adoptions ".
          "SELECT name, species ".
          "INTERSECT ".
          "FROM vaccinations ".
          "SELECT name, species"
      ::
      %+  shelter-result  ~[rel-adoptions rel-vaccinations]
                          rows-adopted-name-species
      ==
::
::  EXCEPT of sources with different primary keys
++  test-set-op-except-01
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "SELECT name, species ".
          "EXCEPT ".
          "FROM adoptions ".
          "SELECT name, species"
      ::
      %+  shelter-result  ~[rel-adoptions rel-vaccinations]
                          rows-unadopted-name-species
      ==
::
::  projections of several source rows to equal data are one row
++  test-set-op-union-02
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "WHERE name = 'Bon bon' ".
          "SELECT name, vaccine ".
          "UNION ".
          "FROM vaccinations ".
          "WHERE name = 'Baloo' ".
          "SELECT name, vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations]
                          :~  (name-vaccine-row 'Baloo' 'Rabies')
                              (name-vaccine-row 'Bon bon' 'Myxomatosis')
                              (name-vaccine-row 'Bon bon' 'Rabies')
                              ==
      ==
::
::  exact: one-row divisor of literals without FROM
++  test-set-op-divided-by-08
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "SELECT name, vaccine ".
          "DIVIDED BY ".
          "SELECT 'Rabies' AS vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations]
                          rows-rabies-names-exact
      ==
::
::  remainder: one-row divisor of literals without FROM
++  test-set-op-divide-with-remainder-08
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "FROM vaccinations ".
          "SELECT name, vaccine ".
          "DIVIDED BY WITH REMAINDER ".
          "SELECT 'Rabies' AS vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations]
                          rows-rabies-names
      ==
::
::  exact: one-row dividend of literals without FROM
++  test-set-op-divided-by-09
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "SELECT 'Baloo' AS name, 'Rabies' AS vaccine ".
          "DIVIDED BY ".
          "FROM vaccinations ".
          "WHERE name = 'Baloo' ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations]
                          ~[(name-row 'Baloo')]
      ==
::
::  remainder: one-row dividend of literals without FROM
++  test-set-op-divide-with-remainder-09
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "SELECT 'Baloo' AS name, 'Rabies' AS vaccine ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM vaccinations ".
          "WHERE name = 'Baloo' ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations]
                          ~[(name-row 'Baloo')]
      ==
::
::  exact: one-row dividend of literals, divisor it lacks
++  test-set-op-divided-by-10
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "SELECT 'Baloo' AS name, 'Rabies' AS vaccine ".
          "DIVIDED BY ".
          "FROM vaccinations ".
          "WHERE name = 'Bon bon' ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations]
                          ~
      ==
::
::  remainder: one-row dividend of literals, divisor it lacks
++  test-set-op-divide-with-remainder-10
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "SELECT 'Baloo' AS name, 'Rabies' AS vaccine ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM vaccinations ".
          "WHERE name = 'Bon bon' ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations]
                          ~
      ==
::
::  exact: one-row dividend of literals, empty divisor
++  test-set-op-divided-by-11
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "SELECT 'Baloo' AS name, 'Rabies' AS vaccine ".
          "DIVIDED BY ".
          "FROM vaccinations ".
          "WHERE name = 'Nobody' ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations]
                          ~
      ==
::
::  remainder: one-row dividend of literals, empty divisor
++  test-set-op-divide-with-remainder-11
  =|  run=@ud
  %-  exec-0-1
  :*  run
      [~2012.4.30 %animal-shelter shelter-setup]
      ::
      :+  ~2012.5.3
          %animal-shelter
          "SELECT 'Baloo' AS name, 'Rabies' AS vaccine ".
          "DIVIDED BY WITH REMAINDER ".
          "FROM vaccinations ".
          "WHERE name = 'Nobody' ".
          "SELECT vaccine"
      ::
      %+  shelter-result  ~[rel-vaccinations]
                          ~[(name-row 'Baloo')]
      ==
::
--
