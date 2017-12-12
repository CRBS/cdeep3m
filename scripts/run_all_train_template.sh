#!/bin/bash

if [ $# -ne 1 ] ; then
  echo "$0 <caffe bin path> <# iterations>"
  echo ""
  echo "Runs caffe_train.sh for all three models in directory this script is located"
  echo ""
  echo "<# iterations> -- Sets number of iterations caffe should be run. This is done"
  echo "                  by passing this value to caffe_train.sh"
  echo ""
  exit 1
fi

script_dir=`dirname "$0"`

caffe_path=""

if [ "$1" != "" ] ; then
   caffe_path="${1}/"
fi

num_iterations=$2

for Y in `echo 1fm 3fm 5fm` ; do
  echo "Running $Y train"
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
