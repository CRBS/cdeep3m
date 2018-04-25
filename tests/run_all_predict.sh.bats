#!/usr/bin/env bats


setup() {
    export RUN_ALL_PREDICT_SH="${BATS_TEST_DIRNAME}/../run_all_predict.sh"
    export TEST_TMP_DIR="${BATS_TMPDIR}/"`uuidgen`
    /bin/mkdir -p "$TEST_TMP_DIR"
}

teardown() {
    if [ -d "$TEST_TMP_DIR" ] ; then
        /bin/rm -rf "$TEST_TMP_DIR"
    fi
}

@test "run_all_predict.sh no args" {
    run $RUN_ALL_PREDICT_SH
    echo "$status $output" 1>&2
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "usage: run_all_predict.sh [-h]" ]
}

@test "run_all_predict.sh no predict.config file" {
    run $RUN_ALL_PREDICT_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 2 ]
    [ "${lines[0]}" = "ERROR no $TEST_TMP_DIR/predict.config file found" ]
}

@test "run_all_predict.sh no trainedmodeldir in predict.config file" {
    echo "hi" > "$TEST_TMP_DIR/predict.config"
    run $RUN_ALL_PREDICT_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 3 ]
    [ "${lines[0]}" = "ERROR unable to extract trainedmodeldir from $TEST_TMP_DIR/predict.config" ]
}

@test "run_all_predict.sh no imagedir in predict.config file" {
    echo "trainedmodeldir=traindir" > "$TEST_TMP_DIR/predict.config"
    run $RUN_ALL_PREDICT_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 4 ]
    [ "${lines[0]}" = "ERROR unable to extract imagedir from $TEST_TMP_DIR/predict.config" ]
}

@test "run_all_predict.sh no models in predict.config file" {
    echo "trainedmodeldir=traindir" > "$TEST_TMP_DIR/predict.config"
    echo "imagedir=imgdir" >> "$TEST_TMP_DIR/predict.config"
    run $RUN_ALL_PREDICT_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 5 ]
    [ "${lines[0]}" = "ERROR unable to extract models from $TEST_TMP_DIR/predict.config" ]
}

@test "run_all_predict.sh no augspeed in predict.config file" {
    echo "trainedmodeldir=traindir" > "$TEST_TMP_DIR/predict.config"
    echo "imagedir=imgdir" >> "$TEST_TMP_DIR/predict.config"
    echo "models=1fm,3fm" >> "$TEST_TMP_DIR/predict.config"
    run $RUN_ALL_PREDICT_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 6 ]
    [ "${lines[0]}" = "ERROR unable to extract augspeed from $TEST_TMP_DIR/predict.config" ]
}

@test "run_all_predict.sh no package_processing_info.txt file in images" {
    echo "trainedmodeldir=traindir" > "$TEST_TMP_DIR/predict.config"
    echo "imagedir=imgdir" >> "$TEST_TMP_DIR/predict.config"
    echo "models=1fm,3fm" >> "$TEST_TMP_DIR/predict.config"
    echo "augspeed=4" >> "$TEST_TMP_DIR/predict.config"
    run $RUN_ALL_PREDICT_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 7 ]
    [ "${lines[0]}" = "Running Prediction" ]
    [ "${lines[1]}" = "Trained Model Dir: traindir" ]
    [ "${lines[2]}" = "Image Dir: imgdir" ]
    [ "${lines[3]}" = "Models: 1fm,3fm" ]
    [ "${lines[4]}" = "Speed: 4" ]
    [ "${lines[5]}" = "ERROR $TEST_TMP_DIR/augimages/package_processing_info.txt not found" ]
}

@test "run_all_predict.sh no de_augmentation_info.mat file" {
    echo "trainedmodeldir=traindir" > "$TEST_TMP_DIR/predict.config"
    echo "imagedir=imgdir" >> "$TEST_TMP_DIR/predict.config"
    echo "models=1fm,3fm" >> "$TEST_TMP_DIR/predict.config"
    echo "augspeed=4" >> "$TEST_TMP_DIR/predict.config"
    mkdir -p "$TEST_TMP_DIR/augimages"
    echo "foo" > "$TEST_TMP_DIR/augimages/package_processing_info.txt"
    run $RUN_ALL_PREDICT_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 8 ]
    [ "${lines[6]}" = "ERROR unable to copy $TEST_TMP_DIR/augimages/de_augmentation_info.mat to $TEST_TMP_DIR" ]
}

@test "run_all_predict.sh unable to copy package_processing_info.txt file" {
    echo "trainedmodeldir=traindir" > "$TEST_TMP_DIR/predict.config"
    echo "imagedir=imgdir" >> "$TEST_TMP_DIR/predict.config"
    echo "models=1fm,3fm" >> "$TEST_TMP_DIR/predict.config"
    echo "augspeed=4" >> "$TEST_TMP_DIR/predict.config"
    mkdir -p "$TEST_TMP_DIR/augimages"
    mkdir -p "$TEST_TMP_DIR/package_processing_info.txt"
    echo "foo" > "$TEST_TMP_DIR/augimages/de_augmentation_info.mat"
    echo "foo" > "$TEST_TMP_DIR/augimages/package_processing_info.txt"
    run $RUN_ALL_PREDICT_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 9 ]
    [ "${lines[6]}" = "ERROR unable to copy $TEST_TMP_DIR/augimages/package_processing_info.txt to $TEST_TMP_DIR" ]
}

@test "run_all_predict.sh ProprocessPackage.m fails" {
    ln -s /bin/echo "$TEST_TMP_DIR/caffepredict.sh"
    ln -s /bin/echo "$TEST_TMP_DIR/Merge_LargeData.m"
    ln -s /bin/false "$TEST_TMP_DIR/PreprocessPackage.m"
    echo "trainedmodeldir=traindir" > "$TEST_TMP_DIR/predict.config"
    echo "imagedir=imgdir" >> "$TEST_TMP_DIR/predict.config"
    echo "models=1fm,3fm,5fm" >> "$TEST_TMP_DIR/predict.config"
    echo "augspeed=4" >> "$TEST_TMP_DIR/predict.config"
    mkdir -p "$TEST_TMP_DIR/augimages"
    echo "foo" > "$TEST_TMP_DIR/augimages/de_augmentation_info.mat"
    echo -e "\nNumber of XY Packages\n1\nNumber of z-blocks\n1" > "$TEST_TMP_DIR/augimages/package_processing_info.txt"
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg001_Z01" "$TEST_TMP_DIR/3fm/Pkg001_Z01" "$TEST_TMP_DIR/5fm/Pkg001_Z01"

    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH

    run $RUN_ALL_PREDICT_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 10 ]
    export PATH=$A_TEMP_PATH
}

@test "run_all_predict.sh Merge_LargeData.m fails" {
    ln -s /bin/echo "$TEST_TMP_DIR/caffepredict.sh"
    ln -s /bin/false "$TEST_TMP_DIR/Merge_LargeData.m"
    ln -s /bin/true "$TEST_TMP_DIR/PreprocessPackage.m"
    echo "trainedmodeldir=traindir" > "$TEST_TMP_DIR/predict.config"
    echo "imagedir=imgdir" >> "$TEST_TMP_DIR/predict.config"
    echo "models=1fm,3fm,5fm" >> "$TEST_TMP_DIR/predict.config"
    echo "augspeed=4" >> "$TEST_TMP_DIR/predict.config"
    mkdir -p "$TEST_TMP_DIR/augimages"
    echo "foo" > "$TEST_TMP_DIR/augimages/de_augmentation_info.mat"
    echo -e "\nNumber of XY Packages\n1\nNumber of z-blocks\n1" > "$TEST_TMP_DIR/augimages/package_processing_info.txt"
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg001_Z01" "$TEST_TMP_DIR/3fm/Pkg001_Z01" "$TEST_TMP_DIR/5fm/Pkg001_Z01"

    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH

    run $RUN_ALL_PREDICT_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 12 ]
    export PATH=$A_TEMP_PATH
}

@test "run_all_predict.sh caffepredict.sh fails" {
    ln -s /bin/false "$TEST_TMP_DIR/caffepredict.sh"
    ln -s /bin/true "$TEST_TMP_DIR/Merge_LargeData.m"
    ln -s /bin/true "$TEST_TMP_DIR/PreprocessPackage.m"
    echo "trainedmodeldir=traindir" > "$TEST_TMP_DIR/predict.config"
    echo "imagedir=imgdir" >> "$TEST_TMP_DIR/predict.config"
    echo "models=1fm,3fm,5fm" >> "$TEST_TMP_DIR/predict.config"
    echo "augspeed=4" >> "$TEST_TMP_DIR/predict.config"
    mkdir -p "$TEST_TMP_DIR/augimages"
    echo "foo" > "$TEST_TMP_DIR/augimages/de_augmentation_info.mat"
    echo -e "\nNumber of XY Packages\n1\nNumber of z-blocks\n1" > "$TEST_TMP_DIR/augimages/package_processing_info.txt"
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg001_Z01" "$TEST_TMP_DIR/3fm/Pkg001_Z01" "$TEST_TMP_DIR/5fm/Pkg001_Z01"
    
    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH

    run $RUN_ALL_PREDICT_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 11 ]
    export PATH=$A_TEMP_PATH
}

@test "run_all_predict.sh no work to do" {
    ln -s /bin/echo "$TEST_TMP_DIR/caffepredict.sh"
    ln -s /bin/echo "$TEST_TMP_DIR/Merge_LargeData.m"
    ln -s /bin/echo "$TEST_TMP_DIR/PreprocessPackage.m"
    echo "trainedmodeldir=traindir" > "$TEST_TMP_DIR/predict.config"
    echo "imagedir=imgdir" >> "$TEST_TMP_DIR/predict.config"
    echo "models=1fm,3fm,5fm" >> "$TEST_TMP_DIR/predict.config"
    echo "augspeed=4" >> "$TEST_TMP_DIR/predict.config"
    mkdir -p "$TEST_TMP_DIR/augimages"
    echo "foo" > "$TEST_TMP_DIR/augimages/de_augmentation_info.mat"
    echo -e "\nNumber of XY Packages\n1\nNumber of z-blocks\n1" > "$TEST_TMP_DIR/augimages/package_processing_info.txt"
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg001_Z01" "$TEST_TMP_DIR/3fm/Pkg001_Z01" "$TEST_TMP_DIR/5fm/Pkg001_Z01"
    touch "$TEST_TMP_DIR/1fm/DONE"
    touch "$TEST_TMP_DIR/1fm/Pkg001_Z01/DONE"
    touch "$TEST_TMP_DIR/3fm/DONE"
    touch "$TEST_TMP_DIR/3fm/Pkg001_Z01/DONE"
    touch "$TEST_TMP_DIR/5fm/DONE"
    touch "$TEST_TMP_DIR/5fm/Pkg001_Z01/DONE"
    
    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH

    run $RUN_ALL_PREDICT_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Running Prediction" ]
    [ "${lines[1]}" = "Trained Model Dir: traindir" ]
    [ "${lines[2]}" = "Image Dir: imgdir" ]
    [ "${lines[3]}" = "Models: 1fm,3fm,5fm" ]
    [ "${lines[4]}" = "Speed: 4" ]
    [ "${lines[5]}" = "Running 1fm predict 1 package(s) to process" ]
    [ "${lines[6]}" = "  Found $TEST_TMP_DIR/1fm/Pkg001_Z01/DONE. Prediction completed. Skipping..." ]
    [ "${lines[7]}" = "Found $TEST_TMP_DIR/1fm/DONE. Merge completed. Skipping..." ]

    export PATH=$A_TEMP_PATH
}

@test "run_all_predict.sh success" {
    ln -s /bin/echo "$TEST_TMP_DIR/caffepredict.sh"
    ln -s /bin/echo "$TEST_TMP_DIR/Merge_LargeData.m"
    ln -s /bin/echo "$TEST_TMP_DIR/PreprocessPackage.m"
    echo "trainedmodeldir=traindir" > "$TEST_TMP_DIR/predict.config"
    echo "imagedir=imgdir" >> "$TEST_TMP_DIR/predict.config"
    echo "models=1fm,3fm,5fm" >> "$TEST_TMP_DIR/predict.config"
    echo "augspeed=4" >> "$TEST_TMP_DIR/predict.config"
    mkdir -p "$TEST_TMP_DIR/augimages"
    echo "foo" > "$TEST_TMP_DIR/augimages/de_augmentation_info.mat"
    echo -e "\nNumber of XY Packages\n1\nNumber of z-blocks\n1" > "$TEST_TMP_DIR/augimages/package_processing_info.txt"
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg001_Z01" "$TEST_TMP_DIR/3fm/Pkg001_Z01" "$TEST_TMP_DIR/5fm/Pkg001_Z01"
    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH

    run $RUN_ALL_PREDICT_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Running Prediction" ]    
    [ "${lines[1]}" = "Trained Model Dir: traindir" ]
    [ "${lines[2]}" = "Image Dir: imgdir" ]
    [ "${lines[3]}" = "Models: 1fm,3fm,5fm" ]
    [ "${lines[4]}" = "Speed: 4" ]
    [ "${lines[5]}" = "Running 1fm predict 1 package(s) to process" ]
    [ "${lines[6]}" = "  Processing Pkg001_Z01 1 of 1 imgdir $TEST_TMP_DIR/augimages 001 01 1fm 4" ]
    [ "${lines[7]}" = "traindir/1fm/trainedmodel $TEST_TMP_DIR/augimages/1fm/Pkg001_Z01 $TEST_TMP_DIR/1fm/Pkg001_Z01" ]
    [ "${lines[11]}" = "Running Merge_LargeData.m $TEST_TMP_DIR/1fm" ]

    export PATH=$A_TEMP_PATH
}

@test "run_all_predict.sh success multi package and multi z" {
    ln -s /bin/true "$TEST_TMP_DIR/caffepredict.sh"
    ln -s /bin/true "$TEST_TMP_DIR/Merge_LargeData.m"
    ln -s /bin/echo "$TEST_TMP_DIR/PreprocessPackage.m"
    echo "trainedmodeldir=traindir" > "$TEST_TMP_DIR/predict.config"
    echo "imagedir=imgdir" >> "$TEST_TMP_DIR/predict.config"
    echo "models=1fm,3fm,5fm" >> "$TEST_TMP_DIR/predict.config"
    echo "augspeed=4" >> "$TEST_TMP_DIR/predict.config"
    mkdir -p "$TEST_TMP_DIR/augimages"
    echo "foo" > "$TEST_TMP_DIR/augimages/de_augmentation_info.mat"
    echo -e "\nNumber of XY Packages\n2\nNumber of z-blocks\n2" > "$TEST_TMP_DIR/augimages/package_processing_info.txt"
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg001_Z01" "$TEST_TMP_DIR/3fm/Pkg001_Z01" "$TEST_TMP_DIR/5fm/Pkg001_Z01"
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg001_Z02" "$TEST_TMP_DIR/3fm/Pkg001_Z02" "$TEST_TMP_DIR/5fm/Pkg001_Z02"
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg002_Z01" "$TEST_TMP_DIR/3fm/Pkg002_Z01" "$TEST_TMP_DIR/5fm/Pkg002_Z01"
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg002_Z02" "$TEST_TMP_DIR/3fm/Pkg002_Z02" "$TEST_TMP_DIR/5fm/Pkg002_Z02"

    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH

    run $RUN_ALL_PREDICT_SH "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Running Prediction" ]
    [ "${lines[1]}" = "Trained Model Dir: traindir" ]
    [ "${lines[2]}" = "Image Dir: imgdir" ]
    [ "${lines[3]}" = "Models: 1fm,3fm,5fm" ]
    [ "${lines[4]}" = "Speed: 4" ]
    [ "${lines[5]}" = "Running 1fm predict 4 package(s) to process" ]
    [ "${lines[6]}" = "  Processing Pkg001_Z01 1 of 4 imgdir $TEST_TMP_DIR/augimages 001 01 1fm 4" ]
    [ "${lines[10]}" = "  Processing Pkg001_Z02 2 of 4 imgdir $TEST_TMP_DIR/augimages 001 02 1fm 4" ]
    [ "${lines[14]}" = "  Processing Pkg002_Z01 3 of 4 imgdir $TEST_TMP_DIR/augimages 002 01 1fm 4" ]
    [ "${lines[18]}" = "  Processing Pkg002_Z02 4 of 4 imgdir $TEST_TMP_DIR/augimages 002 02 1fm 4" ]
    [ "${lines[22]}" = "Running Merge_LargeData.m $TEST_TMP_DIR/1fm" ]
    [ "${lines[23]}" = "Running 3fm predict 4 package(s) to process" ]
    [ "${lines[24]}" = "  Processing Pkg001_Z01 1 of 4 imgdir $TEST_TMP_DIR/augimages 001 01 3fm 4" ]
    [ "${lines[28]}" = "  Processing Pkg001_Z02 2 of 4 imgdir $TEST_TMP_DIR/augimages 001 02 3fm 4" ]
    [ "${lines[32]}" = "  Processing Pkg002_Z01 3 of 4 imgdir $TEST_TMP_DIR/augimages 002 01 3fm 4" ]
    [ "${lines[36]}" = "  Processing Pkg002_Z02 4 of 4 imgdir $TEST_TMP_DIR/augimages 002 02 3fm 4" ]
    [ "${lines[40]}" = "Running Merge_LargeData.m $TEST_TMP_DIR/3fm" ]
    [ "${lines[41]}" = "Running 5fm predict 4 package(s) to process" ]
    [ "${lines[42]}" = "  Processing Pkg001_Z01 1 of 4 imgdir $TEST_TMP_DIR/augimages 001 01 5fm 4" ]
    [ "${lines[46]}" = "  Processing Pkg001_Z02 2 of 4 imgdir $TEST_TMP_DIR/augimages 001 02 5fm 4" ]
    [ "${lines[50]}" = "  Processing Pkg002_Z01 3 of 4 imgdir $TEST_TMP_DIR/augimages 002 01 5fm 4" ]
    [ "${lines[54]}" = "  Processing Pkg002_Z02 4 of 4 imgdir $TEST_TMP_DIR/augimages 002 02 5fm 4" ]
    [ "${lines[58]}" = "Running Merge_LargeData.m $TEST_TMP_DIR/5fm" ]



    export PATH=$A_TEMP_PATH
}

