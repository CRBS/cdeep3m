#!/bin/bash


script_dir=`dirname "$0"`
script_name=`basename $0`
version="???"

source "${script_dir}/commonfunctions.sh"

if [ -f "$script_dir/VERSION" ] ; then
   version=`cat $script_dir/VERSION`
fi

gpu="all"

function usage()
{
    echo "usage: $script_name [-h]
                      model augimagesdir outputdir

              Version: $version

              Runs caffe on CDeep3M model specified by model argument 
              to perform training. The trained model will be stored in
              <model>/trainedmodel directory
              Output from caffe will be redirected to <model>/log/out.log
              When script completes <outputdir>/DONE file will be created
              with last line containing 0 upon success. 
    
positional arguments:
  model                Path to .caffemodel file or directory with caffe
                       model. If later then the latest is used.
  augimagesdir         Directory path with prefix containing the 16 .h5
                       files that end with v#.h5. This data would have been
                       created PreprocessImageData.m
  outdir               Destination directory to write output. Will be
                       created if it does not exist.
optional arguments:
  -h, --help           show this help message and exit
  --gpu                Which GPU to use, can be a number ie 0 or 1 or
                       all to use all GPUs (default $gpu)

    " 1>&2;
   exit 1;
}

TEMP=`getopt -o h --long "help,gpu:" -n '$0' -- "$@"`
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -h ) usage ;;
        --help ) usage ;;
        --gpu ) gpu=$2 ; shift 2 ;;
        --) shift ; break ;;
    esac
done


if [ $# -ne 3 ] ; then
  usage
fi

model=$1
in_dir=$2
out_dir=$3

done_file="$out_dir/PREDICTDONE"


if [ -d "$model" ] ; then
  model_dir="$model"
  latest_iteration=`ls "$model" | egrep "\.caffemodel$" | sed "s/^.*iter_//" | sed "s/\.caffemodel//" | sort -g | tail -n 1`
  if [ "$latest_iteration" == "" ] ; then
     fatal_error "$out_dir" "ERROR no #.caffemodel files found" 2
  fi
  model=`find "$model" -name "*${latest_iteration}.caffemodel" -type f`
else
  model_dir=`dirname "$model"`
fi

deploy_dir="$model_dir/.."


log_dir="$out_dir/log"
out_log="$out_dir/out.log"

mkdir -p "$log_dir"

if [ $? != 0 ] ; then
  fatal_error "$out_dir" "ERROR unable to create $log_dir" 3
fi

gpucount=`nvidia-smi -L | wc -l`
if [ "$gpucount" -eq 0 ] ; then
  fatal_error "$out_dir" "ERROR unable to get count of GPU(s). Is nvidia-smi working?" 4
fi

let maxgpuindex=$gpucount-1

if [ $maxgpuindex -gt 0 ] ; then
  echo -n "Detected $gpucount GPU(s)."
  if [ "$gpu" == "all" ] ; then
    echo " Will run in parallel."
  else
    echo " Using only GPU $gpu"
  fi
else
  echo "Single GPU detected."
fi

if [ "$gpu" == "all" ] ; then
  let cntr=0
else
  let cntr=$gpu
  let gpucount=1
fi

theargs=""
parallel_job_file="$out_dir/parallel.jobs"
for input_file in `find "${in_dir}" -name "*.h5" -type f | sort -V` ;
  do
  
  idx=`echo $input_file | sed "s/^.*_v//" | sed "s/\.h5$//"`
  predict_dir=$out_dir/v$idx;

  if [ ! -d "$predict_dir" ]; then
    # Control will enter here if $DIRECTORY doesn't exist.
    echo "Creating directory $predict_dir" >> "$out_log"
    mkdir -p "$predict_dir"
    if [ $? != 0 ] ; then
      fatal_error "$out_dir" "ERROR unable to create $predict_dir" 5
    fi
  fi
  echo -e "$log_dir\n$deploy_dir\n$model\n$input_file\n$predict_dir\n$cntr" >> $parallel_job_file
  if [ "$gpu" == "all" ] ; then
    let cntr++
    if [ $cntr -gt $maxgpuindex ] ; then
      let cntr=0
    fi
  fi
done

# the --delay 2 is to add a 2 second delay between starting jobs
# without this jobs would fail on GPU with out of memory error
#cat $parallel_job_file | parallel --no-notice --delay 2 -N 6 -j $gpucount 'GLOG_logtostderr="{1}" /usr/bin/time -p $CAFFE_PATH/.build_release/tools/predict_seg_new.bin --model={2}/deploy.prototxt --weights={3} --data={4} --predict={5}/test.h5 --shift_axis=2 --shift_stride=1 --gpu={6}' >> "$out_log" 2>&1
line_cnt=0                      # COUNTS THE LINES IN THE PARALLEL JOBS FILE
job_count=0                     # COUNTS THE NUMBER OF COMMANDS IN THE cmdlets FILE
job_array=""                    # STORES THE PARALLEL JOB INFORMATION
cmdlets="$out_dir/cmdlets"      # STORES THE COMMANDS TO RUN VIA PARALLEL
cmdsran="$out_dir/cmdruns"      # STORES THE COMMANDS THAT WERE ALREADY RUN

# ---------------------------------------------------------------------------------------
# TAKES THE INFORMATION BUILT IN THE parallel.jobs FILE AND PARSES IT
# INTO A COMMAND FILE THAT CAN BE PASSED TO parallel FOR PROCESSING
# The first 4 switch cases grab the following from the parallel.jobs file in order:
# job_array[0] - GLOG folder
# job_array[1] - Training model
# job_array[2] - weights
# job_array[3] - input data
# job_array[4] - output folder
# The 5th switch injects the current line as the --gpu paramater
# Those 5 characteristics together makeup the command to be ran with predict_seg_new.bin
# via parallel
#
# Once the line_cnt is equal to 5 a command is available and the job_count increments.
# When the job_count reaches the gpucount (the max number of parallel jobs that can run)
# the jobs are then pushed into parallel. When parallel finishes blocking the commands
# are logged to the cmdsran file, the job_count is reset and the cmdlets file removed
# for the next iteration of commands.

for line in `cat $parallel_job_file`; do     # EACH LINE IN THE parallel.jobs FILE
  case $line_cnt in
    # GLOG, model, weights, input and output
    [0-4]*)
    job_array[$line_cnt]=$line
    ;;
    # The gpu number makes the final command string
    5)
    echo "GLOG_logtostderr=\"${job_array[0]}\" /usr/bin/time -p $CAFFE_PATH/.build_release/tools/predict_seg_new.bin --model=${job_array[1]}/deploy.prototxt --weights=${job_array[2]} --data=${job_array[3]} --predict=${job_array[4]}/test.h5 --shift_axis=2 --shift_stride=1 --gpu=$line >> \"$out_log\" 2>&1" >> $cmdlets
    ;;
    *)
    echo "I should never be here in default"
    ;;
  esac
  # IF THE line_cnt HAS REACHED 5 A COMMAND HAS BEEN BUILT
  # IF THE job_count HAS REACHED THE gpucount RUN THE NUMBER OF JOBS
  # IN PARALLEL THAT CAN BE RUN
  if [ $line_cnt == 5 ]; then                       # IF THE LINE COUNT IS 5 THEN A COMMAND IS READY
    line_cnt=0                                      # RESET THE CURRENT LINE COUNT
    ((job_count++))                                 # ADD A JOB
    if [ $job_count == $gpucount ]; then            # IF THE job_count HAS REACHED IT'S MAX (gpucount)
      parallel --no-notice -j $gpucount < $cmdlets  # RUN THE CURRENT JOB QUEUE
      ecode=$?
      if [ $ecode != 0 ] ; then
        fatal_error "$out_dir" "ERROR non-zero exit code ($ecode) from running predict_seg_new.bin" 6
      fi
      job_count=0                                   # RESET THE JOB COUNT
      cat $cmdlets >> $cmdsran                      # TRACK THE COMMANDS THAT WERE RUN
      rm -f $cmdlets                                # CLEAN OLD COMMANDS
    fi
  else
    ((line_cnt++))                                  # INCREMENT THE CURRENT LINE COUNT
  fi
done # END - for line in `cat $parallel_job_file`; do

# CHECK TO SEE IF THERE ARE ANY JOBS STILL PENDING AND RUN THEM
if [ $job_count -gt 0 ]; then
  parallel --no-notice -j $gpucount < $cmdlets
  ecode=$?
  if [ $ecode != 0 ] ; then
    fatal_error "$out_dir" "ERROR non-zero exit code ($ecode) from running predict_seg_new.bin" 6
  fi
  cat $cmdlets >> $cmdsran
  rm -f $cmdlets
fi

echo ""

echo -e "Success\n0" >> "$done_file"
exit 0
