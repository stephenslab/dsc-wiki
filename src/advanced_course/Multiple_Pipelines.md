# Multiple DSC pipelines

In this tutorial we further expand benchmark of the DSC problem described in [DSC Introduction](../tutorials/Intro_DSC.html), to demonstrate the use of multiple pipelines (pipeline ensembles) in DSC. Material used in this document can be found in [DSC vignettes repo](https://github.com/stephenslab/dsc/tree/master/vignettes/one_sample_location_winsor).

## Configuration
The DSC problem is similar to what we have previously worked on, i.e. comparison of location parameter estimation methods. This time we simulate data under *t* distribution (df = 2) and Cauchy distribution. Then before estimating location parameter using mean or median method, there is an **optional** `transform` step where we provide two methods for *Winsorization*. This results in two DSC pipelines:

*  simulate -> estimate -> score
*  simulate -> transform -> estimate -> score

The DSC problem is fully specified as:

```yaml
#!/usr/bin/env dsc

normal: normal.R
  n: 100
  $data: x
  $true_mean: 0

t: t.R
  n: 100
  df: 2
  $data: x
  $true_mean: 3

winsor1, winsor2: winsor1.R, winsor2.R
    x: $data
    @winsor1:
      fraction: 0.05
    @winsor2:
      multiple: 3
    $data: x

mean: mean.R
  x: $data
  $est_mean: y

median: median.R
  x: $data
  $est_mean: y

sq_err: sq.R
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
      transform: winsor1, winsor2
      analyze: mean, median
      score: abs_err, sq_err
    run: simulate * (analyze, transform * analyze) * score
    exec_path: R
    output: dsc_result
```

where `transform` module ensemble contains:

```r

  ==> ../vignettes/one_sample_location_winsor/R/winsor1.R <==
  ##  replace the extreme values with limits
  winsor1 <- function (x, fraction=.05)
  {
     if(length(fraction) != 1 || fraction < 0 ||
           fraction > 0.5) {
        stop("bad value for 'fraction'")
     }
     lim <- quantile(x, probs=c(fraction, 1-fraction))
     x[ x < lim[1] ] <- lim[1]
     x[ x > lim[2] ] <- lim[2]
     return(x)
  }
  x = winsor1(x, fraction)

  ==> ../vignettes/one_sample_location_winsor/R/winsor2.R <==
  ## move the datapoints that are x times the absolute deviations from mean
  winsor2 <- function (x, multiple=3)
  {
     if(length(multiple) != 1 || multiple <= 0) {
        stop("bad value for 'multiple'")
     }
     med <- median(x)
     y <- x - med
     sc <- mad(y, center=0) * multiple
     y[ y > sc ] <- sc
     y[ y < -sc ] <- -sc
     return(y + med)
  }
  x = winsor2(x, multiple)

```

As a result, the previous `analyze` step is now a pipeline ensemble of `(transform * analyze, analyze)`.

## Execution

To run the benchmark

```bash
cd ~/GIT/dsc/vignettes/one_sample_location_winsor
```

```bash
./settings.dsc -c 30
```

```
INFO: Checking R library dscrutils@stephenslab/dsc/dscrutils ...
INFO: DSC script exported to dsc_result.html
INFO: Constructing DSC from ./settings.dsc ...
INFO: Building execution graph & running DSC ...
[#####################################################################################] 85 steps processed (85 jobs completed)
INFO: Building DSC database ...
INFO: DSC complete!
INFO: Elapsed time 9.494 seconds.
```
