#!/bin/bash                                      
echo ' (     (                                      ) ' 
echo ' )\ )  )\    )     )      (   (  (     (   ( /( ' 
echo '(()/( ((_)( /(    (      ))\  )\))(   ))\  )\())' 
echo ' /(_)) _  )(_))   )\   /((_)((_))\  /((_)(_))/ ' 
echo '(_) _|| |((_)_  _((_)) (_))   (()(_)(_))  | |_  ' 
echo ' |  _|| |/ _| || |  \()/ -_) / _| | / -_) |  _| ' 
echo ' |_|  |_|\__,_||_|_|_| \___| \__, | \___|  \__| ' 
echo '                             |___/              ' 
echo ' a command line utility for flamegraph automations'

display_help() {
    echo 'Usage flameget --option <argument>'
	echo 'OPTIONS:'
    echo '-n or --node=<kubernetes node name>'
    echo '-p or --pod=<kubernetes pod name>'
    echo '-c or --container=<kubernetes container name>'
    echo '-t or --time=<time in seconds, default 30 seconds>'
    echo '-i or --image-for-profiler=<docker image for profiler to use>'
}

flamegraph(){ 
    while [ "$1" != "" ]; do
            case $1 in
                flamegraph )           echo ''
                                    ;;
                -n | --node )           shift
                                        BPF_TOOLS_NODE=$1
                                        ;;
                -p | --pod )           shift
                                        BPF_TOOLS_POD=$1
                                        ;;
                -c | --container ) shift
                                        BPF_TOOLS_CONTAINER=$1
                                        ;;
                -i | --image-for-profiler ) shift
                                        BPF_TOOLS_IMAGE=$1
                                        ;;
                -t | --time ) shift
                                        BPF_TOOLS_SECONDS=$1
                                        ;;
                -h | --help )           display_help
                                        return 1
                                        ;;
                * )                     display_help
                                        return 1
            esac
            shift
    done

    bpfprofilername=ebpf-profiler
    [ -z "${BPF_TOOLS_NODE}" ] && echo 'missing --node, try --help' && return 1
    [ -z "${BPF_TOOLS_POD}" ] && echo 'missing --pod, try --help' && return 1
    [ -z "${BPF_TOOLS_CONTAINER}" ] && echo 'missing --container, try --help' && return 1
    [ -z "${BPF_TOOLS_IMAGE}" ] && echo 'missing --image-for-profiler, try --help' && return 1
    [ -z "${BPF_TOOLS_SECONDS}" ] && BPF_TOOLS_SECONDS=30 && return 1

    cat ./ebpf-profiler.yaml | \
    sed 's@{{BPF_TOOLS_IMAGE}}@'"$BPF_TOOLS_IMAGE"'@' | \
    sed 's@{{BPF_TOOLS_POD}}@'"$BPF_TOOLS_POD"'@' | \
    sed 's@{{BPF_TOOLS_SECONDS}}@'"$BPF_TOOLS_SECONDS"'@' | \
    sed 's@{{BPF_TOOLS_CONTAINER}}@'"$BPF_TOOLS_CONTAINER"'@' | \
    sed 's@{{BPF_TOOLS_NODE}}@'"$BPF_TOOLS_NODE"'@' | \
    kubectl apply -f -

    #wait for profiler to run
    running=""
    while [ -z "$running" ]; do
        running=$(kubectl get pods | grep "$bpfprofilername" | grep "Running")
        [ -z "$running" ] && sleep 1
    done

    #wait for profiler to complete
    completed_flag=""
    echo "profiling pod ${BPF_TOOLS_POD} ..."
    while [ -z "$completed_flag" ]; do
        completed_flag=$(kubectl logs $bpfprofilername | grep "profiling complete")
        [ -z "$completed_flag" ] && sleep 5
    done

    #get the svg
    kubectl cp ${bpfprofilername}:/work/${BPF_TOOLS_CONTAINER}.svg ./${BPF_TOOLS_CONTAINER}.svg 2>/dev/null
    echo "created ${BPF_TOOLS_CONTAINER}.svg"

    kubectl delete po $bpfprofilername
    echo "done"

}

flamegraph $@
