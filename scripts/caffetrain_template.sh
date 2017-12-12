#!/bin/bash

caffe_path=""

if [ $# -ne 3 ] ; then
  echo "$0 <model ie 1fm, 3fm, or 5fm> <caffe bin path with ending /> <which gpu to use 'all' for all or # ie 1>"
  echo ""
  echo "Runs caffe on model specified as first argument"
  echo ""
  exit 1
fi

script_dir=`dirname "$0"`
model=$1
caffe_path=$2
gpu=$3

base_dir=`cd "$script_dir";pwd`
model_dir="$base_dir/$model"
log_dir="$model_dir/log"

if [ ! -d "$log_dir" ] ; then
  mkdir -p $log_dir
fi

if [ ! -d "$model_dir/trainedmodel" ] ; then 
  mkdir -p "$model_dir/trainedmodel"
fi

latest_iteration=`ls "$model_dir/trainedmodel" | egrep "\.solverstate$" | sed "s/^.*iter_//" | sed "s/\.solverstate//" | sort -g`

snapshot_opts=""
# we got a completed iteration lets start from that
if [ ! "$latest_iteration" == "" ] ; then
  snap_file=`find "$model_dir/trainedmodel -depth 1 -name "*${latest_iteration}.solverstate"`
  snapshot_opts="--snapshot=$snap_file"
fi

GLOG_log_dir=$log_dir $caffe_path/caffe.bin train --solver=$model_dir/solver.prototxt --gpu $gpu $snapshot_opts
