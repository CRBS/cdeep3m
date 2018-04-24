#!/bin/bash


script_dir=`dirname "$0"`
script_name=`basename $0`
version="???"

if [ -f "$script_dir/VERSION" ] ; then
   version=`cat $script_dir/VERSION`
fi

function usage()
{
    echo "usage: $script_name [-h]
                      model augimagesdir outputdir

              Version: $version

              Runs caffe on CDeep3M model specified by model argument 
              to perform training. The trained model will be stored in
              <model>/trainedmodel directory
              Output from caffe will be redirected to <model>/log/out.log
    
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

    " 1>&2;
   exit 1;
}

TEMP=`getopt -o h --long "help" -n '$0' -- "$@"`
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -h ) usage ;;
        --help ) usage ;;
        --) shift ; break ;;
    esac
done


if [ $# -ne 3 ] ; then
  usage
fi

model=$1
in_dir=$2
out_dir=$3


if [ -d "$model" ] ; then
  model_dir="$model"
  latest_iteration=`ls "$model" | egrep "\.caffemodel$" | sed "s/^.*iter_//" | sed "s/\.caffemodel//" | sort -g | tail -n 1`
  if [ "$latest_iteration" == "" ] ; then
     echo "ERROR no #.caffemodel files found"
     exit 2
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
  echo "ERROR unable to create $log_dir"
  exit 3
fi

gpucount=`nvidia-smi -L | wc -l`
if [ "$gpucount" -eq 0 ] ; then
  echo "ERROR unable to get count of GPU(s). Is nvidia-smi working?"
  exit 4
fi

let maxgpuindex=$gpucount-1

if [ $maxgpuindex -gt 0 ] ; then
  echo "Detected $gpucount GPU(s). Will run in parallel"
else
  echo "Single GPU detected"
fi

theargs=""
let cntr=0
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
      echo "ERROR unable to create $predict_dir"
      exit 4
    fi
  fi
  echo -e "$log_dir\n$deploy_dir\n$model\n$input_file\n$predict_dir\n$cntr" >> $parallel_job_file
  let cntr++
  if [ $cntr -gt $maxgpuindex ] ; then
    let cntr=0
  fi
done

# the --delay 2 is to add a 2 second delay between starting jobs
# without this jobs would fail on GPU with out of memory error
#

cat $parallel_job_file | parallel --no-notice --delay 2 -N 6 -j $gpucount 'GLOG_logtostderr="{1}" /usr/bin/time -p predict_seg_new.bin --model={2}/deploy.prototxt --weights={3} --data={4} --predict={5}/test.h5 --shift_axis=2 --shift_stride=1 --gpu={6}' >> "$out_log" 2>&1
  ecode=$?
  if [ $ecode != 0 ] ; then
    echo "ERROR non-zero exit code ($ecode) from running predict_seg_new.bin"
    exit 6
  fi

echo ""
echo "Running StartPostprocessing.m $out_dir"
StartPostprocessing.m "$out_dir" >> "$out_log" 2>&1
ecode=$?

if [ $ecode != 0 ] ; then
  echo "ERROR non-zero exit code ($ecode) from running StartPostprocessing.m"
  exit 7
fi

exit 0
