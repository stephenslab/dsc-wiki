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
  groups: method = (method1, method2), 
          preprocess = split * normalize, 
          simulate = (simulate1 * process_simulate1, simulate2)
  run: simulate * preprocess * method * score
```

# Result extraction
We have discussed this in [this ticket](https://github.com/stephenslab/dsc2/issues/72) and [this ticket](https://github.com/stephenslab/dsc2/issues/71).

From our discussion I get an impression that if users can understand how meta data tables are connected as relational tables, 
it is perhaps more appealing to adopt some simplified version of SQL syntax, ie let's create a DSC query language based on SQL. 

The simplification I have in mind is to automatically guess and join tables so that users do not have to write JOIN clause. 
For example users type:

```sql
select mse 
from score_beta
where mixcompdist.runash == "normal" and nsamp.datamaker == 1000
```

Then internally we'll have to figure out 

1. Tables `score_beta`, `runash` and `datamaker` are involved (via parsing the query)
2. `score_beta` depends on `runash` and `datamaker`, and `runash` depends on `datamaker` (via information stored in `pipeline` table)
3. Complete a JOIN statement to properly put together the relational tables and propagate the SQL query
4. Execute propagated query to obtain output file names, for example `1.rds`. This is what we get after running the SQL-style query.
5. Extract desired quantity in R:
```r
dat = readRDS('1.rds')$mse
```
Again even this simplified SQL style interface requires users to understand the organization of meta data. I'm thinking we should implement a command to display this information nicely -- maybe output to an HTML file? Any R/Rstudio widgets for lists of tables that I can borrow? And if it is easier to do it in R we should build this in shinydsc instead?
