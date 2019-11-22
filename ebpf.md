# eBPF profiler

Grap the process id (PID) of the dotnet process.

```
ps aux | grep dotnet
root     16575 78.2  0.2 20337940 32648 ?      RLsl 13:22   0:10 dotnet src.dll
root     16791  0.0  0.0   1588     4 ?        Ss   13:22   0:00 /bin/sh -c apk add --no-cache curl;sleep 10s; while curl http://sample-dotnet:5000/api/values; curl http://sample-golang/; do  sleep 1s; done
```

The value we are after is the ID `16575` which is `dotnet src.dll` (our app) 

Let's start profiling:

```
docker run -it --rm --privileged \
--pid host \
-v ${PWD}:/out \
-v /etc/localtime:/etc/localtime:ro \
--pid host \
-v /sys/kernel/debug:/sys/kernel/debug \
-v /sys/fs/cgroup:/sys/fs/cgroup \
-v /sys/fs/bpf:/sys/fs/bpf \
--net host \
aimvector/flamegraph
```

Once inside the container, run:

```

./bcc/tools/profile.py -dF 99 -f 15 -p 16575 | \
./FlameGraph/flamegraph.pl > /out/perf.svg
```

Once done, you can exit the container and `perf.svg` will be produced

