# dsc-wiki
Wiki site & writeup for Dynamic Statistical Comparison
https://stephenslab.github.io/dsc-wiki

## Edit web pages

The web pages are edited using Jupyter notebook. 

To revise the wiki, you need to have sos kernel for Jupyter installed:

```
pip install sos-notebook sos-r
python -m sos_notebook.install
```

Then you can open up a notebook via:

```
jupyter notebook filename.ipynb
```
and start editing. You may find [this page](http://jupyter-notebook.readthedocs.io/en/latest/examples/Notebook/Working%20With%20Markdown%20Cells.html) useful if you have not familiar with Jupyter Markdown Cells.

After editing, you should save the notebook before exit.

## Update website

The website is built with [jnbinder](http://github.com/vatlab/jnbinder) (see [this repo](https://github.com/stephenslab/ipynb-website) for a demonstration of how it works).

To build the site, simply type:

```
./release
```

## Update R examples

You will need to configure Jupyter Nootbook with `R` kernel. Here is what worked for me

```r
install.packages(c('repr', 'IRdisplay', 'evaluate', 'crayon', 'pbdZMQ', 'devtools', 'uuid', 'digest'))
devtools::install_github('IRkernel/IRkernel')
IRkernel::installspec()
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
