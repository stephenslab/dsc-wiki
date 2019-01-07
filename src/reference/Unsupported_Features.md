# Unsupported features

As a continuation of the [DSC syntax documentation](../reference/DSC_Configuration.html) this page documents existing DSC features that are possibly useful yet adds complexity to DSC syntax and burden of support. We believe that DSC is well versed to handle most user cases without these features. We may formally discuss and support some of these features in the future when we deem them truly helpful to users.

## Rmarkdown based modules

See [this tutorial](Rmd_Executable.html) for detailed introduction with an example.

## Wildcard operators

### Global variable wildcard
The global variable wildcard `${}`, when used to specify module parameters, refers to variables defined in `DSC::global`.

```yaml
simulate_cosine: cosine.R
    types: ${data_functions}
...

DSC:
    global: 
        data_functions: discrete.cosine, discrete.cosine2, discrete.cosine.peaksel
```

is equivalent to

```yaml
simulate_cosine: cosine.R
    types: discrete.cosine, discrete.cosine2, discrete.cosine.peaksel
```

### Inline module input wildcard

Wildcard `$()` can be used inside language operators to specify module inputs so that they do not have to be defined separately. Here is a full example using this feature:

```yaml
#!/usr/bin/env dsc

normal: R(x = rnorm(n,0,1))
  n: 100
  $data: x
  $true_mean: 0

t: R(x = 3+rt(n,df))
  n: 100
  df: 2
  $data: x
  $true_mean: 3

mean: R(y = mean($(data))) 
  $est_mean: y

median: R(y = median($(data)))
  $est_mean: y

sq_err: R(e = ($(est_mean) - $(true_mean))^2)
  $error: e
 
abs_err: R(e = abs($(est_mean) - $(true_mean)))
  $error: e 
  
DSC:
    define:
      simulate: normal, t
      analyze: mean, median
      score: abs_err, sq_err
    run: simulate * analyze * score
    output: dsc_result
```

`$()` in inline module executables specifies the required pipeline variables. Therefore for modules `mean`, `median` and `sq_err` and `abs_err` only module output needs to be specified -- module input are defined already in this inline module executable style.

### Command argument wildcard

Wildcard `{}` can be used with module executable to specify command argument options when they refer to one of the module parameter, eg:

```yaml
module: Python(import sys; print(sys.argv[1:])) {option} constant
  option: 1, 2
  $out: 0
```

The `print` statement writes to standard output, which is redirected to files:

```yaml
$ cat t/t_1.stdout
['1', 'constant']
$ cat t/t_2.stdout 
['2', 'constant']
```

It shows that command argument `{option}` has been passed to the module as module parameters.

## Grouping operators
Currently `for_each()` and `pairs()` are supported to generate cartesian product and paired grouping of parameters. These operators makes it easier to assign values to DSC. For example:

```yaml
n: for_each(1, [1,2,3])
```

is equivalent to the cartesian product

```yaml
n: (1,1), (1,2), (1,3)
```

and
```yaml
...
  settings: pairs(${classifier}, ${kernel})
...
DSC:
  globals:
    classifier: svm, ridge
    kernel: k1, k2
```
is equivalent to:

```yaml
...
  settings: (svm, k1), (ridge, k2)
...
```

## Named `DSC::run` pipelines

```yaml
DSC:
  run: a * b * c, a * b * e
```

Is equivalent to 

```yaml
DSC:
  run:
     pipeline_1: a * b * c
     pipeline_2: a * b * e
```

From command interface, instead of `--target "a * b * c"` you can use the equivalent command `--target pipeine_1`.