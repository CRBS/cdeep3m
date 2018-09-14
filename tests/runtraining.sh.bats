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
   ln -s /bin/false "$TEST_TMP_DIR/trainworker.sh"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNTRAINING_SH trainimages trainoutdir
   echo "$status $output" 1>&2
   [ "$status" -eq 4 ]
   [ "${lines[0]}" = "trainimages trainoutdir trainimages" ]
   
   export PATH=$A_TEMP_PATH
}

@test "runtraining.sh --retrain set but not valid directory" {
   ln -s /bin/echo "$TEST_TMP_DIR/CreateTrainJob.m"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNTRAINING_SH --retrain "$TEST_TMP_DIR/no" trainimages trainoutdir
   echo "$status $output" 1>&2
   [ "$status" -eq 3 ]
   [ "${lines[0]}" = "trainimages trainoutdir trainimages" ]
   [ "${lines[1]}" = "ERROR, $TEST_TMP_DIR/no is not a directory" ]
   export PATH=$A_TEMP_PATH
}

@test "runtraining.sh --retrain set but no trained models" {
   ln -s /bin/echo "$TEST_TMP_DIR/CreateTrainJob.m"
   ln -s /bin/false "$TEST_TMP_DIR/trainworker.sh"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   trainout="$TEST_TMP_DIR/trainout"
   trainoutdir="$TEST_TMP_DIR/trainoutdir"
   mkdir -p "$trainout" "$trainoutdir"
   run $RUNTRAINING_SH --retrain "$trainout" trainimages "$trainoutdir"
   echo "$status $output" 1>&2
   [ "$status" -eq 4 ]
   [ "${lines[0]}" = "trainimages $trainoutdir trainimages" ]
   [ "${lines[2]}" = "No models $trainout/1fm/trainedmodel leaving numiterations at 30000" ]
   run tail -n 1 "$trainoutdir/readme.txt"
   echo "$status $output" 1>&2
   [ "${lines[0]}" = "--retrain flag set, previous models copied from $trainout" ]
   export PATH=$A_TEMP_PATH
}

@test "runtraining.sh --retrain set with trained models" {
   ln -s /bin/echo "$TEST_TMP_DIR/CreateTrainJob.m"
   ln -s /bin/false "$TEST_TMP_DIR/trainworker.sh"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   trainout="$TEST_TMP_DIR/trainout"
   trainoutdir="$TEST_TMP_DIR/trainoutdir"
   mkdir -p "$trainout/1fm/trainedmodel" "$trainoutdir/1fm/trainedmodel"
   touch "$trainout/1fm/trainedmodel/1fm_classifier_iter_290.solverstate"
   run $RUNTRAINING_SH --retrain "$trainout" trainimages "$trainoutdir"
   echo "$status $output" 1>&2
   [ "$status" -eq 4 ]
   [ "${lines[0]}" = "trainimages $trainoutdir trainimages" ]
   [ "${lines[1]}" = "Latest iteration found in 1fm from $trainout is 290" ]
   [ "${lines[2]}" = "Adding 2000 iterations so will now run to 2290 iterations" ]
   [ "${lines[3]}" = "Copying over trained models" ]
   [ "${lines[4]}" = "Copy of $trainout/1fm/trainedmodel to $trainoutdir/1fm/trainedmodel success" ] 
   [ "${lines[5]}" = "ERROR, a non-zero exit code (1) was received from: trainworker.sh --numiterations 2290" ]
   [ -f "$trainoutdir/1fm/trainedmodel/1fm_classifier_iter_290.solverstate" ] 
   run tail -n 1 "$trainoutdir/readme.txt"
   echo "$status $output" 1>&2
   [ "${lines[0]}" = "--retrain flag set, previous models copied from $trainout" ]
   export PATH=$A_TEMP_PATH
}


@test "runtraining.sh CreateTrainJob.m with --validation flag" {
   ln -s /bin/echo "$TEST_TMP_DIR/CreateTrainJob.m"
   ln -s /bin/false "$TEST_TMP_DIR/trainworker.sh"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNTRAINING_SH --validation_dir foo trainimages trainoutdir
   echo "$status $output" 1>&2
   [ "$status" -eq 4 ]
   [ "${lines[0]}" = "trainimages trainoutdir foo" ]

   export PATH=$A_TEMP_PATH
}

@test "runtraining.sh success" {
   ln -s /bin/true "$TEST_TMP_DIR/CreateTrainJob.m"
   mkdir -p "$TEST_TMP_DIR/trainoutdir"
   ln -s /bin/echo "$TEST_TMP_DIR/trainworker.sh"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNTRAINING_SH trainimages "$TEST_TMP_DIR/trainoutdir"
   echo "$status $output" 1>&2
   [ "$status" -eq 0 ]
   [ "${lines[0]}" = "--numiterations 30000 --gpu all --base_learn 1e-02 --power 0.8 --momentum 0.9 --weight_decay 0.0005 --average_loss 16 --lr_policy poly --iter_size 8 --snapshot_interval 2000 $TEST_TMP_DIR/trainoutdir" ]
   [ "${lines[1]}" = "Training has completed. Results are stored in $TEST_TMP_DIR/trainoutdir" ]

   export PATH=$A_TEMP_PATH
}

@test "runtraining.sh trainworker.sh fails" {
   ln -s /bin/true "$TEST_TMP_DIR/CreateTrainJob.m"
   mkdir -p "$TEST_TMP_DIR/trainoutdir"
   ln -s /bin/false "$TEST_TMP_DIR/trainworker.sh"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNTRAINING_SH trainimages "$TEST_TMP_DIR/trainoutdir"
   [ "$status" -eq 4 ]
   echo "$output" 1>&2
   [ "${lines[0]}" = "ERROR, a non-zero exit code (1) was received from: trainworker.sh --numiterations 30000" ]

   export PATH=$A_TEMP_PATH
}


@test "runtraining.sh success custom --numiterations" {
   ln -s /bin/true "$TEST_TMP_DIR/CreateTrainJob.m"
   mkdir -p "$TEST_TMP_DIR/trainoutdir"
   ln -s /bin/echo "$TEST_TMP_DIR/trainworker.sh"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNTRAINING_SH --numiterations 50 trainimages "$TEST_TMP_DIR/trainoutdir"
   [ "$status" -eq 0 ]
   echo "$output" 1>&2
   [ "${lines[0]}" = "--numiterations 50 --gpu all --base_learn 1e-02 --power 0.8 --momentum 0.9 --weight_decay 0.0005 --average_loss 16 --lr_policy poly --iter_size 8 --snapshot_interval 2000 $TEST_TMP_DIR/trainoutdir" ]
   [ "${lines[1]}" = "Training has completed. Results are stored in $TEST_TMP_DIR/trainoutdir" ]

   export PATH=$A_TEMP_PATH
}

@test "runtraining.sh success --1fmonly and --gpu set" {
   ln -s /bin/true "$TEST_TMP_DIR/CreateTrainJob.m"
   mkdir -p "$TEST_TMP_DIR/trainoutdir"
   ln -s /bin/echo "$TEST_TMP_DIR/trainworker.sh"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNTRAINING_SH --numiterations 50 --1fmonly --gpu 1 trainimages "$TEST_TMP_DIR/trainoutdir"
   [ "$status" -eq 0 ]
   echo "$output" 1>&2
   [ "${lines[0]}" = "--models 1fm --numiterations 50 --gpu 1 --base_learn 1e-02 --power 0.8 --momentum 0.9 --weight_decay 0.0005 --average_loss 16 --lr_policy poly --iter_size 8 --snapshot_interval 2000 $TEST_TMP_DIR/trainoutdir" ]
   [ "${lines[1]}" = "Training has completed. Results are stored in $TEST_TMP_DIR/trainoutdir" ]

   export PATH=$A_TEMP_PATH
}

