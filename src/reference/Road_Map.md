# Release 1.0 roadmap

## Unit tests

### Module names
- [x] module name cannot start with `pipeline_`
- [?] module names have to be SQL friendly
- [!] modules that are identical in every way except names
- [x] module names match number of executables

### Parser
- [] More tests to @FILTER
- [x] More tests to @ALIAS
- [x] More tests to @CONF
- [x] Module inherit omitting exec
- [x] No multiple module input `$x`, `$y` or any mixture of them with module parameters
- [!] All module output in the same block should have same name (a required good practice)
- [] `DSC::run` we support only `()` `*` and  `,`
- [x] Module names / parameters cannot start / end with `_` and cannot have `.` in them
- [x] Duplicate module / parameter names
- [] Different length of params in different exec. e.g. mybeta = 1,2,3 vs. mybeta = (4,5,6) will lead to file lock fail. 
- [] Strings ending with `,` intentionally
- [] Check if @ALIAS is of the right type (is a number or str?)
- [] Check if all parameter names are of the right type
- [x] `@FILTER` cannot have pipeline variables `$`
- [x] Packages installed from github also has version option

### Execution
- [] Identical tasks will result in complaint. check for identical jobs ie same parameter twice 
- [] Both in `DSC::run` and in `--target`: what if the first module has upstream dependency? Should catch and report an error.
- [] Unsupported keywords in `DSC` block
- [] Bad pipeline logic specification (resulting in failure as said in #22 )
- [] Looped steps. Actually this should be a feature when desired ...
- [] Downstream pipeline did not use any of upstream variables
- [] All modules are valid (defined)
- [x] Find some Rmd source code and test if they work as executables
  - `mashr` intro works

### Query
- [x] dsc-query strip path for dsc_output argument

### Misc
- [x] Do not write library installed files if installation fails

## Documentation

Add these related discussions to documentation

### Best practices
- [] RE seeds -- users should ensure seeds for modules are always the same, when applicable.

### Examples
- [x] Convert all previous examples to new syntax
- [] Add a tutorial that compares computation time / speed between modules
- [] Add a tutorial for benchmark output managing, eg, remove / rerun specified steps and moving project from one computer to another
   - Explain how DSC signature works
- [] Add a documentation page on remote execution, and a tutorial for it (`ash` example)
- [x] Add a doucmentation for `dscrutils`, and a tutorial on data extraction using [`one_sample_location` example](https://stephenslab.github.io/dsc-wiki/tutorials/Explore_Output.html); and update [`ash` example](https://stephenslab.github.io/dsc-wiki/tutorials/Intermediate_R_1.html) to include result exploration

## Engineering

- [] Use HDF5 to replace msgpack and reimplement IO_DB to only load the chunk necessary.
- [] Optimize `build_result_db` and `build_io_db` via line profiler.

## Small features
- [!] Add exec `depend` property to track source files
- [x] Create a switch / or --debug switch to generate mock run file
- [!] Pipeline seed batch has to be used / tested; based on total number of jobs distribute it smartly.
- [x] Remove old Rlib info files
- [x] Fix github R package arbitary paths
- [!] Add tags for queries
- [x] Support `(N,P):(100,1000)`
- [!] Unsupport nested tuples `((100,200),(300,400)), ((9,8))` -- i actually have attempted to handle this in R
- [!] Properly handle grouped input eg `g: (N,P)` (then in the table has to have 2 columns g_N and g_P) -- no need. just query with `"(N,P)"` as a string, otherwise users should use paired parameter.
- [x] `file()` / `file(ext)` behavior is reversed ... need to fix
- [x] Replace eg `simulate_n` with `simulate:n` in the column names
- [] Reimplement the underlying `args` and `sys.argv` for plugins -- make them more general
- [x] Support `Rmd` file as executable
- [x] Rmd file chunk name
- [x] Make operator `Python()` smarter, along the lines of `R()` operator
- [x] #98 
- [x] #99

## Major features

Many were existing features removed due to new syntax and SoS advances etc. We need to bring them back in.

### Enhanced interface syntax
- [x] `inline` executables

### R interface
- [x] Make operator `R()` smarter: basically make a `dscrutils::run_r()` function that runs input string as R code and format result as a comma separated string. Raise an error if it fails to format.
- [!] **New data exchange format in HDF5**
  - [x] Might stick to `rpy2` until we need to support Matlab
- [x] New data extraction interface / basic data exploration features in R
- [x] A more self-contained way to load DSC related functions: a companion R package eventually?

### Python interface
- [x] Switch from RDS/rpy2 to HDF5

### Shell command executable related issues
- [] Multiple output files
- [] Executable command options
    ```
    `exec` specifies the names of executable computational routines as well as their command line arguments if applicable. For example an `exec` entry reads:

     exec: datamaker.R, ms $nsam $nreps -t $theta -seed $seed
     ```
 - [] index slicing
    ```
    Index for parameters, for example `exec: makeped.py $data $output[1]` where `output` parameter takes the form of `output: (1.ped, 1.map), (2.ped, 2.map)`. In this case `output[1]` will only use the first value of each parameter group.
    ```

### Engineering
- [x] optimize performance / minimize overhead to the best of my knowledge
   - this is never ending -- i mostly only deal with noticible bottleneck and I use line profiler to identify the culprit.

### Large scale computations
- [x] `--host` option
  - To check: `scp`, `ssh` commands are available
  - To sync by DSC: 
    - the output folder
    - the host config file
- [!] CONF `merge` feature:
   ```
   `inline`: True or False, of whether or not an R script is executed inline with the next procedure instead of producing return files. This feature is useful when the cost of computation for a procedure is trivial compared to the cost of storing its output. For example if a simulation procedure is simply `runif(500000)` it makes more sense to save this line of code and execute it inline with the next step, rather than to save a vector of 500,000 random numbers to disk.
   ```

## Known issues

SoS issues that needs to be fixed:
- [x] Build mode not working
- [x] `stderr` should remove empty files
- [x] Hang on dead-lock

SoS issues that cannot be fixed:

- Multiple loads of I/O data for each task distribution