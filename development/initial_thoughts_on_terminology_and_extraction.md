# Terminology:

- *Module* (or *Module Definition*): A module is a piece of code that takes input and produces output.
  It is defined by an executable (or inline code?), and (optionally) a set of parameters that determine the behavior of the code.
  (It may be important to note that the parameters are considered to be part of the module specification, not an addendum to it,
  so the same executable with different parameters is a different module.)
  Each module must have a name, which will be useful for referring to that module later.
  We generally require the module names to be distinct from one another (with an exception to be discussed later).
  We use a $ prefix to distinguish variables that are inputs and outputs from a module, vs parameters.

  Conceptually: `$input_vars -> module = (exec, param) -> $output_vars`

  Example: a module called `lasso` might run lasso regression on inputs `$x` (covariates) and `$y` (response), and produce output `$beta_est` (regression coefficient estimates). The module might consist of executable code that implements several penalized regression methods, plus a parameter (`type= "lasso"`) that indicates the type of penalized regression (lasso).  Another module `en` might run Elastic net regression on inputs $x and $y, and produce output $beta_est. It might consist of the same executable code but a different parameter (`type="en"`). [Of course it would also be possible for two modules like this to be implemented using different executables; this example just illustrates the ideas of inputs and outputs vs parameters, and also the fact that a module is (executable+parameters) and not only the executable.]

- *Module Instance* is what is created when you actually execute a module in practice
  - module: A module definition
  - seed: value of the seed set before the module is run
  - input: the set of inputs to the module
  - output: the set of outputs produced by executing the module
  
- *Pipeline Definition*: A pipeline definition is a sequence of module definitions. 

- *Valid Pipeline Definition*: A pipeline definition is *valid* if, for each module in the pipeline, the input variables are output variables of (at least one) previous module in the sequence.

- *Pipeline Instance* is a sequence of Module instances. It results from actually executing an instance of a pipeline on data.
  
- *Pipeline output* the set of *all* outputs produced by all module instances in a pipeline instance (not just the final module instance).

- *Pipeline input* the input to the *first* module instance in a pipeline instance.

- *Module* may be used as a synonym for module definition or module instance when the potential ambiguity is clear from the context. 

- *Pipeline* may be used as synonym for either "pipeline definition" or "pipeline instance" when the potential ambiguity is clear from the context. For example, "valid pipeline" must mean "valid pipeline definition";  and "pipeline input/output" must mean "pipeline instance input/output". 

- *Pipeline Variable*: any output variable from any module in the pipeline (will often also be an input variable to another module). Pipeline variables are passed through the pipeline to be available to other modules, and a key feature of DSC is that it facilitates this process. A pipeline variable is created for each output variable of each module. These variables are then available as potential input variables to subsequent modules in the pipeline. They are also saved, and so are available at the end of pipeline execution for inspection (and also potentially for input into other pipelines to be run.)

## Terminology finalized

| where   |      old       |  new |
|----------|:-------------:|------:|
| DSC file |  block | module |
| DSC file |    step   |   ?? |
| `DSC::run` | sequence |  pipeline   |
| meta-data | depends |  parent   |
| meta-data | master |  pipeline??   |


## Seed issue: 

We definitely want to set a seed at the start of the pipeline. What about at the start of each module? My
suggestion is yes. But by default derive this somehow from the pipeline seed.


## Note to clarify the distinction between Parameters vs Pipeline variables:

- Parameters: are parts of a module that determine how code should behave. They are not passed through the pipeline. So subsequent modules cannot access the parameters of a previous module. (However, if necessary a module could output its parameters as an output variable to be passed through the pipeline).


# Extracting information about a pipeline:

A key thing we want to be able to do is extract information about a pipeline (instance).
Conceptually a pipeline instance is an object p (probably a collection of files), which contains all this information.
We want to be able to extract things from p.

One attractive possibility would be to be able to read the pipeline instance into `R`, using something like:
`load_pipeline(dir,normal:mean:mse, SEED = s)`. This could return a named list, `p`,
where `names(p)[i]` is the name of the module was run at step i of the pipeline, and with elements:

`p$[modulename]$output` : a named list containing the values of the output variables of `[modulename]`

`p$[modulename]$exec`  : the value (or filename) of the executable of `[modulename]`

`p$[modulename]$param`  : a named list containing the values of the parameters of `[modulename]`

`p$[modulename]$input` : a named list containing the values of the input variables of `[modulename]`

`p$seed`: the value of the pipeline seed

`p$input`: the input to the pipeline instance

## Edge case: pipelines with modules that are used more than once.

It is conceivable someone might define a pipeline with the same module used more than once.
For example, `normal:norm:analyze:norm:mse` where `norm` is a normalization module, used twice here.

I'm not sure we want to support this, but if so then to distinguish them
these module instances could be referred to by their full path in the pipeline:
so the two different norm modules would be
`p$normal:norm` and `p$normal:norm:analyze:norm`.


# Extracting information from a set of pipelines

Now consider we have run a bunch of pipeline instances, creating a set of objects
`p=(p_1...p_n)`. Of course, we can extract information from each pipeline instance as above.

A common thing we want to do when comparing pipelines is create a data frame summarizing results of the pipelines
for comparison.

The most typical case is that each column of the dataframe is either a module name,
or a pipeline variable. We will also want to allow other parts of the pipeline to be accessed here - for example,
parameter values used in module definitions in the pipeline.

Here the idea is illustrate by example: (syntax may need work here).

``res = create_data_frame(p, scenario =c(norm,t), method=c(mean, median), score = score)``

This would take the pipeline output `p` and
create a data frame with three columns, named `scenario`, `method` and `score`.
(The syntax `scenario=`, `method=` and `score=` and intended to indicate the names of the columns of the dataframe.)

There will be one row for each pipeline instance that involved exactly one of the modules ``(norm,t)`` and exactly
one of the modules ``(mean,median)``.
[If any pipeline runs both modules in a set then an error will
be thrown since the idea here is to compare mutually exclusive modules.]

The scenario column will contain the name of a module: either "norm" or "t" depending on whether `norm` or `t` was run in the pipeline.

The method column will contain either "mean" or "median" depending on whether `mean` or `median` was run in the pipeline.

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

