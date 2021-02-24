# FAQ

## Other DSC features

**I'm done with the DSC introductory tutorials. What next?**

[This document](first_course/Syntax_Tips) demonstrates some of the most useful syntax not covered in introductory tutorials. We believe it is a good next read. 
You can then read the rest of this FAQ page for other topics that interest you, or, to take a quick look at our [Reference Manual](reference/reference).

**My DSC run failed with an error. What should I do?**

Well, the bug might be yours or ours. DSC software is still under active development. If you catch one of our bug please [post an issue](https://github.com/stephenslab/dsc/issues) with a minimal example of DSC file and command executed that allows us to reproduce the bug. It is difficult to fix an issue without being able to reproduce it on our end first. If it is difficult to come up with a minimal working example it is also helpful if you could upload your DSC file for us to diagnose.

If it is a bug on your end, DSC should raise a complaint and ask you to fix the issue, as [demonstrated on this page](first_course/Debug_Tips).

**The introductory tutorials are benchmarks implemented in R. Can I work with other languages?**

Current implementation of DSC works with R, Python and Shell, and provides implicit data handling for R and Python modules. 
You can find in [here](advanced_course/5_Minutes_Python) a Python example, and [here](advanced_course/5_Minutes_RPY) preliminary support to mixing R and Python codes in benchmark.

Additionally DSC provides experimental support for Rmd files to run R benchmarks, see [this tutorial](advanced_course/Rmd_Executable) for details.

**My benchmark is more complicated than the 3-step paradigm ("simulate", "analyze" and "score"). Can I still use DSC?**

Most likely yes. DSC should allow you to run multiple legit pipelines with one or many steps (in DSC's term, modules), as demonstrated in [this toy example](advanced_course/Multiple_Pipelines).

**Can I use DSC to prototype my methods at the "research stage" so that I do not have to migrate code to DSC late?**

Possibly yes, as demonstrated in this [prototyping tutorial](first_course/Prototype_Tips).

**Can I load module developed for another DSC project into my current DSC project without copying the code?**

Yes, we have a preliminary `%include` feature to achieve it. Please find it in the [reference manual](reference/DSC_Configuration) for details.

**I wish DSC has feature *X* to make my benchmarking easier. Can you do that for me?**

Before you [make a feature request](https://github.com/stephenslab/dsc/issues) please take a look at our [Unsupported Features](reference/Unsupported_Features) page. These are features we have implemented but decided to keep hidden in order to make DSC a light-weight program. We appreciate your feedback if you some of these features attractive and that we should officially support them.

## Running DSC benchmarks

**How do I run DSC on a remote computer?**

[Here is a tutorial](advanced_course/Remote_Computations) for running DSC on a remote computer such as HPC cluster.

**I want to share my benchmark for my manuscript that allows others to reproduce with little hassle. What's the best way to do it?**

We suggest using Docker. [Here](advanced_course/DSC_Docker) is a tutorial on dockerizing your benchmark.

**I notice that simple benchmarks are a lot slower to run in DSC than in, say, an equivalent R script. What is going on?**

In short, there are data communication and workflow overhead. Please read a discussion on performance on [this page](advanced_course/DSC_Data).

## DSC under the hood

**I'm curious how DSC handles data implicitly. How does it work?**

[This page](advanced_course/DSC_Data) has a discussion on how  DSC handles data communication and storage for R and Python languages.

**Why is DSC written in Python?**

DSC relies heavily on [Script of Scripts (SoS)](https://github.com/vatlab/SOS) project, a Python-based workflow system. 
Core features in DSC are directly implemented in SoS whenever applicable. DSC also depends on a number of other Python packages [listed here](reference/Implementation_Details).

## Installation troubleshoot

**I am new to `conda`. Do you have advice for setting it up?**

Here we provide some suggestions for installing [Miniconda](https://conda.io/miniconda.html) with Python 3. (The instructions below worked for Miniconda3 4.4.10 -- future versions may have a different 
installation procedure.)

First, download the version Miniconda built for your operating system. On a Mac computer, for example, open up a terminal and run these commands:

```
chmod +x Miniconda3-latest-MacOSX-x86_64.sh
./Miniconda3-latest-MacOSX-x86_64.sh
```

Follow the prompt to install it (use `ctrl+F` a couple of times to quickly jump to the end of the Licenses if you have read them before). At the end of installation, the installer will ask you something like this:

```
Do you wish the installer to prepend the Miniconda3 install location
to PATH in your /home/<user_name>/.bashrc ? [yes|no]
[no] >>>
```

If you are not familiar with `conda`, our recommendation is to type `no` for now. Then the installer would say something like:

```
You may wish to edit your .bashrc to prepend the Miniconda3 install location to PATH:
export PATH=/<path_to_conda>/bin:$PATH
Thank you for installing Miniconda3!
```

The next step is important: open an empty text file `~/.bash_conda`, copy the "`export PATH=...`" line **from your own terminal output (not from above text!)** to this file, and save the file. Then type

```
source ~/.bash_conda
```

to load your new Python 3 environment. **In the future, each time when you open a new terminal to run DSC you need to run `source` with this file**. If you do this often, you may want to add this line to your `.bashrc` file.

**What do I do if I already have `conda`, but not python >= 3.6?**

You have two options: (1) upgrade your Python software to the latest version, or (2) remove your conda installation, and install a new one from scratch.

1. Upgrade to Python 3.6

Run the following to upgrade your Python to 3.6:

```
conda install python=3.6.3
```

2. Start from scratch

The safer option is to install from scratch. To remove your existing installation, first figure out where it is installed. For example:

```
$ which python
/home/osboxes/miniconda3/bin/python
```

Next, remove `/home/osboxes/miniconda3`:

```
rm -rf /home/osboxes/miniconda3
```

Then follow the provided instructions to install Anaconda or Miniconda.

**What do I do when I do not have permission to install Python packages?**

If you did not install Python, it is possible that you will not have permission to install packages. To work around this permissions issue, add the `--user` switch to the `pip` command:

```
pip install --user dsc
```

*Important note:* The `--user` switch will install packages to the `~/.local` hidden directory. This may cause problems if `dsc` is upgraded at a later date without the `--user` switch.

**What to do if I try to run `dscquery` in RStudio, and it complains that the `dsc-query` command is not found?**

If you are using DSC in RStudio on Linux, you will need to adjust your `~/.Renviron` settings. To edit that file from Rstudio,

```r
usethis::edit_r_environ()
```
which will create `~/.Renviron` and open it for you to edit on. Then for example, if your `dsc-query` is in `/home/osboxes/miniconda3/bin` (use `which dsc-query` to figure this out) then your `~/.Renviron` should look like:

```
$ cat ~/.Renviron
PATH=/home/osboxes/miniconda3/bin:${PATH}
```

and restart `R` to load the setting.

On MacOS this file may be found at `/Library/Frameworks/R.framework/Versions/Current/Resources/etc/Renviron` (your platform may vary).


## Contribute

**I would like to help improve DSC documentation. Where should I start?**

The wiki is mostly written in Markdown format with suffix `.md`. Jupyter's `.ipynb` format for interactive documents are also when necessary. We welcome your contributions -- for starters please follow the [`README`](https://github.com/stephenslab/dsc-wiki/blob/master/README.md) of the wiki source repo to set up the software environment for editing.
