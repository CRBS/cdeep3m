#!/usr/bin/env bats


setup() {
    export RUNPREDICTION_SH="${BATS_TEST_DIRNAME}/../runprediction.sh"
    export TEST_TMP_DIR="${BATS_TMPDIR}/"`uuidgen`
    /bin/mkdir -p "$TEST_TMP_DIR"
}

teardown() {
    if [ -d "$TEST_TMP_DIR" ] ; then
        /bin/rm -rf "$TEST_TMP_DIR"
    fi
}

@test "runprediction.sh no args" {
    run $RUNPREDICTION_SH
    [ "$status" -eq 1 ]
    echo "$status $output" 1>&2
    [ "${lines[0]}" = "usage: runprediction.sh [-h] [--models MODELS] [--augspeed AUGSPEED]" ]
}

@test "runprediction.sh invalid --augspeed value" {
    run $RUNPREDICTION_SH --augspeed 0 trainoutdir augimages predictdir
    echo "$status output" 1>&2
    [ "$status" -eq 2 ]
    [ "${lines[0]}" = "ERROR, --augspeed must be one of the following values 1, 2, 4, 10" ]
    run $RUNPREDICTION_SH --augspeed 3 trainoutdir augimages predictdir
    echo "$status output" 1>&2
    [ "$status" -eq 2 ]
    run $RUNPREDICTION_SH --augspeed haha trainoutdir augimages predictdir
    echo "$status output" 1>&2
    [ "$status" -eq 2 ]
}

@test "runprediction.sh valid --augspeed values" {
    #
    # in this test we are assuming the next command after checking
    # --augspeed is valid is the directory check which fails with
    # exit code 3. We expect the mkdir to fail cause there is a file
    # in the way and if we get there then --augspeed value is valid.
    #
    aug_images="$TEST_TMP_DIR/augimages"
    touch "$aug_images"
    run $RUNPREDICTION_SH --augspeed 1 trainoutdir augimages "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 3 ]

    /bin/rm -f "$TEST_TMP_DIR/ERROR"
    run $RUNPREDICTION_SH --augspeed 2 trainoutdir augimages "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 3 ]

    /bin/rm -f "$TEST_TMP_DIR/ERROR"
    run $RUNPREDICTION_SH --augspeed 4 trainoutdir augimages "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 3 ]

    /bin/rm -f "$TEST_TMP_DIR/ERROR"
    run $RUNPREDICTION_SH --augspeed 10 trainoutdir augimages "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 3 ]
}

@test "runprediction.sh mkdir of augimages directory fails" {
    aug_images="$TEST_TMP_DIR/augimages"
    touch "$aug_images"
    run $RUNPREDICTION_SH trainoutdir augimages "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 3 ]
    [ "${lines[1]}" = "ERROR, a non-zero exit code (1) was received from: mkdir -p \"$aug_images\"" ]
}

@test "runprediction.sh DefDataPackages.m fails" {
    ln -s /bin/false "$TEST_TMP_DIR/DefDataPackages.m"
    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH
    run $RUNPREDICTION_SH trainoutdir augimages $TEST_TMP_DIR/predictout
    echo "$status $output" 1>&2
    [ "$status" -eq 4 ]
    [ "${lines[0]}" = "ERROR, a non-zero exit code (1) was received from: DefDataPackages.m \"augimages\" \"$TEST_TMP_DIR/predictout/augimages\"" ]
}

@test "runprediction.sh copy of de_augmentation_info.mat fails" {
    ln -s /bin/true "$TEST_TMP_DIR/DefDataPackages.m"
    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH
    run $RUNPREDICTION_SH trainoutdir augimages $TEST_TMP_DIR/predictout
    echo "$status $output" 1>&2
    [ "$status" -eq 8 ]
    [ "${lines[1]}" = "ERROR unable to copy $TEST_TMP_DIR/predictout/augimages/de_augmentation_info.mat to $TEST_TMP_DIR/predictout" ]
}

@test "runprediction.sh copy of package_processing_info.txt fails" {
    ln -s /bin/true "$TEST_TMP_DIR/DefDataPackages.m"
    mkdir -p "$TEST_TMP_DIR/predictout/augimages"
    touch "$TEST_TMP_DIR/predictout/augimages/de_augmentation_info.mat"
    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH
    run $RUNPREDICTION_SH trainoutdir augimages $TEST_TMP_DIR/predictout
    echo "$status $output" 1>&2
    [ "$status" -eq 9 ]
    [ "${lines[1]}" = "ERROR unable to copy $TEST_TMP_DIR/predictout/augimages/package_processing_info.txt to $TEST_TMP_DIR/predictout" ]
}

@test "runprediction.sh verify correct input to DefDataPakcages.m" {
    ln -s /bin/echo "$TEST_TMP_DIR/DefDataPackages.m"
    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH
    run $RUNPREDICTION_SH trainoutdir augimages $TEST_TMP_DIR/predictout
    echo "$status $output" 1>&2
    [ "$status" -eq 8 ]
    [ "${lines[0]}" = "augimages $TEST_TMP_DIR/predictout/augimages" ]
    export PATH=$A_TEMP_PATH
}

@test "runprediction.sh DONE file found no work to do" {
    mkdir -p "$TEST_TMP_DIR/predictout"
    touch "$TEST_TMP_DIR/predictout/DONE"
    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH
    run $RUNPREDICTION_SH trainoutdir augimages $TEST_TMP_DIR/predictout
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" == "DONE file found in $TEST_TMP_DIR/predictout. Appears no work needs to be done." ]
}

@test "runprediction.sh ERROR file found" {
    mkdir -p "$TEST_TMP_DIR/predictout"
    touch "$TEST_TMP_DIR/predictout/ERROR"
    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH
    run $RUNPREDICTION_SH trainoutdir augimages $TEST_TMP_DIR/predictout
    echo "$status $output" 1>&2
    [ "$status" -eq 99 ]
    [ "${lines[0]}" == "$TEST_TMP_DIR/predictout/ERROR file found. Something failed. Exiting..." ]
}

@test "runprediction.sh EnsemblePredictions.m fails" {
    ln -s /bin/true "$TEST_TMP_DIR/DefDataPackages.m"
    ln -s /bin/true "$TEST_TMP_DIR/preprocessworker.sh"
    ln -s /bin/true "$TEST_TMP_DIR/predictworker.sh"
    ln -s /bin/true "$TEST_TMP_DIR/postprocessworker.sh"
    ln -s /bin/false "$TEST_TMP_DIR/EnsemblePredictions.m"
    mkdir -p "$TEST_TMP_DIR/predictoutdir/augimages"
    touch "$TEST_TMP_DIR/predictoutdir/augimages/de_augmentation_info.mat"
    touch "$TEST_TMP_DIR/predictoutdir/augimages/package_processing_info.txt"

    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH
    run $RUNPREDICTION_SH trainoutdir augimages "$TEST_TMP_DIR/predictoutdir"
    echo "$status $output" 1>&2
    [ "$status" -eq 12 ]
    [ "${lines[0]}" = "Start up worker to generate packages to process" ]
    [ "${lines[1]}" = "Start up worker to run prediction on packages" ]
    [ "${lines[2]}" = "Start up worker to run post processing on packages" ]
   
    run cat "$TEST_TMP_DIR/predictoutdir/ERROR"
    [ "$status" -eq 0 ]
    echo "$status $output" 1>&2
    [ "${lines[0]}" == "ERROR, a non-zero exit code (1) was received from: EnsemblePredictions.m  $TEST_TMP_DIR/predictoutdir/1fm $TEST_TMP_DIR/predictoutdir/3fm $TEST_TMP_DIR/predictoutdir/5fm $TEST_TMP_DIR/predictoutdir/ensembled" ] 

}

@test "runprediction.sh success --maxpackages set to 5" {
    ln -s /bin/true "$TEST_TMP_DIR/DefDataPackages.m"
    ln -s /bin/echo "$TEST_TMP_DIR/preprocessworker.sh"
    ln -s /bin/echo "$TEST_TMP_DIR/predictworker.sh"
    ln -s /bin/echo "$TEST_TMP_DIR/postprocessworker.sh"
    ln -s /bin/echo "$TEST_TMP_DIR/EnsemblePredictions.m"
    mkdir -p "$TEST_TMP_DIR/predictoutdir/augimages"
    touch "$TEST_TMP_DIR/predictoutdir/augimages/de_augmentation_info.mat"
    touch "$TEST_TMP_DIR/predictoutdir/augimages/package_processing_info.txt"

    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH
    run $RUNPREDICTION_SH --maxpackages 5 trainoutdir augimages "$TEST_TMP_DIR/predictoutdir"
    echo "$output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Start up worker to generate packages to process" ]
    [ "${lines[1]}" = "Start up worker to run prediction on packages" ]
    [ "${lines[2]}" = "Start up worker to run post processing on packages" ]

    run cat "$TEST_TMP_DIR/predictoutdir/logs/preprocess.log"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" == "--maxpackages 5 $TEST_TMP_DIR/predictoutdir" ]

    export PATH=$A_TEMP_PATH
}


@test "runprediction.sh success" {
    ln -s /bin/true "$TEST_TMP_DIR/DefDataPackages.m"
    ln -s /bin/echo "$TEST_TMP_DIR/preprocessworker.sh"
    ln -s /bin/echo "$TEST_TMP_DIR/predictworker.sh"
    ln -s /bin/echo "$TEST_TMP_DIR/postprocessworker.sh"
    ln -s /bin/echo "$TEST_TMP_DIR/EnsemblePredictions.m"
    mkdir -p "$TEST_TMP_DIR/predictoutdir/augimages"
    
    export p_outdir="$TEST_TMP_DIR/predictoutdir"
    mkdir -p "$p_outdir/1fm"
    touch "$p_outdir/1fm/Segmented_0001.png"
 
    mkdir -p "$p_outdir/3fm"
    touch "$p_outdir/3fm/Segmented_0001.png"
     
    mkdir -p "$p_outdir/5fm"
    touch "$p_outdir/5fm/Segmented_0001.png"
    
    touch "$TEST_TMP_DIR/predictoutdir/augimages/de_augmentation_info.mat"
    touch "$TEST_TMP_DIR/predictoutdir/augimages/package_processing_info.txt"

    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH
    run $RUNPREDICTION_SH trainoutdir augimages "$p_outdir"
    echo "$output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Start up worker to generate packages to process" ]
    [ "${lines[1]}" = "Start up worker to run prediction on packages" ]
    [ "${lines[2]}" = "Start up worker to run post processing on packages" ]
    
    [ -f "$p_outdir/1fm/Segmented_0001.png" ]
    [ -f "$p_outdir/3fm/Segmented_0001.png" ]
    [ -f "$p_outdir/5fm/Segmented_0001.png" ]
    
    run cat "$TEST_TMP_DIR/predictoutdir/predict.config"
    echo "$output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "[default]" ]
    [ "${lines[1]}" = "trainedmodeldir=trainoutdir" ] 
    [ "${lines[2]}" = "imagedir=augimages" ]
    [ "${lines[3]}" = "models=1fm,3fm,5fm" ]
    [ "${lines[4]}" = "augspeed=1" ]

    run cat "$TEST_TMP_DIR/predictoutdir/logs/preprocess.log"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" == "--maxpackages 3 $TEST_TMP_DIR/predictoutdir" ]

    run cat "$TEST_TMP_DIR/predictoutdir/logs/prediction.log"
    [ "$status" -eq 0 ]
    cat "$TEST_TMP_DIR/predictoutdir/logs/prediction.log" 1>&2
    [ "${lines[0]}" == "--gpu all $TEST_TMP_DIR/predictoutdir" ]

    run cat "$TEST_TMP_DIR/predictoutdir/logs/postprocess.log"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" == "$TEST_TMP_DIR/predictoutdir" ]

    export PATH=$A_TEMP_PATH
}

@test "runprediction.sh success --gpu 4 --models and --augspeed set and only 1 model" {
    ln -s /bin/true "$TEST_TMP_DIR/DefDataPackages.m"
    ln -s /bin/true "$TEST_TMP_DIR/preprocessworker.sh"
    ln -s /bin/echo "$TEST_TMP_DIR/predictworker.sh"
    ln -s /bin/true "$TEST_TMP_DIR/postprocessworker.sh"
    # setting EnsemblePredictions.m to false so the test
    # verifies its not being called cause there is only a single
    # model.
    ln -s /bin/false "$TEST_TMP_DIR/EnsemblePredictions.m"
    mkdir -p "$TEST_TMP_DIR/predictoutdir/augimages"
    touch "$TEST_TMP_DIR/predictoutdir/augimages/de_augmentation_info.mat"
    touch "$TEST_TMP_DIR/predictoutdir/augimages/package_processing_info.txt"
 
    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH
    run $RUNPREDICTION_SH --models 1fm --augspeed 4 --gpu 4 trainoutdir augimages "$TEST_TMP_DIR/predictoutdir"
    echo "$output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Start up worker to generate packages to process" ]
    [ "${lines[1]}" = "Start up worker to run prediction on packages" ]
    [ "${lines[2]}" = "Start up worker to run post processing on packages" ]
    [ "${lines[5]}" = "Prediction has completed. Results are stored in $TEST_TMP_DIR/predictoutdir/ensembled" ]
    run cat "$TEST_TMP_DIR/predictoutdir/predict.config"
    echo "$output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "[default]" ]
    [ "${lines[1]}" = "trainedmodeldir=trainoutdir" ]
    [ "${lines[2]}" = "imagedir=augimages" ]
    [ "${lines[3]}" = "models=1fm" ]
    [ "${lines[4]}" = "augspeed=4" ]

    run cat "$TEST_TMP_DIR/predictoutdir/logs/prediction.log"
    [ "$status" -eq 0 ]
    cat "$TEST_TMP_DIR/predictoutdir/logs/prediction.log" 1>&2
    [ "${lines[0]}" == "--gpu 4 $TEST_TMP_DIR/predictoutdir" ]

    
    export PATH=$A_TEMP_PATH
}


