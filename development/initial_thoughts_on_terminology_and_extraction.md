# Terminology:

- *Module*: A module is a piece of code that takes input and produces output.
  It is defined by an executable (or inline code?), and (optionally) a set of parameters that determine the behavior of the code.
  (It may be important to note that the parameters are considered to be part of the module specification, not an addendum to it,
  so the same executable with different parameters is a different module.)
  Each module must have a name, which will be useful for referring to that module later.
  We generally require the module names to be distinct from one another (with an exception to be discussed later).
  We use a $ prefix to distinguish variables that are inputs and outputs from a module, vs parameters.

  Conceptually: `$input_vars -> module = (exec, param) -> $output_vars`

  Example: a module called `lasso` might run lasso regression on inputs `$x` (covariates) and `$y` (response), and produce output `$beta_est` (regression coefficient estimates). The module might consist of executable code that implements several penalized regression methods, plus a parameter (`type= "lasso"`) that indicates the type of penalized regression (lasso).  Another module `en` might run Elastic net regression on inputs $x and $y, and produce output $beta_est. It might consist of the same executable code but a different parameter (`type="en"`). [Of course it would also be possible for two modules like this to be implemented using different executables; this example just illustrates the ideas of inputs and outputs vs parameters, and also the fact that a module is (executable+parameters) and not only the executable.]

- *Pipeline*: A pipeline is a sequence of modules. (or, possibly, a seed, and set of initial inputs plus a sequence of modules. See discussion on seed). The name of a pipeline is given by the names of the sequence of modules separated by :, for example module1:module2:module3.

- *Valid Pipeline*: A pipeline is *valid* if, for each module in the pipeline, the input variables are output variables of (at least one) previous module in the sequence.

- *Pipeline variable*: any output variable from any module in the pipeline (will often also be an input variable to another module). Pipeline variables are passed through the pipeline to be available to other modules, and a key feature of DSC is that it facilitates this process. A pipeline variable is created for each output variable of each module. These variables are then available as potential input variables to subsequent modules in the pipeline. They are also saved, and so are available at the end of pipeline execution for inspection (and also potentially for input into other pipelines to be run.)

- *Pipeline Output*: The pipeline output is defined to be the values of all the output variables output by all modules in the pipeline. 

- *Pipeline Definition*: The pipeline definition is the sequence of modules make up the pipeline (plus the definitions of these modules). It is a synonym for pipeline that emphasises we are talking about the pipeline definition and not the output.

- *Seed and input issue*: I'm still thinking about this. Do we consider the pipeline to include the seed or not? I think maybe it makes sense to think of the pipeline definition as independent of the seed. A pipeline instance would then consist of a (seed,pipeline) pair. A more general question is whether to allow inputs (eg a list of files) to a pipeline, or whether to force this kind of thing to be created by the first module (so it becomes part of the pipeline definition rather than an addendum). That is we could generalize the notion of pipeline instance to mean (input, pipeline)  (where seed is part of input) or (seed, input, pipeline). 



## Note to clarify the distinction between Parameters vs Pipeline variables:

- Parameters: are parts of a module that determine how code should behave. They are not passed through the pipeline. So subsequent modules cannot access the parameters of a previous module. (However, if necessary a module could output its parameters as an output variable to be passed through the pipeline).


# Extracting information about a pipeline:

A key thing we want to be able to do is extract information about a pipeline.
Conceptually a pipeline creates an object p (actually a collection of files), which contains all this information.
We want to be able to extract things from p.

One attractive possibility would be to be able to read the result of a pipeline into `R`, using something like:
`load_pipeline(dir,normal:mean:mse, SEED = s)`. This could return a named list, `p`,
where `names(p)[i]` is the name of the module was run at step i of the pipeline, and with elements:

`p$[modulename]$output` : a named list containing the values of the output variables of `[modulename]`

`p$[modulename]$exec`  : the value (or filename) of the executable of `[modulename]`

`p$[modulename]$param`  : a named list containing the values of the parameters of `[modulename]`

`p$[modulename]$input` : a named list containing the values of the input variables of `[modulename]`


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

