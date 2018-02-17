#!/bin/bash

script_dir=`dirname "$0"`
script_name=`basename $0`
version="???"

if [ -f "$script_dir/VERSION" ] ; then
   version=`cat $script_dir/VERSION`
fi

numiterations="2000"
gpu="all"

function usage()
{
    echo "usage: $script_name [-h] [--numiterations NUMITERATIONS] [--gpu GPU]
                      model

              Version: $version

              Runs caffe on Deep3m model specified by model argument 
              to perform training. The trained model will be stored in
              <model>/trainedmodel directory
              Output from caffe will be redirected to <model>/log/out.log
    
positional arguments:
  model                The model to train, should be one of the following:
                       1fm, 3fm, 5fm

optional arguments:
  -h, --help           show this help message and exit
  --gpu                Which GPU to use, can be a number ie 0 or 1 or
                       all to use all GPUs (default $gpu)
  --numiterations      Number of training iterations to run (default $numiterations)

    " 1>&2;
   exit 1;
}

TEMP=`getopt -o h --long "gpu:,numiterations:" -n '$0' -- "$@"`
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -h ) usage ;;
        --gpu ) gpu=$2 ; shift 2 ;;
        --numiterations ) numiterations=$2 ; shift 2 ;;
        --) shift ; break ;;
    esac
done


if [ $# -ne 1 ] ; then
  usage
fi

model=$1

base_dir=`cd "$script_dir";pwd`
model_dir="$base_dir/$model"
log_dir="$model_dir/log"


# update the solver.prototxt with numiterations value
sed -i "s/^max_iter:.*/max_iter: $numiterations/g" "${model_dir}/solver.prototxt"

if [ $? != 0 ] ; then
  echo "ERROR trying to update max_iter in $model_dir/solver.prototxt"
  exit 2
fi

if [ ! -d "$log_dir" ] ; then
  mkdir -p "$log_dir"
  if [ $? != 0 ] ; then
     echo "ERROR unable to make $log_dir directory"
     exit 3
  fi
fi

if [ ! -d "$model_dir/trainedmodel" ] ; then 
  mkdir -p "$model_dir/trainedmodel"
  if [ $? != 0 ] ; then
     echo "ERROR unable to make $model_dir/trainedmodel directory"
     exit 4
  fi
fi

latest_iteration=`ls "$model_dir/trainedmodel" | egrep "\.solverstate$" | sed "s/^.*iter_//" | sed "s/\.solverstate//" | sort -g | tail -n 1`

snapshot_opts=""
# we got a completed iteration lets start from that
if [ ! "$latest_iteration" == "" ] ; then
  snap_file=`find "$model_dir/trainedmodel" -name "*${latest_iteration}.solverstate" -type f`
  snapshot_opts="--snapshot=$snap_file"
  echo "Resuming run from snapshot file: $snap_file"
fi

pushd "$model_dir" > /dev/null
GLOG_log_dir=$log_dir caffe.bin train --solver=$model_dir/solver.prototxt --gpu $gpu $snapshot_opts > "${model_dir}/log/out.log" 2>&1
exitcode=$?
popd > /dev/null

if [ $exitcode != 0 ] ; then
  echo "ERROR: caffe had a non zero exit code: $exitcode"
fi

exit $exitcode
