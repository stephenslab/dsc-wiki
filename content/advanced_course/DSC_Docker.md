# Share DSC via containers

First you need to install and configure docker:
- Follow [Docker installation guide](https://www.docker.com/community-edition) until you can use `sudo docker` to print the "Hello World" example.
- Run `sudo usermod -aG docker $USER`
- Log out and log back in

We have provided a docker image for DSC which can be used to

- Run some of the DSC vignettes examples
- Serve as the base docker image to add to it your own benchmarks for others to reproduce.

## Run DSC docker image demo

To use the docker image:

```bash
docker pull gaow/dsc
docker run --rm --security-opt label:disable \
       -v $USER:/home/docker -v /tmp:/tmp -v $PWD:$PWD \
       -t -P -w $PWD -u $UID:${GROUPS[0]} gaow/dsc \
       dsc -h
```

You can add a shortcut to your shell configuration script (`~/.bashrc` on Linux and `~/.bash_profile` on Mac) to trigger docker based DSC:

```bash
alias dsc-docker='docker run --rm --security-opt label:disable -v $USER:/home/docker -v /tmp:/tmp -v $PWD:$PWD -t -P -w $PWD -u $UID:${GROUPS[0]} gaow/dsc dsc'
```

For example, to run the [Introductory DSC tutorial](../tutorials/Intro_DSC.html),

```bash
cd ~/GIT/dsc/vignettes/one_sample_location
```

```bash
docker run --rm --security-opt label:disable -t -P -h DSC \
    -w $PWD -v $HOME:/home/$USER -v /tmp:/tmp -v $PWD:$PWD \
    -u $UID:${GROUPS[0]} -e HOME=/home/$USER -e USER=$USER gaow/dsc \
    dsc first_investigation.dsc --replicate 10 -c 2
```

```
INFO: Checking R library dscrutils@stephenslab/dsc/dscrutils ...
INFO: DSC script exported to first_investigation.html
INFO: Constructing DSC from first_investigation.dsc ...
INFO: Building execution graph & running DSC ...
DSC: 100%|######################################################################| 15/15 [00:19<00:00,  1.01s/it]
INFO: Building DSC database ...
INFO: DSC complete!
INFO: Elapsed time 21.425 seconds.
```

## Use container options in DSC script to share your DSC

`@CONF` provides `container` and `container_engine` options to run DSC using containers ([see this document](DSC_Execution) for what `@CONF` does).

### Set module specific container

The DSC scsript below uses docker image `gaow/susie` which has `susieR` package installed. If you have `docker` on your computer you should be able to run
this module without having to install `susieR`.

```yaml
susie: R(version = packageVersion('susieR'))
  $out: version
  @CONF: container = gaow/susie
```

```bash
dsc test.dsc --target susie
```

```
INFO: Load command line DSC sequence: susie
INFO: DSC script exported to test.html
HINT: Pulling docker image gaow/susie
INFO: Building DSC database ...
[###] 3 steps processed (3 jobs completed)
INFO: DSC complete!
INFO: Elapsed time 8.290 seconds.
```

### Use singularity

To run the container with `singularity` instead of `docker`,

```yaml
susie: R(version = packageVersion('susieR'))
  $out: version
  @CONF: container = gaow/susie, container_engine = singularity
```