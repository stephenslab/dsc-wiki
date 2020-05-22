# DSC syntax: basics of benchmark execution

This document is continuation of discussion in [DSC syntax: basics of modules](DSC_Configuration). We will use toy DSC examples (including breaking down [this toy](https://github.com/stephenslab/dsc/blob/master/vignettes/one_sample_location/first_investigation.dsc)) to introduce a special syntax block called `DSC` that defines module ensembles, pipelines and DSC benchmark, as well as execution environment. This block has a reserved property keyword `DSC` and is required for all DSC scripts. In this document we refer to its contents by `DSC::<key>` where `<key>` is the identifier on the left side of `:` in each line of the `DSC` block.

## Benchmark logic operators

In building a DSC benchmark, two logic are involved: "alternating" modules, or *module ensemble*, refers to groups of modules that achieve the same goal (able to take similar input and provide the same type of output) as if they are exchangable; "concatenating" modules, or *pipelines* refers to sequences of modules that executes one after another as if concatenated into a chain of actions. These logic are implemented via `*`, `,` and `()` operators:

*  `*`: connects concatenating modules, ie, right hand side (RHS) is executed after the left hand side (LHS).
*  `,`: connects alternating modules, ie, RHS and LHS are exchangable.
*  `()`: when alternating modules and concatenating modules are combined, it is used to re-define operator precedence. By default `*` has higher precedence than `,`.

## Module ensembles and pipelines

`DSC::define` defines module ensembles and pipelines, that is, groups of "alternating" or sequences of "concatenating" modules / ensembles. For example:

```yaml
normal, t: rnorm.R, rt.R
    ...
mean, median: mean.R, median.R
    ...

DSC:
    define:
      simulate: normal, t
      estimate: mean, median
```

Here 2 ensembles are defined: `simulate`, of alternating modules `normal` and `t` for data generation, and `estimate`, of alternating modules `mean` and `median` for parameter estimation.

To illustrate pipelines and pipeline ensemble we can add an additional `winsorize` module to `estimate`, creating a pipeline ensemble called `winsorized_estimate`:

```yaml
DSC:
    define:
      simulate: normal, t
      winsorized_estimate: winsorize * (mean, median)
```

`winsorized_estimate` pipeline ensemble contains 2 pipelines `winsorize * mean` and `winsorize * median`. They are not *full pipeline* because they depend on input from `simulate`. DSC benchmark `DSC::run` will require one or multiple full pipelines -- see below for detailed discussions.

## DSC benchmark

DSC benchmark, defined by `DSC::run`, is one or multiple complete pipelines. We will use a series of examples to illustrate how benchmarks are created.

#### Example 1: styles of pipeline speicification
```yaml
run: simulate * estimate * score
```

Here `simulate` and `estimate` are module ensembles (see `DSC::define` of previous section). This is equivalent to writing:

```yaml
run: (normal, t) * (mean, median) * score
```

#### Example 2: concatenating module and pipeline ensembles

```yaml
run: simulate * (winsorize * mean, mean) * score
```
Here `simulate` is a module ensemble, `(winsorize * mean, mean)` is a pipeline ensemble and `score` is a module. DSC will run 2 flavors of pipelines: 1) that involves `winsorize` followed by `mean`, and 2) `mean` only.

#### Example 3: expansion of pipeline operators

```yaml
run: simulate * (voom, sqrt, identity) * (RUV, SVA) * (DESeq, edgeRglm, ash) * score
```

will be expanded to:

```yaml
run: simulate * sqrt * RUV * DESeq * score,
   simulate * sqrt * SVA * DESeq * score,
   simulate * identity * RUV * DESeq * score,
   simulate * voom * RUV * DESeq * score,
   simulate * identity * SVA * DESeq * score,
   simulate * voom * SVA * DESeq * score,
   simulate * sqrt * RUV * ash * score,
   simulate * sqrt * RUV * edgeRglm * score,
   simulate * sqrt * SVA * ash * score,
   simulate * sqrt * SVA * edgeRglm * score,
   simulate * identity * RUV * ash * score,
   simulate * voom * RUV * ash * score,
   simulate * identity * RUV * edgeRglm * score,
   simulate * voom * RUV * edgeRglm * score,
   simulate * identity * SVA * ash * score,
   simulate * voom * SVA * ash * score,
   simulate * identity * SVA * edgeRglm * score,
   simulate * voom * SVA * edgeRglm * score
```

#### Example 4: named pipelines

Pipelines in benchmark can have names, for example:

```yaml
run:
   pipeline_1: simulate * sqrt * RUV * DESeq * score
   pipeline_2: simulate * sqrt * SVA * DESeq * score
```

Here `pipeline_1` and `pipeline_2` are the names of pipelines in benchmark. They are only relevant for command executions (see section below). When pipeline named `default` is found, eg,

```
run:
   default: ...
   other_names: ...
```

then executing the script without additional parameters will only execute the `default` pipeline. Otherwise, all pipelines will be executed just like the case of unnamed pipelines by default.

## Command interface to DSC benchmark

By default, DSC will execute all pipelines defined in `DSC::run`. But one can override pipelines from [command line](Command_Options). For example to execute the complete `Example 1`

```bash
dsc file.dsc --target "simulate * estimate * score"
```
or a subset of `Example 1`:

```bash
dsc file.dsc --target "normal * estimate * score"
```

You can also execute a single module / ensemble **for debug purpose**. Commands below are equivalent:

```bash
dsc file.dsc --target normal t
dsc file.dsc --target simulate
```

To execute one of the two pipelines in Example 4:

```bash
dsc file.dsc --target pipeline_1
```

## Benchmark parameters

These parameters are specified in the rest of `DSC` block:

* `exec_path`: search path (or paths) for executable files
* `lib_path`: search path (or paths) for library files, such as R script to be `source`-ed or Python scripts to be `import`-ed from
* `R_libs`: check required R libraries and if not available, automatically install them from cran, bioconductor or github. 3 formats are accepted:
 * `<package>`: DSC will check / install `package` from cran or bioconductor.
 * `<package@github_repo/subdir>`: DSC will install `package` from `github_repo` on github. `/subdir` is optional -- only applicable when the package is not in the root of the repository. eg `ashr@stephenslab/ashr`, `varbvs@pcarbo/varbvs/varbvs-r`.
 * `<package (version[s])>`: DSC will install `package` and check version as required. A warning message will be generated if version do not match after force installation to the latest. It is possible to specify several versions such as `edgeR (3.12.0, 3.12.1)` or simply `edgeR (3.12.0+)`.
* `python_modules`: check required Python3 modules, and install from pip if not available.
* `container`: docker container images to use, eg, `gaow/susie-paper:latest`
* `container_engine`: optionally specify engine to run containers, can be either `docker` or `singularity`. Default is `docker`.
* `seed`: what to use for random number generator seed setting, can be either `HASH` (use a seed based on HASH of module instance script) or `REPLICATE` (use DSC replicate ID as seed). Default is `HASH`.
* `work_dir`: work directory where benchmarking will take place.
* `output`: folder name to store benchmark output files.
* `global`: defines global variables which can be used in definition of module parameters through [variable wildcard](Unsupported_Features#wildcard-operators) `$()`.
* `replicate`: number of replicate to run the benchmark (default is 1).

### Override runtime options in modules with `@CONF`

Among these DSC runtime options, the following can be customized on per-module basis:

- `exec_path`, `lib_path`, `work_dir`, `R_libs`, `python_modules`

The syntax is similar to that of `@ALIAS`. That is, values are assigned by `=`:

```yaml
simulate: simulate.R
    ...
    @CONF: exec_path = simulate_bin, lib_path = simulate_lib
```

and can be module specific:

```yaml
normal, t: simulate.R
    ...
    @CONF:
        normal: exec_path = normal_bin
        t: exec_path = t_bin
```

Multiple paths needs to be specified as a tuple, eg.

```yaml
simulate: simulate.R
    ...
    @CONF: lib_path = (simulate_lib, main_lib), R_libs = (ashr@stephenslab/ashr 2.2.7+, mashr 0.2.6+)
```

`@CONF` is designed not only to "fine-tune" the runtime environment of a module, but, as a "decorator", will change behavior of a module's execution. Specifically:

- `lib_path` when specified under `@CONF`, all relevant scripts (of the same type as the executable, eg. `R` or `Py`) will be kept track of. Changes to their content will result in re-execution of all instances under this module when running the benchmark.
- `R_libs` when specified under `@CONF` will automatically load all listed libraries via `library(...)` prior to running the module script. **Please use `DSC::R_libs` instead if this is not the desired behavior**. The same holds for `python_modules`.
- `seed` can be used to configure module specific behavior, for example `seed = REPLICATE` will use DSC replicate ID as seed for the module. This is useful in cases where consistent behavior among module instances is desired. For example for different parameter input to a statistical method, we may want to use the same seed for all these parameter inputs.

## Run DSC on HPC cluster or other remote computaters

See [this documentation](../advanced_course/Remote_Computations) for a discussion.
