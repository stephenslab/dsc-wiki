# Command interface

DSC implements 2 command programs, `dsc` and `dsc-query`, for executing DSC and extracting result from executed benchmarks, respectively.

## DSC main program

```bash
dsc -h
```

```
usage: dsc [--target str [str ...]] [--truncate] [--replicate N] [-o str]
           [-s option] [--touch] [--clean option] [-c N] [--ignore-errors]
           [-v {0,1,2,3,4}] [-d] [--host file] [--to-host dir [dir ...]]
           [--version] [-h]
           DSC script

positional arguments:
  DSC script            DSC script to execute.

Customized execution:
  --target str [str ...]
                        This argument can be used in two contexts: 1) When
                        used without "--clean" it overrides "DSC::run" in DSC
                        file. Input should be quoted string(s) defining one or
                        multiple valid DSC pipelines (multiple pipelines
                        should be separated by space). 2) When used along with
                        "--clean" it specifies one or more computational
                        modules, separated by space, whose output are to be
                        removed or replaced by a (smaller) placeholder file.
                        (default: None)
  --truncate            When applied, DSC will only run one value per
                        parameter. For example with "--truncate", "n: R{1:50}"
                        will be truncated to "n: 1". This is useful in
                        exploratory analysis and diagnostics, particularly
                        when used in combination with "--target". (default:
                        False)
  --replicate N         Overrides "DSC::replicate" to set number of
                        replicates. Will be set to 1 when "--truncate" is in
                        action. (default: None)
  -o str                Benchmark output. It overrides "DSC::output" defined
                        in DSC file. (default: None)

Maintenance:
  -s option, --skip option
                        Behavior of how DSC is executed in the presence of
                        existing results. "default": skips modules whose
                        status have not been changed since previous execution.
                        "sloppy": skips modules whose timestamp are newer than
                        their upstream modules. "none": executes DSC from
                        scratch. "all": skips all execution yet build DSC
                        database of what the specified benchmark is supposed
                        to look like, thus making it possible to explore
                        partial benchmark results. (default: default)
  --touch               "Touch" output files if exist, to mark them "up-to-
                        date". It will override "--skip" option. Note that
                        time stamp is irrelevant to whether or not a file is
                        up-to-date. Files will be considered to "exist" as
                        long as module name, module parameters and variables,
                        module script name and command arguments remain the
                        same. Module script content do not matter. The output
                        files will be "touched" to match with the current
                        status of module code. (default: False)
  --clean option        Behavior of how DSC cleans up output folder to save
                        disk space. Use option "all" to remove all output from
                        the current benchmark. "purge", when used without "--
                        target", cleans up everything in folder "DSC::output"
                        irrelevant to the most recent successful execution of
                        the benchmark. When used with "--target" it deletes
                        specified files, or files from specified modules or
                        module groups. "replace", when used with "--target",
                        deletes files as "purge" does, but additionally puts
                        in placeholder files with "*.zapped" extension. When
                        re-running pipelines these "zapped" files will not
                        trigger rerun of their module unless they are directly
                        required by a downstream module that needs re-
                        execution. In other words this is useful to remove
                        large yet unused intermediate module output. (default:
                        None)

Runtime behavior:
  -c N                  Maximum number of CPU threads for local runs, or job
                        managing sockets for remote execution. (default: 8)
  --ignore-errors       Bypass all errors from computational programs. This
                        will keep the benchmark running but all results will
                        be set to missing values and the problematic script
                        will be saved when possible. (default: False)
  -v {0,1,2,3,4}, --verbosity {0,1,2,3,4}
                        Output error (0), warning (1), info (2), debug (3) and
                        trace (4) information. (default: 2)
  -d                    Output benchmark execution graph animation in HTML
                        format. (default: False)

Remote execution:
  --host file           Configuration file for remote computer. (default:
                        None)
  --to-host dir [dir ...]
                        Files and directories to be sent to remote host for
                        use in benchmark. (default: [])

Other options:
  --version             show program's version number and exit
  -h, --help            show this help message and exit
```

Here we elaborate on some of options we did not have space to elaborate on the interface:

*  `-v` controls verbosity level. Default level is 2 (recommended), which displays necessary runtime info and uses a progressbar to display DSC progress. This verbosity level is typically good enough to hide trivial information yet report back errors. When these prompts are not sufficient to fix problems, it is very likely you run into a software bug. It would be very helpful if you could reproduce the bug with increased verbosity level (eg `-v4`) and post the problem to a [github issue](https://github.com/stephenslab/dsc/issues).

* `--target`: this option takes multiple input. 
  * When used without `--clean` it overrides `DSC::run`, where DSC benchmark is defined. For example, benchmark in DSC file
  
      ```yaml
      run: simulate * method * score
      ```
      
      can be re-defined with, for example `--target "simulate * method"` so that the pipeline `simulate * target` will be executed instead. Using this option, one can execute DSC bit by bit to debug, eg, `"simulate"`, then `"simulate * method"` and finally `"simulate * method * score"`.
  * When used with `--clean` it specifies the module(s) whose output are to be "clean"-ed up (defined by behavior specified in `--clean`). Therefore only names of modules are valid input in this context.
* `--skip`: unlike with `Make` / `Snakemake` that determines whether or not to re-execute based on time stamps, DSC creates HASH for modules that takes into consideration all input parameter, input and output module variables, and the content of the module script if applicable. When all these information agree with a previous execution it will by default skip those runs. This behavior can be changed by this `--skip` option. 
  * `--skip none` will re-execute everything: it will remove and ignore any existing output files. 
  * `--skip sloppy` will skip modules whose output is newer than input. This is a simple `Make` style check. It is "sloppy", but is a lot faster than checking and saving file signatures. It is recommanded for use when benchmarks are immediately re-executed to recover some failures without having to worry about potential output file corruption or computer clock skew.
  * `--skip all` will not perform any module computations. It will only construct the execution meta-data and create a DSC database that one can query from. That is, `dsc <script> --skip all` followed by `dsc-query <output> -o` will help one understand the expected results from specified DSC benchmark. This can also be used as sanity check when benchmark is only partially completed. If you are uncertain about the scale of the benchmark, for example, it is recommanded to run DSC with `--skip all` and use `dsc-query <output> -o` to view the benchmark structure.
* `--clean all`, `--clean purge`, `--clean purge --target` and `--clean replace --target`: these options are *not* meant to delete files generated by modules. They are meant to downsize the benchmark intermediate data without triggering reruns. The first approach is via `--clean purge`: in DSC we keep track of script signatures and assign unique output files to each "version" of the script. As a result different versions of output are saved to disk. `--clean purge` allows one to remove those obsolete versions when only the latest successful run is meant to be kept. The second approach is `--clean purge --target` which remove files, modules or module groups specified by `--target`. The third approach is via `--clean replace --target ...`, which, instead of removing the output file for given modules, replaces them with a file suffixed by `*.zapped`. This will remove output files from specified modules without triggering rerun of benchmark, unless the upstream of these modules have changed. `--clean replace` is particularly useful to remove large intermediate module output to save disk space. Finally, `--clean all` deletes everything generated by the DSC.
* `-c` configures parallel computing. Since DSC is designed to be executed in either local or remote computers, `-c` configures the number of CPU threads used on a local computer; or number of threads used to manage jobs such as checking and saving signatures for files on remote computers, when used with `--host` option. This number should be specifically configured if one wants to use more (or less) computing power on a desktop. On a remote compute typically no more than 6 processes is enough to handle job scheduling, check and caching.

## DSC query program

This is a companion program to `dsc` that can be used to extract results from benchmark.


```bash
dsc-query -h
```

```
usage: dsc-query [-h] [--version] -o str [--limit N] [--title str]
                 [--description str [str ...]] [-t WHAT [WHAT ...]]
                 [-c WHERE [WHERE ...]] [-g G:A,B [G:A,B ...]]
                 [--language str] [--addon str [str ...]]
                 [--rds {omit,overwrite}] [-f] [-v {0,1,2,3}]
                 DSC output folder or a single output file

An internal command to extract meta-table for DSC results (requires 'sos-
essentials' package to use notebook output).

positional arguments:
  DSC output folder or a single output file

optional arguments:
  -h, --help            show this help message and exit
  --version             show program's version number and exit
  -o str, --output str  Output notebook / data file name. In query
                        applications if file name ends with ".csv", ".ipynb"
                        or ".xlsx" then only data file will be saved as result
                        of query. Otherwise both data file in ".xlsx" format
                        and a notebook that displays the data will be saved.
                        (default: None)
  --limit N             Number of rows to display for tables. Default is to
                        display it for all rows (will result in very large
                        HTML output for large benchmarks). (default: -1)
  --title str           Title for notebook file. (default: DSC summary &
                        query)
  --description str [str ...]
                        Text to add under notebook title. Each string is a
                        standalone paragraph. (default: None)
  -t WHAT [WHAT ...], --target WHAT [WHAT ...]
                        Query targets. (default: None)
  -c WHERE [WHERE ...], --condition WHERE [WHERE ...]
                        Query conditions. (default: None)
  -g G:A,B [G:A,B ...], --groups G:A,B [G:A,B ...]
                        Definition of module groups. (default: None)
  --language str        Language kernel to switch to for follow up analysis in
                        notebook generated. (default: None)
  --addon str [str ...]
                        Scripts to load to the notebooks for follow up
                        analysis. Only usable in conjunction with "--
                        language". (default: None)
  --rds {omit,overwrite}
                        Convert Python serialized files to R serialized files
                        (default: None)
  -f, --force           Force overwrite existing query result files (default:
                        False)
  -v {0,1,2,3}, --verbosity {0,1,2,3}
                        Output error (0), warning (1), info (2) and debug (3)
                        information. (default: 2)
```

### To query result

The main goal of `dsc-query` is to extract results from benchmark given conditions. Although `dsc-query` works as is, we are extending it to meet language specific demands by creating separate software packages that wraps this command and enhances it -- the approach differs from language to language and will be documented in language specific manner. Therefore we will not provide in-depth documentation to this program.

Currently supported languages specific libraries are:

- R: `dscquery()` function for [`dscrutils` package](https://github.com/stephenslab/dsc/tree/master/dscrutils).

### To dump single file from DSC benchmark to text

`dsc-query` can also be used to convert to text file single benchmark output file in `rds` or `pkl` format, along with a scripts to reproduce the result. For example:

```bash
dsc-query dsc_result/simulate/data_1.pkl -o data.out
INFO: Loading database ...
INFO: Data dumped to text files data.out and data.out.script.
```

`*.out` file contains data in plain text, and `*.script` contains the script that generated the data as well as the time elapsed executing the script.