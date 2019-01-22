# Running DSC on a remote computer

## Overview

DSC uses one additional configuration file and two command options (`--host` and `--to-host`) to run on a remote computer (or "host", hereafter). Here a remote computer can be:

1. A standalone desktop workstation without a job queue system
2. A system with a job queue manager, such as PBS-based cluster

DSC facilicate two approaches to run remote tasks:

1. "On-Host", the conventional way: log in to the host and run remote jobs. For a standalone system, this is no difference from logging in to the system and run DSC benchmark directly. For a cluster system this will automatically submit jobs to compute nodes based on provided template.
2. "Local-Host", a host friendly way: do not log in to the host to run jobs. Rather, have a copy of DSC software installed to your local computer (Mac or Linux), and configure the host to have DSC and all required tools for benchmarking installed. Then run DSC from local computer with additional folders to be synced to the host specified by `--to-host` option. The local computer will serve as the job dispatcher and job monitor. This provides a way to run on hosts that has some policy constraints on long running jobs from the headnode, for example.

Under the hood, DSC configures all modules and converts them to [`SoS`](https://vatlab.github.io/sos-docs) tasks. Enthusiastic readers shall refer to [this page](https://vatlab.github.io/sos-docs/doc/documentation/Remote_Execution.html) for details under the hood. Configuration here in DSC is further automated for benchmarking and thus simpler interface-wise.

In this tutorial we'll focus on discussing running jobs on a cluster with queue manager.

## Job configuration template and command options

Using a template and command options, DSC allows users to:

1. Configure job submission on host.
2. Configure resource requirement per module.

Using command options, users can

1. Submit the entire benchmark with controlled maximum job limits (command option `-c`).
2. When submitting from local to host computer, automatically send required files to the host for benchmarking (command option `--to-host`).

Users can also use SoS utility tools to manage jobs. The end of documentation will briefly discuss a few SoS utility commands with examples.

## Host configuration example

DSC command option `--host` accepts a YAML configuration file that specifies a *template* for remote jobs. **We provide support to such configuration files on need-basis**, because we (the DSC developers) can only verify and ensure the it works on system that we have access to and use on regular basis. For example, [here is a template](https://github.com/stephenslab/dsc-reg/blob/master/midway.yml) for a system running PBS type of queue via Slurm Workload Manage:

```yaml
DSC:
  midway2:
    description: UChicago RCC cluster Midway 2
    address: localhost
    paths:
      home: /home/gaow
    queue_type: pbs
    status_check_interval: 60
    max_running_jobs: 40
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
      #SBATCH --output={cur_dir}/{job_name}.stdout
      #SBATCH --error={cur_dir}/{job_name}.stderr
      cd {cur_dir}
      module load R/3.4.3
    partition: "SBATCH --partition=broadwl"
    account: ""
    submit_cmd: sbatch {job_file}
    submit_cmd_output: "Submitted batch job {job_id}"
    status_cmd: squeue --job {job_id}
    kill_cmd: scancel {job_id}
  faraway2:
    based_on: midway2
    description: Submit and manage jobs to `midway2` from a local computer.
    address: gaow@midway2.rcc.uchicago.edu
  stephenslab:
    based_on: midway2
    max_cores: 28
    max_mem: 128G
    max_walltime: "10d"
    partition: "SBATCH --partition=mstephens"
    account: "SBATCH --account=pi-mstephens"

default:
  queue: midway2
  time_per_instance: 10m
  instances_per_job: 2
  n_cpu: 1
  mem_per_cpu: 2G

# module specific configurations
# mostly to consolidate small jobs
simulate:
  instances_per_job: 20

score:
  instances_per_job: 20
```

The section `DSC` is required to provide various templates for a number of systems. Here `midway2` is a host provided by [The University of Chicago RCC group](https://rcc.uchicago.edu). Jobs are submitted to `partition=broadwl`. Typically it has 40 cores per node, allows for maximum of 40 concurrent jobs per user, and a maximum running time of 36hrs per job. These limitations have been reflected by the `max_*` values in the configuration. 

There are also 2 "derived" queue: `stephenslab` is a special partition on `midway2` that allows for different configurations, thus it is derived from `midway2` via `based_on: midway2`. Also relevant is the `faraway2`, also `based_on: midway2`, but specifies the address of how to connect to `midway2`. Then DSC will assume that the request is made from a local computer and try to use the "local-host" mechanism to run jobs.

The section `default` is also required. It provides default settings for all modules in the DSC. Available settings are:

- `queue`: name of the queue on the remote host to use, one of the various queues defined in `DSC` section.
    - Here in the template it is set to `midway2`, which is a "On-Host" queue.
- `time_per_instance`: maximum computation time for each module instance.
- `instance_per_job`: how many module instances to submit as one remote job. This is useful consolidating numerous light-weight module instances into one jobs submission. 
- `n_cpu` and `mem_per_cpu` specify the CPU and memory requirement of a module instance.

For example for 100 module instances of `simulate` that each generates some data in under a minute, one can specify `time_per_instance: 1m` and `instance_per_job: 200`. Then a single job containing 200 simulations will be submitted to the host with a total of 200 minutes computation time reserved.

Typically, `DSC` and `default` section for host configuration do not have to be changed for different projects. Users can carefully configure them once, and reuse for various projects. For Stephens Lab users for example, one can take the example from above and replace `gaow` with their UChicago cnetID.

**Please never use this template without configuring the required resources, particularly `time_per_instance` and `instance_per_job`. They should be tailored for your project. In proper configuration of these settings will lead to running many small jobs (too low on `instance_per_job`) and waste of resource (too high on `time_per_instance`)**

## Control number of jobs to submit

In the configuration file, `max_running_jobs` confines the maximum number of jobs to run on the host. This is set to have a safe limit that prevents from harming the host sytem (and getting angry system emails). For each benchmark submitted, the command option `-c` should be used to customize the maximum number of jobs to have in the queue. Command `dsc -h` will show you the default value of this number. Since it is a shared command option with running jobs locally, the default is set to ~1/2 of the total available CPU threads on the computer that executes `dsc`. That is, for the "On-Host" submission the default number of jobs will be half of threads on the head node; for the "Local-Host" submission the default will be half of threads on a local computer, which can be quite small when running from, say, a regular laptop. It is thus advised to always specify `-c` option.

## Run remote jobs

If the `default` queue is a "On-Host" queue (`address: localhost`), then

```bash
dsc ... --host /path/to/config.yml -c 30
```

will configuration in `/path/to/config.yml` and submit jobs, in batches of 30. 

For the "Local-Host" mechanism (`default::address: <some URL>`), 

```bash
dsc ... --host /path/to/config.yml --to-host file1 dir1 file2 -c 30
```

will additionally use `--to-host` to sync specified files and folders to the remote, if the particular benchmark requires these files and folders to execute (eg, data resource, shell executables, or scripts in `DSC::lib_path`).

Caution that to successfully use `--to-host`, the command program [`rsync`](https://rsync.samba.org) have to be available from the local computer.

## Monitor and manage jobs

When jobs are submitted, you should see on the screen something like:

```
INFO: M2_9eb9ad957cc31d50 submitted to midway2 with job id 45634260
```

So there is a task ID `M2_9eb9ad957cc31d50` and job ID `45634260`. This can also be observed from your system's job queue, for example:


```
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          45633096   broadwl M2_2eac6     gaow PD       0:00      1 (Priority)
          45633098   broadwl M2_c6ed0     gaow PD       0:00      1 (Priority)
          45633099   broadwl M2_38e36     gaow PD       0:00      1 (Priority)
          45633100   broadwl M2_8fea7     gaow PD       0:00      1 (Priority)
          45633101   broadwl M2_829d4     gaow PD       0:00      1 (Priority)
          45633102   broadwl M2_3ab21     gaow PD       0:00      1 (Priority)
          45633103   broadwl M2_ed42e     gaow PD       0:00      1 (Priority)
          45633104   broadwl M2_2966b     gaow PD       0:00      1 (Priority)
          45633086   broadwl M2_13151     gaow  R       0:01      1 midway2-0033
          45633087   broadwl M2_01df1     gaow  R       0:01      1 midway2-0033
          45633088   broadwl M2_b8668     gaow  R       0:01      1 midway2-0033
          45633089   broadwl M2_89a83     gaow  R       0:01      1 midway2-0070
          45633090   broadwl M2_7cbdd     gaow  R       0:01      1 midway2-0070
          45633091   broadwl M2_56fa6     gaow  R       0:01      1 midway2-0070
          45633092   broadwl M2_4baac     gaow  R       0:01      1 midway2-0070
```

To check on one of the job, for example the first one:

```bash
sos status M2_2eac6 -v3
```

You will see information such as:

```
Started 27 min 13 sec ago
Duration 26 min 59 sec

TAGS:
=====
e0b204d49b525c52 susie2_0 susie2_sparse_13_susie2_1 susie2_sparse_14_susie2_1

...
```

The `TAGS` line explains that the job comes from the module `susie2` and produces 2 files `susie2/sparse_13_susie2_1` and  `susie2/sparse_14_susie2_1`. That is, 2 module instances per job. There are also some other useful info on execution stats such as memory usage.

To have more details,

```bash
sos status M2_2eac6 -v4
```

and the output:

```
M2_2eac66b84134d3f8.err:
========================
2eac66b84134d3f8: completed
2018-05-02 07:49:50,749: DEBUG: 2eac66b84134d3f8 ``started``
2018-05-02 07:49:51,249: DEBUG: 2eac66b84134d3f8 ``completed``
c9afa00936023dba: completed
2018-05-02 07:49:51,299: DEBUG: c9afa00936023dba ``started``
2018-05-02 07:49:51,788: DEBUG: c9afa00936023dba ``completed``

M2_2eac66b84134d3f8.out:
========================
2eac66b84134d3f8: completed
output: {file_target('benchmark/susie2/sparse_13_susie2_1.rds'): '12e0ebc6506e00e2'}
c9afa00936023dba: completed
output: {file_target('benchmark/susie2/sparse_14_susie2_1.rds'): '98adf711379a200e'}

M2_2eac66b84134d3f8.sh:
=======================
#!/bin/bash
#SBATCH --time=00:10:00
#SBATCH --partition=broadwl

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=3
#SBATCH --mem-per-cpu=4G
#SBATCH --job-name=M2_2eac66b84134d3f8
#SBATCH --output=/scratch/midway2/gaow/GIT/lab-dsc/dsc-reg/.sos/M2_2eac66b84134d3f8.stdout
#SBATCH --error=/scratch/midway2/gaow/GIT/lab-dsc/dsc-reg/.sos/M2_2eac66b84134d3f8.stderr
cd /scratch/midway2/gaow/GIT/lab-dsc/dsc-reg
module load R/3.4.3
sos execute M2_2eac66b84134d3f8 -v 2 -s default
```


You will see the actual SBATCH script submitted. Of perticular interest is perhaps the `stderr` and `stdout`. They record screen output of a job. To check them out:

```bash
cat /scratch/midway2/gaow/GIT/lab-dsc/dsc-reg/.sos/M2_2eac66b84134d3f8.err
```

```
Note that the current default version of R is 3.4.3.
Type "module help R" for advice on using R on midway.
```

So I get two lines of messages related to loading R modules and nothing else. This is perhaps a good sign that no error or warning messages were generated from my R-based jobs.
