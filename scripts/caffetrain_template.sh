#!/bin/bash


if [ $# -ne 3 ] ; then
  echo "$0 <model> <# iterations> <gpu>"
  echo ""
  echo "Runs caffe on model specified by first argument. The trained"
  echo "model will be stored in <model>/trainedmodel directory"
  echo "Output from caffe will be redirected to <mode>/log/out.log"
  echo ""
  echo "<model> -- The model to train, should be one of the following:"
  echo "           1fm, 3fm, or 5fm"
  echo ""
  echo "<# iterations> -- # of training iterations to run, should be a"
  echo "                  number like 1000, or 50000"
  echo "<gpu> -- The gpu to use (expects a number ie 0, or 1 or all)"
  echo ""
  exit 1
fi

script_dir=`dirname "$0"`
model=$1

# set number of iterations
num_iterations=$2

# set gpu value
gpu=$3

base_dir=`cd "$script_dir";pwd`
model_dir="$base_dir/$model"
log_dir="$model_dir/log"


# update the solver.prototxt with num_iterations value
sed -i "s/^max_iter:.*/max_iter: $num_iterations/g" "${model_dir}/solver.prototxt"

if [ $? != 0 ] ; then
  echo "Error trying to update max_iter in $model_dir/solver.prototxt."
  echo "Please set number of iterations directly in this file"
fi

if [ ! -d "$log_dir" ] ; then
  mkdir -p $log_dir
fi

if [ ! -d "$model_dir/trainedmodel" ] ; then 
  mkdir -p "$model_dir/trainedmodel"
fi

latest_iteration=`ls "$model_dir/trainedmodel" | egrep "\.solverstate$" | sed "s/^.*iter_//" | sed "s/\.solverstate//" | sort -g | tail -n 1`

snapshot_opts=""
# we got a completed iteration lets start from that
if [ ! "$latest_iteration" == "" ] ; then
  snap_file=`find "$model_dir/trainedmodel" -name "*${latest_iteration}.solverstate" -type f`
  snapshot_opts="--snapshot=$snap_file"
  echo "Resuming run from snapshot file: $snap_file"
fi

pushd "$model_dir" > /dev/null
GLOG_log_dir=$log_dir caffe.bin train --solver=$model_dir/solver.prototxt --gpu $gpu $snapshot_opts > "${model_dir}/log/out.log" 2>&1
exitcode=$?
popd > /dev/null

if [ $exitcode != 0 ] ; then
  echo "ERROR: caffe had a non zero exit code: $exitcode"
fi

exit $exitcode
