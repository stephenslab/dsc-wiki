This documents finalizes proposals on terminology and extraction 
from [here](initial_thoughts_on_terminology_and_extraction.md) and discussions
in [github issues 68 - 74](https://github.com/stephenslab/dsc2/issues).

# Terminology
## DSC script terminology
To adopt

* Module
  * Module input and output (`$` variables)
  * Module instance: when a module is executed given input and parameters
* Pipeline
  * Pipeline input and output
  * Pipeline variable
  * Pipeline instance: when a pipeline is executed given input and parameters
  * Pipeline seed
* Ensemble of pipelines
  * A group of modules or pipelines as an entity with well defined functionality  
* Variables
  * Input / output / parameters are all variables
  * Input / output are public (or external) variables accessible to other modules 
  * Parameters are private (or internal) variables local to a module
  
To banish
* Block
* Step

To discuss
* We have not yet defined DSC. Is it a "benchmark" running multiple pipelines?

## DSC result meta-data terminology
Change `depends` to `parent`; change `master` to `pipeline`

## New syntax
1. Remove `exec` and `.alias` for `exec`, and replace the old `block` concept with using module directly
```yaml
ash : ash.R
  seed: ...
  return: ...
```
2. For multiple similar modules the succinct definition is:
```yaml
ash.hu, ash.n : ash.R
  seed: ...
  return ...
```

Or,

```yaml
method1, method2 : xxx.R, yyy.R
  seed: ...
```

and for module derivation:

```yaml
method1, method2 (ash.hu, ash.n): xxx.R, yyy.R
```

3. Module groups. This has not been discussed but we can do something in DSC section like:

```yaml
DSC:
  define: method = (method1, method2), 
          preprocess = split * normalize, 
          simulate = (simulate1 * process_simulate1, simulate2)
  run: simulate * preprocess * method * score
```

# Result extraction
We have discussed this in [this ticket](https://github.com/stephenslab/dsc2/issues/72) and [this ticket](https://github.com/stephenslab/dsc2/issues/71).

From our discussion I get an impression that if users can understand how meta data tables are connected as relational tables, 
it is perhaps more appealing to adopt some simplified version of SQL syntax, ie let's create a DSC query language based on SQL. 

## An SQL like interface
The simplification I have in mind is to automatically guess and join tables so that users do not have to write JOIN clause. 
For example users type:

```sql
select score_beta.mse
where runash.mixcompdist = "normal" and datamaker.nsamp = 1000
```

Then internally we'll have to figure out 

1. Tables `score_beta`, `runash` and `datamaker` are involved (via parsing the query)
2. `score_beta` depends on `runash` and `datamaker`, and `runash` depends on `datamaker` (via information stored in `pipeline` table)
3. Complete a JOIN statement to properly put together the relational tables and propagate the SQL query
```sql
select score_beta.result
from score_beta
inner join runash 
on score_beta.parent = runash.id
inner join datamaker
on runash.parent = datamaker.id
where runash.mixcompdist = "normal" and datamaker.nsamp = 1000
```
4. Execute propagated query to obtain output file names, for example `1.rds`. This is what we get after running the SQL-style query.
5. Extract desired quantity in R:
```r
dat = readRDS('1.rds')$mse
```
6. Other than extracting results, we also support extracting parameters, for example:
```sql
select score_beta.n
where runash.mixcompdist = "normal" and datamaker.nsamp = 1000
```
would be translated to 
```sql
select score_beta.n
from score_beta
inner join runash 
...
```
and step 5 will be skipped because this quantity should be immediately available in meta database.

## How much do we resemble SQL?
Again even this simplified SQL style interface requires users to understand the organization of meta data. I'm thinking we should implement a command to display this information nicely -- maybe output to an HTML file? Any R/Rstudio widgets for lists of tables that I can borrow? And if it is easier to do it in R we should build this in shinydsc instead?

Another protential problem is that it is then tempting to write:

```sql
select avg(score_beta.mse)
...
```
But this will be invalid syntax because under the hood we do not store values of `mse` in the meta-data. Instead we query the output file name and extract `mse` from there. There are 2 ways around this: 

1. Use a partial SQL (more constrained) syntax hybrid with command switch:

```bash
dsc -e mse:score_beta --condition "runash:mixcompdist = 'normal' and datamaker:nsamp = 1000"
```
which will still be translated to the SQL query above and use R to extract results. That is to say, we do not claim to adopt a full version of SQL but rather only the "WHERE" clause.

2. We parse the quantity `mse` from the SQL-like query, extract the quantity from RDS file to swap with the meta table (in memory), and perform query directly. The upside is one can use a number of SQL functions for `SELECT` statement and there is no need to further process the output. The downside is apparently implementation difficulties. 

**I'm leaning towards solution 1, but comments welcomed**

## Default field name syntax and behavior in ensemble case
So far we require one to use `module_name.variable` syntax to extract a quantity. But let's make it default that when only `module_name` is specified one can extract the module name. This is a shortcut to `module.name` interface [we've discussed before](https://github.com/stephenslab/dsc2/issues/72). This is particularly useful for ensembles. Suppose we have an ensemble `ash = (ash_hu, ash_n)`. Then running 

```sql
select score_beta.mse, datamaker.nsamp, ash 
where ...
```
will make a table that looks like:


| mse   |     datamaker.nsamp      |  ash |
|----------|:-------------:|------:|
| xx |  1000 | ash_hu |
| xx |  1000   |   ash_n |
