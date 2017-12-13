#!/bin/bash

if [ $# -ne 2 ] ; then
  echo "$0 <caffe bin path> <# iterations>"
  echo ""
  echo "Runs caffe_train.sh for all three models in directory this script is located"
  echo ""
  echo "<caffe bin path> -- Directory where caffe.bin binary resides"
  echo "                    On AWS EC2 AMI its usually"
  echo "                    /home/ubuntu/caffe_nd_sense_segmentation/build/tools/" 
  echo ""
  echo "<# iterations> -- Sets number of iterations caffe should be run."
  echo "                  Ex: 1000 for 1,000 iterations"
  echo ""
  exit 1
fi

script_dir=`dirname "$0"`

caffe_path=""

if [ "$1" != "" ] ; then
   caffe_path="${1}/"
fi

num_iterations=$2

time_est=`perl -e "printf('%.2f',${num_iterations}*4/3600);"`

echo ""
echo "Estimating $time_est hours of processing per model (there are 3 models) on p3.2xlarge"
echo ""

for Y in `echo 1fm 3fm 5fm` ; do
  echo "Running $Y train, expect this model to train for $time_est hours on p3.2xlarge"
  /usr/bin/time -p $script_dir/caffe_train.sh $Y $caffe_path $num_iterations all
  if [ $? != 0 ] ; then
    echo "Non zero exit code from caffe for train of $Y model. Exiting."
    outfile="$script_dir/$Y/log/out.log"
    if [ -f "$outfile" ] ; then
      echo "Here is last 10 lines of $outfile:"
      echo ""
      tail $outfile
    fi
    exit 1
  fi
done

echo ""
echo "Training has completed. Have a nice day!"
echo ""
