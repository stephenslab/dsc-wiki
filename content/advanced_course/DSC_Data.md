# DSC data storage

This documentation discusses how DSC variables and parameters are handled and stored. The former is relevant to how one think about data flow when developing the benchmark; the latter is relevant to how parameters are used in 1) user provided scripts when executing benchmark and 2) user specified filter conditions when making queries on results.

## DSC variables

DSC variables are module input and output. Since a module input is always output from another module we focus our discussion on handling of module outputs.

When working in pure R or Python environments users do not have to worry about how module outputs are stored, because all data objects will flow across modules without loss of information using serialized files. Specifically we use [`RDS`](http://www.inside-r.org/r-doc/base/saverds) for R, and `pickle` for Python. Under the hood one such file is generated per module instance to include all output variables.

For mixed languages, currently for R and Python, our solution is to use an `rpy2` interface to convert between `RDS` and `pickle` data to communicate between modules. Caution that information exchanges is no longer loss-less (see [these codes](https://github.com/stephenslab/dsc/blob/ad84ac2254204e955d2ec575ef48e7b27436be76/src/dsc_io.py#L35) for how it works -- we will continue to improve these utility functions to support more type exchanges). In the future we may switch to `HDF5` to support more languages. 

In sum, for R and Python scripts users do not need to worry about files when thinking about DSC variables, though bearing in mind the caveat that mixed language communication is not loss-less and only "shareable" types of objects should be used to communicated cross language. 


### A note on performance

Saving and loading intermediate files can be costly in both execution time and disk space; as a result you may notice that it seems to take DSC rather long time to complete a job compared to directly running R or Python scripts involved to complete a job. On the other hand, archiving outcome of computational routines in the form of serialized data files makes it possible to re-use existing results, thus beneficial in the long run, particularly for projects where computational steps are not trivial and there is a need to actively add new computational routines to existing DSC framework.

Other "overhead" of DSC include:

1. Executing every single module instance as separate external commands, eg. `Rscript script.R` rather than running all in one opened R session. This helps parallel to many nodes on a cluster, yet can appear to be slower for light jobs on a local computer.
2. Workflow related features, such as building execution graph, archiving file hash and checking them.

## DSC parameters

### Basic behavior

| type | DSC interface | DSC processed |
|:-----:|:-----:|:-----:|
|un-quoted string| `NULL`, `TRUE` | `NULL`, `TRUE` |
|quoted string| `"a"`, `'a'` | `"a"`, `'a'` |
|int|`1`, `1.0`|`1`, `1`|
|float|`3.14`|`3.14`|
|1-D vector|`(1,2,3)`|language specific|

### Advanced behavior

**FIXME: document `R()`, `R{}` etc or at least refer to where they are documented; document 1-D vector for different languages; document nested vector**
