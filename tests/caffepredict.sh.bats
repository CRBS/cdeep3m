#!/usr/bin/env bats


# Example output of nvidia-smi -L from single node
# TODO

# Example output of nvidia-smi -L from 4 node
#GPU 0: Tesla V100-SXM2-16GB (UUID: GPU-ccf578c6-5369-9ff4-e1c2-d4c0c9d4d338)
#GPU 1: Tesla V100-SXM2-16GB (UUID: GPU-7bbcd9e7-b1e2-5e53-fb9a-6d27e364dd40)
#GPU 2: Tesla V100-SXM2-16GB (UUID: GPU-0b610645-cc68-d906-0b75-f88e8d241313)
#GPU 3: Tesla V100-SXM2-16GB (UUID: GPU-362ffce9-16cd-679a-9e46-0da23373846d)


setup() {
    export CAFFE_PREDICT_SH="${BATS_TEST_DIRNAME}/../caffepredict.sh"
    export TEST_TMP_DIR="${BATS_TMPDIR}/"`uuidgen`
    /bin/mkdir -p "$TEST_TMP_DIR"
}

teardown() {
    if [ -d "$TEST_TMP_DIR" ] ; then
        /bin/rm -rf "$TEST_TMP_DIR"
    fi
}

@test "caffepredict.sh no args empty dir" {
    run $CAFFE_PREDICT_SH
    echo "$status $output" 1>&2
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "usage: caffepredict.sh [-h]" ]
}

@test "caffepredict.sh model passed in is empty dir" {
    run $CAFFE_PREDICT_SH "$TEST_TMP_DIR" blah "$TEST_TMP_DIR"

    [ "$status" -eq 2 ]
    run cat "$TEST_TMP_DIR/ERROR"
    [ "${lines[0]}" = "ERROR no #.caffemodel files found" ] 
    [ "${lines[1]}" = "2" ]
}

@test "caffepredict.sh unable to create log directory" {
    touch "$TEST_TMP_DIR/foo.caffemodel"
    touch "$TEST_TMP_DIR/log"
    run $CAFFE_PREDICT_SH "$TEST_TMP_DIR/foo.caffemodel" blah "$TEST_TMP_DIR"
    
    [ "$status" -eq 3 ] 
    run cat "$TEST_TMP_DIR/ERROR" 
    [ "${lines[0]}" = "ERROR unable to create $TEST_TMP_DIR/log" ]
    [ "${lines[1]}" = "3" ] 
}

@test "caffepredict.sh unable to get count of GPUs" {
    touch "$TEST_TMP_DIR/foo.caffemodel"
    ln -s /bin/false "$TEST_TMP_DIR/nvidia-smi"
    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH
    run $CAFFE_PREDICT_SH "$TEST_TMP_DIR/foo.caffemodel" "$TEST_TMP_DIR" "$TEST_TMP_DIR"
    export PATH=$A_TEMP_PATH
    [ "$status" -eq 4 ]
    echo "$status $output" 2>&1
    run cat "$TEST_TMP_DIR/ERROR"
    [ "${lines[0]}" = "ERROR unable to get count of GPU(s). Is nvidia-smi working?" ]
    [ "${lines[1]}" = "4" ]
}

@test "caffepredict.sh unable to create a v# directory" {
    touch "$TEST_TMP_DIR/foo.caffemodel"
    touch "$TEST_TMP_DIR/test_data_full_stacks_v1.h5"
    touch "$TEST_TMP_DIR/v1"
    echo "#!/bin/bash" > "$TEST_TMP_DIR/nvidia-smi"
    echo "echo 'GPU 0'" >> "$TEST_TMP_DIR/nvidia-smi"
    chmod a+x "$TEST_TMP_DIR/nvidia-smi"
    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH
    run $CAFFE_PREDICT_SH "$TEST_TMP_DIR/foo.caffemodel" "$TEST_TMP_DIR" "$TEST_TMP_DIR"
    export PATH=$A_TEMP_PATH
    echo "$status $output" 2>&1
    [ "$status" -eq 5 ]
    [ "${lines[0]}" = "Single GPU detected." ]
    run cat "$TEST_TMP_DIR/ERROR"
    [ "${lines[0]}" = "ERROR unable to create $TEST_TMP_DIR/v1" ]
    [ "${lines[1]}" = "5" ] 

}

@test "caffepredict.sh run success on 16 .h5 files all gpus" {
   mkdir -p "$TEST_TMP_DIR/augimages"
   ln -s /bin/echo "$TEST_TMP_DIR/StartPostprocessing.m"
   ln -s /bin/echo "$TEST_TMP_DIR/Merge_LargeData.m"
   ln -s /bin/echo "$TEST_TMP_DIR/predict_seg_new.bin"
   ln -s /bin/echo "$TEST_TMP_DIR/parallel"
   echo "#!/bin/bash" > "$TEST_TMP_DIR/nvidia-smi"
   echo "echo -e 'GPU 0\nGPU 1'" >> "$TEST_TMP_DIR/nvidia-smi"
   chmod a+x "$TEST_TMP_DIR/nvidia-smi"

   for Y in `seq 1 16` ; do
     touch "$TEST_TMP_DIR/augimages/blah_v${Y}.h5"
   done

   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH

   run $CAFFE_PREDICT_SH "$TEST_TMP_DIR/foo.caffemodel" "$TEST_TMP_DIR/augimages" "$TEST_TMP_DIR"
   echo "$status $output" 1>&2
   [ "$status" -eq 0 ]
   [ "${lines[0]}" = "Detected 2 GPU(s). Will run in parallel." ]
   export PATH=$A_TEMP_PATH
   run cat "$TEST_TMP_DIR/out.log"
   echo "From cat out.log: $status $output" 1>&2
   [ "${lines[0]}" = "Creating directory $TEST_TMP_DIR/v1" ]
   [ "${lines[1]}" = "Creating directory $TEST_TMP_DIR/v2" ]
   [ "${lines[15]}" = "Creating directory $TEST_TMP_DIR/v16" ]

   #[ "${lines[16]}" = "--no-notice --delay 2 -N 6 -j 2 GLOG_logtostderr=\"{1}\" /usr/bin/time -p predict_seg_new.bin --model={2}/deploy.prototxt --weights={3} --data={4} --predict={5}/test.h5 --shift_axis=2 --shift_stride=1 --gpu={6}" ]

   run cat "$TEST_TMP_DIR/parallel.jobs"
   cat "$TEST_TMP_DIR/parallel.jobs" 1>&2
   [ "${lines[0]}" == "$TEST_TMP_DIR/log" ]
   [ "${lines[1]}" == "$TEST_TMP_DIR/.." ]
   [ "${lines[2]}" == "$TEST_TMP_DIR/foo.caffemodel" ]
   [ "${lines[3]}" == "$TEST_TMP_DIR/augimages/blah_v1.h5" ]
   [ "${lines[4]}" == "$TEST_TMP_DIR/v1" ]
   [ "${lines[5]}" == "0" ]
   
   [ "${lines[6]}" == "$TEST_TMP_DIR/log" ]
   [ "${lines[7]}" == "$TEST_TMP_DIR/.." ]
   [ "${lines[8]}" == "$TEST_TMP_DIR/foo.caffemodel" ]
   [ "${lines[9]}" == "$TEST_TMP_DIR/augimages/blah_v2.h5" ]
   [ "${lines[10]}" == "$TEST_TMP_DIR/v2" ]
   [ "${lines[11]}" == "1" ]

   [ "${lines[17]}" == "0" ]
   
   [ "${lines[23]}" == "1" ]

   [ -f "$TEST_TMP_DIR/PREDICTDONE" ] 

   [ ! -f "$TEST_TMP_DIR/ERROR" ] 
}

@test "caffepredict.sh run success on 16 .h5 files --gpu 1" {
   mkdir -p "$TEST_TMP_DIR/augimages"
   ln -s /bin/echo "$TEST_TMP_DIR/StartPostprocessing.m"
   ln -s /bin/echo "$TEST_TMP_DIR/Merge_LargeData.m"
   ln -s /bin/echo "$TEST_TMP_DIR/predict_seg_new.bin"
   ln -s /bin/echo "$TEST_TMP_DIR/parallel"
   echo "#!/bin/bash" > "$TEST_TMP_DIR/nvidia-smi"
   echo "echo -e 'GPU 0\nGPU 1'" >> "$TEST_TMP_DIR/nvidia-smi"
   chmod a+x "$TEST_TMP_DIR/nvidia-smi"

   for Y in `seq 1 16` ; do
     touch "$TEST_TMP_DIR/augimages/blah_v${Y}.h5"
   done

   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH

   run $CAFFE_PREDICT_SH --gpu 1 "$TEST_TMP_DIR/foo.caffemodel" "$TEST_TMP_DIR/augimages" "$TEST_TMP_DIR"
   echo "$status $output" 1>&2
   [ "$status" -eq 0 ]
   [ "${lines[0]}" = "Detected 2 GPU(s). Using only GPU 1" ]
   export PATH=$A_TEMP_PATH
   run cat "$TEST_TMP_DIR/out.log"
   echo "From cat out.log: $status $output" 1>&2
   [ "${lines[0]}" = "Creating directory $TEST_TMP_DIR/v1" ]
   [ "${lines[1]}" = "Creating directory $TEST_TMP_DIR/v2" ]
   [ "${lines[15]}" = "Creating directory $TEST_TMP_DIR/v16" ]

   #[ "${lines[16]}" = "--no-notice --delay 2 -N 6 -j 1 GLOG_logtostderr=\"{1}\" /usr/bin/time -p predict_seg_new.bin --model={2}/deploy.prototxt --weights={3} --data={4} --predict={5}/test.h5 --shift_axis=2 --shift_stride=1 --gpu={6}" ]

   run cat "$TEST_TMP_DIR/parallel.jobs"
   cat "$TEST_TMP_DIR/parallel.jobs" 1>&2
   [ "${lines[0]}" == "$TEST_TMP_DIR/log" ]
   [ "${lines[1]}" == "$TEST_TMP_DIR/.." ]
   [ "${lines[2]}" == "$TEST_TMP_DIR/foo.caffemodel" ]
   [ "${lines[3]}" == "$TEST_TMP_DIR/augimages/blah_v1.h5" ]
   [ "${lines[4]}" == "$TEST_TMP_DIR/v1" ]
   [ "${lines[5]}" == "1" ]

   [ "${lines[6]}" == "$TEST_TMP_DIR/log" ]
   [ "${lines[7]}" == "$TEST_TMP_DIR/.." ]
   [ "${lines[8]}" == "$TEST_TMP_DIR/foo.caffemodel" ]
   [ "${lines[9]}" == "$TEST_TMP_DIR/augimages/blah_v2.h5" ]
   [ "${lines[10]}" == "$TEST_TMP_DIR/v2" ]
   [ "${lines[11]}" == "1" ]

   [ "${lines[17]}" == "1" ]

   [ "${lines[23]}" == "1" ]

   [ -f "$TEST_TMP_DIR/PREDICTDONE" ]

   [ ! -f "$TEST_TMP_DIR/ERROR" ]
}


@test "caffepredict.sh predict_seg_new.bin fails" {
   mkdir -p "$TEST_TMP_DIR/augimages"
   ln -s /bin/true "$TEST_TMP_DIR/predict_seg_new.bin"
   ln -s /bin/false "$TEST_TMP_DIR/parallel"
   echo "#!/bin/bash" > "$TEST_TMP_DIR/nvidia-smi"
   echo "echo -e 'GPU 0\nGPU 1\nGPU 2\nGPU 3\nGPU 4\nGPU 5'" >> "$TEST_TMP_DIR/nvidia-smi"
   chmod a+x "$TEST_TMP_DIR/nvidia-smi"
   for Y in `seq 1 16` ; do
     touch "$TEST_TMP_DIR/augimages/blah_v${Y}.h5"
   done
   parent_dir=`dirname "$TEST_TMP_DIR"`

   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH

   run $CAFFE_PREDICT_SH "$TEST_TMP_DIR/foo.caffemodel" "$TEST_TMP_DIR/augimages" "$TEST_TMP_DIR"
   echo "$status $output" 1>&2
   [ "$status" -eq 6 ]
   [ "${lines[0]}" = "Detected 6 GPU(s). Will run in parallel." ]
   run cat "$TEST_TMP_DIR/ERROR" 
   [ "${lines[0]}" = "ERROR non-zero exit code (1) from running predict_seg_new.bin" ]
   [ "${lines[1]}" = "6" ]
   export PATH=$A_TEMP_PATH
}


# TODO add tests to verify fining last completed iteration works


@test "caffepredict.sh test find latest caffemodel" {
   mkdir -p "$TEST_TMP_DIR/augimages"
   ln -s /bin/echo "$TEST_TMP_DIR/predict_seg_new.bin"
   ln -s /bin/echo "$TEST_TMP_DIR/StartPostprocessing.m"
   ln -s /bin/echo "$TEST_TMP_DIR/parallel"
   echo "#!/bin/bash" > "$TEST_TMP_DIR/nvidia-smi"
   echo "echo 'GPU 0'" >> "$TEST_TMP_DIR/nvidia-smi"
   chmod a+x "$TEST_TMP_DIR/nvidia-smi"
   model_dir="$TEST_TMP_DIR/model"
   mkdir -p "$model_dir"
   touch "$model_dir/1fm_classifier_iter_10.caffemodel"
   touch "$model_dir/1fm_classifier_iter_10.solverstate"
   touch "$model_dir/1fm_classifier_iter_100.caffemodel"
   touch "$model_dir/1fm_classifier_iter_100.solverstate"
   for Y in `seq 1 16` ; do
     touch "$TEST_TMP_DIR/augimages/blah_v${Y}.h5"
   done
   parent_dir=`dirname "$TEST_TMP_DIR"`

   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH

   run $CAFFE_PREDICT_SH "$model_dir" "$TEST_TMP_DIR/augimages" "$TEST_TMP_DIR"
   echo "$status $output" 2>&1
   [ "$status" -eq 0 ]
   run cat $TEST_TMP_DIR/parallel.jobs 2>&1
   echo "parallel.jobs: $status $output" 1>&2
   [ "${lines[0]}" = "$TEST_TMP_DIR/log" ]
   [ "${lines[1]}" = "$TEST_TMP_DIR/model/.." ]
   [ "${lines[2]}" = "$TEST_TMP_DIR/model/1fm_classifier_iter_100.caffemodel" ]
   [ "${lines[3]}" = "$TEST_TMP_DIR/augimages/blah_v1.h5" ]
   [ "${lines[4]}" = "$TEST_TMP_DIR/v1" ]
   [ "${lines[5]}" = "0" ]
   export PATH=$A_TEMP_PATH
}

