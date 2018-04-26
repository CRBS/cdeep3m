#!/bin/bash



script_name=`basename $0`
script_dir=`dirname $0`
version="???"

if [ -f "$script_dir/VERSION" ] ; then
   version=`cat $script_dir/VERSION`
fi

numiterations="30000"
one_fmonly=""
base_lr="1e-02"
power="0.8"
momentum="0.9"
weight_decay="0.0005"
average_loss="16"
lr_policy="poly"
iter_size="8"
snapshot_interval="2000"
validation_dir=""

function usage()
{
    echo "usage: $script_name [-h] [--1fmonly] [--numiterations NUMITERATIONS]
                              [--base_lr BASE_LR] [--power POWER] 
                              [--momentum MOMENTUM] 
                              [--weight_decay WEIGHT_DECAY] 
                              [--average_loss AVERAGE_LOSS] 
                              [--lr_policy POLICY] [--iter_size ITER_SIZE] 
                              [--snapshot_interval SNAPSHOT_INTERVAL]
                              [--validation_dir VALIDATION_DIR]
                              augtrainimages trainoutdir

              Version: $version

              Trains Deep3M model using caffe with training data
              passed into script. 

              For further information about parameters below please see: 
              https://github.com/BVLC/caffe/wiki/Solver-Prototxt

    
positional arguments:
  augtrainimages       Augmented training data from PreprocessTrainingData.m
  trainoutdir          Desired output directory

optional arguments:
  -h, --help           show this help message and exit
  --1fmonly            Only train 1fm model
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
  --validation_dir     Augmented validation data

    " 1>&2;
   exit 1;
}

TEMP=`getopt -o h --long "1fmonly,numiterations:,base_learn:,power:,momentum:,weight_decay:,average_loss:,lr_policy:,iter_size:,snapshot_interval:,validation_dir:" -n '$0' -- "$@"`
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -h ) usage ;; 
        --1fmonly ) one_fmonly="--1fmonly " ; shift ;;
        --base_learn ) base_lr=$2 ; shift 2 ;;
        --power ) power=$2 ; shift 2 ;;
        --momentum ) momentum=$2 ; shift 2 ;;
        --weight_decay ) weight_decay=$2 ; shift 2 ;;
        --average_loss ) average_loss=$2 ; shift 2 ;;
        --lr_policy ) lr_policy=$2 ; shift 2 ;;
        --iter_size ) iter_size=$2 ; shift 2 ;;
        --snapshot_interval ) snapshot_interval=$2 ; shift 2 ;;
        --numiterations ) numiterations=$2 ; shift 2 ;;
        --validation_dir ) validation_dir=$2 ; shift 2 ;;
        --) shift ; break ;;
    esac
done


if [ $# -ne 2 ] ; then
  usage 
fi

declare -r aug_train=$1
declare -r train_out=$2


if [ -z $validation_dir ] ; then 
  validation_dir=$aug_train
fi

./CreateTrainJob.m "$aug_train" "$train_out" "$validation_dir"
ecode=$?
if [ $ecode != 0 ] ; then
  echo "Error, a non-zero exit code ($ecode) was received from: CreateTrainJob.m \"$aug_train\" \"$train_out\""
  echo ""
  exit 2
fi

if [ ! -x "$train_out/run_all_train.sh" ] ; then
  echo "ERROR, either $train_out/run_all_train.sh is missing or non-executable"
  exit 3
fi

"$train_out/run_all_train.sh" ${one_fmonly}--numiterations $numiterations --base_learn $base_lr --power $power --momentum $momentum --weight_decay $weight_decay --average_loss $average_loss --lr_policy $lr_policy --iter_size $iter_size --snapshot_interval $snapshot_interval
ecode=$?
if [ $ecode != 0 ] ; then
  echo "ERROR, a non-zero exit code ($ecode) was received from: \"$train_out/run_all_train.sh\" --numiterations $numiterations"
  exit 4
fi

echo ""
echo "Training has completed. Results are stored in $train_out"
echo "Have a nice day!"
echo ""
