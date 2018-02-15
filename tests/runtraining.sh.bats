#!/usr/bin/env bats


setup() {
    export RUNTRAINING_SH="${BATS_TEST_DIRNAME}/../runtraining.sh"
    export TEST_TMP_DIR="${BATS_TMPDIR}/"`uuidgen`
    /bin/mkdir -p "$TEST_TMP_DIR"
}

teardown() {
    if [ -d "$TEST_TMP_DIR" ] ; then
        /bin/rm -rf "$TEST_TMP_DIR"
    fi
}

@test "runtraining.sh no args" {
    run $RUNTRAINING_SH
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "usage: runtraining.sh [-h] [--1fmonly] [--numiterations NUMITERATIONS]" ]
}


@test "runtraining.sh verify correct input to CreateTrainJob.m" {
   ln -s /bin/echo "$TEST_TMP_DIR/CreateTrainJob.m"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNTRAINING_SH trainimages trainoutdir
   [ "$status" -eq 3 ]
   [ "${lines[0]}" = "trainimages trainoutdir" ]
   
   export PATH=$A_TEMP_PATH
}

@test "runtraining.sh success" {
   ln -s /bin/true "$TEST_TMP_DIR/CreateTrainJob.m"
   mkdir -p "$TEST_TMP_DIR/trainoutdir"
   ln -s /bin/echo "$TEST_TMP_DIR/trainoutdir/run_all_train.sh"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNTRAINING_SH trainimages "$TEST_TMP_DIR/trainoutdir"
   [ "$status" -eq 0 ]
   echo "$output" 1>&2
   [ "${lines[0]}" = "--numiterations 2000" ]
   [ "${lines[1]}" = "Training has completed. Results are stored in $TEST_TMP_DIR/trainoutdir" ]

   export PATH=$A_TEMP_PATH
}

@test "runtraining.sh success custom --numiterations" {
   ln -s /bin/true "$TEST_TMP_DIR/CreateTrainJob.m"
   mkdir -p "$TEST_TMP_DIR/trainoutdir"
   ln -s /bin/echo "$TEST_TMP_DIR/trainoutdir/run_all_train.sh"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNTRAINING_SH --numiterations 50 trainimages "$TEST_TMP_DIR/trainoutdir"
   [ "$status" -eq 0 ]
   echo "$output" 1>&2
   [ "${lines[0]}" = "--numiterations 50" ]
   [ "${lines[1]}" = "Training has completed. Results are stored in $TEST_TMP_DIR/trainoutdir" ]

   export PATH=$A_TEMP_PATH
}

@test "runtraining.sh success --1fmonly set" {
   ln -s /bin/true "$TEST_TMP_DIR/CreateTrainJob.m"
   mkdir -p "$TEST_TMP_DIR/trainoutdir"
   ln -s /bin/echo "$TEST_TMP_DIR/trainoutdir/run_all_train.sh"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNTRAINING_SH --numiterations 50 --1fmonly trainimages "$TEST_TMP_DIR/trainoutdir"
   [ "$status" -eq 0 ]
   echo "$output" 1>&2
   [ "${lines[0]}" = "--1fmonly --numiterations 50" ]
   [ "${lines[1]}" = "Training has completed. Results are stored in $TEST_TMP_DIR/trainoutdir" ]

   export PATH=$A_TEMP_PATH
}

