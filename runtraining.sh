#!/bin/bash



script_name=`basename $0`
script_dir=`dirname $0`
version="???"

if [ -f "$script_dir/VERSION" ] ; then
   version=`cat $script_dir/VERSION`
fi

numiterations="30000"
one_fmonly=""

function usage()
{
    echo "usage: $script_name [-h] [--1fmonly] [--numiterations NUMITERATIONS]
                      augtrainimages trainoutdir

              Version: $version

              Trains Deep3M model using caffe with training data
              passed into script. 
    
positional arguments:
  augtrainimages       Augmented training data from PreprocessTrainingData.m
  trainoutdir          Desired output directory

optional arguments:
  -h, --help           show this help message and exit
  --1fmonly            Only train 1fm model
  --numiterations      Number of training iterations to run (default $numiterations)

    " 1>&2;
   exit 1;
}

TEMP=`getopt -o h --long "1fmonly,numiterations:" -n '$0' -- "$@"`
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -h ) usage ;; 
        --1fmonly ) one_fmonly="--1fmonly " ; shift ;;
        --numiterations ) numiterations=$2 ; shift 2 ;;
        --) shift ; break ;;
    esac
done


if [ $# -ne 2 ] ; then
  usage 
fi

declare -r aug_train=$1
declare -r train_out=$2

CreateTrainJob.m "$aug_train" "$train_out"
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

"$train_out/run_all_train.sh" ${one_fmonly}--numiterations $numiterations
ecode=$?
if [ $ecode != 0 ] ; then
  echo "ERROR, a non-zero exit code ($ecode) was received from: \"$train_out/run_all_train.sh\" --numiterations $numiterations"
  exit 4
fi

echo ""
echo "Training has completed. Results are stored in $train_out"
echo "Have a nice day!"
echo ""
