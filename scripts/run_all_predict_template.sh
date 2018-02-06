#!/bin/bash

if [ $# -ne 3 ] ; then
  echo "$0 <trained model dir> <image dir> <caffe bin path>"
  echo ""
  echo "Runs caffe_predict.sh for all three models in directory this script"
  echo "is located"
  echo ""
  echo "<trained model dir> -- Directory created by Train.m with trained"
  echo "                       models created by invocation of run_all_train.sh"
  echo ""
  echo "<image dir> -- Directory containing augmented images"
  echo ""
  echo "<caffe bin path> -- Directory where caffe.bin binary resides"
  echo "                    On AWS EC2 AMI its usually"
  echo "                    /home/ubuntu/caffe_nd_sense_segmentation/build/tools/" 
  echo ""
  exit 1
fi

gpu="0"

script_dir=`dirname "$0"`

trained_model_dir=$1

img_dir="$2"

caffe_path=""

if [ "$3" != "" ] ; then
   caffe_path="${3}/"
fi

for Y in `find "$script_dir" -name "*fm" -type d | sort` ; do
  model_name=`basename $Y`
  echo "Running $model_name predict"
  for Z in `find "$Y" -name "Pkg*" -type d` ; do
     if [ -f "$Z/DONE" ] ; then
        echo "Found $Z/DONE. Prediction completed. Skipping..."
        continue
     fi
     pkg_name=`basename $Z`
     outfile="$Z/out.log"
     /usr/bin/time -p $script_dir/caffe_predict.sh "$trained_model_dir/$model_name/trainedmodel" "$caffe_path" "${img_dir}/${pkg_name}" $gpu "$Z" > "$outfile" 2>&1
    if [ $? != 0 ] ; then
      echo "Non zero exit code from caffe for predict $Z model. Exiting."
      if [ -f "$outfile" ] ; then
        echo "Here is last 10 lines of $outfile:"
        echo ""
        tail $outfile
        exit 1
      fi
    fi
    echo "Prediction completed: `date +%s`" > "$Z/DONE"
  done
done


echo ""
echo "Prediction has completed. Have a nice day!"
echo ""
