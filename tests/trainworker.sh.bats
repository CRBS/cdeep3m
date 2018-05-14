#!/usr/bin/env bats


setup() {
    export TRAIN_WORKER_SH="${BATS_TEST_DIRNAME}/../trainworker.sh"
    export TEST_TMP_DIR="${BATS_TMPDIR}/"`uuidgen`
    /bin/mkdir -p "$TEST_TMP_DIR"
}

teardown() {
    if [ -d "$TEST_TMP_DIR" ] ; then
        /bin/rm -rf "$TEST_TMP_DIR"
    fi
}

@test "trainworker.sh no args" {
    run $TRAIN_WORKER_SH
    echo "$status $output" 2>&1
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "usage: trainworker.sh [-h] [--models MODELS]" ]


}

@test "trainworker.sh unable to get count of GPUs" {
    touch "$TEST_TMP_DIR/foo.caffemodel"
    ln -s /bin/false "$TEST_TMP_DIR/nvidia-smi"
    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH
    run $TRAIN_WORKER_SH "$TEST_TMP_DIR"
    export PATH=$A_TEMP_PATH
    echo "$status:: $output" 2>&1
    [ "$status" -eq 4 ]
    [ "${lines[0]}" = "ERROR unable to get count of GPU(s). Is nvidia-smi working?" ]
}

@test "trainworker.sh no args empty dir" {
    echo "#!/bin/bash" > "$TEST_TMP_DIR/nvidia-smi"
    echo "echo 'GPU 0'" >> "$TEST_TMP_DIR/nvidia-smi"
    chmod a+x "$TEST_TMP_DIR/nvidia-smi"
    ln -s /bin/echo "$TEST_TMP_DIR/parallel"
    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH
    run $TRAIN_WORKER_SH "$TEST_TMP_DIR"
    export PATH=$A_TEMP_PATH
    echo "$status: $output" 1>&2
    [ "$status" -eq 2 ]
    [ "${lines[0]}" = "Single GPU detected." ]
    [ "${lines[1]}" = "ERROR, no $TEST_TMP_DIR/1fm directory found." ]
}

@test "trainworker.sh success no args with 4 GPUs" {
    ln -s /bin/echo "$TEST_TMP_DIR/caffetrain.sh"
    mkdir -p "$TEST_TMP_DIR/1fm" "$TEST_TMP_DIR/3fm" "$TEST_TMP_DIR/5fm"
    echo "echo -e 'GPU 0\nGPU 1\nGPU 2\nGPU 3'" >> "$TEST_TMP_DIR/nvidia-smi"
    chmod a+x "$TEST_TMP_DIR/nvidia-smi"
    ln -s /bin/echo "$TEST_TMP_DIR/parallel"

    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH
    run $TRAIN_WORKER_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Detected 4 GPU(s). Will run in parallel." ]
    [ "${lines[1]}" = "--no-notice --delay 2 -N 12 -j 4 caffetrain.sh --numiterations {1} --gpu {2} --base_learn {3} --power {4} --momentum {5} --weight_decay {6} --average_loss {7} --lr_policy {8} --iter_size {9} --snapshot_interval {10} {11} {12}" ]    
    [ "${lines[2]}" = "Training has completed. Have a nice day!" ]
    export PATH=$A_TEMP_PATH
    run cat "$TEST_TMP_DIR/parallel.jobs"
    echo "$status $output" 1>&2
    [ "${lines[0]}" = "30000" ]
    [ "${lines[1]}" = "0" ]
    [ "${lines[2]}" = "1e-02" ]
    [ "${lines[3]}" = "0.8" ]
    [ "${lines[4]}" = "0.9" ]
    [ "${lines[5]}" = "0.0005" ]
    [ "${lines[6]}" = "16" ]
    [ "${lines[7]}" = "poly" ]
    [ "${lines[8]}" = "8" ]
    [ "${lines[9]}" = "2000" ]
    [ "${lines[10]}" = "1fm" ]
    [ "${lines[11]}" = "$TEST_TMP_DIR" ]
    [ "${lines[13]}" = "1" ]
    [ "${lines[22]}" = "3fm" ]
    [ "${lines[25]}" = "2" ]
    [ "${lines[34]}" = "5fm" ]

}

@test "trainworker.sh success no args with 1 GPU" {
    ln -s /bin/echo "$TEST_TMP_DIR/caffetrain.sh"
    mkdir -p "$TEST_TMP_DIR/1fm" "$TEST_TMP_DIR/3fm" "$TEST_TMP_DIR/5fm"
    echo "echo 'GPU 0'" >> "$TEST_TMP_DIR/nvidia-smi"
    chmod a+x "$TEST_TMP_DIR/nvidia-smi"
    ln -s /bin/echo "$TEST_TMP_DIR/parallel"

    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH
    run $TRAIN_WORKER_SH "$TEST_TMP_DIR"
    export PATH=$A_TEMP_PATH
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Single GPU detected." ]
    [ "${lines[1]}" = "--no-notice --delay 2 -N 12 -j 1 caffetrain.sh --numiterations {1} --gpu {2} --base_learn {3} --power {4} --momentum {5} --weight_decay {6} --average_loss {7} --lr_policy {8} --iter_size {9} --snapshot_interval {10} {11} {12}" ]
    [ "${lines[2]}" = "Training has completed. Have a nice day!" ]
    run cat "$TEST_TMP_DIR/parallel.jobs"
    echo "$status $output" 1>&2
    [ "${lines[1]}" = "0" ]
    [ "${lines[10]}" = "1fm" ]
    [ "${lines[13]}" = "0" ]
    [ "${lines[22]}" = "3fm" ]
    [ "${lines[25]}" = "0" ]
    [ "${lines[34]}" = "5fm" ]
}

@test "trainworker.sh test custom parameters" {
    ln -s /bin/echo "$TEST_TMP_DIR/caffetrain.sh"
    mkdir -p "$TEST_TMP_DIR/1fm" "$TEST_TMP_DIR/3fm" "$TEST_TMP_DIR/5fm"
    echo "echo -e 'GPU 0\nGPU 1\nGPU 2\nGPU 3'" >> "$TEST_TMP_DIR/nvidia-smi"
    chmod a+x "$TEST_TMP_DIR/nvidia-smi"
    ln -s /bin/echo "$TEST_TMP_DIR/parallel"

    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH
    run $TRAIN_WORKER_SH --models 3fm,5fm --base_learn base --power power --momentum momentum --weight_decay weight --average_loss average --lr_policy lr --iter_size iter --snapshot_interval snapshot --numiterations numiterations "$TEST_TMP_DIR"
    export PATH=$A_TEMP_PATH
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Detected 4 GPU(s). Will run in parallel." ]
    [ "${lines[1]}" = "--no-notice --delay 2 -N 12 -j 4 caffetrain.sh --numiterations {1} --gpu {2} --base_learn {3} --power {4} --momentum {5} --weight_decay {6} --average_loss {7} --lr_policy {8} --iter_size {9} --snapshot_interval {10} {11} {12}" ]
    [ "${lines[2]}" = "Training has completed. Have a nice day!" ]
    run cat "$TEST_TMP_DIR/parallel.jobs"
    echo "$status $output" 1>&2
    [ "${lines[0]}" = "numiterations" ]
    [ "${lines[1]}" = "0" ]
    [ "${lines[2]}" = "base" ]
    [ "${lines[3]}" = "power" ]
    [ "${lines[4]}" = "momentum" ]
    [ "${lines[5]}" = "weight" ]
    [ "${lines[6]}" = "average" ]
    [ "${lines[7]}" = "lr" ]
    [ "${lines[8]}" = "iter" ]
    [ "${lines[9]}" = "snapshot" ]
    [ "${lines[10]}" = "3fm" ]
    [ "${lines[13]}" = "1" ]
    [ "${lines[22]}" = "5fm" ]
}

@test "trainworker.sh fail no args" {
    ln -s /bin/echo "$TEST_TMP_DIR/caffetrain.sh"
    mkdir -p "$TEST_TMP_DIR/1fm" "$TEST_TMP_DIR/3fm" "$TEST_TMP_DIR/5fm"
    echo "echo 'GPU 0'" >> "$TEST_TMP_DIR/nvidia-smi"
    chmod a+x "$TEST_TMP_DIR/nvidia-smi"
    ln -s /bin/false "$TEST_TMP_DIR/parallel"

    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH
    run $TRAIN_WORKER_SH "$TEST_TMP_DIR"
    export PATH=$A_TEMP_PATH
    echo "$status $output" 1>&2
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "Single GPU detected." ]
    [ "${lines[1]}" = "Non zero exit code from caffe for train of model. Exiting." ]
}

