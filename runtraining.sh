#!/bin/bash



script_name=`basename $0`
script_dir=`dirname $0`
version="???"

if [ -f "$script_dir/VERSION" ] ; then
   version=`cat $script_dir/VERSION`
fi

source "${script_dir}/commonfunctions.sh"

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
retrain=""
additerations="2000"

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
                              [--additerations NUMITERATIONS]
                              [--retrain TRAINOUTDIR]
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
  --retrain            Continue training trained models from train directory
                       passed in here, writing results to trainoutdir
  --additerations      If --retrain is set, this value is added to the
                       latest iteration model file found in the 
                       <retrain dir>/1fm/trainedmodel directory. For example,
                       if the latest iteration found in 
                       <retrain>/1fm/trainedmodel is 10000 and 
                       --additerations is set to 500 then training will
                       run to 10500 iterations. (default $additerations)

    " 1>&2;
   exit 1;
}

TEMP=`getopt -o h --long "1fmonly,numiterations:,base_learn:,power:,momentum:,weight_decay:,average_loss:,lr_policy:,iter_size:,snapshot_interval:,validation_dir:,retrain:,additerations:" -n '$0' -- "$@"`
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -h ) usage ;; 
        --1fmonly ) one_fmonly="--models 1fm " ; shift ;;
        --base_learn ) base_lr=$2 ; shift 2 ;;
        --power ) power=$2 ; shift 2 ;;
        --momentum ) momentum=$2 ; shift 2 ;;
        --weight_decay ) weight_decay=$2 ; shift 2 ;;
        --average_loss ) average_loss=$2 ; shift 2 ;;
        --lr_policy ) lr_policy=$2 ; shift 2 ;;
        --iter_size ) iter_size=$2 ; shift 2 ;;
        --snapshot_interval ) snapshot_interval=$2 ; shift 2 ;;
        --numiterations ) numiterations=$2 ; shift 2 ;;
        --additerations ) additerations=$2 ; shift 2 ;;
        --retrain ) retrain=$2 ; shift 2 ;;
        --validation_dir ) validation_dir=$2 ; shift 2 ;;
        --) shift ; break ;;
    esac
done


if [ $# -ne 2 ] ; then
  usage 
fi

declare -r aug_train=$1
declare -r train_out=$2

if [ -z "$validation_dir" ] ; then 
    validation_dir=$aug_train
fi

CreateTrainJob.m "$aug_train" "$train_out" "$validation_dir"
ecode=$?
if [ $ecode != 0 ] ; then
    echo "Error, a non-zero exit code ($ecode) was received from: CreateTrainJob.m \"$aug_train\" \"$train_out\" \"$validation_dir\""
    echo ""
    exit 2
fi

if [ -n "$retrain" ] ; then
    if [ ! -d "$retrain" ] ; then
        echo "ERROR, $retrain is not a directory"
        exit 3
    fi
    latest_iteration=$(get_latest_iteration "$retrain/1fm/trainedmodel")
    if [ -n "$latest_iteration" ] ; then
        echo "Latest iteration found in 1fm from $retrain is $latest_iteration"
        let numiterations=$latest_iteration+$additerations
        echo "Adding $additerations iterations so will now run to $numiterations iterations"
    else
        echo "No models $retrain/1fm/trainedmodel leaving numiterations at $numiterations"
    fi

    echo "--retrain flag set, previous models copied from $retrain" >> "$train_out/readme.txt"

    echo "Copying over trained models"
    res=$(copy_trained_models "$retrain" "$train_out")
    echo "$res"   
fi

trainworker.sh ${one_fmonly}--numiterations $numiterations --base_learn $base_lr --power $power --momentum $momentum --weight_decay $weight_decay --average_loss $average_loss --lr_policy $lr_policy --iter_size $iter_size --snapshot_interval $snapshot_interval "$train_out"
ecode=$?
if [ $ecode != 0 ] ; then
    echo "ERROR, a non-zero exit code ($ecode) was received from: trainworker.sh --numiterations $numiterations"
    exit 4
fi

echo ""
echo "Training has completed. Results are stored in $train_out"
echo "Have a nice day!"
echo ""
