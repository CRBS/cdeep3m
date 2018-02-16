#!/usr/bin/env bats


setup() {
    export CAFFE_TRAIN_TEMPLATE_SH="${BATS_TEST_DIRNAME}/../scripts/caffetrain_template.sh"
    export TEST_TMP_DIR="${BATS_TMPDIR}/"`uuidgen`
    /bin/mkdir -p "$TEST_TMP_DIR"
    export CAFFE_TRAIN_SH="$TEST_TMP_DIR/caffetrain.sh"
   /bin/cp "$CAFFE_TRAIN_TEMPLATE_SH" "$CAFFE_TRAIN_SH"
}

teardown() {
    if [ -d "$TEST_TMP_DIR" ] ; then
        /bin/rm -rf "$TEST_TMP_DIR"
    fi
}

@test "caffetrain.sh no args empty dir" {
    run $CAFFE_TRAIN_SH
    echo "$status $output" 1>&2
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "usage: caffetrain.sh [-h] [--numiterations NUMITERATIONS] [--gpu GPU]" ]
}

@test "caffetrain.sh 1fm no 1fm/solver.prototxt file" {
    run $CAFFE_TRAIN_SH 1fm
    echo "$status $output" 1>&2
    [ "$status" -eq 2 ] 
    [ "${lines[1]}" = "ERROR trying to update max_iter in $TEST_TMP_DIR/1fm/solver.prototxt" ]
}

@test "caffetrain.sh 1fm verify correctly updated solver.prototxt file" {
    mkdir -p $TEST_TMP_DIR/1fm
    echo "#blah" > $TEST_TMP_DIR/1fm/solver.prototxt
    echo "power: 0.8" >> $TEST_TMP_DIR/1fm/solver.prototxt
    echo "snapshot: 2000" >> $TEST_TMP_DIR/1fm/solver.prototxt
    echo "max_iter: 50000" >> $TEST_TMP_DIR/1fm/solver.prototxt
    echo "solver mode: GPU" >> $TEST_TMP_DIR/1fm/solver.prototxt
    touch $TEST_TMP_DIR/1fm/log
    run $CAFFE_TRAIN_SH --numiterations 24 1fm
    [ "$status" -eq 3 ]
    [ "${lines[1]}" = "ERROR unable to make $TEST_TMP_DIR/1fm/log directory" ]
    run cat $TEST_TMP_DIR/1fm/solver.prototxt
  
    [ "${lines[0]}" = "#blah" ]
    [ "${lines[1]}" = "power: 0.8" ]
    [ "${lines[2]}" = "snapshot: 2000" ]
    [ "${lines[3]}" = "max_iter: 24" ]
    [ "${lines[4]}" = "solver mode: GPU" ]

}

@test "caffetrain.sh 1fm unable to create log directory" {
    mkdir -p $TEST_TMP_DIR/1fm
    touch $TEST_TMP_DIR/1fm/solver.prototxt
    touch $TEST_TMP_DIR/1fm/log
    run $CAFFE_TRAIN_SH 1fm 
    echo "$status $output" 1>&2
    [ "$status" -eq 3 ]
    [ "${lines[1]}" = "ERROR unable to make $TEST_TMP_DIR/1fm/log directory" ]
}

@test "caffetrain.sh 1fm unable to create trainedmodel directory" {
    mkdir -p $TEST_TMP_DIR/1fm
    touch $TEST_TMP_DIR/1fm/solver.prototxt
    touch $TEST_TMP_DIR/1fm/trainedmodel
    run $CAFFE_TRAIN_SH 1fm
    echo "$status $output" 1>&2
    [ "$status" -eq 4 ]
    [ "${lines[1]}" = "ERROR unable to make $TEST_TMP_DIR/1fm/trainedmodel directory" ]
}

@test "caffetrain.sh 1fm success" {
    mkdir -p $TEST_TMP_DIR/1fm
    touch $TEST_TMP_DIR/1fm/solver.prototxt
    ln -s /bin/echo $TEST_TMP_DIR/caffe.bin 
    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH
     
    run $CAFFE_TRAIN_SH 1fm
    [ "$status" -eq 0 ]
    echo "$status $output" 1>&2
    [ "${lines[0]}" = "" ]
    
    run cat "$TEST_TMP_DIR/1fm/log/out.log"
    echo "$status $output" 1>&2
    [ "${lines[0]}" = "train --solver=${TEST_TMP_DIR}/1fm/solver.prototxt --gpu all" ]

    export PATH=$A_TEMP_PATH
}

# TODO add tests to verify fining last completed iteration works



