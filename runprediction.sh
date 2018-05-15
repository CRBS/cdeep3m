#!/bin/bash

shutdown() {
    # Get our process group id
    PGID=$(ps -o pgid= $$ | grep -o [0-9]*)

    # Kill it in a new new process group
    setsid kill -- -$PGID
    exit 0
}

trap "shutdown" SIGINT SIGTERM

script_name=`basename $0`
script_dir=`dirname $0`
version="???"
maxpackages="3"

source "${script_dir}/commonfunctions.sh"

if [ -f "$script_dir/VERSION" ] ; then
    version=`cat $script_dir/VERSION`
fi

model_list="1fm,3fm,5fm"
aug_speed="1"

function usage()
{
    echo "usage: $script_name [-h] [--models MODELS] [--augspeed AUGSPEED]
                              [--maxpackages PACKAGES]
                      trainoutdir imagesdir predictoutdir

              Version: $version

              Runs Deep3M prediction using via caffe writing output
              to predictoutdir
    
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
  --maxpackages        Number of packages to preprocess before
                       waiting for prediction to catch up. The
                       larger the number the more disk space used,
                       but less likely prediction has to wait
                       for data to be preprocessed. (default $maxpackages)

    " 1>&2;
    exit 1;
}

TEMP=`getopt -o h --long "help,models:,augspeed:,maxpackages:" -n '$0' -- "$@"`
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -h ) usage ;; 
        --help ) usage ;;
        --models ) model_list=$2 ; shift 2 ;;
        --augspeed ) aug_speed=$2 ; shift 2 ;;
        --maxpackages ) maxpackages=$2 ; shift 2 ;;
        --) shift ; break ;;
    esac
done


if [ $# -ne 3 ] ; then
    usage 
fi

declare -r train_out=$1
declare -r images=$2
declare -r out_dir=$3


# check aug_speed is a valid value
if [ "$aug_speed" -eq 1 ] || [ "$aug_speed" -eq 2 ] || [ "$aug_speed" -eq 4 ] || [ $aug_speed -eq 10 ] ; then
    : # the : is a no-op command
else
    fatal_error "$out_dir" "ERROR, --augspeed must be one of the following values 1, 2, 4, 10" 2
fi

if [ -f "$out_dir/DONE" ] ; then
    echo "DONE file found in $out_dir. Appears no work needs to be done."
    exit 0
fi

if [ -f "$out_dir/ERROR" ] ; then
    echo "$out_dir/ERROR file found. Something failed. Exiting..."
    exit 99
fi

log_dir="$out_dir/logs"
mkdir -p "$log_dir"
ecode=$?
if [ $ecode != 0 ] ; then
    fatal_error "$out_dir" "ERROR, a non-zero exit code ($ecode) was received from: mkdir -p \"$log_dir\"" 3
fi

augimages="$out_dir/augimages"

mkdir -p "$augimages"
ecode=$?

if [ $ecode != 0 ] ; then
    fatal_error "$out_dir" "ERROR, a non-zero exit code ($ecode) was received from: mkdir -p \"$augimages\"" 3
fi

DefDataPackages.m "$images" "$augimages"
ecode=$?

if [ $ecode != 0 ] ; then
    fatal_error "$out_dir" "ERROR, a non-zero exit code ($ecode) was received from: DefDataPackages.m \"$images\" \"$augimages\"" 4
fi

cp "$out_dir/augimages/de_augmentation_info.mat" "$out_dir/."

if [ $? != 0 ] ; then
    fatal_error "$out_dir" "ERROR unable to copy $out_dir/augimages/de_augmentation_info.mat to $out_dir" 8
fi

cp "$out_dir/augimages/package_processing_info.txt" "$out_dir/."

if [ $? != 0 ] ; then
    fatal_error "$out_dir" "ERROR unable to copy $out_dir/augimages/package_processing_info.txt to $out_dir" 9
fi

# write out readme.txt
echo "
This directory contains files and directories needed to
run Cdeep3M prediction using caffe. Below is a description
of the key files and directories:

$model_list                 -- Contains results from running prediction.
predict.config              -- Contains path to trained model, and input
                               images.
augimages/                  -- Directory where augmented version of input
                               images will be temporarily stored.
logs/                       -- Contains log files from the 3 worker scripts 
                               running in parallel.
de_augmentation_info.mat    -- Contains information on how dataset is
                               broken into packages.
package_processing_info.txt -- Contains summary of number of packages
                               that will be created.
" > "$out_dir/readme.txt"

# write out predict.config

echo "[default]
trainedmodeldir=$train_out
imagedir=$images
models=$model_list
augspeed=$aug_speed" > "$out_dir/predict.config"

echo "Start up worker to generate packages to process"
preprocessworker.sh --maxpackages $maxpackages "$out_dir" >> "$log_dir/preprocess.log" 2>&1 &

echo "Start up worker to run prediction on packages"
predictworker.sh "$out_dir" >> "$log_dir/prediction.log" 2>&1 &

echo "Start up worker to run post processing on packages"
postprocessworker.sh "$out_dir" >> "$log_dir/postprocess.log" 2>&1 &

echo ""
echo "To see progress run the following command in another window:"
echo ""
echo "tail -f \"$out_dir/*.log\""

wait

space_sep_models=$(get_models_as_space_separated_list $model_list)
for Y in `echo $space_sep_models` ; do
    ensemble_args=`echo "$ensemble_args $out_dir/$Y"`
done

ensemble_args=`echo "$ensemble_args $out_dir/ensembled"`

EnsemblePredictions.m $ensemble_args
ecode=$?
if [ $ecode != 0 ] ; then
    fatal_error "$out_dir" "ERROR, a non-zero exit code ($ecode) was received from: EnsemblePredictions.m $ensemble_args" 12
fi

echo -e "success\n0" > "$out_dir/DONE"

echo ""
echo "Prediction has completed. Results are stored in $out_dir/ensembled"
echo "Have a nice day!"
echo ""
exit 0
