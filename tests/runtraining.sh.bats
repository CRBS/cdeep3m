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

@test "runtraining.sh PreprocessTrainingData.m fails" {
   ln -s /bin/false "$TEST_TMP_DIR/PreprocessTrainingData.m"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNTRAINING_SH trainimages trainlabels trainoutdir
   export PATH=$A_TEMP_PATH
   [ "$status" -eq 2 ]
   echo "$output" 1>&2
   [ "${lines[0]}" = "ERROR, a non-zero exit code (1) was received from: PreprocessTrainingData.m \"trainimages\" \"trainlabels\" \"trainoutdir/augtrain_images\"" ]
   export PATH=$A_TEMP_PATH
}

@test "runtraining.sh verify correct input to PreprocessTrainingData.m" {
   ln -s /bin/echo "$TEST_TMP_DIR/PreprocessTrainingData.m"
   ln -s /bin/false "$TEST_TMP_DIR/CreateTrainJob.m"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNTRAINING_SH trainimages trainlabels trainoutdir
   export PATH=$A_TEMP_PATH
   [ "$status" -eq 3 ]
   [ "${lines[0]}" = "trainimages trainlabels trainoutdir/augtrain_images" ] 
   export PATH=$A_TEMP_PATH
}

@test "runtraining.sh verify correct input to CreateTrainJob.m" {
   ln -s /bin/true "$TEST_TMP_DIR/PreprocessTrainingData.m"
   ln -s /bin/echo "$TEST_TMP_DIR/CreateTrainJob.m"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNTRAINING_SH trainimages trainlabels trainoutdir
   [ "$status" -eq 4 ]
   [ "${lines[0]}" = "trainoutdir/augtrain_images trainoutdir" ]
   
   export PATH=$A_TEMP_PATH
}

@test "runtraining.sh success" {
   ln -s /bin/true "$TEST_TMP_DIR/PreprocessTrainingData.m"
   ln -s /bin/true "$TEST_TMP_DIR/CreateTrainJob.m"
   mkdir -p "$TEST_TMP_DIR/trainoutdir"
   ln -s /bin/true "$TEST_TMP_DIR/trainoutdir/run_all_train.sh"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNTRAINING_SH trainimages trainlabels "$TEST_TMP_DIR/trainoutdir"
   [ "$status" -eq 0 ]
   echo "$output" 1>&2
   [ "${lines[0]}" = "Training has completed. Results are stored in $TEST_TMP_DIR/trainoutdir" ]

   export PATH=$A_TEMP_PATH
}

