#!/bin/bash

function fatal_error {
    local jobdir=$1
    local errmsg=$2
    local ecode=$3
    echo "$errmsg" 1>&2
    echo "$errmsg" >> "$jobdir/ERROR"
    echo "$errmsg" >> "$jobdir/KILL.REQUEST"
    if [ -n "$ecode" ] ; then
        echo "$ecode" >> "$jobdir/ERROR"
        exit $ecode
    fi
}

function copy_trained_models {
# Copies any trained models from 
# source train_out dir $1 to
# dest train_out dir $2
    local src=$1
    local dest=$2
    local res=""
    for Y in `echo "1fm 3fm 5fm"` ; do
        if [ ! -d "$src/$Y/trainedmodel" ] ; then
            continue
        fi
        if [ ! -d "$dest/$Y/trainedmodel" ] ; then
            continue
        fi
        res=$(copy_models_from_dir "$src/$Y/trainedmodel" "$dest/$Y/trainedmodel")
        echo "$res"
    done
}

function copy_models_from_dir {
# Copies trained models from $1 directory
# to $2 directory if both directories exist
# returning following values strings
# Copy of $1 to $2 success - if both directories exist
# $1 src dir not found - if source is not a directory
# $2 dest dir not found - if destination is not a directory
# ERROR $1 to $2 copy failed - if there was an error with copy
# such as no files
    local src=$1
    local dest=$2
    if [ ! -d "$src" ] ; then
        echo "$src src dir not found"
        return 0
    fi
    if [ ! -d "$dest" ] ; then
        echo "$dest dest dir not found"
        return 0
    fi
    /bin/cp "$src"/*.* "$dest/."
    local ee=$?
    if [ $ee != 0 ] ; then
        echo "ERROR $src to $dest copy failed"
        return 0
    fi
    echo "Copy of $src to $dest success"
}

function get_latest_iteration {
# given path to trainedmodel directory
# find latest iteration by parsing out
# the iteration value from .solverstate
# file in directory
    local trainedmodeldir=$1
    local latest_iteration=`ls "$trainedmodeldir" | egrep "\.solverstate$" | sed "s/^.*iter_//" | sed "s/\.solverstate//" | sort -g | tail -n 1`
    echo "$latest_iteration"
}

function get_package_name {
# get_package_name ($package_num, $package_z)
# given package number and z sets
# $package_name to standard naming convention
# for packages. Namely Pkg###_Z##
    local rawpkg=$1
    local rawz=$2
    curpkg=`echo "$rawpkg" | sed "s/^0*//"`
    curz=`echo "$rawz" | sed "s/^0*//"`
    local pad_pkg=`printf "%03d" $curpkg`
    local pad_z=`printf "%02d" $curz`
    echo "Pkg${pad_pkg}_Z${pad_z}"
}

function get_number_done_files_in_dir {
    local thedir=$1
    number_done_files=`find "$thedir" -name "DONE" -type f | wc -l`
    echo "$number_done_files"
}

function wait_for_predict_to_finish_on_package {
    local job_dir=$1
    local pkg_dir=$2
    local wait_time=$3

    if [ -f "$job_dir/KILL.REQUEST" ] ; then
        echo "killed"
        return 0
    fi

    while [ ! -f "$pkg_dir/PREDICTDONE" ] ; do
        if [ -f "$job_dir/KILL.REQUEST" ] ; then
            echo "killed"
            return 0
        fi
        sleep $wait_time
    done
    echo ""
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
    local job_dir=$1
    local package_dir=$2
    local wait_time=$3
    if [ -f "$job_dir/KILL.REQUEST" ] ; then
        echo "killed"
        return 0
    fi

    while [ ! -f "$package_dir/DONE" ] ; do
         if [ -f "$job_dir/KILL.REQUEST" ] ; then
             echo "killed"
             return 0
         fi
        sleep $wait_time
    done
    echo ""
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
  
    local package_proc_info=$1
    num_pkgs=`head -n 3 $package_proc_info | tail -n 1`
    num_zstacks=`tail -n 1 $package_proc_info`
    let tot_pkgs=$num_pkgs*$num_zstacks
}

function get_models_as_space_separated_list {
    local space_sep_models=`echo "$1" | sed "s/,/ /g"`
    echo "$space_sep_models"
}

function get_number_of_models {
# Counts number of models passed in string by
# replacing , character with newline and counting
# number of lines
    if [ -z "$1" ] ; then
        echo "0"
        return 0
    fi
    local model_count=`echo "$1" | sed "s/,/\n/g" | wc -l`
    echo "$model_count"
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

    local predict_config=$1

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
