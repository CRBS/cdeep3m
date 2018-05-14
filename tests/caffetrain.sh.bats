#!/usr/bin/env bats


setup() {
    export CAFFE_TRAIN_SH="${BATS_TEST_DIRNAME}/../caffetrain.sh"
    export TEST_TMP_DIR="${BATS_TMPDIR}/"`uuidgen`
    /bin/mkdir -p "$TEST_TMP_DIR"
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
    run $CAFFE_TRAIN_SH 1fm "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 2 ] 
    [ "${lines[1]}" = "ERROR trying to update max_iter in $TEST_TMP_DIR/1fm/solver.prototxt" ]
}

@test "caffetrain.sh 1fm verify correctly updated solver.prototxt file no args set" {
    mkdir -p $TEST_TMP_DIR/1fm
    echo "#blah" > $TEST_TMP_DIR/1fm/solver.prototxt
    echo "base_lr: 1" >> $TEST_TMP_DIR/1fm/solver.prototxt 
    echo "power: 2" >> $TEST_TMP_DIR/1fm/solver.prototxt
    echo "momentum: 3.5" >> $TEST_TMP_DIR/1fm/solver.prototxt
    echo "weight_decay: 4.4" >> $TEST_TMP_DIR/1fm/solver.prototxt
    echo "average_loss: 1" >> $TEST_TMP_DIR/1fm/solver.prototxt
    echo "lr_policy: \"foo\"" >> $TEST_TMP_DIR/1fm/solver.prototxt
    echo "iter_size: 23" >> $TEST_TMP_DIR/1fm/solver.prototxt
    echo "snapshot: 3" >> $TEST_TMP_DIR/1fm/solver.prototxt
    echo "max_iter: 4" >> $TEST_TMP_DIR/1fm/solver.prototxt
    echo "solver mode: GPU" >> $TEST_TMP_DIR/1fm/solver.prototxt
   
    touch $TEST_TMP_DIR/1fm/log
    run $CAFFE_TRAIN_SH 1fm "$TEST_TMP_DIR"
    [ "$status" -eq 3 ]
    [ "${lines[1]}" = "ERROR unable to make $TEST_TMP_DIR/1fm/log directory" ]
    run cat $TEST_TMP_DIR/1fm/solver.prototxt
  
    [ "${lines[0]}" = "#blah" ]
    [ "${lines[1]}" = "base_lr: 1e-02" ]
    [ "${lines[2]}" = "power: 0.8" ]
    [ "${lines[3]}" = "momentum: 0.9" ]
    [ "${lines[4]}" = "weight_decay: 0.0005" ]
    [ "${lines[5]}" = "average_loss: 16" ]
    [ "${lines[6]}" = "lr_policy: \"poly\"" ] 
    [ "${lines[7]}" = "iter_size: 8" ]
    [ "${lines[8]}" = "snapshot: 2000" ]
    [ "${lines[9]}" = "max_iter: 30000" ]
    [ "${lines[10]}" = "solver mode: GPU" ]
}

@test "caffetrain.sh 1fm verify correctly updated solver.prototxt file no args set" {
    mkdir -p $TEST_TMP_DIR/1fm
    echo "#blah" > $TEST_TMP_DIR/1fm/solver.prototxt
    echo "base_lr: 1" >> $TEST_TMP_DIR/1fm/solver.prototxt
    echo "power: 2" >> $TEST_TMP_DIR/1fm/solver.prototxt
    echo "momentum: 3.5" >> $TEST_TMP_DIR/1fm/solver.prototxt
    echo "weight_decay: 4.4" >> $TEST_TMP_DIR/1fm/solver.prototxt
    echo "average_loss: 1" >> $TEST_TMP_DIR/1fm/solver.prototxt
    echo "lr_policy: \"foo\"" >> $TEST_TMP_DIR/1fm/solver.prototxt
    echo "iter_size: 23" >> $TEST_TMP_DIR/1fm/solver.prototxt
    echo "snapshot: 3" >> $TEST_TMP_DIR/1fm/solver.prototxt
    echo "max_iter: 4" >> $TEST_TMP_DIR/1fm/solver.prototxt
    echo "solver mode: GPU" >> $TEST_TMP_DIR/1fm/solver.prototxt
    
    touch $TEST_TMP_DIR/1fm/log
    run $CAFFE_TRAIN_SH --base_learn "1e-04" --power 0.2 --momentum 0.3 --weight_decay 0.4 --average_loss 0.5 --lr_policy yo --iter_size 7 --snapshot_interval 8 --numiterations 9 1fm "$TEST_TMP_DIR"
    [ "$status" -eq 3 ]
    [ "${lines[1]}" = "ERROR unable to make $TEST_TMP_DIR/1fm/log directory" ]
    run cat $TEST_TMP_DIR/1fm/solver.prototxt
    
    [ "${lines[0]}" = "#blah" ]
    [ "${lines[1]}" = "base_lr: 1e-04" ]
    [ "${lines[2]}" = "power: 0.2" ]
    [ "${lines[3]}" = "momentum: 0.3" ]
    [ "${lines[4]}" = "weight_decay: 0.4" ]
    [ "${lines[5]}" = "average_loss: 0.5" ]
    [ "${lines[6]}" = "lr_policy: \"yo\"" ]
    [ "${lines[7]}" = "iter_size: 7" ] 
    [ "${lines[8]}" = "snapshot: 8" ]
    [ "${lines[9]}" = "max_iter: 9" ] 
    [ "${lines[10]}" = "solver mode: GPU" ]
}


@test "caffetrain.sh 1fm unable to create log directory" {
    mkdir -p $TEST_TMP_DIR/1fm
    touch $TEST_TMP_DIR/1fm/solver.prototxt
    touch $TEST_TMP_DIR/1fm/log
    run $CAFFE_TRAIN_SH 1fm "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 3 ]
    [ "${lines[1]}" = "ERROR unable to make $TEST_TMP_DIR/1fm/log directory" ]
}

@test "caffetrain.sh 1fm unable to create trainedmodel directory" {
    mkdir -p $TEST_TMP_DIR/1fm
    touch $TEST_TMP_DIR/1fm/solver.prototxt
    touch $TEST_TMP_DIR/1fm/trainedmodel
    run $CAFFE_TRAIN_SH 1fm "$TEST_TMP_DIR"
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
     
    run $CAFFE_TRAIN_SH 1fm "$TEST_TMP_DIR"
    [ "$status" -eq 0 ]
    echo "$status $output" 1>&2
    [ "${lines[0]}" = "" ]
    
    run cat "$TEST_TMP_DIR/1fm/log/out.log"
    echo "$status $output" 1>&2
    [ "${lines[0]}" = "train --solver=${TEST_TMP_DIR}/1fm/solver.prototxt --gpu all" ]

    export PATH=$A_TEMP_PATH
}

# TODO add tests to verify fining last completed iteration works



