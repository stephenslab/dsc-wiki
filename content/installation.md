# DSC Installation Guide

Follow these steps to get started using DSC. 

If you encounter a problem during the installation procedure, please see the ["Troubleshooting installation"](faq#installation-troubleshoot) section in the FAQ for a possible solution.

*Note:* If you have [Docker](https://www.docker.com), you can follow the [Docker instructions](advanced_course/DSC_Docker) instead of installing DSC from source. Once you have completed the Docker instructions, jump directly to Installation Step 5 below.

*Note to developers:* Please refer to the installation instructions in the `README` of the [dsc repository](https://github.com/stephenslab/dsc).

## Overview of DSC components

DSC consists of several components that interact with each other. Before beginning the installation, it is helpful to know: (1) what is being installed, (2) where DSC is installed, and (3) what software is needed to run DSC successfully.

To install DSC, you will need to have the following software on your computer:

1. [Python](http://python.org) (version 3.6 or greater).

2. Several Python modules, including NumPy and Pandas.

3. Optionally, [R](https://www.r-project.org). Although not required, to get the full benefit of DSC we recommend installing R.

The DSC software consists of the following three components:

1. A [Python module](https://docs.python.org/3/tutorial/modules.html) called `dsc`. It is installed in the same location as other Python modules (unless you choose to override the standard choice).

2. Two Python executables, `dsc` and `dsc-query`, that can be run from the command-line shell. These executables are also installed and managed by the `pip` program. It is installed in the same location as other Python executables (unless you choose to override the standard choice).

3. An R package called `dscrutils` that provides an interface for querying DSC results in R, as well as tools to run R code inside a DSC program. It is installed in the same location as other R packages.

A complete installation of DSC not only involves installing these components, but also setting up your computing environment to ensure that these components can communicate with each other. We will explain how to do this in the steps below.

## 1. Install python >= 3.6

To use DSC, you must have Python version 3.6 or greater. There are several ways you can install Python >= 3.6.

**Our recommendation:** Install Python via a [conda](https://conda.io/docs)-based package manager such as [Miniconda](https://conda.io/miniconda.html) or [Anaconda](https://anaconda.org/). If you are starting from scratch, we recommend [Miniconda](https://conda.io/miniconda.html). See [here](faq#installation-troubleshoot) for additional advice on installing and configuring Miniconda.

** Other options:** DSC will also work with standalone distributions of Python (e.g., downloaded from [Python.org](https://www.python.org)), and the instructions below should work regardless of how Python is installed on your computer. However, we recommend `conda` because it will provide easy access to various Python packages DSC depends on, thus making it a lot easier to install DSC.

## 2. Check your Python installation

DSC is distributed via [pypi](https://pypi.python.org/pypi/dsc). The simplest way to install a Python module from pypi is with `pip`. [All recent Python versions are by default bundled with pip](https://pip.pypa.io/en/stable/installing). Before running `pip`, check that you are running the version bundled with Python >= 3.6:

```bash
python --version
pip --version
```

or 

```bash
python3 --version
pip3 --version
```

If the reported Python version is or greater than 3.6.0 and `pip` is reported to come from that version (eg. `pip 9.0.1 from /path/to/python (python 3.6)`), then you are ready for the next step. 

**Important:** *In the instructions below, we assume your Python 3.6+ executable is `python`, and your pip (python 3.6+) executable is `pip`. However, you might need to replace `python` with `python3` and `pip` with `pip3`.* 

If you already have an old version of Miniconda or Anaconda installed, but you do not have Python >= 3.6, see [here](faq#installation-troubleshoot) for advice on how to proceed.

## 3. Install (or upgrade) DSC

We provide two sets of installation instructions: Python installed with `conda` (*i.e.*, Anaconda or Miniconda), and Python not installed with `conda`.


### 3a. If Python is installed with `conda` (Anaconda or Miniconda)

Using `conda`, install DSC from the conda-forge channel:

```bash
conda install -c conda-forge dsc
```

### 3b. If Python is *not* installed with `conda`

Run this command to install or upgrade DSC (and any Python dependencies that remain uninstalled):

```bash
pip install -U --upgrade-strategy only-if-needed dsc
```

However, we caution that:

* You must have both `C` and `Fortran` compilers (and accompanying libraries).

* The `pip` command may take a long time to run because several packages will need to be built from source. 

* Installation of some packages may fail. If so, try running the same command again; *sometimes running the same `pip` command a second time works!*

If you are having difficulty installing DSC and its dependnencies directly from source, we recommend switching to using `conda`. Since `conda` installs binary packages that have already been compiled, this saves you from having to configure the correct compiler settings on your local machine.

## 4. Install modules for network visualization of benchmarks (optional)

If you'd like to be able to create a network visualization of your benchmarks, you'll need to install some additional Python modules. This is an entirely optional feature which will not affect the running of your DSC benchmarks.


### 3a. If Python is installed with `conda` (Anaconda or Miniconda)

Run the following:

```bash
conda install -c conda-forge python-graphviz imageio pillow
```

### 3b. If Python is *not* installed with `conda`

Run the following:

```bash
pip install -U --upgrade-strategy only-if-needed graphviz imageio pillow
```


## 5. Verify installation of Python module

Check that the Python module is installed and recognized in your current shell environment by running this command:

```bash
pip show dsc
```

After running this command, you should see something like this:

```
Name: dsc
Version: 0.2.7.2
Summary: Implementation of Dynamic Statistical Comparisons
Home-page: https://github.com/stephenslab/dsc
Author: Gao Wang
Author-email: gaow@uchicago.edu
License: MIT
Location: /home/jsmith/anaconda3/lib/python3.6/site-packages
Requires: numpy, pandas, sympy, numexpr, sos, sos-pbs, h5py, pyarrow, sqlalchemy, msgpack-python
```

## 6. Test installation of Python executables

Run the following commands to verify that the Python executables are accessible in your current shell environment:

```bash
dsc --version
dsc-query --version
```

For both commands, you should see the software version number printed to the screen.

If you get an error, and you have verified that the Python module has been successfully installed, the most likely explanation is that the Python executables are stored in a location that is not in your command search path. In particular, this location needs to be included in the `PATH` environment variable.

*NOTE: I think it would be better to move this to the FAQ Troubleshooting section, with title, "What do I do when it says that commands dsc or dsc-query cannot be found"?*

The most reliable is to way to find the location of the executables is to run these two commands:

```bash
pip show dsc
pip show dsc --files | grep dsc-query
```

The first command gives the install location of the Python module, and the second command gives the install location of the executables *which may be relative to the Python module.* Based on this, you can run the following command in the bash shell to add the appropriate location to your command search path:

```bash
export PATH=<python-exec-path>:$PATH
```

where `<python-exec-path>` was identified from running the commands above. For example, in Anaconda the first and second install locations may look something like `/home/jsmith/anaconda3/lib/python3.6/site-packages` and `../../../bin/dsc-query`, in which case running

```bash
export PATH=/home/jsmith/anaconda3/lib:$PATH
```

should make the `dsc` and `dsc-query` commands accessible.

## 7. Install R (optional)

R is optional, but highly recommended—it is useful for querying DSC results. It is also required for running any DSC benchmarks that run R code. Follow the instructions on the [CRAN website](https://cran.r-project.org) to install R on your computer. DSC also works with [RStudio](http://rstudio.com), although an additional setup step may be required for RStudio.

## 8. Install `dscrutils` R package (optional)

The simplest way to install the `dscrutils` package is to start up R or RStudio and run the following code:

```R
install.packages("devtools")
library(devtools)
install_github("stephenslab/dsc",subdir = "dscrutils",force = TRUE)
```

This will also install the [devtools](https://github.com/hadley/devtools) package.

## 9. Ensure `dsc-query` is recognized in R (optional)

In a previous step, you verified that `dsc-query` can be run from the command-line shell. In order to query DSC results, we also need to make sure that it can be run inside your preferred R environment.

Start up R or RStudio, and run

```R
system("dsc-query --version")
```

If this outputs a version number, then you are ready to use the `dscrutils` package. If this command reports an error, then most likely you will need to fix the command search path inside R or RStudio; see the [Troubleshooting](faq#installation-troubleshoot) section of the FAQ page for instructions on how to do this.

## 10. Start your first DSC project

*If you have reached this point, you have everything you need to start working with DSC.*

Start from [here](first_course/Intro_Syntax_I) for a first course on DSC. See [here](first_course/first_course) for more introductory tutorials.
