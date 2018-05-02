#!/bin/bash



script_name=`basename $0`
script_dir=`dirname $0`
version="???"

if [ -f "$script_dir/VERSION" ] ; then
   version=`cat $script_dir/VERSION`
fi



python $CAFFE_PATH/tools/extra/parse_log.py $1/log/out.log $1/log/


PlotValidation.m $1/log/out.log.train $1/log/out.log.test $1
