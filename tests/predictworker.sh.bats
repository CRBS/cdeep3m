#!/usr/bin/env bats


setup() {
    export PREDICT_WORKER_SH="${BATS_TEST_DIRNAME}/../predictworker.sh"
    export TEST_TMP_DIR="${BATS_TMPDIR}/"`uuidgen`
    /bin/mkdir -p "$TEST_TMP_DIR"
}

teardown() {
    if [ -d "$TEST_TMP_DIR" ] ; then
        /bin/rm -rf "$TEST_TMP_DIR"
    fi
}

@test "predictworker.sh no args" {
    run $PREDICT_WORKER_SH
    echo "$status $output" 1>&2
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "usage: predictworker.sh [-h] [--gpu GPU] [--waitinterval WAIT]" ]
}

@test "predictworker.sh empty dir" {
    run $PREDICT_WORKER_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 2 ]
    [ "${lines[0]}" == "ERROR no $TEST_TMP_DIR/predict.config file found" ]
    run cat "$TEST_TMP_DIR/ERROR"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" == "ERROR parsing $TEST_TMP_DIR/predict.config" ]
}

@test "predictworker.sh no package_processing_info.txt" {
    pconfig="$TEST_TMP_DIR/predict.config"
    echo "trainedmodeldir=tmodel" >> "$pconfig"
    echo "imagedir=imagey" >> "$pconfig"
    echo "models=1fm" >> "$pconfig"
    echo "augspeed=1" >> "$pconfig"
    run $PREDICT_WORKER_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 7 ]
    [ "${lines[6]}" == "ERROR $TEST_TMP_DIR/augimages/package_processing_info.txt not found" ]
}

@test "predictworker.sh DONE found no work to do" {
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
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg001_Z01"
    touch "$TEST_TMP_DIR/1fm/Pkg001_Z01/DONE"

    run $PREDICT_WORKER_SH --waitinterval 0 "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" == "Running Prediction" ]
    [ "${lines[6]}" == "  Found $TEST_TMP_DIR/1fm/Pkg001_Z01/DONE Postprocessing completed. Skipping..." ]
    [ "${lines[7]}" == "Prediction has completed." ]
    [ ! -f "$TEST_TMP_DIR/ERROR" ]
}

@test "predictworker.sh PREDICTDONE found no work to do" {
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
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg001_Z01"
    touch "$TEST_TMP_DIR/1fm/Pkg001_Z01/PREDICTDONE"
    
    run $PREDICT_WORKER_SH --waitinterval 0 "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" == "Running Prediction" ]
    [ "${lines[6]}" == "  Found $TEST_TMP_DIR/1fm/Pkg001_Z01/PREDICTDONE Prediction completed. Skipping..." ]
    [ "${lines[7]}" == "Prediction has completed." ]
    [ ! -f "$TEST_TMP_DIR/ERROR" ]
}

@test "predictworker.sh caffepredict.sh fails" {
    ln -s /bin/false "$TEST_TMP_DIR/caffepredict.sh"
    pconfig="$TEST_TMP_DIR/predict.config"
    echo "trainedmodeldir=tmodel" >> "$pconfig"
    echo "imagedir=imagey" >> "$pconfig"
    echo "models=1fm" >> "$pconfig"
    echo "augspeed=1" >> "$pconfig"
    mkdir -p "$TEST_TMP_DIR/augimages/1fm/Pkg001_Z01"
    p_info="$TEST_TMP_DIR/augimages/package_processing_info.txt"
    echo "" > "$p_info"
    echo "Number of XY Packages" >> "$p_info"
    echo "1" >> "$p_info"
    echo "Number of z-blocks" >> "$p_info"
    echo "1" >> "$p_info"
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg001_Z01"
    touch "$TEST_TMP_DIR/augimages/1fm/Pkg001_Z01/DONE"
    
    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH

    run $PREDICT_WORKER_SH --waitinterval 0 "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 4 ]
    [ "${lines[0]}" == "Running Prediction" ]
    [ "${lines[6]}" == "For model 1fm preprocessing Pkg001_Z01 1 of 1" ]
    [ "${lines[7]}" == "Running prediction on 1fm Pkg001_Z01" ]
    [ "${lines[12]}" == "ERROR, a non-zero exit code (1) was received from: caffepredict.sh" ]
    [ -f "$TEST_TMP_DIR/ERROR" ]

    run cat "$TEST_TMP_DIR/ERROR" 
    [ "${lines[0]}" == "ERROR, a non-zero exit code (1) was received from: caffepredict.sh" ]
    [ "${lines[1]}" == "4" ]
    
    export PATH=$A_TEMP_PATH
}

@test "predictworker.sh caffepredict.sh success no gpu flag" {
    ln -s /bin/echo "$TEST_TMP_DIR/caffepredict.sh"
    pconfig="$TEST_TMP_DIR/predict.config"
    echo "trainedmodeldir=tmodel" >> "$pconfig"
    echo "imagedir=imagey" >> "$pconfig"
    echo "models=1fm" >> "$pconfig"
    echo "augspeed=1" >> "$pconfig"
    mkdir -p "$TEST_TMP_DIR/augimages/1fm/Pkg001_Z01"
    p_info="$TEST_TMP_DIR/augimages/package_processing_info.txt"
    echo "" > "$p_info"
    echo "Number of XY Packages" >> "$p_info"
    echo "1" >> "$p_info"
    echo "Number of z-blocks" >> "$p_info"
    echo "1" >> "$p_info"
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg001_Z01"
    touch "$TEST_TMP_DIR/augimages/1fm/Pkg001_Z01/DONE"

    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH

    run $PREDICT_WORKER_SH --waitinterval 0 "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" == "Running Prediction" ]
    [ "${lines[6]}" == "For model 1fm preprocessing Pkg001_Z01 1 of 1" ]
    [ "${lines[7]}" == "Running prediction on 1fm Pkg001_Z01" ]
    [ "${lines[8]}" == "--gpu all tmodel/1fm/trainedmodel $TEST_TMP_DIR/augimages/1fm/Pkg001_Z01 $TEST_TMP_DIR/1fm/Pkg001_Z01" ]
    [ ! -f "$TEST_TMP_DIR/ERROR" ]

    export PATH=$A_TEMP_PATH
}

@test "predictworker.sh caffepredict.sh success --gpu 3 flag" {
    ln -s /bin/echo "$TEST_TMP_DIR/caffepredict.sh"
    pconfig="$TEST_TMP_DIR/predict.config"
    echo "trainedmodeldir=tmodel" >> "$pconfig"
    echo "imagedir=imagey" >> "$pconfig"
    echo "models=1fm" >> "$pconfig"
    echo "augspeed=1" >> "$pconfig"
    mkdir -p "$TEST_TMP_DIR/augimages/1fm/Pkg001_Z01"
    p_info="$TEST_TMP_DIR/augimages/package_processing_info.txt"
    echo "" > "$p_info"
    echo "Number of XY Packages" >> "$p_info"
    echo "1" >> "$p_info"
    echo "Number of z-blocks" >> "$p_info"
    echo "1" >> "$p_info"
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg001_Z01"
    touch "$TEST_TMP_DIR/augimages/1fm/Pkg001_Z01/DONE"

    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH

    run $PREDICT_WORKER_SH --waitinterval 0 --gpu 3 "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" == "Running Prediction" ]
    [ "${lines[6]}" == "For model 1fm preprocessing Pkg001_Z01 1 of 1" ]
    [ "${lines[7]}" == "Running prediction on 1fm Pkg001_Z01" ]
    [ "${lines[8]}" == "--gpu 3 tmodel/1fm/trainedmodel $TEST_TMP_DIR/augimages/1fm/Pkg001_Z01 $TEST_TMP_DIR/1fm/Pkg001_Z01" ]
    [ ! -f "$TEST_TMP_DIR/ERROR" ]

    export PATH=$A_TEMP_PATH
}


