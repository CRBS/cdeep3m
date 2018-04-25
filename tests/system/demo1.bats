#!/usr/bin/env bats

setup() {
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

@test "Runs demo 1, predict on pretrained model, est time 15 min" {
    run $RUNPREDICTION_SH ~/sbem/mitochrondria/xy5.9nm40nmz/30000iterations_train_out ~/cdeep3m/mito_testsample/testset/ "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    run $RUNENSEMBLE "$TEST_TMP_DIR/1fm" "$TEST_TMP_DIR/3fm" "$TEST_TMP_DIR/5fm" "$TEST_TMP_DIR/out"
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ -s "$TEST_TMP_DIR/out/Segmented_0001.png" ]
    [ -s "$TEST_TMP_DIR/out/Segmented_0002.png" ]
    [ -s "$TEST_TMP_DIR/out/Segmented_0003.png" ]
    [ -s "$TEST_TMP_DIR/out/Segmented_0004.png" ]
    [ -s "$TEST_TMP_DIR/out/Segmented_0005.png" ]
}



