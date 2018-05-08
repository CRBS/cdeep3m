#!/usr/bin/env bats


setup() {
    export PREPROCESS_WORKER_SH="${BATS_TEST_DIRNAME}/../preprocessworker.sh"
    export TEST_TMP_DIR="${BATS_TMPDIR}/"`uuidgen`
    /bin/mkdir -p "$TEST_TMP_DIR"
}

teardown() {
    if [ -d "$TEST_TMP_DIR" ] ; then
        /bin/rm -rf "$TEST_TMP_DIR"
    fi
}

@test "preprocessworker.sh no args" {
    run $PREPROCESS_WORKER_SH
    echo "$status $output" 1>&2
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "usage: preprocessworker.sh [-h]" ]
}

@test "preprocessworker.sh empty dir" {
    run $PREPROCESS_WORKER_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 2 ]
    [ "${lines[0]}" == "ERROR no $TEST_TMP_DIR/predict.config file found" ]
    run cat "$TEST_TMP_DIR/ERROR"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" == "ERROR parsing $TEST_TMP_DIR/predict.config" ]
}

@test "preprocessworker.sh no package_processing_info.txt" {
    pconfig="$TEST_TMP_DIR/predict.config"
    echo "trainedmodeldir=tmodel" >> "$pconfig"
    echo "imagedir=imagey" >> "$pconfig"
    echo "models=1fm" >> "$pconfig"
    echo "augspeed=1" >> "$pconfig"
    run $PREPROCESS_WORKER_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 7 ]
    [ "${lines[5]}" == "ERROR $TEST_TMP_DIR/augimages/package_processing_info.txt not found" ]
}

@test "preprocessworker.sh PreprocessPackage.m fails" {
    ln -s /bin/false "$TEST_TMP_DIR/PreprocessPackage.m"
    pconfig="$TEST_TMP_DIR/predict.config"
    echo "trainedmodeldir=tmodel" >> "$pconfig"
    echo "imagedir=imagey" >> "$pconfig"
    echo "models=1fm" >> "$pconfig"
    echo "augspeed=1" >> "$pconfig"

    mkdir -p "$TEST_TMP_DIR/augimages"
    p_info="$TEST_TMP_DIR/augimages/package_processing_info.txt"
    echo "" > "$p_info"
    echo "Number of XY Packages" >> "$p_info"
    echo "4" >> "$p_info"
    echo "Number of z-blocks" >> "$p_info"
    echo "6" >> "$p_info"

    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH

    run $PREPROCESS_WORKER_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 8 ]
    run cat "$TEST_TMP_DIR/ERROR"
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" == "ERROR, a non-zero exit code (1) received from PreprocessPackage.m 001 01 1fm 1" ] 
    export PATH=$A_TEMP_PATH
}

@test "preprocessworker.sh success" {
    ln -s /bin/echo "$TEST_TMP_DIR/PreprocessPackage.m"
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

    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH

    run $PREPROCESS_WORKER_SH --maxpackages 20 --waitinterval 0 "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" == "Running PreprocessPackage" ] 
    [ "${lines[5]}" == "Preprocessing Pkg001_Z01 in model 1fm" ]
    [ "${lines[6]}" == "Waiting for prediction to catch up" ]
    [ "${lines[7]}" == "PreprocessPackaging has completed." ]
    [ ! -f "$TEST_TMP_DIR/ERROR" ]
    
    run cat "$TEST_TMP_DIR/augimages/preproc.1fm.Pkg001_Z01.log"
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" == "imagey $TEST_TMP_DIR/augimages 001 01 1fm 1" ]
    export PATH=$A_TEMP_PATH
}
