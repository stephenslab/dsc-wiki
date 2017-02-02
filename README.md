# dsc-wiki
Documents / write-up for Dynamic Statistical Comparison
https://stephenslab.github.io/dsc-wiki

## Edit web pages

The web pages are edited using Jupyter notebook. 
The `*.ipynb` files are found under folders in `docs/src`.

To revise the wiki, you need to have sos kernel for Jupyter installed:

```
pip3 install sos
```

Then you can open up a notebook via:

```
jupyter notebook xxx.ipynb
```
and start editing. You may find [this page](http://jupyter-notebook.readthedocs.io/en/latest/examples/Notebook/Working%20With%20Markdown%20Cells.html) useful if you have not familiar with Jupyter Markdown Cells.

After editing, you can save the notebook and edit.

## Update webpage themes

These templates controls the theme of the website: 

```
./docs/src/documentation/toc_doc.tpl
./docs/src/tutorials/toc_tut.tpl
./docs/src/homepage/homepage.tpl
```
You do not need to edit these templates unless you want to change the look of the web pages.

## Update website

First navigate to `development` folder. The script `release` can be used to update the website. Command to update the entire website is:

```
./release update-website
```

If you want to check changes offline, you can run one (or all) of these commands:
```
./release convert-documentation
./release convert-homepage
./release convert-tutorials
```
The first time executing this script can take a while, but after that, it will keep track of changes you made to files and only compile the ones that have been changed. Under the hood, the script will convert Jupyter notebook files to HTML files, and push the website to github.io.
