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
    [ "${lines[0]}" = "ERROR no #.caffemodel files found" ]
}

@test "caffepredict.sh unable to create log directory" {
    touch "$TEST_TMP_DIR/foo.caffemodel"
    touch "$TEST_TMP_DIR/log"
    run $CAFFE_PREDICT_SH "$TEST_TMP_DIR/foo.caffemodel" blah "$TEST_TMP_DIR"
    
    [ "$status" -eq 3 ] 
    [ "${lines[1]}" = "ERROR unable to create $TEST_TMP_DIR/log" ]

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
    [ "$status" -eq 4 ]
    echo "$status $output" 2>&1
    [ "${lines[2]}" = "ERROR unable to create $TEST_TMP_DIR/v1" ]

}

@test "caffepredict.sh run success on 16 .h5 files" {
   mkdir -p "$TEST_TMP_DIR/augimages"
   ln -s /bin/echo "$TEST_TMP_DIR/StartPostprocessing.m"
   ln -s /bin/echo "$TEST_TMP_DIR/Merge_LargeData.m"
   ln -s /bin/echo "$TEST_TMP_DIR/predict_seg_new.bin"

   for Y in `seq 1 16` ; do
     touch "$TEST_TMP_DIR/augimages/blah_v${Y}.h5"
   done
   parent_dir=`dirname "$TEST_TMP_DIR"`

   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH

   run $CAFFE_PREDICT_SH "$TEST_TMP_DIR/foo.caffemodel" "$TEST_TMP_DIR/augimages" "$TEST_TMP_DIR"
   echo "$status $output" 1>&2
   [ "$status" -eq 0 ]
   [ "${lines[0]}" = "................" ]
   [ "${lines[1]}" = "Running StartPostprocessing.m $TEST_TMP_DIR" ]
   export PATH=$A_TEMP_PATH
   run cat "$TEST_TMP_DIR/out.log"
   echo "From cat out.log: $status $output" 1>&2
   [ "${lines[0]}" = "Creating directory $TEST_TMP_DIR/v1" ]
   [ "${lines[1]}" = "Input: $TEST_TMP_DIR/augimages/blah_v1.h5" ]
   [ "${lines[2]}" = "Output: $TEST_TMP_DIR/v1" ]
   [ "${lines[3]}" = "--model=$TEST_TMP_DIR/../deploy.prototxt --weights=$TEST_TMP_DIR/foo.caffemodel --data=$TEST_TMP_DIR/augimages/blah_v1.h5 --predict=$TEST_TMP_DIR/v1/test.h5 --shift_axis=2 --shift_stride=1 --gpu=0" ] 

   run tail -n 2 "$TEST_TMP_DIR/out.log"
   echo "From tail -n 2 out.log: $status $output" 1>&2
   [ "${lines[1]}" = "$TEST_TMP_DIR" ]
}

@test "caffepredict.sh StartPostprocessing.m fails" {
   mkdir -p "$TEST_TMP_DIR/augimages"
   ln -s /bin/false "$TEST_TMP_DIR/StartPostprocessing.m"
   ln -s /bin/echo "$TEST_TMP_DIR/predict_seg_new.bin"

   for Y in `seq 1 16` ; do
     touch "$TEST_TMP_DIR/augimages/blah_v${Y}.h5"
   done
   parent_dir=`dirname "$TEST_TMP_DIR"`

   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH

   run $CAFFE_PREDICT_SH "$TEST_TMP_DIR/foo.caffemodel" "$TEST_TMP_DIR/augimages" "$TEST_TMP_DIR"
   echo "$status $output" 1>&2
   [ "$status" -eq 7 ]
   [ "${lines[0]}" = "................" ]
   [ "${lines[1]}" = "Running StartPostprocessing.m $TEST_TMP_DIR" ]
   [ "${lines[2]}" = "ERROR non-zero exit code (1) from running StartPostprocessing.m" ]
   export PATH=$A_TEMP_PATH
}

@test "caffepredict.sh predict_seg_new.bin fails" {
   mkdir -p "$TEST_TMP_DIR/augimages"
   ln -s /bin/false "$TEST_TMP_DIR/predict_seg_new.bin"

   for Y in `seq 1 16` ; do
     touch "$TEST_TMP_DIR/augimages/blah_v${Y}.h5"
   done
   parent_dir=`dirname "$TEST_TMP_DIR"`

   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH

   run $CAFFE_PREDICT_SH "$TEST_TMP_DIR/foo.caffemodel" "$TEST_TMP_DIR/augimages" "$TEST_TMP_DIR"
   echo "$status $output" 1>&2
   [ "$status" -eq 6 ]
   [ "${lines[0]}" = ".ERROR non-zero exit code (1) from running predict_seg_new.bin" ]
   export PATH=$A_TEMP_PATH
}

@test "caffepredict.sh custom gpu" {
   mkdir -p "$TEST_TMP_DIR/augimages"
   ln -s /bin/echo "$TEST_TMP_DIR/predict_seg_new.bin"

   for Y in `seq 1 16` ; do
     touch "$TEST_TMP_DIR/augimages/blah_v${Y}.h5"
   done
   parent_dir=`dirname "$TEST_TMP_DIR"`

   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH

   run $CAFFE_PREDICT_SH --gpu 4 "$TEST_TMP_DIR/foo.caffemodel" "$TEST_TMP_DIR/augimages" "$TEST_TMP_DIR"
   run cat "$TEST_TMP_DIR/out.log"
   echo "out.log: $status $output" 1>&2 
   [ "${lines[3]}" = "--model=$TEST_TMP_DIR/../deploy.prototxt --weights=$TEST_TMP_DIR/foo.caffemodel --data=$TEST_TMP_DIR/augimages/blah_v1.h5 --predict=$TEST_TMP_DIR/v1/test.h5 --shift_axis=2 --shift_stride=1 --gpu=4" ]
   export PATH=$A_TEMP_PATH
}



# TODO add tests to verify fining last completed iteration works


@test "caffepredict.sh test find latest caffemodel" {
   mkdir -p "$TEST_TMP_DIR/augimages"
   ln -s /bin/echo "$TEST_TMP_DIR/predict_seg_new.bin"
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
   run cat "$TEST_TMP_DIR/out.log"
   echo "out.log: $status $output" 1>&2
   [ "${lines[3]}" = "--model=$model_dir/../deploy.prototxt --weights=$model_dir/1fm_classifier_iter_100.caffemodel --data=$TEST_TMP_DIR/augimages/blah_v1.h5 --predict=$TEST_TMP_DIR/v1/test.h5 --shift_axis=2 --shift_stride=1 --gpu=0" ]
   export PATH=$A_TEMP_PATH
}

