#!/bin/bash

script_name=`basename $0`
script_dir=`dirname $0`
version="???"

if [ -f "$script_dir/VERSION" ] ; then
   version=`cat $script_dir/VERSION`
fi

numiterations="30000"
gpu="all"
one_fmonly=false
base_lr="1e-02"
power="0.8"
momentum="0.9"
weight_decay="0.0005"
average_loss="16"
lr_policy="poly"
iter_size="8"
snapshot_interval="2000"
model_list="1fm,3fm,5fm"


function usage()
{
    echo "usage: $script_name [-h] [--models MODELS] 
                              [--numiterations NUMITERATIONS] 
                              [--gpu GPU] [--base_lr BASE_LR] [--power POWER] 
                              [--momentum MOMENTUM] 
                              [--weight_decay WEIGHT_DECAY] 
                              [--average_loss AVERAGE_LOSS] 
                              [--lr_policy POLICY] [--iter_size ITER_SIZE] 
                              [--snapshot_interval SNAPSHOT_INTERVAL]

              Version: $version

              Runs caffe training on CDeep3M model in directory where
              this script resides

              For further information about parameters below please see: 
              https://github.com/BVLC/caffe/wiki/Solver-Prototxt 


optional arguments:
  -h, --help           show this help message and exit
  --models             Only train on models specified in comma 
                       delimited list. (default 1fm,3fm,5fm)
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

TEMP=`getopt -o h --long "models:,gpu:,numiterations:,base_learn:,power:,momentum:,weight_decay:,average_loss:,lr_policy:,iter_size:,snapshot_interval:" -n '$0' -- "$@"`
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -h ) usage ;;
        --models ) model_list=$2 ; shift 2 ;;
        --numiterations ) numiterations=$2 ; shift 2 ;;
        --gpu ) gpu=$2 ; shift 2 ;;
        --base_learn ) base_lr=$2 ; shift 2 ;;
        --power ) power=$2 ; shift 2 ;;
        --momentum ) momentum=$2 ; shift 2 ;;
        --weight_decay ) weight_decay=$2 ; shift 2 ;;
        --average_loss ) average_loss=$2 ; shift 2 ;;
        --lr_policy ) lr_policy=$2 ; shift 2 ;;
        --iter_size ) iter_size=$2 ; shift 2 ;;
        --snapshot_interval ) snapshot_interval=$2 ; shift 2 ;;
        --) break ;;
    esac
done

echo ""

let maxgpuindex=0
gpucount=`nvidia-smi -L | wc -l`
if [ "$gpucount" -eq 0 ] ; then
  echo "ERROR unable to get count of GPU(s). Is nvidia-smi working?"
  exit 4
fi

let maxgpuindex=$gpucount-1

if [ $maxgpuindex -gt 0 ] ; then
  echo -n "Detected $gpucount GPU(s)."
  if [ "$gpu" == "all" ] ; then
    echo " Will run in parallel."
  else
    echo " Using only GPU $gpu"
  fi
else
  echo "Single GPU detected."
fi

if [ "$gpu" == "all" ] ; then
  let cntr=0
else
  let cntr=$gpu
fi

parallel_job_file="$script_dir/parallel.jobs"

for model_name in `echo "$model_list" | sed "s/,/ /g"` ; do
  if [ ! -d "$script_dir/$model_name" ] ; then
    echo "ERROR, no $script_dir/$model_name directory found."
    exit 2
  fi
  echo -e "$numiterations\n$cntr\n$base_lr\n$power\n$momentum\n$weight_decay\n$average_loss\n$lr_policy\n$iter_size\n$snapshot_interval\n$model_name" >> $parallel_job_file
  if [ "$gpu" == "all" ] ; then
    let cntr++
    if [ $cntr -gt $maxgpuindex ] ; then
      let cntr=0
    fi  
  fi
done

# the --delay 2 is to add a 2 second delay between starting jobs
# without this jobs would fail on GPU with out of memory error
#
 
cat $parallel_job_file | parallel --no-notice --delay 2 -N 11 -j $gpucount $script_dir/caffe_train.sh --numiterations {1} --gpu {2} --base_learn {3} --power {4} --momentum {5} --weight_decay {6} --average_loss {7} --lr_policy {8} --iter_size {9} --snapshot_interval {10} {11}
  if [ $? != 0 ] ; then
    echo "Non zero exit code from caffe for train of model. Exiting."
    exit 1
  fi

echo ""
echo "Training has completed. Have a nice day!"
echo ""
