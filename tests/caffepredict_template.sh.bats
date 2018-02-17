#!/usr/bin/env bats


setup() {
    export CAFFE_PREDICT_TEMPLATE_SH="${BATS_TEST_DIRNAME}/../scripts/caffepredict_template.sh"
    export TEST_TMP_DIR="${BATS_TMPDIR}/"`uuidgen`
    /bin/mkdir -p "$TEST_TMP_DIR"
    export CAFFE_PREDICT_SH="$TEST_TMP_DIR/caffepredict.sh"
   /bin/cp "$CAFFE_PREDICT_TEMPLATE_SH" "$CAFFE_PREDICT_SH"
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
    [ "${lines[0]}" = "usage: caffepredict.sh [-h] [--gpu GPU]" ]
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
    touch "$TEST_TMP_DIR/v1"
    run $CAFFE_PREDICT_SH "$TEST_TMP_DIR/foo.caffemodel" blah "$TEST_TMP_DIR"

    [ "$status" -eq 4 ]
    [ "${lines[1]}" = "ERROR unable to create $TEST_TMP_DIR/v1" ]

}

@test "caffepredict.sh unable to find a .h5 file in input" {
   touch "$TEST_TMP_DIR/foo.caffemodel"
   run $CAFFE_PREDICT_SH "$TEST_TMP_DIR/foo.caffemodel" "$TEST_TMP_DIR" "$TEST_TMP_DIR"
   echo "$status $output" 1>&2
   [ "$status" -eq 5 ]
}

@test "caffepredict.sh run success on 16 .h5 files" {
   mkdir -p "$TEST_TMP_DIR/augimages"
   # TODO add StartPostProcessing.m and Merge_LargeData.m to path
   # TODO add predict_seg_new.bin to path as well!!!
   for Y in `seq 1 16` ; do
     touch "$TEST_TMP_DIR/augimages/blah_v${Y}.h5"
   done
   run $CAFFE_PREDICT_SH "$TEST_TMP_DIR/foo.caffemodel" "$TEST_TMP_DIR/augimages" "$TEST_TMP_DIR"
   echo "$status $output" 1>&2
   [ "$status" -eq 5 ]


}




# TODO add tests to verify fining last completed iteration works



