# Tips and Tricks

Once you have completed the [Introduction to DSC](Intro_DSC), 
you should be ready to write your own DSC.

This file introduces you
to some of the most convenient syntax short-cuts we have implemented
to make DSCs easier to write and read.


## Combining definitions of similar modules

Sometimes modules share much of their definition.
For example:

```yaml
mean: R(y = mean(x))
  x: $data
  $est_mean: y

median: R(y = median(x))
  x: $data
  $est_mean: y
```

Here DSC allows a shorthand syntax to define both modules:

```yaml
mean, median: R(y = mean(x)), R(y=median(x))
  x: $data
  $est_mean: y
```

## Aliasing

### Renaming a parameter

This feature allows one to use a different name for a parameter
than is used in a script. For example:

```yaml
t: R( y = rt(m, df=2))
  n: 100, 1000 
  $data: y
  $true_mean: 3
  @ALIAS: m = n
```
This defines a module with parameter `n`, and the `ALIAS` command 
tells DSC to pass the parameter value to the script variable `m` (rather than 
the default, which is to pass it to the script variable of the same name as the parameter).

This can be useful when you want two different modules to have the same
parameter names, even when the scripts use different script variables.

## Module inheritance

```yaml
normal: R( x = mu + rnorm(n) )
  n: 100, 1000
  mu: 0
  $data: x
  $true_mean: mu

shifted_normal(normal): 
  mu: 1
```