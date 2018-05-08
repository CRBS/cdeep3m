#!/bin/bash

function fatal_error {
  jobdir=$1
  errmsg=$2
  echo "$errmsg" 1>&2
  echo "$errmsg" >> "$jobdir/ERROR"
}

function get_package_name {
# get_package_name ($package_num, $package_z)
# given package number and z sets
# $package_name to standard naming convention
# for packages. Namely Pkg###_Z##
  local curpkg=$1
  local curz=$2
  local pad_pkg=`printf "%03d" $curpkg`
  local pad_z=`printf "%02d" $curz`
  echo "Pkg${pad_pkg}_Z${pad_z}"
}

function get_number_done_files_in_dir {
  thedir=$1
  number_done_files=`find "$thedir" -name "DONE" -type f | wc -l`
  echo "$number_done_files"
}

function wait_for_predict_to_finish_on_package {
  local pkg_dir=$1
  local wait_time=$2
  while [ ! -f "$pkg_dir/PREDICTDONE" ] ; do
    sleep $wait_time
  done
}

function wait_for_prediction_to_catchup {
  local augimages=$1
  local max_pkgs=$2
  local wait_time=$3
  
  local num_pkgs=$(get_number_done_files_in_dir "$augimages")
  while [ "$num_pkgs" -gt "$max_pkgs" ] ; do
    sleep $wait_time
    num_pkgs=$(get_number_done_files_in_dir "$augimages")
    if [ -f "$augimages/KILL.REQUEST" ] ; then
      echo "killed"
      return 0
    fi
  done
  echo ""
}

function wait_for_preprocess_to_finish_on_package {
  local package_dir=$1
  local wait_time=$2
  while [ ! -f "$package_dir/DONE" ] ; do
    sleep $wait_time
  done
}

function parse_package_processing_info {
# Parses file passed assuming its 
# a package_processing_info.txt with format
#
# <blank line>
# Number of XY Packages
# <val 1>
# Number of z-blocks
# <val 2>
#
# and sets $num_pkgs to <val 1>, 
# $num_zstacks to <val 2> and 
# $tot_pkgs to $num_pkgs*$num_zstacks
  
  package_proc_info=$1
  num_pkgs=`head -n 3 $package_proc_info | tail -n 1`
  num_zstacks=`tail -n 1 $package_proc_info`
  let tot_pkgs=$num_pkgs*$num_zstacks
}

function get_models_as_space_separated_list {
 local space_sep_models=`echo "$1" | sed "s/,/ /g"`
 echo "$space_sep_models"
}

function parse_predict_config {
# parses file passed in as first 
# argument which is assumed to be
# a predict.config file with this format:
#
#  trainedmodeldir=<val>
#  imagedir=<val>
#  models=<val>
#  augspeed=<va>
#
# and sets the following variables to values
# found in the config file
# $trained_model_dir
# $img_dir
# $model_list
# $aug_speed
#
# If no file found 2 is returned
# If unable to parse trainedmodeldir from config 3 is returned
# If unable to parse imagedir from config 4 is returned
# If unable to parse models from config 5 is returned
# If unable to parse augspeed from config 6 is returned

  predict_config=$1

  if [ ! -s "$predict_config" ] ; then
    echo "ERROR no $predict_config file found"
    return 2
  fi

  trained_model_dir=`egrep "^ *trainedmodeldir *=" "$predict_config" | sed "s/^.*=//" | sed "s/^ *//"`

  if [ -z "$trained_model_dir" ] ; then
    echo "ERROR unable to extract trainedmodeldir from $predict_config"
    return 3
  fi

  img_dir=`egrep "^ *imagedir *=" "$predict_config" | sed "s/^.*=//" | sed "s/^ *//"`

  if [ -z "$img_dir" ] ; then
    echo "ERROR unable to extract imagedir from $predict_config"
    return 4
  fi

  model_list=`egrep "^ *models *=" "$predict_config" | sed "s/^.*=//" | sed "s/^ *//"`

  if [ -z "$model_list" ] ; then
    echo "ERROR unable to extract models from $predict_config"
    return 5
  fi

  aug_speed=`egrep "^ *augspeed *=" "$predict_config" | sed "s/^.*=//" | sed "s/^ *//"`

  if [ -z "$aug_speed" ] ; then
    echo "ERROR unable to extract augspeed from $predict_config"
    return 6
  fi
  return 0
}
