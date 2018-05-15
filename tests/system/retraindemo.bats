#!/usr/bin/env bats

setup() {
    export RUNTRAINING_SH="${BATS_TEST_DIRNAME}/../../runtraining.sh"
    export RUNPREPROC_SH="${BATS_TEST_DIRNAME}/../../PreprocessTrainingData.m"
    export RUNPREDICTION_SH="${BATS_TEST_DIRNAME}/../../runprediction.sh"
    export TEST_TMP_DIR="${BATS_TMPDIR}/"`uuidgen`
    /bin/mkdir -p "$TEST_TMP_DIR"
}

teardown() {
    if [ -d "$TEST_TMP_DIR" ] ; then
        /bin/rm -rf "$TEST_TMP_DIR"
    fi
}

@test "Runs a retrain and then prediction" {
    run $RUNPREPROC_SH ~/cdeep3m/mito_testsample/training/images ~/cdeep3m/mito_testsample/training/labels "$TEST_TMP_DIR/mito_testaugtrain"
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    run $RUNTRAINING_SH --retrain ~/sbem/mitochrondria/xy5.9nm40nmz/30000iterations_train_out --additerations 50 "$TEST_TMP_DIR/mito_testaugtrain" "$TEST_TMP_DIR/train_out"
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]

    run $RUNPREDICTION_SH "$TEST_TMP_DIR/train_out" ~/cdeep3m/mito_testsample/testset/ "$TEST_TMP_DIR/predictout"
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ] 

    [ -s "$TEST_TMP_DIR/predictout/ensembled/Segmented_0001.png" ]
    [ -s "$TEST_TMP_DIR/predictout/ensembled/Segmented_0002.png" ]
    [ -s "$TEST_TMP_DIR/predictout/ensembled/Segmented_0003.png" ]
    [ -s "$TEST_TMP_DIR/predictout/ensembled/Segmented_0004.png" ]
    [ -s "$TEST_TMP_DIR/predictout/ensembled/Segmented_0005.png" ]
    
}



