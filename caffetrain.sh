#!/bin/bash

script_dir=`dirname "$0"`
script_name=`basename $0`
version="???"

if [ -f "$script_dir/VERSION" ] ; then
   version=`cat $script_dir/VERSION`
fi

source "${script_dir}/commonfunctions.sh"

numiterations="30000"
gpu="all"
base_lr="1e-02"
power="0.8"
momentum="0.9"
weight_decay="0.0005"
average_loss="16"
lr_policy="poly"
iter_size="8"
snapshot_interval="2000"

function usage()
{
    echo "usage: $script_name [-h] [--numiterations NUMITERATIONS] [--gpu GPU]
                              [--base_lr BASE_LR] [--power POWER] 
                              [--momentum MOMENTUM] 
                              [--weight_decay WEIGHT_DECAY] 
                              [--average_loss AVERAGE_LOSS] 
                              [--lr_policy POLICY] [--iter_size ITER_SIZE] 
                              [--snapshot_interval SNAPSHOT_INTERVAL]
                              model trainoutdir

              Version: $version

              Runs caffe on CDeep3M model specified by model argument 
              to perform training. The trained model will be stored in
              <trainoutdir>/<model>/trainedmodel directory
              Output from caffe will be redirected to <trainoutdir>/<model>/log/out.log
 
              For further information about parameters below please see: 
              https://github.com/BVLC/caffe/wiki/Solver-Prototxt

    
positional arguments:
  model                The model to train, should be one of the following:
                       1fm, 3fm, 5fm
  trainoutdir          Directory created by runtraining.sh contained
                       output of training.

optional arguments:
  -h, --help           show this help message and exit
  --gpu                Which GPU to use, can be a number ie 0 or 1 or
                       all to use all GPUs (default $gpu)
  --base_learn         Base learning rate (default $base_lr)
  --power              Used in poly and sigmoid lr_policies. (default $power)
  --momentum           Indicates how much of the previous weight will be 
                       retained in the new calculation. (default $momentum)
  --weight_decay       Factor of (regularization) penalization of large
                       weights (default $weight_decay)
  --average_loss       Number of iterations to use to average loss
                       (default $average_loss)
  --lr_policy          Learning rate policy (default $lr_policy)
  --iter_size          Accumulate gradients across batches through the 
                       iter_size solver field. (default $iter_size)
  --snapshot_interval  How often caffe should output a model and solverstate.
                       (default $snapshot_interval)
  --numiterations      Number of training iterations to run (default $numiterations)

    " 1>&2;
   exit 1;
}

TEMP=`getopt -o h --long "gpu:,numiterations:,base_learn:,power:,momentum:,weight_decay:,average_loss:,lr_policy:,iter_size:,snapshot_interval:" -n '$0' -- "$@"`
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -h ) usage ;;
        --gpu ) gpu=$2 ; shift 2 ;;
        --numiterations ) numiterations=$2 ; shift 2 ;;
        --base_learn ) base_lr=$2 ; shift 2 ;;
        --power ) power=$2 ; shift 2 ;;
        --momentum ) momentum=$2 ; shift 2 ;;
        --weight_decay ) weight_decay=$2 ; shift 2 ;;
        --average_loss ) average_loss=$2 ; shift 2 ;;
        --lr_policy ) lr_policy=$2 ; shift 2 ;;
        --iter_size ) iter_size=$2 ; shift 2 ;;
        --snapshot_interval ) snapshot_interval=$2 ; shift 2 ;;
        --) shift ; break ;;
    esac
done


if [ $# -ne 2 ] ; then
  usage
fi

model=$1

base_dir=$2
model_dir="$base_dir/$model"
log_dir="$model_dir/log"


# update the solver.prototxt with numiterations value
sed -i "s/^max_iter:.*/max_iter: $numiterations/g" "${model_dir}/solver.prototxt"

if [ $? != 0 ] ; then
  echo "ERROR trying to update max_iter in $model_dir/solver.prototxt"
  exit 2
fi

# update solver.protoxt with base_lr value
sed -i "s/^base_lr:.*/base_lr: $base_lr/g" "${model_dir}/solver.prototxt"

# update solver.prototxt with power value
sed -i "s/^power:.*/power: $power/g" "${model_dir}/solver.prototxt"

# update solver.prototxt with momentum value
sed -i "s/^momentum:.*/momentum: $momentum/g" "${model_dir}/solver.prototxt"

# update solver.prototxt with weight_decay value
sed -i "s/^weight_decay:.*/weight_decay: $weight_decay/g" "${model_dir}/solver.prototxt"

# update solver.prototxt with average loss value
sed -i "s/^average_loss:.*/average_loss: $average_loss/g" "${model_dir}/solver.prototxt"

# update solver.prototxt with lr_policy value
sed -i "s/^lr_policy:.*/lr_policy: \"$lr_policy\"/g" "${model_dir}/solver.prototxt"

# update solver.prototxt with iter_size value
sed -i "s/^iter_size:.*/iter_size: $iter_size/g" "${model_dir}/solver.prototxt"

# update solver.prototxt with snapshot interval value
sed -i "s/^snapshot:.*/snapshot: $snapshot_interval/g" "${model_dir}/solver.prototxt"

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

latest_iteration=$(get_latest_iteration "$model_dir/trainedmodel")

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
