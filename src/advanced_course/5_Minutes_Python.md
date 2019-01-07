# DSC in 5 Minutes with Python

This tutorials shows re-implementation of the [DSC Introduction](../tutorials/Intro_DSC.html) in Python. Source code to run this example can be found [here](https://github.com/stephenslab/dsc/tree/master/vignettes/one_sample_location_python).

The DSC script mostly the same as the Quick Start example:

```yaml
#!/usr/bin/env dsc

normal: normal.py
  n: 100
  $data: x
  $true_mean: 0

t: t.py
  n: 100
  df: 2
  $data: x
  $true_mean: 3

mean: mean.py
  x: $data
  $est_mean: y

median: median.py
  x: $data
  $est_mean: y

sq_err: sq.py
  a: $est_mean
  b: $true_mean
  $error: e
 
abs_err: abs.py
  a: $est_mean
  b: $true_mean
  $error: e 
  
DSC:
    define:
      simulate: normal, t
      analyze: mean, median
      score: abs_err, sq_err
    run: simulate * analyze * score
    exec_path: PY
    python_modules: numpy
    output: dsc_result

```

You may notice the only difference are the executables (and search path) -- now implemented in Python:
```python
==> normal.py <==
import numpy
x=numpy.random.normal(loc=0, size=n)

==> t.py <==
import numpy
x=3+numpy.random.standard_t(df=df,size=n)

==> mean.py <==
import numpy
y = numpy.mean(x)

==> median.py <==
import numpy
y = numpy.median(x)

==> abs.py <==
e = abs(a-b)

==> sq.py <==
e = (a-b)**2
```
To run the DSC,

```bash
cd ~/GIT/dsc/vignettes/one_sample_location_python
```

```bash
./settings.dsc -c 30
```

```
INFO: Checking Python module numpy ...
INFO: DSC script exported to dsc_result.html
INFO: Constructing DSC from ./settings.dsc ...
INFO: Building execution graph & running DSC ...
[#############################] 29 steps processed (29 jobs completed)
INFO: Building DSC database ...
INFO: DSC complete!
INFO: Elapsed time 6.030 seconds.
```