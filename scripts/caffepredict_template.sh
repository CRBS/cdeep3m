#!/bin/bash

if [ $# -ne 3 ] ; then
  echo "$0 <model> <caffe bin> <input dir with prefix id /data/test> <gpu> <output dir>"
  echo ""
  echo "<model> -- path to .caffemodel file"
  echo ""
  echo "<caffe bin path> -- Directory where caffe.bin binary resides"
  echo "                    If no path needed specify \"\""
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

if [ "$2" != "" ] ; then
   caffe_path="${2}/"
fi

in_dir=$3

# set gpu value
gpu=$4

out_dir=$5

log_dir="$out_dir/log"

mkdir -p "$log_dir"

for idx in {1..16..1}
  do
  predict_dir=$out_dir/v$idx;

  if [ ! -d "$predict_dir" ]; then
    # Control will enter here if $DIRECTORY doesn't exist.
    echo "Creating directory $predict_dir"
    mkdir -p "$predict_dir"
  fi

  input_file="${in_dir}${idx}.h5"
  if [ ! -f $input_file ] ; then
    echo "file not found: $input_file"
  fi

  echo "Input: $input_file"
  echo "Output: $predict_dir"

  GLOG_logtostderr="$log_dir" /usr/bin/time -p $caffe_path/predict_seg_new.bin --model=deploy.prototxt --weights=${model} --data=${input_file} --predict=$predict_dir/test.h5 --shift_axis=2 --shift_stride=1 --gpu=0

done
