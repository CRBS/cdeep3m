#!/bin/bash

if [ $# -ne 3 ] ; then
  echo "$0 <model> <input dir with prefix id ../../data/snemi_test> <output dir>"
  echo ""
  echo "<model> -- path to .caffemodel file"
  echo "<input dir..> -- directory path with prefix to 16 .h5 files that end" 
  echo "                 with v#.h5"
  echo "<output dir> -- Output directory, will be created if needed. ex ./yo"
  echo ""
  exit 1
fi

model=$1
in_dir=$2
out_dir=$3

caffe_path=../../../caffe_nd_sense_segmentation/build/tools
for idx in {1..16..1}
  do
  predict_dir=$out_dir/v$idx;

  if [ ! -d "LOG2" ] ; then
    mkdir LOG2
  fi

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

  GLOG_logtostderr=LOG2 /usr/bin/time -p $caffe_path/predict_seg_new.bin --model=deploy.prototxt --weights=${model} --data=${input_file} --predict=$predict_dir/test.h5 --shift_axis=2 --shift_stride=1 --gpu=0

done
~/deep3m/StartPostprocessing.m $out_dir not_needed
