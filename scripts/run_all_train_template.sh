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

function usage()
{
    echo "usage: $script_name [-h] [--1fmonly] [--numiterations NUMITERATIONS] 
                              [--gpu GPU] [--base_lr BASE_LR] [--power POWER] 
                              [--momentum MOMENTUM] 
                              [--weight_decay WEIGHT_DECAY] 
                              [--average_loss AVERAGE_LOSS] 
                              [--lr_policy POLICY] [--iter_size ITER_SIZE] 
                              [--snapshot_interval SNAPSHOT_INTERVAL]

              Version: $version

              Runs caffe training on CDeep3M model in directory where
              this script resides 

optional arguments:
  -h, --help           show this help message and exit
  --1fmonly            Only train 1fm model
  --gpu                Which GPU to use, can be a number ie 0 or 1 or
                       all to use all GPUs (default $gpu)
  --base_learn         Base learning rate (default $base_lr)
  --power              Used in poly and sigmoid lr_policies. 
                       (default $power) See
                       https://github.com/BVLC/caffe/wiki/Solver-Prototxt
  --momentum           Indicates how much of the previous weight will be 
                       retained in the new calculation. (default $momentum)
  --weight_decay       Factor of (regularization) penalization of large
                       weights (default $weight_decay)
  --average_loss       ??? (default $average_loss)
  --lr_policy          Learning rate policy (default $lr_policy) See
                       https://github.com/BVLC/caffe/wiki/Solver-Prototxt
  --iter_size          Accumulate gradients across batches through the 
                       iter_size solver field. (default $iter_size)
                       See https://github.com/BVLC/caffe/wiki/Solver-Prototxt
  --snapshot_interval  How often caffe should output a model and solverstate.
                       (default $snapshot_interval)
  --numiterations      Number of training iterations to run (default $numiterations)
    " 1>&2;
   exit 1;
}

TEMP=`getopt -o h --long "1fmonly,gpu:,numiterations:,base_learn:,power:,momentum:,weight_decay:,average_loss:,lr_policy:,iter_size:,snapshot_interval:" -n '$0' -- "$@"`
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -h ) usage ;;
        --1fmonly ) one_fmonly=true ; shift ;;
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

# time_est=`perl -e "printf('%.2f',${num_iterations}*8/3600);"`

echo ""

for Y in `echo 1fm 3fm 5fm` ; do
  if [ ! -d "$script_dir/$Y" ] ; then
    echo "ERROR, no $script_dir/$Y directory found."
    exit 2
  fi
  echo "Running $Y train, this could take a while"
  /usr/bin/time -p $script_dir/caffe_train.sh --numiterations $numiterations --gpu $gpu --base_learn $base_lr --power $power --momentum $momentum --weight_decay $weight_decay --average_loss $average_loss --lr_policy $lr_policy --iter_size $iter_size --snapshot_interval $snapshot_interval $Y
  if [ $? != 0 ] ; then
    echo "Non zero exit code from caffe for train of $Y model. Exiting."
    outfile="$script_dir/$Y/log/out.log"
    if [ -f "$outfile" ] ; then
      echo "Here is last 10 lines of $outfile:"
      echo ""
      tail $outfile
    fi
    exit 1
  fi
  if [ $one_fmonly == true ] ; then
    echo "--1fmonly flag set, skipping 3fm and 5fm models."
    break
  fi
done

echo ""
echo "Training has completed. Have a nice day!"
echo ""
