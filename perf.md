# Perf profiler

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
