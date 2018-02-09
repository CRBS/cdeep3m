#!/bin/bash

if [ $# -ne 0 ] ; then
  echo "$0"
  echo ""
  echo "Runs caffe_predict.sh for all three models in directory this script"
  echo "is located, using config file predict.config to obtain location of"
  echo "trained model and image data"
  echo ""
  exit 1
fi

gpu="0"

script_dir=`dirname "$0"`

predict_config="$script_dir/predict.config"

trained_model_dir=`egrep "^ *trainedmodeldir *=" "$predict_config" | sed "s/^.*=//" | sed "s/^ *//"`

img_dir=`egrep "^ *augimagedir *=" "$predict_config" | sed "s/^.*=//" | sed "s/^ *//"`

echo "Trained Model Dir: $trained_model_dir"
echo "Image Dir: $img_dir"

for Y in `find "$script_dir" -name "*fm" -type d | sort` ; do
 
  num_pkgs=`find "$Y" -name "Pkg*" -type d | wc -l`
  model_name=`basename $Y`
  echo "Running $model_name predict ($num_pkgs) packages to process"
  let cntr=1
  for Z in `find "$Y" -name "Pkg*" -type d` ; do
     if [ -f "$Z/DONE" ] ; then
        echo "Found $Z/DONE. Prediction completed. Skipping..."
        continue
     fi
     pkg_name=`basename $Z`
     outfile="$Z/out.log"
     echo -n "  Processing $pkg_name $cntr of $num_pkgs "
     /usr/bin/time -p $script_dir/caffe_predict.sh "$trained_model_dir/$model_name/trainedmodel" "${img_dir}/${pkg_name}" $gpu "$Z"
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
    let cntr+=1
  done
done


echo ""
echo "Prediction has completed. Have a nice day!"
echo ""
