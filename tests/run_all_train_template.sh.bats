#!/usr/bin/env bats


setup() {
    export RUN_ALL_TRAIN_TEMPLATE_SH="${BATS_TEST_DIRNAME}/../scripts/run_all_train_template.sh"
    export TEST_TMP_DIR="${BATS_TMPDIR}/"`uuidgen`
    /bin/mkdir -p "$TEST_TMP_DIR"
    export RUN_ALL_TRAIN_SH="$TEST_TMP_DIR/run_all_train.sh"
   /bin/cp "$RUN_ALL_TRAIN_TEMPLATE_SH" "$RUN_ALL_TRAIN_SH"
}

teardown() {
    if [ -d "$TEST_TMP_DIR" ] ; then
        /bin/rm -rf "$TEST_TMP_DIR"
    fi
}

@test "run_all_train.sh no args empty dir" {
    run $RUN_ALL_TRAIN_SH
    echo "$status $output" 1>&2
    [ "$status" -eq 2 ]
    [ "${lines[0]}" = "ERROR, no $TEST_TMP_DIR/1fm directory found." ]
}

@test "run_all_train.sh success no args" {
    ln -s /bin/echo "$TEST_TMP_DIR/caffe_train.sh"
    mkdir -p "$TEST_TMP_DIR/1fm" "$TEST_TMP_DIR/3fm" "$TEST_TMP_DIR/5fm"
    run $RUN_ALL_TRAIN_SH
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Running 1fm train, this could take a while" ]    
    [ "${lines[1]}" = "1fm 2000 all" ]
    [ "${lines[5]}" = "Running 3fm train, this could take a while" ]
    [ "${lines[6]}" = "3fm 2000 all" ]
    [ "${lines[10]}" = "Running 5fm train, this could take a while" ]
    [ "${lines[11]}" = "5fm 2000 all" ]
    [ "${lines[15]}" = "Training has completed. Have a nice day!" ]
}

@test "run_all_train.sh caffe_train.sh fail" {
    ln -s /bin/false "$TEST_TMP_DIR/caffe_train.sh"  
    mkdir -p "$TEST_TMP_DIR/1fm" "$TEST_TMP_DIR/3fm" "$TEST_TMP_DIR/5fm"
    run $RUN_ALL_TRAIN_SH
    echo "$status $output" 1>&2
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "Running 1fm train, this could take a while" ]        
    [ "${lines[1]}" = "Command exited with non-zero status 1" ]
    [ "${lines[5]}" = "Non zero exit code from caffe for train of 1fm model. Exiting." ]
}

@test "run_all_train.sh success custom iterations and gpu" {
    ln -s /bin/echo "$TEST_TMP_DIR/caffe_train.sh"  
    mkdir -p "$TEST_TMP_DIR/1fm" "$TEST_TMP_DIR/3fm" "$TEST_TMP_DIR/5fm"
    run $RUN_ALL_TRAIN_SH --numiterations 2500 --gpu yo
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Running 1fm train, this could take a while" ]        
    [ "${lines[1]}" = "1fm 2500 yo" ]
    [ "${lines[5]}" = "Running 3fm train, this could take a while" ]
    [ "${lines[6]}" = "3fm 2500 yo" ]
    [ "${lines[10]}" = "Running 5fm train, this could take a while" ]
    [ "${lines[11]}" = "5fm 2500 yo" ]
    [ "${lines[15]}" = "Training has completed. Have a nice day!" ]
}

@test "run_all_train.sh success --1fmonly" {
    ln -s /bin/echo "$TEST_TMP_DIR/caffe_train.sh"  
    mkdir -p "$TEST_TMP_DIR/1fm" "$TEST_TMP_DIR/3fm" "$TEST_TMP_DIR/5fm"
    run $RUN_ALL_TRAIN_SH --1fmonly
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Running 1fm train, this could take a while" ]        
    [ "${lines[1]}" = "1fm 2000 all" ]
    [ "${lines[5]}" = "--1fmonly flag set, skipping 3fm and 5fm models." ]
    [ "${lines[6]}" = "Training has completed. Have a nice day!" ]
}

