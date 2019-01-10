# DSC syntax: basics of modules

In this document we mainly use partial DSC examples (along the lines of [this toy](https://github.com/stephenslab/dsc/blob/master/vignettes/one_sample_location/settings.dsc) but with advanced features not used there) to introduce basic DSC syntax. Before diving into the details, you may find [DSC introduction tutorials](../first_course/first_course) a useful first-read to help better understand DSC syntax. 

We endeavor to maintain DSC syntax simple and intuitive. This documentation covers the basic DSC syntax for users to get started quickly. We will use dedicated tutorial examples on various specific user cases separatedly, such as using other languages / command tools, using DSC in exploratory phase of research projects, and working with remote computers or HPC clusters for large scale computation. (**FIXME: create these tutorials and add links to them**)

A DSC file consists of one or more syntax blocks to configure *modules*, and one block to configure *pipelines* and *benchmark*. Here we focus on discussing modules. DSC pipelines and benchmark execution will be discussed in [a separate document](DSC_Execution).

## Modules

A module block is conceptually consisted of:

* `property`
* `input`
* `parameters`
* `output`

and, optionally, `decorators` that provide customization to flavors of modules. Note that we do not use these exact terms as keywords in module syntax, yet as will be illustrated soon, these components distinguish from each other syntactically.

### Module property

Modules, the building blocks of DSC, can be minimally specified as follows:

```yaml
normal, t: rnorm.R, rt.R
    n: 1000
    $x: x
```

Here we focus on the first line (aka the "module property" line):

```yaml
normal, t: rnorm.R, rt.R
```

The two elements separated by `:` are module names and executables. The module named `normal` corresponds to `rnorm.R`, `t` corresponds to `rt.R`. For cases when there are multiple module names on the left of `:` yet only one executable on the right, eg:

```yaml
normal, t: simulate.R
```

then the two modules will share the same executable (yet, to be discussed later, possibly different module parameters).

#### Compound module executables

Multiple scripts can be connected with `+` for one module to allow them be loaded sequentially as if they are concatenated to one script. For example:

```yaml
method: utils.R + main.R
```

will load `utils.R` followed by `main.R`.

[Tuple operator](#tuple-operator) `()` can be used in conjuction with `+` to expand the logic of concatenation, as a shorthand to define multiple compound executables. For example:

```yaml
method1, method2: (utils1.R, utils2.R) + main.R
```

will load `utils1.R` followed by `main.R` for module `method1`, `utils2.R` followed by `main.R` for module `method2`.

#### Inline executables

Instead of having to use scripts to specify module executables, [language interpreter](#language-interpreters) operators can be used to define codes for modules inline. For example:

```yaml
normal: R(x = rnorm(n))
    n: 1000
    $x: x
```

It can also be combined with scripts as a concatenation:

```yaml
method: utils.R + R(res = main(...))
```

Or, 

```yaml
method1, method2: (utils1.R, utils2.R) + R(res = main(...))
```

### Module Inheritance

Modules can be *inherited* as follows, a shorthand to define new modules based on existing ones:

```yaml
normal: R( x = mu + rnorm(n) )
  n: 100, 1000
  mu: 0
  $data: x
  $true_mean: mu

shifted_normal(normal): 
  mu: 1
```

`shifted_normal` is a derived module from `normal`. The complete definition of `shifted_normal`, after expanding the derived contents, is in fact:

```yaml
shifted_normal: R( x = mu + rnorm(n) )
  n: 100, 1000
  mu: 1
  $data: x
  $true_mean: mu
```

The inheritance syntax makes module definitions not only succint but also conceptually more clear to define new modules -- in this example we can tell that `shifted_normal` is essentially `normal` with different parameters.

Module inheritance can also be used to add parameters, eg, 


```yaml
normal: R( x = mu + rnorm(n) )
  n: 100, 1000
  mu: 0
  $data: x
  $true_mean: mu

t(normal): R( x = mu + rt(n,df) )
  df: 2
```

Then `t` is inherited from `normal` with a different script and additional parameter, which will get expanded to:

```yaml
t: R( x = mu + rt(n,df) )
  n: 100, 1000
  mu: 0
  df: 2
  $data: x
  $true_mean: mu
```

### Module parameters

Each module parameter is an indented property under module property line. In the example above, `n` is module input parameter for both modules `normal` and `t`, corresponding to the variable `n` in both [rnorm.R](https://github.com/stephenslab/dsc/blob/master/vignettes/one_sample_location/R/scenarios/rnorm.R) and [rt.R](https://github.com/stephenslab/dsc/blob/master/vignettes/one_sample_location/R/scenarios/rt.R) scripts. Here `n` is set to `1000`. When set to an array-like value, eg `n: 100, 500, 1000` then effectively 3 modules are defined for `normal` and `t` each. Take `normal` for example:

* module 1: `rnorm.R` with `n` set to 100
* module 2: `rnorm.R` with `n` set to 500
* module 3: `rnorm.R` with `n` set to 1000

It is also possible to specify a parameter with groups of values, for example, `p: (0.1, 0.9), (0.2, 0.8)` will initialize 2 modules each with parameter `p` of length 2.

When multiple parameters are specified, eg:

```yaml
    n: 10, 20
    p: 0.1, 0.2
```

Combinations of parameters (Cartesian product style by default) will be assigned to all modules unless otherwise instructed via [`@FILTER`](#decorator-filter) decorator. In the example above each module will take 4 sets of parameters : `(n = 10, p = 0.1), (n = 10, p = 0.2), (n = 20, p = 0.1), (n = 20, p = 0.2)`.

To get "paired" parameters instead, the [Tuple operator](#tuple-operator) can be used on both sides of the property. For example,

```yaml
(n, p): (10, 0.1), (20, 0.2)
```

results in `(n = 10, p = 0.1), (n = 20, p = 0.2)`.

Caution that module parameter names must match with variable names, or command-line arguments, for module executables. For example, module parameter `n` is specified at DSC level and passed to [rnorm.R](https://github.com/stephenslab/dsc/blob/master/vignettes/one_sample_location/R/scenarios/rnorm.R) and [rt.R](https://github.com/stephenslab/dsc/blob/master/vignettes/one_sample_location/R/scenarios/rt.R) -- neither of these executables has definition for `n` because they rely on DSC to provide it. It is the user's responsibility to ensure that they match.

### Module output

Module output are pipeline variables that can be accessed by other downstream modules in the pipeline. These variables have a leading `$` symbol followed by variable names. For example:

```yaml
normal, t: rnorm.R, rt.R
    n: 1000
    $x: x
```

`$x` on the left hand side of `:` is a module output. Under the hood, the [`rnorm.R`](https://github.com/stephenslab/dsc/blob/master/vignettes/one_sample_location/R/scenarios/rnorm.R) script generates a variable `x`, which is an `n` vector of normally distributed numbers. By specifying `$x: x`, `x` becomes a "module output". That is, other downstream steps will be able to use it via `$x` as their input, as will be discussed later in detail.

Language specific syntax can be used to extract specific data from objects for use as module output. For example `$beta: data$meta_info$beta` extracts `beta` from an `R` nested list and save it directly as module output `beta`.

For modules whose executables are R or Python scripts, a module output can match any arbitary variable name inside the script, thus may or may not appear in module parameters. In the above example, `x` is not a module parameter. For command-line executables module output will have to be files (see [`file()` operator](#file-generator) below).

### Module input

Module input are pipeline variables generated by other upstream modules in the pipeline. Same as module output, module input has the pipeline variable syntax `$` followed by variable names. What distinguishes module input and output syntactically is whether they appear on the left side or the right side of `:`. For example:

```yaml
normal, t: rnorm.R, rt.R
    n: 1000
    $x: x

shrink: method.R
    x: $x
```

Here in the `shrink` module, `$x` is a module input, whose value will be assigned to a variable `x` that will be used in `method.R` script. The runtime environment determines which module this variable comes from. For example if the pipeline is `normal -> shrink` then module input `$x` of `shrink` is output `$x` of `normal` module.

## Decorators

The word "decorator" is borrowed from the term "decorator pattern" in object-oriented programming (a design pattern that allows behavior to be added to an individual object without affecting the behavior of other objects from the same class). A DSC decorator, when applied, will modify behavior of modules specified without impacting other modules in the same syntax block. Available decorators are:

* @ < module >
* @ALIAS
* @FILTER
* @CONF

`@<module>` is specifically used to adjust settings for one module, when multiple modules are specified in the same code block. The other 3 decorators can also be used even when only single module is present in a code block -- this typically applies to derived modules whose behavior is adjusted by decorators to distinguish from the module they inherited.

### Module as decorator

Module decorator sepcifies parameters or inputs unique to one module but not applicable to others. for example

```yaml
normal, t: rnorm.R, rt.R
    n: 1000
    @t:
        df: 5, 10
...
```

where `n` is shared by both modules but parameter `df` is only used by module `t`. Module decorator always took precedence over parameters / inputs shared by modules when assigning new variables or modify existing ones, that is:

```yaml
normal, t: rnorm.R, rt.R
    n: 1000
    @t:
        n: 200
...
```
will set `n = 200` for `t`, rather than using `n = 1000`. 

Bulk syntax is supported:

```yaml
normal, t, cauchy: rnorm.R, rt.R, rcauchy.R
    n: 1000
    @t,cauchy:
        n: 200
```

Caution that module decorators cannot be used to configure module output variables, because module output are required to be the same for all modules specified in the same syntax block.

### Decorator ALIAS

`@ALIAS` is used to adjust the way inputs and parameters are passed to modules. DSC module parameter are of "simple" types (single elements or an array of single elements). In practice parameters specification may get complicated. `@ALIAS` can be used to compose a commonly used parameter input theme: all parameters are nested inside a "key-value" system.

For example an R script `method.R` accepts one "List" variable `args` that contains `var_a` and `var_b`:

```r
f1 = function(x) { ... }
f2 = function(x) { ... }
result = f1(args$var_a) / f2(args$var_b)
```

Then instead of modifying `method.R` to take "simple" parameters, we can use `@ALIAS`,

```yaml
method: method.R
    a: 1
    b: 2
    @ALIAS: args = List(var_a = a, var_b = b)
```

such that `a` and `b` are properly consolidated into an R List `args` as `var_a` and `var_b` respectively. Currently we allow for `List()` and `Dict()` for R's List and Python's Dictionary though more object types may be supported as needed in future versions.


### ALIAS operators

ALIAS operators, `List()` and `Dict()` are used in `@ALIAS` decorator to help construct variables of nested `List` or `dictionary` structures in `R` and `Python`. For example for `R` modules:

```yaml
@ALIAS: args = List()
```
 
will convert all input / parameters the module has available, say `x,y,z` to `args <- list(x = ..., y = ..., z = ...)`. Likewise, `List()` will convert parameters to `dictionary` in Python. Partial conversion is also supported, for example `args = List(x, y)` will only convert selected variables to R list which will be translated to R code `args <- list(x = x, y = y)`.

**Note that when a variable is made into ALIAS operator it will no longer be available as is**. For example,

```yaml
n: 1
m: 2
@ALIAS: args = List()
```

Then you cannot use `m` or `n` in the module script. Rather they become `args$m` and `args$n`. To exclude variables from being included,

```yaml
n: 1
...
...
@ALIAS: args = List(!n)
```

Then for an R module every other parameters will be consolidated into R list `args`, except for parameter `n`. Multiple `!` is supported, eg, `List(!n, !m)`.


Another **important** usage of `@ALIAS` is to adjust parameter names for the module specified. For example, suppose the variable `n` in script `rnorm.R` is `n` but in `rt.R` it is `n_samples`, then we can use `@ALIAS` to adjust module `t`:

```yaml
normal, t: rnorm.R, rt.R
    n: 1000
    @ALIAS:
        t: n_samples = n
```

Then `n` is renamed to `n_samples` for input to module `t`.

When both module specific `@ALIAS` and global `@ALIAS` are to be specified, one can either use module decorator in combination with `@ALIAS`, or use wildcard `*` in addition to module specific adjustment. For example the following two code blocks are equivalent:

```yaml
normal, t, rcauchy: rnorm.R, rt.R, rcauchy.R
    n: 1000
    mu: 5
    @ALIAS:
        *: args = List(mu)
        t: args = List(mu), n_samples = n
```

```yaml
normal, t, rcauchy: rnorm.R, rt.R, rcauchy.R
    n: 1000
    mu: 5
    @ALIAS: args = List(mu)
    @t:
        @ALIAS: args = List(mu), n_samples = n
```

### Decorator FILTER

`@FILTER` can be used to modify default logic that all parameters are combined the Cartesian product style. The `@FILTER` syntax is the same as the `condition` statement in `dsc-query` command; both [documented elsewhere](DSC_Filtering). Here we elaborate on some examples:

```yaml
normal, t: normal.R, t.R
    n: 100, 200, 300, 400, 500
    k: 0, 1
    @FILTER:
        t: (n <= 300 and k = 0) or (n > 300 and k = 1)
        normal: n = 500
```

Without `@FILTER` DSC will exhaust all combinations of 5 values of `n` and 2 of `k` for both modules, creating a total of 20 parallel jobs. The `@FILTER` here states that instead of running all 20 jobs, DSC will run for `t` 3 values from `n` with `k = 0`, then run the rest 2 values of `n` with `k = 1`, which is a total of 5 jobs for `t`. Then it runs for `normal` with `n = 500` combined with 2 values from `k`, a total of 2 jobs. Therefore only 7 jobs will be executed after applying the `@FILTER`.


When no module name is specified, eg. `n`, then all modules will subject to the filter:
```yaml
    @FILTER: (n in [100,200,300] and k = 0)
```

Wildcard `*` is also supported, 

```yaml
    @FILTER: 
        *: n in [100,200,300]
        t: n = 300
```

then for `t` we restrict `n` to `300`, and for all other modules we set `n` to loop over `100,200,300`.

### Decorator CONF

`@CONF` provides interface to override certain properties in benchmark configuration section (`DSC` section), including `work_dir`, `exec_path`, `lib_path`. See [this document](DSC_Execution) for more details.

## Operators

### Tuple operator
When used to specify module parameters, tuple operator `()` simply creates grouped values as module parameters, for example

```yaml
method: method.R
    K: (1,2,3), (4,5,6)
```

With `()`, `(1,2,3)` will be translated as a group to `c(1, 2, 3)` in `R`, `(1,2,3)` in `Python`, or space separated argument sequence `1 2 3` for command-line tools. Values will be assigned in groups defined by `()` instead of separately.

When used to define [module executables](#module-property), in conjunction with concatenating operator `+` it helps matching compound executables to each module in the same block.

### Language interpreters

Currently `R()/R{}`, `Python()/Python{}`, and `Shell()/Shell{}` are supported to specify module parameters. Codes inside these operators will be interpreted while DSC parses the configuration file; output will be evaluated as parameter values. For example `n: R((1:5)*10)` results in `n: (10, 20, 30, 40, 50)` and `n: R{(1:5)*10}` results in `n: 10, 20, 30, 40, 50`. This provides handy tool for generating input parameters with R, Python or Shell languages.

`R()` and `Python()` can also be used to [create inline module executables](#module-property). They will be interpreted at runtime as part of the module executable scripts.

### Raw string indicator

In cases when we want to input a chunk of scripts as un-quoted string that may conflict with DSC parser behavior, `raw()` indicator can be used to "protect" the input content from being processed by DSC, for example:

```yaml
g: [1,2,3]
```

will result in the `Python` code

```python
g = (1,2,3)
```

because vector-like atomic types are converted to python "tuples" from DSC interface. But with `raw()` it will result in `R` code

```python
g = [1,2,3]
```

as initially specified.

Another example:

```yaml
normal: R(x <- rnorm(n,mean = mu,sd = 1))
  mu: raw(0.0)
```

will result in 

```r
x <- rnorm(n,mean = 0.0,sd = 1)
```

However replacing `raw(0.0)` with `0.0` it will result in

```r
x <- rnorm(n,mean = 0,sd = 1)
```

Caution that whatever goes into `raw()` will be treated as strings in the `condition` parameter of [`dscrutils::dscquery`](https://github.com/stephenslab/dsc/blob/master/dscrutils/man/dscquery.Rd). 

### File generator

**FIXME: multiple output file generator objects are not yet allowed, and will not be available until DSC 0.3.x. Convention of module output file will therefore subject to change.**

When a DSC module involves use of files yet to be created by a module instance, `file()` can be used to ensure a file is properly generated without racing with other module instances; or simply put, to generate unique file name strings per module instance.

File generator `file()` will generate unique files by the following conventions:

1. When used as module parameter and without an extension it generates a temporary file, eg, `cache: file()`.
2. When used as module parameter with an extension it generates files with unique names into DSC output folder. eg, `cache: file(txt)` or equivalently `cache: file(.txt)`.
3. When used as module output with an extension it generates files with unique name as the module output file.

Before explaining in detail, here is a couple of simple DSC modules to demonstrate the usage:

```yaml
t1: R(print(paste("Parameter 'file1', an un-saved tmp file: ", file1));
      print(paste("Parameter 'file2', a saved tmp file: ", file2));
      print(paste("Module output 'out', a saved and tracked file: ", out));
      write(0,out))
  file1: file()
  file2: file(txt)
  $out: file(txt)

t2: R(print(paste("Module input 'data' is previous module output 'out': ", data));
      out = read.table(data))
  data: $out
  $out: out
```

Then run:

```bash
$ dsc test.dsc --target "t1*t2"
$ find test -name "*.stdout" -exec tail -vn +1 {} \;

==> test/t2/t1_1_t2_1.stdout <==
[1] "Module input 'data' is previous module output 'out':  test/t1/t1_1.txt"
==> test/t1/t1_1.stdout <==
[1] "Parameter 'file1', an un-saved tmp file:  /tmp/RtmpxetZNc/t1_1.file1"
[1] "Parameter 'file2', a saved tmp file:  test/t1/t1_1.file2.txt"
[1] "Module output 'out', a saved and tracked file:  test/t1/t1_1.txt"
```

you see 3 types of file names printed to screen, corresponding to the 3 conventions previously introduced:

1. `/tmp/RtmpxetZNc/t1_1.file1`
2. `test/t1/t1_1.file2.txt`
3. `test/t1/t1_1.txt`


#### Extension not specified

When using `file()` without specifing the extension, it generates a file path in the system [temporary folder](https://en.wikipedia.org/wiki/Temporary_folder) and can be used as a "temp file". It will not appear in users' work directory, and as with other system temp files there is generally no need to worry about their management / maintenance. Itis useful when there is a need to create some intermediate file for a module to run, yet there is no need to keep it for trouble-shooting. In the example above, parameter `file1` is a temporary file.

#### Extension specified

`file()` with extension will result in a unique and informative basename for use in a module instance, and will result in files under the DSC output directory. When used as a module parameter, intermediate file cache are generated and saved, but will not be tracked by DSC or used in other modules. This means deleting this file manually afterwards will not trigger rerun of the pipelines involved. When used as a module output, DSC will keep track of it as pipeline variable that other modules can use. For example:

```yaml
t1: R(print(cache); write(out, 0))
  n: 1, 2, 3, 4
  cache: file(cache)
  $out: file(txt)
```

Here the output `out` is a file name string, generated by the module taking parameter `n` in 4 different values. This will result in 4 module instance each with an output. Names of these `out` files will be automatically assigned for use with the downstream pipelines.

Parameter `cache` is also a file name string, but it is not a module output. This will create a situation where a properly named file `*.cache` is generated to the output directory yet we do not keep track of it: We keep these files just in case we may want to examine them to debug.

One can also use the `.` notation for file extensions to enhance readability, for example `file(.txt)` is equivalent to `file(txt)`.

## Load modules from other files

We provide preliminary support to load modules from other files, using `%include`, eg.

```yaml
%include /path/to/other/file1
%include /path/to/other/file2
```

It will (recursively) load modules from other files. This feature is useful particularly in a collaborative development of a DSC that each developer can write their own module file and use a "master" DSC file to include them all.

## Improving DSC script readability
### Use comments
As with many scripting languages (R, Python, shell), `#` can be used to make human-readable explanation to the contents of DSC script. We suggest using single `#` to distinguish between various types of syntax groups introduced in this document, and double `##` to annotate parameters. For example:

```yaml
# Various modules to estimate location parameter
mean, median: mean.R, median.R
    # parameters
    ## set to 0 for no winsorization
    winsorize: 0, 0.02
    # input
    x: $x
    # output
    $mean: mean
    # decorators
    @ALIAS:
        median: w = winsorize
```

### Turn on YAML syntax highlighter
Although DSC script is not compatible with YAML, the syntax highlighter for YAML is good enough to enhance readability of DSC scripts. You may turn on the YAML syntax highlighter in your text editor when composing DSC scripts.
