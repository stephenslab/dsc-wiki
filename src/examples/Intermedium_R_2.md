# Reproducing `simulator` package Quick Start

This tutorial reimplements the execution part of [Getting Started with Simulator](http://faculty.bscb.cornell.edu/~bien/simulator_vignettes/getting-started.html) example. We demonstrate in this tutorial how compound module executables are specified with scripts and inline executables.

Material to run this tutorial can be found in [DSC vignettes repo](https://github.com/stephenslab/dsc/tree/master/vignettes/simulator_example). It also contains the code to reproduce the original `simulator` simulation.

## DSC Specification
The problem is fully specified in DSC syntax below:

```yaml
simulate: model.R + R(m = simulate(n, prob))
  seed: R(1:10)
  n: 50
  prob: R(seq(0,1,length=6))
  $model: m

my_method, their_method: (my.R, their.R) + R(fit = method($(model)$x)$fit)
  $fit: fit

abs, mse: (herloss.R, hisloss.R) + R(score = metric($(model)$mu, $(fit)))
  $score: score

DSC:
  define:
    method: my_method, their_method
    score: abs, mse
  run: simulate * method * score
  output: simulator_results
  exec_path: R
```

## Run DSC

```bash
cd ~/GIT/dsc/vignettes/simulator_example
```

```bash
dsc main.dsc
```

```
INFO: Checking R library dscrutils@stephenslab/dsc/dscrutils ...
INFO: DSC script exported to simulator_results.html
INFO: Constructing DSC from main.dsc ...
INFO: Building execution graph & running DSC ...
[###############] 15 steps processed (428 jobs completed)
INFO: Building DSC database ...
INFO: DSC complete!
INFO: Elapsed time 35.413 seconds.
```

You may notice that for this trivial benchmark, the execution is a lot slower compared to the original implementation. This is a limitation of DSC when running lite jobs -- having to build and execute DAG, checking file signatures and monitoring runtime environment results in substential overhead. For real-world benchmarking when execution time is much longer, this overhead is perhaps tolerable because it is relatively insignificant under such scenario. Also notice that under `simulator_results` there are 420 intermediate output `*.rds` files generated, compared to only 31 `*.Rdata` itermediate files generated when you run the `simulator` version of the example. This is because the demonstrated DSC implementation is a lot more modular. You can compare the data generating code in [DSC](https://github.com/stephenslab/dsc/blob/master/vignettes/simulator_example/R/model.R) vs in [`simulator`](https://github.com/stephenslab/dsc/blob/master/vignettes/simulator_example/sims/model_functions.R) to tell the more modular setup we have adopted here -- although it is entirely possible to develop a different style of DSC that reproduces exactly the `simulator` example's output (yet stored in `rds` rather than `Rdata` format).