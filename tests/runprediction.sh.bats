#!/usr/bin/env bats


setup() {
    export RUNPREDICTION_SH="${BATS_TEST_DIRNAME}/../runprediction.sh"
    export TEST_TMP_DIR="${BATS_TMPDIR}/"`uuidgen`
    /bin/mkdir -p "$TEST_TMP_DIR"
}

teardown() {
    if [ -d "$TEST_TMP_DIR" ] ; then
        /bin/rm -rf "$TEST_TMP_DIR"
    fi
}

@test "runprediction.sh no args" {
    run $RUNPREDICTION_SH
    [ "$status" -eq 1 ]
    echo "$status $output" 1>&2
    [ "${lines[0]}" = "usage: runprediction.sh [-h] [--1fmonly]" ]
}


@test "runprediction.sh verify correct input to CreatePredictJob.m" {
   ln -s /bin/echo "$TEST_TMP_DIR/CreatePredictJob.m"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNPREDICTION_SH trainoutdir augimages predictout
   echo "$status $output" 1>&2
   [ "$status" -eq 3 ]
   [ "${lines[0]}" = "trainoutdir augimages predictout" ]
   [ "${lines[1]}" = "ERROR, either predictout/run_all_predict.sh is missing or non-executable" ] 
   export PATH=$A_TEMP_PATH
}

@test "runprediction.sh success" {
   ln -s /bin/true "$TEST_TMP_DIR/CreatePredictJob.m"
   mkdir -p "$TEST_TMP_DIR/predictoutdir"
   ln -s /bin/echo "$TEST_TMP_DIR/predictoutdir/run_all_predict.sh"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNPREDICTION_SH trainoutdir augimages "$TEST_TMP_DIR/predictoutdir"
   [ "$status" -eq 0 ]
   echo "$output" 1>&2
   [ "${lines[0]}" = "Prediction has completed. Results are stored in $TEST_TMP_DIR/predictoutdir" ]

   export PATH=$A_TEMP_PATH
}


@test "runprediction.sh success --1fmonly set" {
   ln -s /bin/true "$TEST_TMP_DIR/CreatePredictJob.m"
   mkdir -p "$TEST_TMP_DIR/predictoutdir"
   ln -s /bin/echo "$TEST_TMP_DIR/predictoutdir/run_all_predict.sh"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNPREDICTION_SH --1fmonly trainoutdir augimages "$TEST_TMP_DIR/predictoutdir"
   [ "$status" -eq 0 ]
   echo "$output" 1>&2
   [ "${lines[0]}" = "--1fmonly" ]
   [ "${lines[1]}" = "Prediction has completed. Results are stored in $TEST_TMP_DIR/predictoutdir" ]

   export PATH=$A_TEMP_PATH
}

@test "runprediction.sh run_all_predict.sh fails" {
   ln -s /bin/true "$TEST_TMP_DIR/CreatePredictJob.m"
   mkdir -p "$TEST_TMP_DIR/predictoutdir"
   ln -s /bin/false "$TEST_TMP_DIR/predictoutdir/run_all_predict.sh"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNPREDICTION_SH trainoutdir augimages "$TEST_TMP_DIR/predictoutdir"
   echo "$status $output" 1>&2
   [ "$status" -eq 4 ]
   [ "${lines[0]}" = "ERROR, a non-zero exit code (1) was received from: \"$TEST_TMP_DIR/predictoutdir/run_all_predict.sh\" " ]

   export PATH=$A_TEMP_PATH
}

