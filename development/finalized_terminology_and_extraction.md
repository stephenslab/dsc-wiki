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
```sql
select score_beta.result
from score_beta
inner join runash 
on score_beta.parent = runash.id
inner join datamaker
on runash.parent = datamaker.id
where mixcompdist.runash == "normal" and nsamp.datamaker == 1000
```
4. Execute propagated query to obtain output file names, for example `1.rds`. This is what we get after running the SQL-style query.
5. Extract desired quantity in R:
```r
dat = readRDS('1.rds')$mse
```
Again even this simplified SQL style interface requires users to understand the organization of meta data. I'm thinking we should implement a command to display this information nicely -- maybe output to an HTML file? Any R/Rstudio widgets for lists of tables that I can borrow? And if it is easier to do it in R we should build this in shinydsc instead?

Another protential problem is that it is then tempting to write:

```sql
select avg(mse)
from score_beta 
...
```
But this will be invalid syntax because under the hood we do not store values of `mse` in the meta-data. Instead we query the output file name and extract `mse` from there. There are 2 ways around this: 

1. Use a partial SQL (more constrained) syntax hybrid with command switch:

```bash
dsc -e mse:score_beta --condition "mixcompdist:runash == "normal" and nsamp:datamaker == 1000"
```
which will still be translated to the SQL query above and use R to extract results. That is to say, we do not claim to adopt a full version of SQL but rather only the "WHERE" clause.

2. We parse the quantity `mse` from the SQL-like query, extract the quantity from RDS file to swap with the meta table (in memory), and perform query directly. The upside is one can use a number of SQL functions for `SELECT` statement and there is no need to further process the output. The downside is apparently implementation difficulties. 
