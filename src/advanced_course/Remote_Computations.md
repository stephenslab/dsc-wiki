# Running DSC on a computer cluster

Here we illustrate how DSC can facilitate remote computation. This is
useful when working with a DSC that involves intensive and/or
long-running computations; many of the computations involved are
ammenable to parallel or distributing computation, so we would like to
advantage of a high-performance computing system to speed up running a
benchmark.

## Prerequisites

We will use a simple example to demonstrate how to run DSC on a remote
computing system. Although this example is not particularly
well-suited for running on a high-performance compute cluster---it can
be easily run on a standard desktop computer, and the individual
computing tasks are very short---we will use this example to
illustrate the features of DSC for facilitating remote computation. We
will draw from the example presented in
[DSC basics, part I][dsc-intro-1]. The source code can be found
[here][one-sample-location].

Our aim is to submit it to a remote cluster to generate all the
results. Before doing so, we should make sure it works.

First, run the the "truncate" version of the DSC command to test the
script (see [here][dsc-prototyping-tips] for details):

```bash
dsc first_investigate_simpler.dsc --truncate
```

If the "truncated run" reports error, try to
[debug DSC][dsc-debugging-tips] and test again until the truncated run
works.

Now we are ready to submit the DSC to run on computer cluster.
 
## Overview of running remote jobs

DSC uses an additional configuration file and two command options
(`--host` and `--to-host`) to run on a remote system.

DSC facilicates two approaches to running remote tasks:

1. "On Host": Log in to the remote computing system ("the host"), and
run DSC with `--host` argument. When configured properly, DSC will
automatically submit jobs to the job scheduling system on the host.

2. "Local Host": Run DSC from local computer with
additional folders to be synced to the host specified by `--to-host`
option. The local computer will serve as the job dispatcher and job
monitor. This provides a way to run on hosts whose headnode cannot
execute long running `dsc` process and/or whose compute nodes cannot be
used to submit jobs.

Under the hood, DSC configures all modules and converts them to
[`SoS`][sos-docs] tasks. Interested readers may refer to
[this page][sos-docs-remote-exec] for implementation details.

*Note to RCC users at the University of Chicago:* It is recommended to
use the "On Host" mode.

## Job configuration template and command options

Using a template and in combination with the command options, DSC
allows users to configure job submission and the resource requirements
for the jobs.

Using command options, users can:

1. Submit the entire benchmark.

2. Automatically upload required files to the host for benchmarking
(when `--to-host` is used).

Users can also use SoS utility tools to manage jobs. See below for a
brief discussion of a few SoS utility commands with examples.

## Basic configuration example

We begin with an example illustrating the essential elements of a
configuration file. This example was configured for the
high-performance compute cluster run out of the University of Chicago
("midway2"), so we have called this file "midway2.yml". To use this
configuration file to run your benchmark (called "mybenchmark.dsc"),
you would log in to the remote computing system, and run the following
command: `dsc mybenchmark.dsc --host midway2.yml`.

```yaml
DSC:
  midway2:
    address: localhost
    queue_type: pbs
    status_check_interval: 120
    max_running_jobs: 10
    instances_per_job: 100
    job_template: |
      #!/bin/bash
      #SBATCH --time=6:00:00
      #SBATCH --partition=broadwl
      #SBATCH --mem=4G
      #SBATCH --exclusive
    submit_cmd: sbatch {job_file}
    submit_cmd_output: "Submitted batch job {job_id}"
    status_cmd: squeue --job {job_id}
    kill_cmd: scancel {job_id}
```

Let's walk through this configuration file step-by-step:

+ `DSC2` is required for specifying a configuration.

+ `midway2` is the label assigned to the configuration.

+ `status_check_interval: 120` means that DSC checks the job status
  every 120 seconds (2 minutes), and takes action if the job has
  failed or completed. It is important to set this interval to a
  reasonable period so as not to overload the job scheduling service
  when it is being shared with many other users.

+ `max_running_jobs: 10` the maximum number of jobs that will run at
  any one time. Again, it is important not to set this to be too large
  on a system that is shared with other users.

+ `instances_per_job: 100` tells DSC that each job should attempt to
  generate at most 100 module outputs within each job. If the DSC
  contains long-running modules, this number should be made smaller,
  otherwise each job will take a long time to complete. For modules
  that run very quickly, `instances_per_job` should be set to a large
  number to avoid overloading the job management system on a shared
  computing environment.

+ The `job_template` entry gives the initial steps that are run to set
  up the computing environment for computation in DSC. In this case,
  this is a basic bash script with additional instructions for the
  [Slurm][slurm] job scheduler. The amount of memory and the time
  limit should be adjusted for the DSC; in this simple example, the
  time limit of 6 hours is probably a vast overestimate of the actual
  time needed.

+ The `submit_cmd`, `Submitted batch job {job_id}`, `squeue
  --job` and `kill_cmd` give additional instructions on how DSC should
  interact with the job management system (in this case, the Slurm job
  management system).

This basic configuration file is sufficient to run DSC computations on
a system that uses Slurm; compute systems that use different job
management software (e.g., TORQUE) can be configured similarly.

## More advanced configuration example

DSC command option `--host` accepts a YAML configuration file that
specifies a *template* for remote jobs. **We provide support to such
configuration files on an as-need basis**, because we (the DSC
developers) can only verify and ensure the it works on system that we
have access to and use on regular basis. For example,
[here is a template](https://github.com/stephenslab/dsc/blob/master/vignettes/one_sample_location/midway.yml)
for a system running PBS type of queue via Slurm Workload Manage:

```yaml
DSC:
  midway2:
    description: UChicago RCC cluster Midway 2
    address: localhost
    paths:
      home: /home/kaiqianz
    queue_type: pbs
    status_check_interval: 60
    max_running_jobs: 60
    max_cores: 40
    max_walltime: "36:00:00"
    max_mem: 64G
    job_template: |
      #!/bin/bash
      #SBATCH --time={walltime}
      #{partition}
      #{account}
      #SBATCH --nodes=1
      #SBATCH --ntasks-per-node={cores}
      #SBATCH --mem-per-cpu={mem//10**9}G
      #SBATCH --job-name={job_name}
      #SBATCH --output={cur_dir}/{job_name}.out
      #SBATCH --error={cur_dir}/{job_name}.err
      cd {cur_dir}
      module load R
    partition: "SBATCH --partition=broadwl"
    account: ""
    submit_cmd: sbatch {job_file}
    submit_cmd_output: "Submitted batch job {job_id}"
    status_cmd: squeue --job {job_id}
    kill_cmd: scancel {job_id}
  faraway2:
    based_on: midway2
    description: Submit and manage jobs to `midway2` from a local computer.
    address: kaiqianz@midway2.rcc.uchicago.edu
  stephenslab:
    based_on: midway2
    max_cores: 28
    max_mem: 128G
    max_walltime: "10d"
    partition: "SBATCH --partition=mstephens"
    account: "SBATCH --account=pi-mstephens"

default:
  queue: midway2
  time_per_instance: 3m
  instances_per_job: 20
  n_cpu: 1
  mem_per_cpu: 2G

simulate:
  instances_per_job: 20

score:
  queue: midway2.local
```

The section `DSC` is required to provide various templates for a
number of systems. Here, `midway2` is a host provided by
[The Research Computing Center at the University of Chicago](https://rcc.uchicago.edu). Jobs
are submitted to `partition=broadwl`. Typically it has 40 cores per
node. It is recommended that users do not submit more than 60 jobs at
a time, and maximum running time should best be under 36hrs per
job. These limitations have been reflected by the `max_*` values in
the configuration.

There are also 2 "derived" queues: `stephenslab` is a special
partition on `midway2` that allows for different configurations, thus
it is derived from `midway2` via `based_on: midway2`. Also relevant is
the `faraway2`, also `based_on: midway2`, but specifies the address of
how to connect to `midway2`. Then DSC will assume that the request is
made from a local computer and try to use the "local-host" mechanism
to run jobs.

The section `default` is also required. It provides default settings
for all modules in the DSC. Available settings are:

- `queue`: name of the queue on the remote host to use, one of the
various queues defined in `DSC` section.

    - Here in the template it is set to `midway2`, which is a "On-Host" queue.
    - `<queue>.local` is convention to execute locally without submitting to PBS.

- `time_per_instance`: maximum computation time for each module
  instance.

- `instance_per_job`: how many module instances to submit as one
remote job. This is useful consolidating numerous light-weight
module instances into one jobs submission.

- `n_cpu` and `mem_per_cpu` specify the CPU and memory requirement of
a module instance.

For example for 100 module instances of `simulate` that each generates
some data in under a minute, one can specify `time_per_instance: 1m`
and `instance_per_job: 200`. Then a single job containing 200
simulations will be submitted to the host with a total of 200 minutes
computation time reserved.

Typically, `DSC` and `default` section for host configuration do not
have to be changed for different projects. Users can carefully
configure them once, and reuse for various projects. For Stephens Lab
users for example, one can take the example from above and replace
`kaiqianz` with their UChicago cnetID.

In our example, under the folder `vignettes/one_sample_location` you
should find a file called `midway.yml` as described above. You can
open it with a text editor (on a cluster use `nano` from the terminal
for example), edit it to suit your project, and save it.

*Please do not use this template without configuring the required
resources, particularly `time_per_instance` and
`instance_per_job`. They should be tailored for your project. In
proper configuration of these settings will lead to running many
small jobs (too low on `instance_per_job`) and waste of resource (too
high on `time_per_instance`).*

## Run remote jobs

If the `default` queue is a "On-Host" queue (`address: localhost`), then

```bash
dsc ... --host /path/to/config.yml
```

will configuration in `/path/to/config.yml` and submit jobs.

For the "Local-Host" mechanism (`default::address: <some URL>`), 

```bash
dsc ... --host /path/to/config.yml --to-host file1 dir1 file2
```

will additionally use `--to-host` to sync specified files and folders
to the remote, if the particular benchmark requires these files and
folders to execute (eg, data resource, shell executables, or scripts
in `DSC::lib_path`).

Caution that to successfully use `--to-host`, the command program
[`rsync`](https://rsync.samba.org) have to be available from the local
computer.

In our example, under the same folder
("/dsc/vignettes/one_sample_location"), we run

```bash
dsc first_investigation_simpler.dsc --host midway.yml
```

## Monitor and manage jobs

When jobs are submitted, you should see on the screen something like:

```
INFO: M1_9056f36343b32614 submitted to midway2 with job id 59250575
```

So there is a task ID `M1_9056f36343b32614` and job ID `59250575`. This can also be observed from your system's job queue, for example:


```
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          59250575   broadwl M1_9056f kaiqianz  R       0:04      1 midway2-0003
          59250576   broadwl M1_10b92 kaiqianz  R       0:04      1 midway2-0003
```

To check on one of the job, for example the first one:

```bash
sos status M1_9056f -v3
```

You will see information such as:

```
M1_9056f36343b32614	56ed1083fa5bd015 normal normal_normal_1	
Created 20 hr ago	Started 2 min ago	Ran for 1 sec 	
completed
```


This means that the job comes from the module `normal` and produces 1 file `normal/normal_1`. There are also some other useful info on execution stats such as memory usage.

To have more details,

```bash
sos status M1_9056f -v4
```

and the output:

```
M1_9056f36343b32614	completed

Created 21 hr ago
Started 6 min ago
Ran for 1 sec
TASK:
=====

TAGS:
=====
56ed1083fa5bd015 normal normal_normal_1

ENVIRONMENT:
============
_runtime              {'cores': 1,
 'cur_dir': '/home/kaiqianz/dsc/vignettes/one_sample_location',
 'home_dir': '/home/kaiqianz',
 'mem': 2000000000,
 'run_mode': 'run',
 'sig_mode': 'default',
 'verbosity': 2,
 'walltime': '00:03:00'}
step_name             'normal'

execution script:
================
#!/bin/bash
#SBATCH --time=00:03:00
#SBATCH --partition=broadwl
#
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=2G
#SBATCH --job-name=M1_9056f36343b32614
#SBATCH --output=/home/kaiqianz/dsc/vignettes/one_sample_location/M1_9056f36343b32614.out
#SBATCH --error=/home/kaiqianz/dsc/vignettes/one_sample_location/M1_9056f36343b32614.err
cd /home/kaiqianz/dsc/vignettes/one_sample_location
module load R
sos execute M1_9056f36343b32614 -v 2 -s default
standout output:
================
9056f36343b32614: completed
output: first_investigation/normal/normal_1.rds

standout error:
================
9056f36343b32614: completed
```


You will see the actual SBATCH script submitted. Of perticular interest is perhaps the `.err` and `.out`. They record screen output of a job. To check them out:

```bash
cat /home/kaiqianz/dsc/vignettes/one_sample_location/M1_9056f36343b32614.err
```

```
Note that the current default version of R is 3.5.1.
INFO: M1_9056f36343b32614 started
INFO: All 1 tasks in M1_9056f36343b32614 completed
```

So here are three lines of messages related to loading R modules and nothing else. This is perhaps a good sign that no error or warning messages were generated from R-based jobs.

## Computer resource overhead

DSC keeps track of jobs submitted to compute nodes on the computer you
submit the jobs from. This is some resource "overhead" one has to pay
for to run DSC on cluster. While it is convenient and tempting to run
directly from the head node, we recommend to submit this DSC command
as a job itself to a compute node. Or, to open up an interactive
session on a compute node and run from there.

The number of CPUs you ask for running the DSC submitter command
should match the `dsc ... -c` option. You can check the default
setting for `-c` by running `dsc -h` and look for documentation on
`-c` to find out the default (because the default depends on the
machine you run it from). We recommand requesting a compute node for 4
CPUs each with 2GB memory allocated. Then submit with `-c 4`.

[dsc-intro-1]:          ../first_course/Intro_Syntax_I.html
[dsc-prototyping-tips]: ../first_course/Prototype_Tips.html
[dsc-debugging-tips]:   ../first_course/Debug_Tips.html
[sos-docs]:             https://vatlab.github.io/sos-docs
[sos-docs-remote-exec]: https://vatlab.github.io/sos-docs/doc/documentation/Remote_Execution.html
[one-sample-location]:  https://github.com/stephenslab/dsc/tree/master/vignettes/one_sample_location
[slurm]:                http://slurm.schedmd.com
