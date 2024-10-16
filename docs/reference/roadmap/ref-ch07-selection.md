# Selection

The `<selection>` statements provides a means of chaining commands on `<table-set>`s produced by any command, either by passing the resulting `<table-set>` to the next command -- similar to how CTEs work -- or by applying a set operation on two resulting `<table-set>`s. It also provides the framework for declaring `<common-table-expression>`s, which can be consumed by following commands.


```
<selection> ::=
  [ WITH [ <common-table-expression> [ ,...n ] ] ]
  <cmd>
  [ INTO <table>
    | <selection-op> [ ( ] <cmd> [ ) ]
    | <tee-op> <set-op> [ ( ] <cmd> [ ) ]
  ] [ ...n ]
  [ AS OF [ <as-of-time> ] ]
```

```
<common-table-expression> ::= <selection> [ AS ] <alias>
```

A `<selection>` in a CTE cannot include a `WITH` clause.

```
<cmd> ::=
  <delete>
  | <insert>
  | <merge>
  | <query>
  | <update>
```

A `<cmd>` is considered terminal when it operates on a `<table>` and potentially mutates its state, whether it mutates `<table>` state or not. A terminal `<cmd>` must be the last step in a `<selection>`, it cannot be grouped by parentheses, and if is not the only `<cmd>` it must have been preceded by a `<pass-thru-op>`. 

The `<query>` command by itself is never terminal. It is terminal when it is followed by `INTO <table>`.

```
<selection-op> ::= <set-op> | <pass-thru-op>
```

```
<set-op> ::=
  UNION
  | EXCEPT
  | INTERSECT
  | DIVIDED BY [ WITH REMAINDER ]
```

Set operations between two result `<table-sets>`. The left `<table-set>` represents the running result of the `<selection>` and the right `<table-set>` can be the result of nested `<cmd>`s.

**UNION**

`UNION` concatenates the left and right `<table-set>`s into one `<table-set>` of distinct rows.

**EXCEPT**

`EXCEPT` returns distinct rows from the left `<table-set>` that are not in the right `<table-set>`. Rows that are not of the same `<row-type>` are considered not matching.

**INTERSECT**

`INTERSECT` returns distinct rows that are in both the left and right `<table-set>`s. Rows that are not of the same `<row-type>` are considered not matching.

**DIVIDED BY [ WITH REMAINDER ]**

This operator performs a relational division on the left `<table-set>` as the dividend and the right `<table-set>` as divisor.

NOTE: rule for dividing union `<row-type>`s TBD.


```
<pass-thru-op> ::=
  PASS-THRU
  | TEE
  | MULTEE
```
```
<tee-op> ::=
  TEE
  | MULTEE
```

`<pass-thru-op>`s make the left resulting `<table-set>` available for consumption by the next `<cmd>` in the `<selection>`. The right side of the statement cannot be nested. The left `<table-set>` can be consumed by `*`, in which case column identifiers and `<row-type>` column alignments from the left `<cmd>` apply, or a list of column aliases, in which case all columns produced by the left `<cmd>` must be included in the order produced.  (See the definition of `<table-set>` in the Introduction.) In other words the `<row-type>` of the left `<table-set>` applies when consumed by the right `<cmd>`.

**PASS-THRU**

The result `<table-set>` of the left sequence of `<cmd>`s in the `<selection>` is available to the next (right) `<cmd>`.

**TEE**

The result `<table-set>` of the left sequence of `<cmd>`s in the `<selection>` is available to the next (right) `<cmd>` and the left `<table-set>` is placed in order in the list of `<table-set>`s resulting from the parent `<selection>`.

**MULTEE**

The result `<table-set>` of the left sequence of `<cmd>`s in the `<selection>` is available to the next (right) `<cmd>` and the results of each `<row-type>` in the left `<table-set>` union type is placed in order in the list of `<table-set>`s resulting from the parent `<selection>`. The order of the resulting `<row-type>`s from the union type is arbitrary.

NOTE: deterministic ordering of union type results TBD.

```
<set-functions> ::=
  <cmd> | <set-op>
```

API:
```
+$  selection
  $:
  %selection
  ctes=(list <common-table-expression>)
  set-functions=(tree <set-functions>)
  ==
```

## Arguments

**`WITH [ <common-table-expression> [ ,...n ] ]`**

The `WITH` clause makes the result `<table-set>` of a `<selection>` statement available to the subsequent `<selection>` statements in the `WITH` clause and `<cmd>`s in the main `<selection>` by `<alias>`. `<selection>`s in the `WITH` clause cannot have their own `WITH` clause, rather preceding CTEs within the clause are available and function as a virtual `WITH` clause.

When used as a `<common-table-expression>`, `<selection>` output must be a pass-thru virtual-table.

When used as a `<common-table-expression>`, `<selection>` cannot include `TEE` and `MULTEE` operators.

**`INTO <table>`**

This clause inserts the resulting `<table-set>` into `<table>`. The associated `<cmd>` is terminal. This is the only case in which `<query>` is terminal.

**`<selection-op> [ ( ] <cmd> [ ) ]`**

If `<selection-op>` is a `<set-op>` the result `<table-set>` from the left side is applied to the next (right) result or result from next nested `<cmd>`s.

If `<selection-op>` is a `<pass-thru-op>` the result `<table-set>` from the left side is available to the next `<cmd>`.

Nesting left paren `(` can only exist singly, but right paren `)` may be stacked to any depth `...)))`, so long as left and right are matching. In other words nesting can only be applied on the right side.

**`<as-of-time>`**

The `AS OF` provides a means to "travel through time" through the state changes of the `<database>`(s). The default is the current state at execution, `NOW`. 

If the last `<cmd>` is terminal (i.e. potentially state mutating, see discussion above), the affected `<table>` definition (columns, indices, and foreign keys) must be the same currently and in the `AS OF` time period. Foreign key constraints will operate against the current parent `<table>`s. All other `<database>` state will be in the `AS OF` time period.

Due to possible `<database>` state changes there is no guarantee of the success of an `AS OF` `<selection>`.

**`<timestamp>`** 

Any valid date/time before the time of execution. 

**`n`**

Integer seconds, minutes, hours, days, weeks, months, or years before execution time. If months is specified and the time "lands" on a day that is beyond the last day of that month, the date defaults to the last day of the landing month.

**`<inline-scalar>`**

TBD

## Remarks

The `<selection>` command potentially results in a state change of the Obelisk agent depending on the `<cmd>` in the last step.

If a `<cmd>` is terminal it must be the last `<cmd>` in the `<selection>`, cannot be nested by parentheses, and cannot be the right side of a `<set-op>`.

## Produced Metadata

list of output `<table-set>`s in order produced (if the last `<cmd>` is terminal it produces no output)
metadata from last `<cmd>`, if it was not the right side of a `<set-op>`
`@@ROWCOUNT` returns the total number of rows returned, if the last `<cmd>` is in the right side of a `<set-op>`

## Exceptions
`<table>` does not exist
mismatch of result `<row-type>` and `<table>`
`GRANT` permission on `<table>` violated
unique key violation on `<table>`
`AS OF` prior to creation of any `<table>` directly or indirectly (through a `<view>`) referenced in the `<selection>`
any exception for `<cmd>` anywhere in the `<selection>`
