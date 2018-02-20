#!/usr/bin/env bats


setup() {
    export RUN_ALL_PREDICT_TEMPLATE_SH="${BATS_TEST_DIRNAME}/../scripts/run_all_predict_template.sh"
    export TEST_TMP_DIR="${BATS_TMPDIR}/"`uuidgen`
    /bin/mkdir -p "$TEST_TMP_DIR"
    export RUN_ALL_PREDICT_SH="$TEST_TMP_DIR/run_all_predict.sh"
   /bin/cp "$RUN_ALL_PREDICT_TEMPLATE_SH" "$RUN_ALL_PREDICT_SH"
}

teardown() {
    if [ -d "$TEST_TMP_DIR" ] ; then
        /bin/rm -rf "$TEST_TMP_DIR"
    fi
}

@test "run_all_predict.sh no args empty dir" {
    run $RUN_ALL_PREDICT_SH
    echo "$status $output" 1>&2
    [ "$status" -eq 2 ]
    [ "${lines[0]}" = "ERROR no $TEST_TMP_DIR/predict.config file found, which is required" ]
}

@test "run_all_predict.sh success no args and no packages to process" {
    ln -s /bin/echo "$TEST_TMP_DIR/caffe_predict.sh"
    mkdir -p "$TEST_TMP_DIR/1fm" "$TEST_TMP_DIR/3fm" "$TEST_TMP_DIR/5fm"
    echo "trainedmodeldir=$TEST_TMP_DIR/tmodel" > $TEST_TMP_DIR/predict.config
    echo "augimagedir=$TEST_TMP_DIR/augimage" >> $TEST_TMP_DIR/predict.config
    run $RUN_ALL_PREDICT_SH
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Running Prediction" ]    
    [ "${lines[1]}" = "Trained Model Dir: $TEST_TMP_DIR/tmodel" ]
    [ "${lines[2]}" = "Image Dir: $TEST_TMP_DIR/augimage" ]
    [ "${lines[3]}" = "Running 1fm predict 0 package(s) to process" ]
    [ "${lines[4]}" = "Running 3fm predict 0 package(s) to process" ]
    [ "${lines[5]}" = "Running 5fm predict 0 package(s) to process" ]
    [ "${lines[6]}" = "Prediction has completed. Have a nice day!" ]
}

@test "run_all_predict.sh success --1fmonly and no packages to process" {
    ln -s /bin/echo "$TEST_TMP_DIR/caffe_predict.sh" 
    mkdir -p "$TEST_TMP_DIR/1fm" "$TEST_TMP_DIR/3fm" "$TEST_TMP_DIR/5fm"
    echo "trainedmodeldir=$TEST_TMP_DIR/tmodel" > $TEST_TMP_DIR/predict.config
    echo "augimagedir=$TEST_TMP_DIR/augimage" >> $TEST_TMP_DIR/predict.config
    run $RUN_ALL_PREDICT_SH --1fmonly
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Running Prediction" ]    
    [ "${lines[1]}" = "Trained Model Dir: $TEST_TMP_DIR/tmodel" ] 
    [ "${lines[2]}" = "Image Dir: $TEST_TMP_DIR/augimage" ]
    [ "${lines[3]}" = "Running 1fm predict 0 package(s) to process" ]
    [ "${lines[4]}" = "--1fmonly flag set skipping prediction for $TEST_TMP_DIR/3fm" ]
    [ "${lines[5]}" = "--1fmonly flag set skipping prediction for $TEST_TMP_DIR/5fm" ]
    [ "${lines[6]}" = "Prediction has completed. Have a nice day!" ]
}

@test "run_all_predict.sh success no args all packages done" {
    ln -s /bin/echo "$TEST_TMP_DIR/caffe_predict.sh" 
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg001_Z01" "$TEST_TMP_DIR/3fm/Pkg002_Z01" "$TEST_TMP_DIR/5fm/Pkg003_Z01"
    touch "$TEST_TMP_DIR/1fm/Pkg001_Z01/DONE"
    touch "$TEST_TMP_DIR/3fm/Pkg002_Z01/DONE"
    touch "$TEST_TMP_DIR/5fm/Pkg003_Z01/DONE"
    echo "trainedmodeldir=$TEST_TMP_DIR/tmodel" > $TEST_TMP_DIR/predict.config
    echo "augimagedir=$TEST_TMP_DIR/augimage" >> $TEST_TMP_DIR/predict.config
    run $RUN_ALL_PREDICT_SH
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Running Prediction" ]    
    [ "${lines[1]}" = "Trained Model Dir: $TEST_TMP_DIR/tmodel" ] 
    [ "${lines[2]}" = "Image Dir: $TEST_TMP_DIR/augimage" ]
    [ "${lines[3]}" = "Running 1fm predict 1 package(s) to process" ]
    [ "${lines[4]}" = "Found $TEST_TMP_DIR/1fm/Pkg001_Z01/DONE. Prediction completed. Skipping..." ]
    [ "${lines[5]}" = "Running 3fm predict 1 package(s) to process" ]
    [ "${lines[6]}" = "Found $TEST_TMP_DIR/3fm/Pkg002_Z01/DONE. Prediction completed. Skipping..." ]
    [ "${lines[7]}" = "Running 5fm predict 1 package(s) to process" ]
    [ "${lines[8]}" = "Found $TEST_TMP_DIR/5fm/Pkg003_Z01/DONE. Prediction completed. Skipping..." ]
    [ "${lines[9]}" = "Prediction has completed. Have a nice day!" ]
}

@test "run_all_predict.sh success no args 1 package in each model dir" {
    ln -s /bin/echo "$TEST_TMP_DIR/caffe_predict.sh"
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg001_Z01" "$TEST_TMP_DIR/3fm/Pkg002_Z01" "$TEST_TMP_DIR/5fm/Pkg002_Z01"
    echo "trainedmodeldir=$TEST_TMP_DIR/tmodel" > $TEST_TMP_DIR/predict.config
    echo "augimagedir=$TEST_TMP_DIR/augimage" >> $TEST_TMP_DIR/predict.config
    run $RUN_ALL_PREDICT_SH
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Running Prediction" ]
    [ "${lines[1]}" = "Trained Model Dir: $TEST_TMP_DIR/tmodel" ]
    [ "${lines[2]}" = "Image Dir: $TEST_TMP_DIR/augimage" ]
    [ "${lines[3]}" = "Running 1fm predict 1 package(s) to process" ]
    [ "${lines[4]}" = "  Processing Pkg001_Z01 1 of 1 --gpu 0 $TEST_TMP_DIR/tmodel/1fm/trainedmodel $TEST_TMP_DIR/augimage/Pkg001_Z01 $TEST_TMP_DIR/1fm/Pkg001_Z01" ]
    [ "${lines[8]}" = "Running 3fm predict 1 package(s) to process" ]
    [ "${lines[9]}" = "  Processing Pkg002_Z01 1 of 1 --gpu 0 $TEST_TMP_DIR/tmodel/3fm/trainedmodel $TEST_TMP_DIR/augimage/Pkg002_Z01 $TEST_TMP_DIR/3fm/Pkg002_Z01" ]
    [ "${lines[13]}" = "Running 5fm predict 1 package(s) to process" ]
    [ "${lines[14]}" = "  Processing Pkg002_Z01 1 of 1 --gpu 0 $TEST_TMP_DIR/tmodel/5fm/trainedmodel $TEST_TMP_DIR/augimage/Pkg002_Z01 $TEST_TMP_DIR/5fm/Pkg002_Z01" ]
    [ "${lines[18]}" = "Prediction has completed. Have a nice day!" ]
    [ -f "$TEST_TMP_DIR/1fm/Pkg001_Z01/DONE" ]
    [ -f "$TEST_TMP_DIR/3fm/Pkg002_Z01/DONE" ]
    [ -f "$TEST_TMP_DIR/5fm/Pkg002_Z01/DONE" ]

}

@test "run_all_predict.sh success --gpu 1 set" {
    ln -s /bin/echo "$TEST_TMP_DIR/caffe_predict.sh"
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg001_Z01" "$TEST_TMP_DIR/3fm/Pkg002_Z01" "$TEST_TMP_DIR/5fm/Pkg002_Z01"
    echo "trainedmodeldir=$TEST_TMP_DIR/tmodel" > $TEST_TMP_DIR/predict.config
    echo "augimagedir=$TEST_TMP_DIR/augimage" >> $TEST_TMP_DIR/predict.config
    run $RUN_ALL_PREDICT_SH --gpu 1
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Running Prediction" ]
    [ "${lines[1]}" = "Trained Model Dir: $TEST_TMP_DIR/tmodel" ]
    [ "${lines[2]}" = "Image Dir: $TEST_TMP_DIR/augimage" ]
    [ "${lines[3]}" = "Running 1fm predict 1 package(s) to process" ]
    [ "${lines[4]}" = "  Processing Pkg001_Z01 1 of 1 --gpu 1 $TEST_TMP_DIR/tmodel/1fm/trainedmodel $TEST_TMP_DIR/augimage/Pkg001_Z01 $TEST_TMP_DIR/1fm/Pkg001_Z01" ]
    [ "${lines[8]}" = "Running 3fm predict 1 package(s) to process" ]
    [ "${lines[9]}" = "  Processing Pkg002_Z01 1 of 1 --gpu 1 $TEST_TMP_DIR/tmodel/3fm/trainedmodel $TEST_TMP_DIR/augimage/Pkg002_Z01 $TEST_TMP_DIR/3fm/Pkg002_Z01" ]
    [ "${lines[13]}" = "Running 5fm predict 1 package(s) to process" ]
    [ "${lines[14]}" = "  Processing Pkg002_Z01 1 of 1 --gpu 1 $TEST_TMP_DIR/tmodel/5fm/trainedmodel $TEST_TMP_DIR/augimage/Pkg002_Z01 $TEST_TMP_DIR/5fm/Pkg002_Z01" ]
    [ "${lines[18]}" = "Prediction has completed. Have a nice day!" ]
    [ -f "$TEST_TMP_DIR/1fm/Pkg001_Z01/DONE" ]
    [ -f "$TEST_TMP_DIR/3fm/Pkg002_Z01/DONE" ]
    [ -f "$TEST_TMP_DIR/5fm/Pkg002_Z01/DONE" ]

}


@test "run_all_predict.sh caffe_predict.sh fails" {
    ln -s /bin/false "$TEST_TMP_DIR/caffe_predict.sh"
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg001_Z01" "$TEST_TMP_DIR/3fm/Pkg002_Z01" "$TEST_TMP_DIR/5fm/Pkg002_Z01"
    echo "trainedmodeldir=$TEST_TMP_DIR/tmodel" > $TEST_TMP_DIR/predict.config
    echo "augimagedir=$TEST_TMP_DIR/augimage" >> $TEST_TMP_DIR/predict.config
    run $RUN_ALL_PREDICT_SH
    echo "$status $output" 1>&2
    [ "$status" -eq 3 ]
    [ "${lines[0]}" = "Running Prediction" ]
    [ "${lines[1]}" = "Trained Model Dir: $TEST_TMP_DIR/tmodel" ]
    [ "${lines[2]}" = "Image Dir: $TEST_TMP_DIR/augimage" ]
    [ "${lines[3]}" = "Running 1fm predict 1 package(s) to process" ]
    [ "${lines[4]}" = "  Processing Pkg001_Z01 1 of 1 Command exited with non-zero status 1" ]
    [ "${lines[8]}" = "Non zero exit code from caffe for predict $TEST_TMP_DIR/1fm/Pkg001_Z01 model. Exiting." ]
    [ ! -f "$TEST_TMP_DIR/1fm/Pkg001_Z01/DONE" ]

}



