#!/usr/bin/env bats

setup() {
    export RUNTRAINING_SH="${BATS_TEST_DIRNAME}/../../runtraining.sh"
    export RUNPREPROC_SH="${BATS_TEST_DIRNAME}/../../PreprocessTrainingData.m"
    export RUNPREDICTION_SH="${BATS_TEST_DIRNAME}/../../runprediction.sh"
    export RUNENSEMBLE="${BATS_TEST_DIRNAME}/../../EnsemblePredictions.m"
    export TEST_TMP_DIR="${BATS_TMPDIR}/"`uuidgen`
    /bin/mkdir -p "$TEST_TMP_DIR"
}

teardown() {
    if [ -d "$TEST_TMP_DIR" ] ; then
        /bin/rm -rf "$TEST_TMP_DIR"
    fi
}

@test "Runs demo 2, train and predict, est time 15 min" {
    run $RUNPREPROC_SH ~/cdeep3m/mito_testsample/training/images ~/cdeep3m/mito_testsample/training/labels "$TEST_TMP_DIR/mito_testaugtrain"
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    run $RUNTRAINING_SH --numiterations 100 "$TEST_TMP_DIR/mito_testaugtrain" "$TEST_TMP_DIR/train_out"
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
}



