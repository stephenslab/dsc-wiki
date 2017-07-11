# dsc-wiki
Wiki site & writeup for Dynamic Statistical Comparison
https://stephenslab.github.io/dsc-wiki

## Edit web pages

The web pages are edited using Jupyter notebook. 

To revise the wiki, you need to have sos kernel for Jupyter installed:

```
pip3 install sos
```

Then you can open up a notebook via:

```
jupyter notebook xxx.ipynb
```
and start editing. You may find [this page](http://jupyter-notebook.readthedocs.io/en/latest/examples/Notebook/Working%20With%20Markdown%20Cells.html) useful if you have not familiar with Jupyter Markdown Cells.

After editing, you should save the notebook before exit.

## Update website

The website is built with [jnbinder](http://github.com/gaow/jnbinder) (see [this repo](https://github.com/stephenslab/ipynb-website) for a demonstration of how it works).

To build the site, simply type:

```
./release
```
