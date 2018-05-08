#!/usr/bin/env bats


setup() {
    export POSTPROCESS_WORKER_SH="${BATS_TEST_DIRNAME}/../postprocessworker.sh"
    export TEST_TMP_DIR="${BATS_TMPDIR}/"`uuidgen`
    /bin/mkdir -p "$TEST_TMP_DIR"
}

teardown() {
    if [ -d "$TEST_TMP_DIR" ] ; then
        /bin/rm -rf "$TEST_TMP_DIR"
    fi
}

@test "postprocessworker.sh no args" {
    run $POSTPROCESS_WORKER_SH
    echo "$status $output" 1>&2
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "usage: postprocessworker.sh [-h]" ]
}

@test "postprocessworker.sh empty dir" {
    run $POSTPROCESS_WORKER_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 2 ]
    [ "${lines[0]}" == "ERROR no $TEST_TMP_DIR/predict.config file found" ]
    run cat "$TEST_TMP_DIR/ERROR"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" == "ERROR parsing $TEST_TMP_DIR/predict.config" ]
}

@test "postprocessworker.sh no package_processing_info.txt" {
    pconfig="$TEST_TMP_DIR/predict.config"
    echo "trainedmodeldir=tmodel" >> "$pconfig"
    echo "imagedir=imagey" >> "$pconfig"
    echo "models=1fm" >> "$pconfig"
    echo "augspeed=1" >> "$pconfig"
    run $POSTPROCESS_WORKER_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 7 ]
    [ "${lines[5]}" == "ERROR $TEST_TMP_DIR/augimages/package_processing_info.txt not found" ]
}

@test "postprocessworker.sh DONE file in each model, no work to do" {
    pconfig="$TEST_TMP_DIR/predict.config"
    echo "trainedmodeldir=tmodel" >> "$pconfig"
    echo "imagedir=imagey" >> "$pconfig"
    echo "models=1fm" >> "$pconfig"
    echo "augspeed=1" >> "$pconfig"
    mkdir -p "$TEST_TMP_DIR/augimages"
    p_info="$TEST_TMP_DIR/augimages/package_processing_info.txt"
    echo "" > "$p_info"
    echo "Number of XY Packages" >> "$p_info"
    echo "1" >> "$p_info"
    echo "Number of z-blocks" >> "$p_info"
    echo "1" >> "$p_info"
    mkdir -p "$TEST_TMP_DIR/1fm/"
    touch "$TEST_TMP_DIR/1fm/DONE" 
    run $POSTPROCESS_WORKER_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" == "FIX ME" ]


}
