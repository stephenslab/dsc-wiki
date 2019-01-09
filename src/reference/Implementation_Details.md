# Implementation details

DSC is implemented in Python 3. It relies on a number of libraries:

*  DSC relies intensely on codes from [`SoS`](https://github.com/vatlab/SoS) project for the execution of modules, which implements job dispatch and management via [`networkx`](https://networkx.github.io/) and, different from other timestamp-based workflow tools, a file signature system via [`xxHash`](https://cyan4973.github.io/xxHash/). Development of DSC is contributed directly to `SoS` whenever approperate.
*  [`sympy`](http://www.sympy.org/en/index.html) is used to expand DSC benchmark specification into pipelines, and to expand logic for `@FILTER` decorator.
*  [`pandas`](http://pandas.pydata.org/) is used to ensure proper conversion between R and Python data frames. It is also used to manipulate output data.
* [`scipy`](https://www.scipy.org) provides a `sparse` module that supports storing `scipy.sparse` type of matrix to DSC default storage format for Python. 
* [`pytables`](http://www.pytables.org) provides support to HDF5 format for hierarchical data storage as DSC default storage format for Python.
* [`sqlalchemy`](https://www.sqlalchemy.org) supports `dsc-query` via SQL-like syntax.

In addition,

* Preliminary cross-language communication from R to Python is implemented in [`rpy2`](https://rpy2.bitbucket.io/), and from Python to R using [`reticulate`](https://github.com/rstudio/reticulate). This might be replaced in future versions with some data bus implementation in the SoS project.
