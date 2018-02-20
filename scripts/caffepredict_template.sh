#!/bin/bash


script_dir=`dirname "$0"`
script_name=`basename $0`
version="???"

if [ -f "$script_dir/VERSION" ] ; then
   version=`cat $script_dir/VERSION`
fi

gpu="0"


function usage()
{
    echo "usage: $script_name [-h] [--gpu GPU]
                      model augimagesdir outputdir

              Version: $version

              Runs caffe on Deep3m model specified by model argument 
              to perform training. The trained model will be stored in
              <model>/trainedmodel directory
              Output from caffe will be redirected to <model>/log/out.log
    
positional arguments:
  model                Path to .caffemodel file or directory with caffe
                       model. If later then the latest is used.
  augimagesdir         Directory path with prefix containing the 16 .h5
                       files that end with v#.h5. This data would have been
                       created PreprocessImageData.m
  outdir               Destination directory to write output. Will be
                       created if it does not exist.
optional arguments:
  -h, --help           show this help message and exit
  --gpu                Which GPU to use, can be a number ie 0 or 1 or
                       all to use all GPUs (default $gpu)

    " 1>&2;
   exit 1;
}

TEMP=`getopt -o h --long "gpu:" -n '$0' -- "$@"`
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -h ) usage ;;
        --gpu ) gpu=$2 ; shift 2 ;;
        --) shift ; break ;;
    esac
done


if [ $# -ne 3 ] ; then
  usage
fi

model=$1
in_dir=$2
out_dir=$3


if [ -d "$model" ] ; then
  model_dir="$model"
  latest_iteration=`ls "$model" | egrep "\.caffemodel$" | sed "s/^.*iter_//" | sed "s/\.caffemodel//" | sort -g | tail -n 1`
  if [ "$latest_iteration" == "" ] ; then
     echo "ERROR no #.caffemodel files found"
     exit 2
  fi
  model=`find "$model" -name "*${latest_iteration}.caffemodel" -type f`
else
  model_dir=`dirname "$model"`
fi

deploy_dir="$model_dir/.."


log_dir="$out_dir/log"
out_log="$out_dir/out.log"

mkdir -p "$log_dir"

if [ $? != 0 ] ; then
  echo "ERROR unable to create $log_dir"
  exit 3
fi


for idx in {1..16..1}
  do
  predict_dir=$out_dir/v$idx;

  if [ ! -d "$predict_dir" ]; then
    # Control will enter here if $DIRECTORY doesn't exist.
    echo "Creating directory $predict_dir" >> "$out_log"
    mkdir -p "$predict_dir"
    if [ $? != 0 ] ; then
      echo "ERROR unable to create $predict_dir"
      exit 4
    fi
  fi

  input_file=`find "${in_dir}" -name "*_v${idx}.h5" -type f`
  if [ ! -f "$input_file" ] ; then
    echo "ERROR file not found: $input_file" >> "$out_log"
    exit 5
  fi 
  echo -n "."
  echo "Input: $input_file" >> "$out_log"
  echo "Output: $predict_dir" >> "$out_log"

  GLOG_logtostderr="$log_dir" /usr/bin/time -p predict_seg_new.bin --model=${deploy_dir}/deploy.prototxt --weights=${model} --data=${input_file} --predict=$predict_dir/test.h5 --shift_axis=2 --shift_stride=1 --gpu=$gpu >> "$out_log" 2>&1
  ecode=$?
  if [ $ecode != 0 ] ; then
    echo "ERROR non-zero exit code ($ecode) from running predict_seg_new.bin"
    exit 6
  fi
done

echo ""
echo "Running StartPostprocessing.m $out_dir"
StartPostprocessing.m "$out_dir" >> "$out_log" 2>&1
ecode=$?

if [ $ecode != 0 ] ; then
  echo "ERROR non-zero exit code ($ecode) from running StartPostprocessing.m"
  exit 7
fi

fm_dir=`dirname "$out_dir"`
echo ""
echo "Running Merge_LargeData.m $fm_dir"
Merge_LargeData.m "$fm_dir" >> "$out_log" 2>&1
ecode=$?

if [ $ecode != 0 ] ; then
  echo "ERROR non-zero exit code ($ecode) from running Merge_LargeData.m"
  exit 8
fi

exit 0
