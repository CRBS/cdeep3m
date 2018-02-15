#!/bin/bash



script_name=`basename $0`
script_dir=`dirname $0`
version="???"

if [ -f "$script_dir/VERSION" ] ; then
   version=`cat $script_dir/VERSION`
fi

one_fmonly=""
gpu="0"
function usage()
{
    echo "usage: $script_name [-h] [--1fmonly]
                      trainoutdir augimagesdir predictoutdir

              Version: $version

              Runs Deep3M prediction using via caffe
    
positional arguments:
  trainoutdir          Directory containing Deep3m trained models
  augimages            Augmented image data from PreprocessImageData.m
  predictoutdir        Directory containing output from prediction

optional arguments:
  -h, --help           show this help message and exit
  --1fmonly            Only run prediction on 1fm model

    " 1>&2;
   exit 1;
}

TEMP=`getopt -o h --long "1fmonly,gpu:" -n '$0' -- "$@"`
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -h ) usage ;; 
        --1fmonly ) one_fmonly="--1fmonly " ; shift ;;
        --) shift ; break ;;
    esac
done


if [ $# -ne 3 ] ; then
  usage 
fi

declare -r train_out=$1
declare -r augimages=$2
declare -r predict_out=$3

CreatePredictJob.m "$train_out" "$augimages" "$predict_out"
ecode=$?
if [ $ecode != 0 ] ; then
  echo "Error, a non-zero exit code ($ecode) was received from: CreatePredictJob.m \"$train_out\" \"$augimages\" \"$predict_out\""
  echo ""
  exit 2
fi

if [ ! -x "$predict_out/run_all_predict.sh" ] ; then
  echo "ERROR, either $predict_out/run_all_predict.sh is missing or non-executable"
  exit 3
fi

"$predict_out/run_all_predict.sh" ${one_fmonly}
ecode=$?
if [ $ecode != 0 ] ; then
  echo "ERROR, a non-zero exit code ($ecode) was received from: \"$predict_out/run_all_predict.sh\" ${one_fmonly}"
  exit 4
fi

echo ""
echo "Prediction has completed. Results are stored in $predict_out"
echo "Have a nice day!"
echo ""
