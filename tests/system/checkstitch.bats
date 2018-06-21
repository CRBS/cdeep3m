#!/usr/bin/env bats

setup() {
    export RUNPREDICTION_SH="${BATS_TEST_DIRNAME}/../../runprediction.sh"
    export TEST_TMP_DIR="${BATS_TMPDIR}/"`uuidgen`
    /bin/mkdir -p "$TEST_TMP_DIR"
    export TEST_DATA_DIR="${BATS_TEST_DIRNAME}/testdata" 
}

teardown() {
    if [ -d "$TEST_TMP_DIR" ] ; then
        /bin/rm -rf "$TEST_TMP_DIR"
    fi
}

@test "Runs demo 1, predict on pretrained model against 5 2k x 2k images 30min" {

    imgdir="$TEST_TMP_DIR/myimages"
    mkdir -p "$imgdir"
    for Y in `seq 1 5` ; do 
        cp "$TEST_DATA_DIR/2kimage/images.081.mirrored.png" "$imgdir/$Y.png"
    done
    run $RUNPREDICTION_SH ~/sbem/mitochrondria/xy5.9nm40nmz/30000iterations_train_out "$imgdir" "$TEST_TMP_DIR/job"
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ -s "$TEST_TMP_DIR/job/ensembled/Segmented_0001.png" ]
    [ -s "$TEST_TMP_DIR/job/ensembled/Segmented_0002.png" ]
    [ -s "$TEST_TMP_DIR/job/ensembled/Segmented_0003.png" ]
    [ -s "$TEST_TMP_DIR/job/ensembled/Segmented_0004.png" ]
    [ -s "$TEST_TMP_DIR/job/ensembled/Segmented_0005.png" ]
}



