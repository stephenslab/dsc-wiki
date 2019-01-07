# dsc-wiki
Wiki site & writeup for Dynamic Statistical Comparison
https://stephenslab.github.io/dsc-wiki

## Edit web pages

The web pages are edited using either plain text markdown file, or, when interactive analysis is involved, Jupyter notebook with R kernel.

All source files are under `src` folder. To revise `*.md` files simply open them with your favorate text editor and make changes. To revise `*.ipynb` files you need to install Jupyter Notebook with R kernel. For example,

```bash
pip install jupyter jupyter_contrib_nbextensions
```

And in R:

```r
install.packages('IRkernel')
IRkernel::installspec()
```

Then you can open up a notebook via:

```
jupyter notebook filename.ipynb
```
and start editing. You may find [this page](http://jupyter-notebook.readthedocs.io/en/latest/examples/Notebook/Working%20With%20Markdown%20Cells.html) useful if you have not familiar with Jupyter Markdown Cells.

After editing, you should save the notebook before exit.

## Update website

To build the site for the first time on your computer you need to create the docker image for relevant tools. To do so, run

```
./release.sos docker_image
```

This command requires that you have `docker` installed and configured on your computer.

Then to build the site, simply type:

```
./release.sos build
```

## Work with Jupyter Notebooks

`nbdime` is a good tool to work with Jupyter Notebooks for a git repo. To install:

```
pip install nbdime
```

To view notebook differences, for example:

```
nbdiff <notebook_name>
```

Run this command if you want `git diff` to behave like `nbdiff` by default:

```
nbdime config-git --enable --global
```
