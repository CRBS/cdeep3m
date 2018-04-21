#!/usr/bin/env bats


setup() {
    export RUN_ALL_PREDICT_SH="${BATS_TEST_DIRNAME}/../run_all_predict.sh"
    export TEST_TMP_DIR="${BATS_TMPDIR}/"`uuidgen`
    /bin/mkdir -p "$TEST_TMP_DIR"
}

teardown() {
    if [ -d "$TEST_TMP_DIR" ] ; then
        /bin/rm -rf "$TEST_TMP_DIR"
    fi
}

@test "run_all_predict.sh no args" {
    run $RUN_ALL_PREDICT_SH
    echo "$status $output" 1>&2
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "usage: run_all_predict.sh [-h] [--gpu GPU]" ]
}

@test "run_all_predict.sh no predict.config file" {
    run $RUN_ALL_PREDICT_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 2 ]
    [ "${lines[0]}" = "ERROR no $TEST_TMP_DIR/predict.config file found" ]
}

@test "run_all_predict.sh no package_processing_info.txt file in images" {
    echo "trainedmodeldir=traindir" > "$TEST_TMP_DIR/predict.config"
    echo "imagedir=imgdir" >> "$TEST_TMP_DIR/predict.config"
    echo "models=1fm,3fm" >> "$TEST_TMP_DIR/predict.config"
    echo "augspeed=4" >> "$TEST_TMP_DIR/predict.config"
    run $RUN_ALL_PREDICT_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 3 ]
    [ "${lines[0]}" = "Running Prediction" ]
    [ "${lines[1]}" = "Trained Model Dir: traindir" ]
    [ "${lines[2]}" = "Image Dir: imgdir" ]
    [ "${lines[3]}" = "Models: 1fm,3fm" ]
    [ "${lines[4]}" = "Speed: 4" ]
    [ "${lines[5]}" = "ERROR imgdir/package_processing_info.txt not found" ]
}


#@test "run_all_predict.sh success cause nothing left to do" {
#    ln -s /bin/echo "$TEST_TMP_DIR/caffepredict.sh"
#    ln -s /bin/echo "$TEST_TMP_DIR/Merge_LargeData.m"
#    ln -s /bin/echo "$TEST_TMP_DIR/PreprocessPackage.m"
#    mkdir -p "$TEST_TMP_DIR/1fm" "$TEST_TMP_DIR/3fm" "$TEST_TMP_DIR/5fm"
#    echo "trainedmodeldir=$TEST_TMP_DIR/tmodel" > $TEST_TMP_DIR/predict.config
#    echo "augimagedir=$TEST_TMP_DIR/augimage" >> $TEST_TMP_DIR/predict.config

#    export A_TEMP_PATH=$PATH
#    export PATH=$TEST_TMP_DIR:$PATH

#    run $RUN_ALL_PREDICT_SH
#    echo "$status $output" 1>&2
#    [ "$status" -eq 0 ]
#    [ "${lines[0]}" = "Running Prediction" ]    
#    [ "${lines[1]}" = "Trained Model Dir: $TEST_TMP_DIR/tmodel" ]
#    [ "${lines[2]}" = "Image Dir: $TEST_TMP_DIR/augimage" ]
#    [ "${lines[3]}" = "Running 1fm predict 0 package(s) to process" ]
#    [ "${lines[4]}" = "Running Merge_LargeData.m $TEST_TMP_DIR/1fm" ]
#    [ "${lines[5]}" = "Running 3fm predict 0 package(s) to process" ]
#    [ "${lines[6]}" = "Running Merge_LargeData.m $TEST_TMP_DIR/3fm" ]
#    [ "${lines[7]}" = "Running 5fm predict 0 package(s) to process" ]
#    [ "${lines[8]}" = "Running Merge_LargeData.m $TEST_TMP_DIR/5fm" ]
#    [ "${lines[9]}" = "Prediction has completed. Have a nice day!" ]

#    export PATH=$A_TEMP_PATH
#}

