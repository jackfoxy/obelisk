::  Unit testing set operation query execution on a Gall agent with %obelisk.
::
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
      insert-same-a
      insert-same-b
      insert-same-c
      insert-same-d
      insert-diff-name
      insert-diff-order
      insert-diff-type
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
::
++  result-ab-union
  :-  %results
      :~  [%action 'SELECT']
          [%result-set rows-union-ab]
          [%server-time ~2012.5.3]
          [%relation 'db1.dbo.same-a']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation 'db1.dbo.same-b']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%vector-count 4]
          ==
++  result-ab-except
  :-  %results
      :~  [%action 'SELECT']
          [%result-set rows-except-ab]
          [%server-time ~2012.5.3]
          [%relation 'db1.dbo.same-a']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation 'db1.dbo.same-b']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%vector-count 1]
          ==
++  result-ab-intersect
  :-  %results
      :~  [%action 'SELECT']
          [%result-set rows-intersect-ab]
          [%server-time ~2012.5.3]
          [%relation 'db1.dbo.same-a']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation 'db1.dbo.same-b']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%vector-count 2]
          ==
++  result-abd-union
  :-  %results
      :~  [%action 'SELECT']
          [%result-set rows-union-abd]
          [%server-time ~2012.5.3]
          [%relation 'db1.dbo.same-a']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation 'db1.dbo.same-b']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation 'db1.dbo.same-d']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%vector-count 5]
          ==
++  result-abc-chain
  :-  %results
      :~  [%action 'SELECT']
          [%result-set rows-union-ab-except-c]
          [%server-time ~2012.5.3]
          [%relation 'db1.dbo.same-a']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation 'db1.dbo.same-b']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation 'db1.dbo.same-c']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%vector-count 2]
          ==
++  result-abcd-chain
  :-  %results
      :~  [%action 'SELECT']
          [%result-set rows-chain-final]
          [%server-time ~2012.5.3]
          [%relation 'db1.dbo.same-a']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation 'db1.dbo.same-b']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation 'db1.dbo.same-c']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation 'db1.dbo.same-d']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%vector-count 1]
          ==
++  result-ab-empty
  :-  %results
      :~  [%action 'SELECT']
          [%result-set ~]
          [%server-time ~2012.5.3]
          [%relation 'db1.dbo.same-a']
          [%schema-time ~2012.4.30]
          [%data-time ~2012.4.30]
          [%relation 'db1.dbo.same-b']
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
              [%relation 'db1.dbo.same-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.same-b']
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
              [%relation 'db1.dbo.same-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.same-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.same-c']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.same-d']
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
              [%relation 'db1.dbo.same-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.same-b']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.same-d']
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
              [%relation 'db1.dbo.same-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.same-b']
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
              [%relation 'db1.dbo.same-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.same-b']
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
              [%relation 'db1.dbo.same-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.same-b']
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
              [%relation 'db1.dbo.diff-name']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.diff-order']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.diff-type']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.same-a']
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
              [%relation 'db1.dbo.diff-name']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.diff-order']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.diff-type']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.same-a']
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
              [%relation 'db1.dbo.diff-name']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.same-a']
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
              [%relation 'db1.dbo.diff-order']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.same-a']
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
              [%relation 'db1.dbo.diff-type']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%relation 'db1.dbo.same-a']
              [%schema-time ~2012.4.30]
              [%data-time ~2012.4.30]
              [%vector-count 0]
              ==
      ==
::
--
