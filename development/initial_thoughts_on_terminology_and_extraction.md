# Terminology:

- Module: A module is a piece of code that takes input and produces output.
  It is defined by an executable (or inline code?), and (optionally) a set of parameters that determine the behavior of the code.
  (It may be important to note that the parameters are considered to be part of the module specification, not an addendum to it,
  so the same executable with different parameters is a different module.)
  Each module must have a name, which will be useful for referring to that module later.
  We require the module names to be distinct from one another, with the exception of "multi-modules" (see later).
  We use a $ prefix to distinguish variables that are inputs and outputs from a module, vs parameters.

  Conceptually: $input_var -> module = (exec, param) -> $output_var

  For example, a module called `lasso` might run lasso on inputs $x and $y, and produce output $beta_est.
  The module might consist of code `glm` plus parameters (type= lasso, lambda=CV) [get syntax here?]

- Pipeline: A pipeline is a sequence of modules. (or, possibly, a set of initial inputs plus a sequence of modules. One can
  simply consider the initial inputs to be a simple module that produces those inputs...). The name of a pipeline
  is given by the sequence of modules separated by :, for example module1:module2:module3

- Pipeline Output: The pipeline output is defined to be the values of all the output variables output by all modules in the pipeline.


# Extracting information about a pipeline:

A key thing we want to be able to do is extract information about a pipeline.
Conceptually a pipeline creates an object p (actually a collection of files), which contains all this information.
We want to be able to extract things from p. These would certainly include:

`p$[modulename]$output` : a named list containing the values of the output variables of `[modulename]`

and probably also:

`p$[modulename]$exec`  : the value of the executable of `[modulename]`
`p$[modulename]$param`  : a named list containing the values of the parameters of `[modulename]`
`p$[modulename]$input` : a named list containing the values of the input variables of `[modulename]`

`p` is itself a named list of modules, indicating which modules were run in the pipeline.
So `names(p)[i]` indicates which module was run at step i of the pipeline.

## Edge case: pipelines with modules that are used more than once.

It is conceivable someone might run a pipeline with the same module used more than once.
For example, `p= normal:norm:analyze:norm:mse` where `norm` is a normalization module, used twice here.

I'm not sure we want to support this, but if so then to distinguish them
these module instances could be referred to by their full path in the pipeline:
so the two different norm modules would be
`p$normal:norm` and `p$normal:norm:analyze:norm`.


# Extracting information from a set of pipelines

Now consider we have run a bunch of pipelines, creating a set of pipeline objects
`p=(p_1...p_n)`. Of course, we can extract information from each pipeline as above.

A common thing we want to do when comparing pipelines is create a data frame summarizing results of the pipelines
for comparison.

The most typical case is that each column of the dataframe is either a module name,
or a pipeline variable (we will also want to allow parameter values.. to be discussed).

Here the idea is illustrate by example:

``res = create_data_frame(p, scenario =c(norm,t), method=c(mean, median), score = score)``

This would take the pipeline output `p` and
create a data frame with three columns, named scenario, method and score.
(The syntax scenario=, method= and score= and intended to indicate the names of the columns of the dataframe.)

There will be one row for each pipeline that ran one of the modules ``(norm,t)`` and one of the modules ``(mean,median)``.
[If any pipeline runs both modules in a set then an error will
be thrown since the idea here is to compare mutually exclusive modules.]

The scenario column will contain the name of a module: either "norm" or "t" depending on whether norm or t was run in the pipeline.

The method column will contain either "mean" or "median" depending on whether mean or median was run in the pipeline.

The score column will contain the final value of the `$score` pipeline variable at the end of the pipeline.
(that is, it will search back through the pipeline, from the end,
to find which module last output a variable called $score, and output that value).

So the syntaxes supported are:
`name = c(mutually exclusive modules)`
`name = (atomic) pipeline variable`

we would also like to support extraction of parameters, executables, and  along the lines of
`name = modulename$param$n`
`name = modulename$input$x`
`name = modulename$output$y`

to access the parameters, input or output of arbitrary modules.
And combine these to allow access to mutually exclusive modules.
For example
`res = create_data_frame(p, scenario =c(norm,t), method=c(mean, median), score = score,
n= c(norm$param$n, t$param$n))`

would add a column "n" containing the parameter value n from either the norm module or the t module, depending on
which one was run in that pipeline.

