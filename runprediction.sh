#!/bin/bash



script_name=`basename $0`
script_dir=`dirname $0`
version="???"

if [ -f "$script_dir/VERSION" ] ; then
   version=`cat $script_dir/VERSION`
fi

one_fmonly=""
gpu="0"
aug_speed="1"

function usage()
{
    echo "usage: $script_name [-h] [--1fmonly] [--augspeed AUGSPEED]
                      trainoutdir imagesdir predictoutdir

              Version: $version

              Runs Deep3M prediction using via caffe
    
positional arguments:
  trainoutdir          Directory containing Deep3m trained models
  images               Directory of images to process
  predictoutdir        Directory containing output from prediction

optional arguments:
  -h, --help           show this help message and exit
  --1fmonly            Only run prediction on 1fm model
  --augspeed           Augmentation speed. Higher the number
                       the less augmentations generated and
                       faster performance at cost of lower
                       accuracy. (valid values 1, 2, 4, 10)
                       (default 1)

    " 1>&2;
   exit 1;
}

TEMP=`getopt -o h --long "1fmonly,augspeed:" -n '$0' -- "$@"`
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -h ) usage ;; 
        --1fmonly ) one_fmonly="--1fmonly " ; shift ;;
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
  exit 7
fi

augimages="$predict_out/augimages"

mkdir -p "$augimages"
ecode=$?

if [ $ecode != 0 ] ; then
  echo "ERROR, a non-zero exit code ($ecode) was received from: mkdir -p \"$augimages\""
  exit 6
fi

DefDataPackages.m "$images" "$augimages"
ecode=$?

if [ $ecode != 0 ] ; then
  echo "ERROR, a non-zero exit code ($ecode) was received from: DefDataPackages.m \"$images\" \"$augimages\""
  exit 5
fi

CreatePredictJob.m "$train_out" "$augimages" "$predict_out"
ecode=$?
if [ $ecode != 0 ] ; then
  echo "ERROR, a non-zero exit code ($ecode) was received from: CreatePredictJob.m \"$train_out\" \"$augimages\" \"$predict_out\""
  echo ""
  exit 2
fi

if [ ! -x "$predict_out/run_all_predict.sh" ] ; then
  echo "ERROR, either $predict_out/run_all_predict.sh is missing or non-executable"
  exit 3
fi

"$predict_out/run_all_predict.sh" ${one_fmonly} --augspeed ${aug_speed}
ecode=$?
if [ $ecode != 0 ] ; then
  echo "ERROR, a non-zero exit code ($ecode) was received from: \"$predict_out/run_all_predict.sh\" ${one_fmonly} --augspeed ${aug_speed}"
  exit 4
fi

echo ""
echo "Prediction has completed. Results are stored in $predict_out"
echo "Have a nice day!"
echo ""
