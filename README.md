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

## Edit website organization

Use a text editor to modify the file `cfg/toc.yml`.

## Automatic deployment

We use [this Action repository](https://github.com/xinhe-lab/sos-dockerfile-action) to create a github `Action`
to build the website automatically once a commit is received. Here is how it was configured:

1. Create the [`.github/workflows/jekyll.yml`](https://github.com/stephenslab/dsc-wiki/blob/master/.github/workflows/jekyll.yml) file.
2. Create a [personal access token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) if you dont have one.
3. Add the token to [`secrets`](https://github.com/stephenslab/dsc-wiki/settings/secrets) with name `ACESS_TOKEN` and value `username:token`.
4. Go to [settings](https://github.com/stephenslab/dsc-wiki/settings) of the repository, in "GitHub Pages" section change "Source" to `gh-pages-branch`.

After these settings, you can make changes to source codes in this repository and the changes will be reflected on the [wiki website](https://stephenslab.github.io/) a minute or two, after your changes are pushed to the `master` branch of this repository. You can track the progress under [`Actions`](https://github.com/stephenslab/dsc-wiki/actions) tab.

## Build the website manually

You can skip this section if you are using the "Automatic deployment" method above.

The website is built using [`jupyter-book`](https://github.com/jupyter/jupyter-book). We implemented a SoS workflow to streamline the process. You should have SoS installed if you have installed DSC.

### First time build

To build the site for the first time on your computer you need to download `jupyter-book` and create the docker image for relevant tools to compile it. To do so, run

```
./release.sos setup
```

This command requires that you have `pip` installed on your computer.

### Update website

To build the site, simply type:

```
./release.sos
```
This command requires that you have `docker` installed and configured on your computer.

### Preview your update

To preview changes before pushing it, run:

```
./release.sos serve
```

and enter URL `http://0.0.0.0:4000/dsc-wiki/overview.html` to your browser address bar to preview.

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