# Terminology

This document defines a list of DSC jargons. We will use these terms throughout the DSC documentation. Here we focus on fundamental concepts. Other jargons, particularly a whole class of various *operators*, will be defined and explained at the same time in [DSC modules](DSC_Configuration) and [DSC benchmark](DSC_Execution) documentations.

## DSC file (or DSC script)
A [YAML](http://yaml.org) flavored text file (yet not YAML compatible!) that configures DSC **modules** and **benchmark**.

### Code block (or block)
A piece of code that starts at (and includes) a line where there is no indentation and ends at (and excludes) another line where there is no indentation.

### Property
A line of code that has a "key: value" syntax: the name of the property is on the left side of `:`, followed by the contents of the property on the right side.

## Module

A module is a block that takes *input* and produces *output*, and otherwise has no side effects. It is defined by an executable (or inline code), and (optionally) a set of *parameters* and *decorators* that determine the behavior of the code. Each module must have a unique name, which will be useful for referring to that module later. We use a $ prefix to distinguish variables that are inputs and outputs from a module, vs parameters. 

## Module flavors

*parameters* and *decorators* characterize the *flavor* of a module. That is, the same module with different parameters is a different module flavor. *Module* is a succint way to specify a number of syntactically exchangable modules of different flavors. Each module flavor has a unique set of parameter combination:

- *parameters*: a set of fixed values that distinguishes flavors of modules from each other in a module.
- *decorators*: a mechanism to modify how parameters are passed to the module

## Module instance
A module instance is what is created when a module is executed in practice. It is module with specific:

* *module input*: the set of inputs to the module
* *module output*: the set of outputs produced by executing the module

## Module ensemble and pipeline

A module ensemble is a collection of alternating modules that solves the same problem (analogous to machine learning ensemble). A pipeline is a sequence of concatenating modules to perform a series of computational tasks. A pipeline, in its simplest form, is a module. 

### Valid pipeline

A pipeline is valid if, for each module in the pipeline, the *input* are *output* of (at least one) previous module in the sequence.


### Pipeline ensemble

Similar to module ensembles, a pipeline ensemble is a collection of alternating pipelines that solves the same problem. For example if a module ensemble `M` contains modules `M1` and `M2`, then a pipeline ensemble can be created as `M -> N`, which in fact is ensemble of 2 pipelines `M1 -> N` and `M2 -> N`.


### Full pipeline

A pipeline whose first module does not require *output* from another module, thus can be executed as is.

## Pipeline instance

Pipeline instance is a sequence of Module instances. It results from actually executing an instance of a pipeline on data.

- *pipeline input*: the input to the first module instance in a pipeline instance.
- *pipeline output*: the set of all outputs produced by all module instances in a pipeline instance (not just the final module instance).

## Pipeline variable

Any output variable from any module in the pipeline (will often also be an *input* to another module). Pipeline variables are passed through the pipeline to be available to other modules, and a key feature of DSC is that it facilitates this process. A pipeline variable is created for each output variable of each module. These variables are then available as potential input variables to subsequent modules in the pipeline. They are also saved, and so are available at the end of pipeline execution for inspection (and also potentially for input into other pipelines to be run).

*Note: "Module" may be used as a synonym for "Module flavor" or "Module instance" when the potential ambiguity is clear from the context; "Pipeline" may be used as synonym for one of "pipeline", "full pipeline", or "pipeline instance" when the potential ambiguity is clear from the context. For example, "pipeline input/output" must mean "pipeline instance input/output". "Ensemble" may mean either "module ensemble" or "pipeline ensemble".*

## DSC benchmark

DSC benchmark is a collective term for all pipelines specified in a DSC file (or via `dsc` command line interface).

You may glance over some [sample DSC scripts](../examples#advanced-examples) to have an idea of DSC syntax. It is also recommended that you read the [DSC introduction](../first_course/Intro_DSC) before diving into the details throughout the rest of the documentation on this site.
