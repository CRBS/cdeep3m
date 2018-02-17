#!/bin/bash

script_name=`basename $0`
script_dir=`dirname $0`
version="???"

if [ -f "$script_dir/VERSION" ] ; then
   version=`cat $script_dir/VERSION`
fi

numiterations="2000"
gpu="all"
one_fmonly=false
function usage()
{
    echo "usage: $script_name [-h] [--1fmonly] [--numiterations NUMITERATIONS]

              Version: $version

              Runs caffe training on Deep3M model in directory where
              this script resides 

optional arguments:
  -h, --help           show this help message and exit
  --1fmonly            Only train 1fm model
  --numiterations      Number of training iterations to run (default $numiterations)
  --gpu                Which GPU to use, can be a number ie 0 or 1 or
                       all to use all GPUs (default $gpu)

    " 1>&2;
   exit 1;
}

TEMP=`getopt -o h --long "1fmonly,numiterations:,gpu:" -n '$0' -- "$@"`
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -h ) usage ;;
        --1fmonly ) one_fmonly=true ; shift ;;
        --numiterations ) numiterations=$2 ; shift 2 ;;
        --gpu ) gpu=$2 ; shift 2 ;;
        --) break ;;
    esac
done

# time_est=`perl -e "printf('%.2f',${num_iterations}*8/3600);"`

echo ""

for Y in `echo 1fm 3fm 5fm` ; do
  if [ ! -d "$script_dir/$Y" ] ; then
    echo "ERROR, no $script_dir/$Y directory found."
    exit 2
  fi
  echo "Running $Y train, this could take a while"
  /usr/bin/time -p $script_dir/caffe_train.sh --numiterations $numiterations --gpu $gpu $Y
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
  if [ $one_fmonly == true ] ; then
    echo "--1fmonly flag set, skipping 3fm and 5fm models."
    break
  fi
done

echo ""
echo "Training has completed. Have a nice day!"
echo ""
