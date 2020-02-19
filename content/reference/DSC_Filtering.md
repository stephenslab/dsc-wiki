# DSC filter syntax

This document specifically focus on the syntax of `@FILTER` in `dsc` (for users) and `-c` option in `dsc-query` (for developers).

## For users

DSC filtering syntax, when applied in `@FILTER`, selects parameter combinations to allow for only a subset of modules can stem from a module definition.

The basic structure for a filtering statement `@FILTER` is

```yaml
C_i = {parameter}_i {condition operator} {value}
C = C_1 {logic operator} C_2 {logic operator} ...
```

Where we support

* condition operators: `=, ==, >, <, >=, <=, !=, in`
* logic operators: `AND`, `OR`, `NOT`, or derived compound logic, eg `((NOT (a AND b) OR c) AND d)`

Notice that `in` logic will have to use `[]`, eg, `in [1,2,3]`, not `in (1,2,3)` because `()` is reserved for specifying order of operations (precedence). Misuse of `()` will lead to parser error. 

Here is an example:
```yaml
simulate: sim.R
    n: 10, 20, 150, 200
    @FILTER: n > 100
method: method.R
    p1: 0.1, 0.9
    p2: 0.2, 0.8
    @FILTER: p1 < 0.5, p2 < 0.5
```

When multiple conditions are involved (separated by comma `,`), eg. `p1 < 0.5, p2 < 0.5` above, they will be connected by the `AND` logic. The setting after filter is:

```yaml
simulate: sim.R
    n: 150, 200
method: method.R
    p1: 0.1
    p2: 0.2
```

For more complex logic one might have to explictly use `OR`, for example:

```yaml
@FILTER: p1 < 0.5 OR p2 < 0.5
```

will only rule out the combination of `(p1, p2) = (0.1, 0.2)` in the example above.

## For developers

`dsc-query` command can serve as the core to writing extension packages to explore DSC benchmark results. The command option is `dsc-query -c`, which allows users to decide which specific pipeline instance to extract and explore. The syntax is similar to in `@FILTER` except instead of `{parameter}_i`, here we need to specify `{module.parameter}_i` or `{group.parameter}_i`. For example,

```bash
dsc_query ... -c "simulate.n > 100" "method.p1 < 0.5 OR method.p2 < 0.5"
```

Multiple conditions are connected by the `AND` logic, that is, the above condition is `simulate.n > 100 AND (method.p1 < 0.5 OR method.p2 < 0.5)`.