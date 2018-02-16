#!/bin/bash

script_name=`basename $0`
script_dir=`dirname $0`
version="???"

if [ -f "$script_dir/VERSION" ] ; then
   version=`cat $script_dir/VERSION`
fi

gpu="0"
one_fmonly=false

function usage()
{
    echo "usage: $script_name [-h] [--1fmonly] [--gpu GPU]

              Version: $version

              Runs caffe prediction on Deep3M trained model using
              predict.config file to obtain location of trained
              model and image data

optional arguments:
  -h, --help           show this help message and exit
  --1fmonly            Only run prediction on 1fm model
  --gpu                Which GPU to use, can be a number ie 0 or 1
                       (default $gpu)

    " 1>&2;
   exit 1;
}

TEMP=`getopt -o h --long "1fmonly,gpu:" -n '$0' -- "$@"`
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -h ) usage ;;
        --1fmonly ) one_fmonly=true ; shift ;;
        --gpu ) gpu=$2 ; shift 2 ;;
        --) break ;;
    esac
done

echo ""

predict_config="$script_dir/predict.config"

if [ ! -s "$predict_config" ] ; then
  echo "ERROR no $predict_config file found, which is required"
  exit 2
fi

trained_model_dir=`egrep "^ *trainedmodeldir *=" "$predict_config" | sed "s/^.*=//" | sed "s/^ *//"`

img_dir=`egrep "^ *augimagedir *=" "$predict_config" | sed "s/^.*=//" | sed "s/^ *//"`

echo "Running Prediction"
echo ""

echo "Trained Model Dir: $trained_model_dir"
echo "Image Dir: $img_dir"
echo ""

for Y in `find "$script_dir" -name "*fm" -type d | sort` ; do
 
  if [ $one_fmonly == true ] ; then
    if [ "$Y" != "$script_dir/1fm" ] ; then
       echo "--1fmonly flag set skipping prediction for $Y"
       continue
    fi
  fi

  num_pkgs=`find "$Y" -name "Pkg*" -type d | wc -l`
  model_name=`basename $Y`
  echo "Running $model_name predict $num_pkgs package(s) to process"
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
      fi
      exit 3
    fi
    echo "Prediction completed: `date +%s`" > "$Z/DONE"
    let cntr+=1
  done
done


echo ""
echo "Prediction has completed. Have a nice day!"
echo ""
