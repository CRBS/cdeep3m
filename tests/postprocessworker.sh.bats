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
    [ "${lines[5]}" == "Found $TEST_TMP_DIR/1fm/DONE Prediction on model completed. Skipping..." ]
    [ "${lines[6]}" == "Postprocessing has completed." ]
}

@test "postprocessworker.sh StartPostprocessing.m fails" {
    ln -s /bin/false "$TEST_TMP_DIR/StartPostprocessing.m"

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
     
    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH
    run $POSTPROCESS_WORKER_SH --waitinterval 0 "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 7 ]
    [ "${lines[12]}" == "ERROR non-zero exit code (1) from running StartPostprocessing.m" ]
    [ -f "$TEST_TMP_DIR/ERROR" ]
    run cat "$TEST_TMP_DIR/ERROR" 
    [ "${lines[0]}" == "ERROR non-zero exit code (1) from running StartPostprocessing.m" ]
    export PATH=$A_TEMP_PATH
}

@test "postprocessworker.sh Merge_LargeData.m fails" {
    ln -s /bin/true "$TEST_TMP_DIR/StartPostprocessing.m"
    ln -s /bin/false "$TEST_TMP_DIR/Merge_LargeData.m"
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

    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH
    run $POSTPROCESS_WORKER_SH --waitinterval 0 "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 8 ]
    [ "${lines[16]}" == "ERROR non-zero exit code (1) from running Merge_LargeData.m" ]
    [ -f "$TEST_TMP_DIR/ERROR" ]
    run cat "$TEST_TMP_DIR/ERROR"
    [ "${lines[0]}" == "ERROR non-zero exit code (1) from running Merge_LargeData.m" ]
    export PATH=$A_TEMP_PATH
}

@test "postprocessworker.sh success" {
    ln -s /bin/echo "$TEST_TMP_DIR/StartPostprocessing.m"
    ln -s /bin/echo "$TEST_TMP_DIR/Merge_LargeData.m"
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
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg_001"
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg_002"
    touch "$TEST_TMP_DIR/1fm/Pkg_001/test.5h.png"
    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH
    run $POSTPROCESS_WORKER_SH --waitinterval 0 "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" == "Running Postprocess" ]
    [ ! -f "$TEST_TMP_DIR/ERROR" ]
    [ "${lines[5]}" == "For model 1fm postprocessing Pkg001_Z01 1 of 1" ]
    [ "${lines[6]}" == "Waiting for $TEST_TMP_DIR/1fm/Pkg001_Z01 to finish processing" ]
    [ "${lines[7]}" == "Running StartPostprocessing.m on $TEST_TMP_DIR/1fm/Pkg001_Z01" ]
    [ "${lines[8]}" == "$TEST_TMP_DIR/1fm/Pkg001_Z01" ]
    [ "${lines[12]}" == "Removing $TEST_TMP_DIR/augimages/1fm/Pkg001_Z01" ]
    [ "${lines[13]}" == "$TEST_TMP_DIR/1fm" ] 
    [ "${lines[17]}" == "Removing Pkg_* folders" ]
    [ "${lines[18]}" == "Postprocessing has completed." ]

    [ ! -d "$TEST_TMP_DIR/1fm/Pkg_001" ] 
    [ ! -d "$TEST_TMP_DIR/1fm/Pkg_002" ]
    export PATH=$A_TEMP_PATH
}

