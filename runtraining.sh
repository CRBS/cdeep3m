#!/bin/bash



script_name=`basename $0`
script_dir=`dirname $0`
version="???"

if [ -f "$script_dir/VERSION" ] ; then
   version=`cat $script_dir/VERSION`
fi

numiterations="2000"

function usage()
{
    echo "usage: $script_name [-h] [--1fmonly] [--numiterations NUMITERATIONS]
                      trainimages trainlabels trainoutdir

              Version: $version

              Trains Deep3M model using caffe with training data
              passed into script. 
    
positional arguments:
  trainimages          Directory of images, or TIF stack of images
  trainlabels          Directory of label images, or TIF stack of label images
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
        --1fmonly ) one_fmonly=true ; shift ;;
        --numiterations ) numiterations=$2 ; shift 2 ;;
        --) break ;;
    esac
done


if [ $# -ne 3 ] ; then
  usage 
fi

declare -r train_images=$1
declare -r train_labels=$2
declare -r train_out=$3

declare -r aug_train="$train_out/augtrain_images"

PreprocessTrainingData.m "$train_images" "$train_labels" "$aug_train"

ecode=$?
if [ $ecode != 0 ] ; then
  echo "ERROR, a non-zero exit code ($ecode) was received from: PreprocessTrainingData.m \"$train_images\" \"$train_labels\" \"$aug_train\""
  echo ""
  exit 2
fi

CreateTrainJob.m "$aug_train" "$train_out"
ecode=$?
if [ $ecode != 0 ] ; then
  echo "Error, a non-zero exit code ($ecode) was received from: CreateTrainJob.m \"$aug_train\" \"$train_out\""
  echo ""
  exit 3
fi

"$train_out"/run_all_train.sh $numiterations
ecode=$?
if [ $? != 0 ] ; then
  echo "ERROR, a non-zero exit code ($ecode) was received from: \"$train_out\"/run_all_train.sh $num_iterations"
  exit 4
fi

echo ""
echo "Training has completed. Results are stored in $train_out"
echo "Have a nice day!"
echo ""
