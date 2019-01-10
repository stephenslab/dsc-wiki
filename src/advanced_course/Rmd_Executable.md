# Convert existing Rmarkdown file to DSC executables

This tutorial demonstrates a convenient way to construct DSC based on Rmarkdown files being used in Rstudio interactive sessions. Material used can be found in [DSC vignettes repository](https://github.com/stephenslab/dsc/tree/master/vignettes/mash).

Caution that running DSC with source code provided from Rmarkdown files is meant to ease DSC development, but is more error prone because users may make more mistakes matching variables or code chunks between DSC interface and Rmarkdown documents. This feature is therefore intended to only prototyping a benchmark. Users will be discouraged with a DSC warning message to use Rmd files in finalized benchmark.

The Rmarkdown file comes from the [`mashr` package intro vigenette](https://stephenslab.github.io/mashr/docs/intro_mash.html). Here we run in DSC the steps of simulating data, compute covariance matrices (prior), and fit the `mash` model. The DSC file is specified as:

```yaml
#!/usr/bin/env dsc

simulate: R(library(mashr)) + simulate_*@intro_mash.Rmd
  n_effects: 500
  n_cond: 5
  $data: data

get_cov: R(library(mashr)) + cov*@intro_mash.Rmd
  data: $data
  $U_c: U.c 

fit: R(library(mashr)) + fit*@intro_mash.Rmd
  U_c: $U_c
  data: $data
  $m_c: m.c
  @ALIAS: U.c = U_c
 
DSC:
  run: simulate * get_cov * fit
  R_libs: mashr@stephenslab/mashr (>=0.2.6)
  output: mash_result
```

Take `simulate_*@intro_mash.Rmd` for example: it means the module executable comes from code chunks matching `simulate_*` pattern in file `intro_mash.Rmd`. The code chunk matching pattern follows from [UNIX wildcard](http://www.robelle.com/smugbook/wildcard.html) convention. When only the Rmarkdown filename (the part after `@`) is specified, all code chunks in the Rmarkdown file will be loaded.

The extracted code can be found in DSC code browser [`mash_result.html`](../external/mash_result.html). To run the benchmark:

```bash
cd ~/GIT/dsc/vignettes/mash
```


{:.output .output_stream}
```
/home/gaow/GIT/dsc/vignettes/mash
```

```sos
./settings.dsc
```

```
WARNING: Source code of simulate is loaded from intro_mash.Rmd. This is only recommended for prototyping.
WARNING: Source code of get_cov is loaded from intro_mash.Rmd. This is only recommended for prototyping.
WARNING: Source code of fit is loaded from intro_mash.Rmd. This is only recommended for prototyping.
INFO: Checking R library mashr@stephenslab/mashr ...
INFO: Checking R library dscrutils@stephenslab/dsc/dscrutils ...
INFO: DSC script exported to mash_result.html
INFO: Constructing DSC from ./settings.dsc ...
INFO: Building execution graph & running DSC ...
[#######] 7 steps processed (7 jobs completed)
INFO: Building DSC database ...
INFO: DSC complete!
INFO: Elapsed time 9.794 seconds.
```

Note that warning messages are displayed when module executables are loaded from Rmarkdown files, to remind users to finalize the DSC with formal scripts rather than some dynamic document.
