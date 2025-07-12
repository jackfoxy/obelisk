# MERGE
*partially supported in urQL parser, not yet supported in Obelisk*
*some experimental stuff proposed here, take with a grain of salt*

`MERGE` is a statement that conditionally performs `INSERT`, `UPDATE`, or `DELETE` operations. It modifies the content of the `<target-table>`, merging data from the `<source-table>` and static `<common-table-expression>` sources.

First, the MERGE command performs an outer join from `<target-table>` to `<source-table>` using `ON <merge-predicate>` producing candidate change rows. 

For each candidate change row, the `MATCHED` or `NOT MATCHED` status is determined. If applicable, `NOT MATCHED` on `<target-table>` or `<source-table>` is set.

Finally, for each candidate change row, the first `WHEN` clause under the applicable `MATCHED`/`NOT MATCHED` condition is executed.

A `WHEN` clause without `AND <predicate>` implies unconditional execution. Subsequent `WHEN` clauses for the same target/source matching condition are not allowed.

If no `WHEN` clause evaluates as true, the target row remains unchanged, which is equivalent to specifying `NOP`.

`MERGE` actions have the same effect as the standard `UPDATE`, `INSERT`, or `DELETE` commands.

`MERGE` can update the contents of an existing target `<table>`, produce a new `<table>`, or produce a new virtual `<table-set>`.

When `MERGE INTO` is specified or implied, `<target-table>` must be a base `<table>` and contents are updated in place. `PRODUCING NEW` may not be specified.

When `MERGE FROM` is specified, `PRODUCING NEW` must also be specified. `<target-table>` can be a base `<table>` or any virtual table (i.e. `<view>` or `PASS-THRU` `<table-set>`).

If `<new-table>` is specified, it will be created as a new `<table>` and populated in the same way as when `<target-table>` is updated with `MERGE INTO`.

The output `<table-set>`'s row type will correspond to the row type of `<target-table>`. And its primary index (in the case when `<new-table>` is produced) will correspond to the primary index of `<target-table>`. The `<target-table>`'s `<foreign-key>`s are not replicated.

If the resulting virtual-table row type is a union type, then the output must be a virtual-table `PASS-THRU`, not an update to `<target-table>` or creation of `<new-table>` as base `<table>`.

```
<merge> ::=
  MERGE [ { INTO | FROM } ] <target-table> [ [ AS ] <alias> ]
  [ PRODUCING NEW <new-table> ]
  USING <source-table> [ [ AS ] <alias> ]
  [ [ SCALAR ] [ ,...n ] ]
    [ ON <merge-predicate> ]
    [ WHEN MATCHED [ AND <matched-predicate> ]
      THEN <merge-matched> ] [ ...n ]
    [ WHEN NOT MATCHED [ BY TARGET ] [ AND <unmatched-target-predicate> ]
      THEN <merge-not-matched> ] [ ...n ] 
    [ WHEN NOT MATCHED BY SOURCE [ AND <unmatched-source-predicate> ]
      THEN <merge-matched> ] [ ...n ]
  [ <as-of-time> ]
```

```
<target-table>               ::= <table-set>
<new-table>                  ::= <table-set>
<source-table>               ::= <table-set>
<matched-predicate>          ::= <predicate>
<unmatched-target-predicate> ::= <predicate>
<unmatched-source-predicate> ::= <predicate>
```

```
<merge-matched> ::=
  { UPDATE [ SET ] { <column> = <scalar-expression> }  [ ,...n ]
    | DELETE
    | NOP
  }
```

Specifies the update or delete action that is applied to all rows of `<target-table>` that don't match the rows returned by `<table-source>` ON `<merge-predicate>`, and which satisfy any additional predicate.

**`<column>`**

Identifies column in `<target-table>`. Each column may be referenced once.

**`<scalar-expression>`**

Aura must match corresponding aura in `<target-table>`.

**DELETE**

Delete the matched target row.

**NOP**

No operation performed.


```
<merge-not-matched> ::=
  INSERT [ ( <column> [ ,...n ] ) ]
    VALUES ( <scalar-expression> [ ,...n ] )
  | NOP
```

**`<column>`**

Identifies column in `<target-table>`. Each column may be referenced once.

**`<scalar-expression>`**

Aura must match corresponding aura in `<target-table>`.

The count out `INSERT` columns and `VALUES` must match.

**NOP**

No operation performed.

### API
```
+$  merge
  $:
    %merge
    target-table=table-set
    new-table=(unit table-set)
    source-table=table-set
    predicate=predicate
    matched=(list matching)
    unmatched-by-target=(list matching)
    unmatched-by-source=(list matching)
    as-of=(unit as-of)
  ==
```

### Arguments

**`[ { INTO | FROM } ] <target-table> [ [ AS ] <alias> ]`**

`<alias>` is alternative name to reference `<target-table>` in `WHEN` clauses and predicates.

If `{ INTO | FROM }` is not specified, `INTO` is the default.

If `INTO` is specified (or implied) then `<target-table>` is a base-table

If `<target-table>` is a virtual-table -- any `<table-set>` other than a base-table, i.e. qualified `<view>`, `<common-table-expression>`, `*`, or `( column-1 [,...column-n] )` -- then `FROM` is required.

`INTO` must not accompany `PRODUCING NEW` argument.

`FROM` must accompany `PRODUCING NEW` argument.

`<target-table>` is the table, view, or CTE against which the data rows from `<table-source>` are matched based on `<merge-predicate>`. 

If `FROM` is specified, any `INSERT`, `UPDATE`, or `DELETE` operations specified by the `WHEN` clauses, as well as matched but otherwise unaffected target table rows, produce a new `<table-set>` as specified by the `PRODUCING NEW` clause.

**`[ PRODUCING NEW <new-table>` ]**

Required when `FROM` is specified.

Prohibited when `INTO` is specified or implied.

If `<new-table>` has the syntax of a qualified `<table>`, it cannot already exist.

If `<target-table>` has a row type which is a union type, `<new-table>` cannot be a base `<table>`.

**`USING <source-table> [ [ AS ] <alias> ]`**

Specifies the data source that is matched with the data rows in `<target-table>` joining on `<merge-predicate>`. `<table-source>` can be any `<table-set>`.

`<alias>` is an alternative name to reference `<source-table>` in `WHEN` clauses and predicates.


**`[ [ SCALAR ] [ ,...n ] ]`**
TBD

**`ON <merge-predicate>`**

Specifies the conditions on which `<table-source>` joins with `<target-table>`, determining the matching and can be any valid `<predicate>` not resulting in cartesian join.

If `<merge-predicate>` is not specified, source and target must share row type and matching implies rows equal by value.

If `<merge-predicate>` does not resolve for any row sub-type between the target and source it potentially creates `NOT MATCHED` conditions `BY TARGET` and `BY SOURCE` on rows that otherwise are equal by value.


**`[ WHEN MATCHED [ AND <target-predicate> ] THEN <merge-matched> ] [ ...n ]`**

Specifies that all rows of `<target-table>`, which join the rows returned by `<table-source>` ON `<merge-predicate>` or the implied join when `ON` predicate not present, and satisfy `<target-predicate>` (when present), result in some action according to the `<merge-matched>` clause.

`WHEN MATCHED` clause without `AND <matched-predicate>` implies unconditionally apply the `<merge-matched>` action.

If two or more `WHEN MATCHED` clauses are specified only the last clause may be unaccompanied by `AND <matched-predicate>`. 

The first `<matched-predicate>` evaluating to true determines the `<merge-matched>` action.

If there is no unconditional `<merge-matched>` action, it is the same as specifying `NOP` for unconditional action.


**`[ WHEN NOT MATCHED [ BY TARGET ] [ AND <unmatched-target-predicate> ] THEN <merge-not-matched> ] [ ...n ]`**

Specifies the action on `<target-table>` for every row returned by `<table-source>` ON `<merge-predicate>` that doesn't match a row in target-table, but satisfies `<unmatched-target-predicate>`, if present. The action to take is specified by the `<merge-not-matched>` clause.

`WHEN NOT MATCHED BY TARGET` clause without `AND <unmatched-target-predicate>` implies unconditionally apply the `<merge-not-matched>` action.

If two or more `WHEN NOT MATCHED BY TARGET` clauses are specified only the last clause may be unaccompanied by `AND <unmatched-target-predicate>`. 

The first `<unmatched-target-predicate>` evaluating to true determines the `<merge-not-matched>` action.

If there is no unconditional `<merge-not-matched>` action, it is the same as specifying `NOP` for unconditional action.


**`WHEN NOT MATCHED BY SOURCE [ AND <unmatched-source-predicate> ] THEN <merge-matched>`**

Specifies that all rows of `<target-table>`, which don't match the rows returned by `<table-source>` ON `<merge-predicate>`, and that satisfy any additional search condition, are updated or deleted according to the `<merge-matched>` clause.

`WHEN NOT MATCHED BY SOURCE` clause without `AND <unmatched-source-predicate>` implies unconditionally apply the `<merge-matched>` action.

If two or more `WHEN NOT MATCHED BY SOURCE` clauses are specified only the last clause may be unaccompanied by `AND <unmatched-source-predicate>`. 

The first `<unmatched-source-predicate>` evaluating to true determines the `<merge-matched>` action.

If there is no unconditional `<merge-matched>` action, it is the same as specifying `NOP` for unconditional action.

When no rows are returned by `<table-source>`, columns in the source table can't be accessed, and therefore the `<merge-matched>` action cannot reference columns in `<table-source>`.

### Remarks

When `<target-table>` is updated in place or `<new-table>` specified as a base `<table>`, the command potentially results in a state change of the Obelisk agent.

Cross ship merges are not allowed.

In the case of multiple `WHEN MATCHED` or `WHEN NOT MATCHED` and overlapping predicates, the cases are processed in order, so the first successful case takes precedence.

Tables in the namespace *sys* cannot be merged into.

At least one of the three `MATCHED` / `NOT MATCHED` clauses must be specified, but they can be specified in any order.

`INSERT`, `UPDATE`, or `DELETE` actions specified on `<target-table>` are limited by any constraints defined on it (when it is a base `<table>`), including unique indices and any cascading referential integrity constraints. 

It `<target-table>` is updated in place, or a `<new-table>` created, every `INSERT` clause must account for all columns in `<target-table>`. Inserting fewer columns results in a new row sub-type, which is allowed when creating a virtual `<table-set>`.

Any `<binary-operator>` referencing a column each from `<target-table>` and `<source-table>` satisfies the requirement that `ON <merge-predicate>` not produce a cartesian join. However, it is to be noted a cartestian join cannot be entirely prevented depending on column contents. 

### Produced Metadata

`@@ROWCOUNT` returns the total number of rows [inserted=@ud updated=@ud deleted=@ud].

### Exceptions
`<target-table>` does not exist
`GRANT` permission on `<target-table>` violated
`<source-table>` does not exist
`GRANT` permission on `<source-table>` violated
`<new-table>` already exists
referential integrity violation on the updated `<target-table>`
unique key violation
  -- for updateable `<target-table>` unique key violation is a violation of the primary index or any other unique index defined on the table
  -- for producing new base `<table>` output, `<target-table>` primary index determines unique key violations
  -- for producing `PASS-THRU` output, columns referenced in `<merge-predicate>` determine unique key violations for row sub-types that include all of the referenced columns
  -- for producing `PASS-THRU` output when `<merge-predicate>` is not present, or the produced row sub-type does not include all of the referenced columns, the entire row by value determines unique key violations
