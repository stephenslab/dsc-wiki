# DSC in 5 Minutes with R & Python mix

This tutorials shows re-implementation of the [DSC Introduction](../first_course/Intro_DSC) mixing R and Python implementations. Source code to run this example can be found [here](https://github.com/stephenslab/dsc/tree/master/vignettes/one_sample_location_python).

If you are reading this page and are in need of R & Python communications, I suppose you might have experience interacting between R and Python, and appreciate the challenges. Data transfer between R and Python currently depends on `rpy2`. This has 2 implications: 1) information flow is no longer lossless because it is impossible to support the Python counter part for any arbitary R object (and vise versa) and 2) installation of `rpy2` and get it to work can be challenging. While I cannot provide support for `rpy2` installation, here is a [personal note](https://gist.github.com/gaow/39902e16603ffbe185ae38ff062fa266) on how I got it work on my system, possibly the hard way, but might be of interest to those who are in the same situation as I did. Additionally, 3) there is noticible performance overhead at the data transfer interface.

Data communication via a more universial and robust interface [has been proposed](https://github.com/stephenslab/dsc/issues/86). We hope to be able to implement it in a near future release.

Here is the DSC script:

```yaml
#!/usr/bin/env dsc

normal: normal.py
  n: 100
  $data: x
  $true_mean: 0

t: t.R
  n: 100
  df: 2
  $data: x
  $true_mean: 3

mean: mean.R
  x: $data
  $est_mean: y

median: median.py
  x: $data
  $est_mean: y

sq_err: sq.py
  a: $est_mean
  b: $true_mean
  $error: e
 
abs_err: abs.R
  a: $est_mean
  b: $true_mean
  $error: e 
  
DSC:
    define:
      simulate: normal, t
      analyze: mean, median
      score: abs_err, sq_err
    run: simulate * analyze * score
    exec_path: R, PY
    python_modules: numpy
    output: dsc_result
```
To execute:

```bash
cd ~/GIT/dsc/vignettes/one_sample_location_python
```

```bash
./settings_mix.dsc -c 30
```

```
INFO: Checking R library dscrutils@stephenslab/dsc/dscrutils ...
INFO: Checking R library reticulate@rstudio ...
INFO: Checking Python module numpy ...
INFO: Checking Python module rpy2 ...
INFO: DSC script exported to dsc_result.html
INFO: Constructing DSC from ./settings_mix.dsc ...
INFO: Building execution graph & running DSC ...
[#############################] 29 steps processed (26 jobs completed, 3 jobs ignored)
INFO: Building DSC database ...
INFO: DSC complete!
INFO: Elapsed time 9.688 seconds.
```
