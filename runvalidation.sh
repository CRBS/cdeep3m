#!/bin/bash

script_name=`basename $0`
script_dir=`dirname $0`
version="???"

if [ -f "$script_dir/VERSION" ] ; then
   version=`cat $script_dir/VERSION`
fi

function usage()
{
    echo "usage: $script_name log_file out_file

              Script to plot training vs validation loss. 
              Example: runvalidation.sh ~/cdeep3m/train_out/1fm/log/out.log ~/cdeep3m/train_out/1fm/train_vs_val.png

              Version: $version

positional arguments:
  log_file        Log file from desired model. 
  out_file        Filename of output png. 


    " 1>&2;
   exit 1;
}

if [ $# -ne 2 ] ; then
  usage
fi


log_dir=$(dirname $1)


python $CAFFE_PATH/tools/extra/parse_log.py $1 $log_dir 


PlotValidation.m $1.train $1.test $2
