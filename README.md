# Quickstart example guide to cpu performance analysis for Golang and .NET Core
CPU performance analysis demo for docker containers using FlameGraphs

VIDEO: [YouTube](https://www.youtube.com/watch?v=ZaKJL9uUiXY)
![sample](./example.png)

# Get all the tools

1) Download my perf containers (My desktop repo). You will need the dockerfile and the docker-compose file [here](https://github.com/marcel-dempers/my-desktop/tree/master/dockerfiles/perf/dotnetcore)

Note: You need the dotnet core version of the application you are profiling. Check and adjust the dockerfile accordingly
Change directory to where you downloaded those files and run `docker-compose build` to compile perf tools with dotnetcore SDK

2) Download the flamegraph container
```
docker pull aimvector/flamegraph
```

# Start the sample stack

In this directory of this repo, run

```
docker-compose build
docker-compose up
```

While the stack is running you can profile it with the perf container
# Run perf

```
docker run -it --rm --privileged --ipc host --pid host -v ${PWD}:/out -v /var/lib/docker:/var/lib/docker -v /sys:/sys:ro -v /etc/localtime:/etc/localtime:ro -v /run:/run -v /var/log:/var/log --net host --entrypoint /bin/bash aimvector/dotnet-perf:4.15.1
```

Once inside start profiling
The sample below will profile for 3 minutes

```
/perf/perf record -ag -F 99 -- sleep 180
```

# Grab dotnetcore perf maps 

First find the container ID of dotnetcore and copy out the perf map to your host
This is needed for perf to script the map and locate the debug symbols etc.

You will need to run the below on your host (not inside perf), so open a new terminal

```
docker cp containerid:/tmp/perf-1.map . perf-1.map
ls
```

# PERF SCRIPT
You should see the map locally.
Go back to the perf container and script it out:

```
/perf/perf script > out.perf
```

This may generate a bunch of warnings about missing symbols.
Now perf may already have some useful stacks, but you could resolve all these warnings my installing DLLs, mounting files like /var etc.

# FLAME GRAPH

Now start the flamegraph container from the same folder here

```
docker run -it --rm --entrypoint /bin/bash -v ${PWD}:/out aimvector/flamegraph
```

Run `cd ./FlameGraph/ && ./generate.sh` to generate the `perf.svg`

# KUBERNETES

The same process above works for Kubernetes containers as well.
Instead of docker-compose, you will have to use the `./k8s.yaml` file in this repo that runs the perf container in a pod in your cluster.
Be warned! It's armed with priviledges so use with caution and delete it when done :)

Instead of `docker cp`, you can use `kubectl cp` to copy `out.perf` to your machine where you can run the above flamegraph container.
So therefore the same concept applies in Kubernetes.
