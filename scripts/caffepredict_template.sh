#!/bin/bash


if [ $# -ne 4 ] ; then
  echo "Expected 4 arguments got: $*"
  echo ""
  echo "$0 <model> <input dir with prefix id /data/test> <gpu> <output dir>"
  echo ""
  echo "<model> -- path to .caffemodel file or directory with caffe"
  echo "           models in which case the latest is used"
  echo ""
  echo "<input dir..> -- directory path with prefix to 16 .h5 files that end" 
  echo "                 with v#.h5"
  echo ""
  echo "<gpu> -- The gpu to use (expects a number 0, or 1)"
  echo ""
  echo "<output dir> -- Output directory, will be created if needed. ex ./yo"
  echo ""
  exit 1
fi

model=$1

deploy_dir="$model/.."

if [ -d "$model" ] ; then
  latest_iteration=`ls "$model" | egrep "\.caffemodel$" | sed "s/^.*iter_//" | sed "s/\.caffemodel//" | sort -g | tail -n 1`
  if [ "$latest_iteration" == "" ] ; then
     echo "Error no #.caffemodel files found"
     exit 2
  fi
  model=`find "$model" -name "*${latest_iteration}.caffemodel" -type f`
fi

in_dir=$2

# set gpu value
gpu=$3

out_dir=$4

log_dir="$out_dir/log"

out_log="$out_dir/out.log"

mkdir -p "$log_dir"

for idx in {1..16..1}
  do
  predict_dir=$out_dir/v$idx;

  if [ ! -d "$predict_dir" ]; then
    # Control will enter here if $DIRECTORY doesn't exist.
    echo "Creating directory $predict_dir" >> "$out_log"
    mkdir -p "$predict_dir"
  fi

  input_file=`find "${in_dir}" -name "*_v${idx}.h5" -type f`
  if [ ! -f $input_file ] ; then
    echo "file not found: $input_file" >> "$out_log"
    exit 1
  fi 
  echo -n "."
  echo "Input: $input_file" >> "$out_log"
  echo "Output: $predict_dir" >> "$out_log"

  GLOG_logtostderr="$log_dir" /usr/bin/time -p predict_seg_new.bin --model=${deploy_dir}/deploy.prototxt --weights=${model} --data=${input_file} --predict=$predict_dir/test.h5 --shift_axis=2 --shift_stride=1 --gpu=0 >> "$out_log" 2>&1

done

echo "Running StartPostprocessing.m $out_dir"
StartPostprocessing.m "$out_dir"

fm_dir=`dirname "$out_dir"`
echo "Running Merge_LargeData.m $fm_dir"
Merge_LargeData.m "$fm_dir"

exit $?
