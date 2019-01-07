# Prototype in DSC

Although DSC is a benchmarking tool, you might still be able to utilize DSC when you are in a "research mode", or the prototyping stage. Starting directly with DSC to build mini-benchmark for methods prototyping saves the efforts of having to migrate your code over to DSC down the line when you seriously consider expanding your initial comparisons.

In prototyping stage, you might find command options `--target` and `--truncate` are of particular relevance. In brief, `--target` accepts:

- A single or a sequence of modules
- A single or a sequence of module groups
- A single `run` flag

and `--truncate` enables running a fraction of DSC benchmark relatively quickly to ensure everthing is correct. Please read on for details.

## Test out one module at a time

It is highly recommanded that you check the correctness of DSC modules as you develop them. Do not run the entire benchmark unless you have checked it module by module: that is, only add in the next module when you are sure the first module works well. Command options `--target` and `--truncate` can be used for this purpose, for example for a DSC benchmark:

```yaml
DSC:
  define: 
      simulate: normal, t
      estimate: median, mean
  run: simulate * estimate * mse
```

When the benchmark is tested for the first time, one should at least run the following to ensure the first 2 modules work well:

```bash
dsc file.dsc --target normal --truncate -o prototype
dsc file.dsc --target t --truncate -o prototype
```

Here option `-o` will write results to a separate folder called `prototype` (or any name you want to call it) that you can safely remove after done prototyping.

Then move on to testing next modules:

```bash
dsc file.dsc --target "normal * mean" --truncate -o prototype
dsc file.dsc --target "normal * median" --truncate -o prototype
```

and finally:

```bash
dsc file.dsc --target "normal * median * mse" --truncate -o prototype
```

to test `mse`. When everything looks good, run:

```bash
dsc file.dsc 
```

You can also use module groups in `--target`:

```bash
dsc file.dsc --target simulate --truncate -o prototype
```

will run both `normal` and `t` modules.

### Option `--truncate`

`--truncate` allows one to run one instance from a module. For example, for this DSC:

```yaml
simulate: R(x=rnorm(n))
  n: 100, 200, 300, 400
  
DSC:
  replicate: 20
```

Then running 

```bash
dsc file.dsc --target simulate
```

will result in 4 different `n` values and 20 replicates, a total of 80 module instances. However with 

```bash
dsc file.dsc --target simulate --truncate
```

It will only run the first `n` (n=100) with only 1 replicate.

## Test out a particular module downstream

`--target` can also accept temporary `run` flags. This is useful when testing out newly added modules downstream. For example in the DSC section below:

```yaml
DSC:
  define:
    get_Y: original_Y
    init: init_mnm
    fit: fit_mnm, fit_susie, fit_varbvs, fit_finemap
  run:
    first_pass: get_data * get_Y * get_sumstats * init * fit
    dap: get_data * get_Y * get_sumstats * init * fit_dap
```

Two `run` flags are defined: `first_pass` and `dap`. Clearly the difference between `first_pass` and `dap` is that `first_pass` does not have `fit_dap` in its `fit` group, but `dat` has only `fit_dap` not any other modules for `fit`. As their name suggests, `first_pass` are module that has been tested to work, as our first pass to a problem. `dap` include modules that we are currently working on, which is `fit_dap`. To prototype `fit_dap` exclusively:

```bash
dsc file.dsc --target dap
```

You can remove this flag if deemed necessary after prototyping.

## Test locally before running on a cluster system

If you are working with a cluster, we suggest that you have an interactive session on the cluster, and use `--target` & `--truncate` as instructed above to test your modules out quickly; but do not use `--host` so your test DSC runs will be local to the interactive node and you get feedback quickly. Once you are confident everything works, you can submit DSC instances as cluster jobs using `--host` option, from either your computer or from the cluster's head node. See [this tutorial](Remote_Computations.html) for details.