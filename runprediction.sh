#!/bin/bash


script_name=`basename $0`
script_dir=`dirname $0`
version="???"

if [ -f "$script_dir/VERSION" ] ; then
   version=`cat $script_dir/VERSION`
fi

model_list="1fm,3fm,5fm"
aug_speed="1"

function usage()
{
    echo "usage: $script_name [-h] [--models MODELS] [--augspeed AUGSPEED]
                      trainoutdir imagesdir predictoutdir

              Version: $version

              Runs Deep3M prediction using via caffe
    
positional arguments:
  trainoutdir          Directory containing Deep3m trained models
  images               Directory of images to process
  predictoutdir        Directory containing output from prediction

optional arguments:
  -h, --help           show this help message and exit
  --models             Only run prediction on models specified
                       in comma delimited list. (default $model_list)
  --augspeed           Augmentation speed. Higher the number
                       the less augmentations generated and
                       faster performance at cost of lower
                       accuracy. (valid values 1, 2, 4, 10)
                       (default 1)

    " 1>&2;
   exit 1;
}

TEMP=`getopt -o h --long "help,models:,augspeed:" -n '$0' -- "$@"`
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -h ) usage ;; 
        --help ) usage ;;
        --models ) model_list=$2 ; shift 2 ;;
        --augspeed ) aug_speed=$2 ; shift 2 ;;
        --) shift ; break ;;
    esac
done


if [ $# -ne 3 ] ; then
  usage 
fi

declare -r train_out=$1
declare -r images=$2
declare -r predict_out=$3


# check aug_speed is a valid value
if [ "$aug_speed" -eq 1 ] || [ "$aug_speed" -eq 2 ] || [ "$aug_speed" -eq 4 ] || [ $aug_speed -eq 10 ] ; then
  : # the : is a no-op command
else
  echo "ERROR, --augspeed must be one of the following values 1, 2, 4, 10"
  exit 2
fi

augimages="$predict_out/augimages"

mkdir -p "$augimages"
ecode=$?

if [ $ecode != 0 ] ; then
  echo "ERROR, a non-zero exit code ($ecode) was received from: mkdir -p \"$augimages\""
  exit 3
fi

DefDataPackages.m "$images" "$augimages"
ecode=$?

if [ $ecode != 0 ] ; then
  echo "ERROR, a non-zero exit code ($ecode) was received from: DefDataPackages.m \"$images\" \"$augimages\""
  exit 4
fi

# write out readme.txt
echo "
This directory contains files and directories needed to
run Cdeep3M prediction using caffe. Below is a description
of the key files and directories:

$model_list         -- Contains results from running prediction
predict.config      -- Contains path to trained model, and input
                       images
caffepredict.sh     -- Runs prediction on individual .h5 file
run_all_predict.sh  -- Runs caffepredict.sh on all .h5 files
                       This is what you should invoke
" > "$predict_out/readme.txt"

# write out predict.config

echo "[default]
trainedmodeldir=$train_out
imagedir=$images
models=$model_list
augspeed=$aug_speed" > "$predict_out/predict.config"


run_all_predict.sh "$predict_out"
ecode=$?
if [ $ecode != 0 ] ; then
  echo "ERROR, a non-zero exit code ($ecode) was received from: run_all_predict.sh \"$predict_out\""
  exit 5
fi

echo ""
echo "Prediction has completed. Results are stored in $predict_out"
echo "Have a nice day!"
echo ""

