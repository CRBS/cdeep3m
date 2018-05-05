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

@test "run_all_predict.sh PreprocessPackage.m fails" {
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

    run $RUN_ALL_PREDICT_SH --procwait 1 "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 10 ]
    export PATH=$A_TEMP_PATH
}

@test "run_all_predict.sh Merge_LargeData.m fails" {
    ln -s /bin/false "$TEST_TMP_DIR/Merge_LargeData.m"
    echo "#!/bin/bash" > "$TEST_TMP_DIR/PreprocessPackage.m"
    echo 'echo "$2/${5}/Pkg${3}_Z${4}/DONE"' >> "$TEST_TMP_DIR/PreprocessPackage.m"
    echo 'echo -e "success\n0" > $2/${5}/Pkg${3}_Z${4}/DONE' >> "$TEST_TMP_DIR/PreprocessPackage.m"
    chmod a+x "$TEST_TMP_DIR/PreprocessPackage.m"
    echo "#!/bin/bash" > "$TEST_TMP_DIR/caffepredict.sh"
    echo 'echo -e "success\n0" > ${3}/DONE' >> "$TEST_TMP_DIR/caffepredict.sh"
    chmod a+x "$TEST_TMP_DIR/caffepredict.sh"
    echo "trainedmodeldir=traindir" > "$TEST_TMP_DIR/predict.config"
    echo "imagedir=imgdir" >> "$TEST_TMP_DIR/predict.config"
    echo "models=1fm,3fm,5fm" >> "$TEST_TMP_DIR/predict.config"
    echo "augspeed=4" >> "$TEST_TMP_DIR/predict.config"
    mkdir -p "$TEST_TMP_DIR/augimages"
    echo "foo" > "$TEST_TMP_DIR/augimages/de_augmentation_info.mat"
    echo -e "\nNumber of XY Packages\n1\nNumber of z-blocks\n1" > "$TEST_TMP_DIR/augimages/package_processing_info.txt"
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg001_Z01" "$TEST_TMP_DIR/3fm/Pkg001_Z01" "$TEST_TMP_DIR/5fm/Pkg001_Z01"
    mkdir -p "$TEST_TMP_DIR/augimages/1fm/Pkg001_Z01"
    mkdir -p "$TEST_TMP_DIR/augimages/3fm/Pkg001_Z01"
    mkdir -p "$TEST_TMP_DIR/augimages/5fm/Pkg001_Z01" 
    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH

    run $RUN_ALL_PREDICT_SH --procwait 1 "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 13 ]
    export PATH=$A_TEMP_PATH
}

@test "run_all_predict.sh caffepredict.sh fails no DONE file" {
    ln -s /bin/false "$TEST_TMP_DIR/caffepredict.sh"
    echo "#!/bin/bash" > "$TEST_TMP_DIR/PreprocessPackage.m"
    echo 'echo "$2/${5}/Pkg${3}_Z${4}/DONE"' >> "$TEST_TMP_DIR/PreprocessPackage.m"
    echo 'echo -e "success\n0" > $2/${5}/Pkg${3}_Z${4}/DONE' >> "$TEST_TMP_DIR/PreprocessPackage.m"
    chmod a+x "$TEST_TMP_DIR/PreprocessPackage.m"
    echo "trainedmodeldir=traindir" > "$TEST_TMP_DIR/predict.config"
    echo "imagedir=imgdir" >> "$TEST_TMP_DIR/predict.config"
    echo "models=1fm,3fm,5fm" >> "$TEST_TMP_DIR/predict.config"
    echo "augspeed=4" >> "$TEST_TMP_DIR/predict.config"
    mkdir -p "$TEST_TMP_DIR/augimages"
    echo "foo" > "$TEST_TMP_DIR/augimages/de_augmentation_info.mat"
    echo -e "\nNumber of XY Packages\n1\nNumber of z-blocks\n1" > "$TEST_TMP_DIR/augimages/package_processing_info.txt"
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg001_Z01" 
    mkdir -p "$TEST_TMP_DIR/3fm/Pkg001_Z01" 
    mkdir -p "$TEST_TMP_DIR/5fm/Pkg001_Z01"
    mkdir -p "$TEST_TMP_DIR/augimages/1fm/Pkg001_Z01"
    mkdir -p "$TEST_TMP_DIR/augimages/3fm/Pkg001_Z01"
    mkdir -p "$TEST_TMP_DIR/augimages/5fm/Pkg001_Z01"

    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH

    run $RUN_ALL_PREDICT_SH --procwait 3 "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 12 ]
    export PATH=$A_TEMP_PATH
}

@test "run_all_predict.sh caffepredict.sh fails nonzero exit in DONE file" {
    echo "#!/bin/bash" > "$TEST_TMP_DIR/PreprocessPackage.m"
    echo 'echo "$2/${5}/Pkg${3}_Z${4}/DONE"' >> "$TEST_TMP_DIR/PreprocessPackage.m"
    echo 'echo -e "success\n0" > $2/${5}/Pkg${3}_Z${4}/DONE' >> "$TEST_TMP_DIR/PreprocessPackage.m"
    chmod a+x "$TEST_TMP_DIR/PreprocessPackage.m"
    echo "#!/bin/bash" > "$TEST_TMP_DIR/caffepredict.sh"
    echo 'echo -e "fail\n1" > ${3}/DONE' >> "$TEST_TMP_DIR/caffepredict.sh"
    chmod a+x "$TEST_TMP_DIR/caffepredict.sh"
    echo "#!/bin/bash" > "$TEST_TMP_DIR/Merge_LargeData.m"
    echo 'echo -e "success\n0" > ${1}/DONE' >> "$TEST_TMP_DIR/Merge_LargeData.m"
    chmod a+x "$TEST_TMP_DIR/Merge_LargeData.m"

    echo "trainedmodeldir=traindir" > "$TEST_TMP_DIR/predict.config"
    echo "imagedir=imgdir" >> "$TEST_TMP_DIR/predict.config"
    echo "models=1fm,3fm,5fm" >> "$TEST_TMP_DIR/predict.config"
    echo "augspeed=4" >> "$TEST_TMP_DIR/predict.config"
    mkdir -p "$TEST_TMP_DIR/augimages"
    echo "foo" > "$TEST_TMP_DIR/augimages/de_augmentation_info.mat"
    echo -e "\nNumber of XY Packages\n1\nNumber of z-blocks\n1" > "$TEST_TMP_DIR/augimages/package_processing_info.txt"
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg001_Z01"
    mkdir -p "$TEST_TMP_DIR/3fm/Pkg001_Z01"
    mkdir -p "$TEST_TMP_DIR/5fm/Pkg001_Z01"
    mkdir -p "$TEST_TMP_DIR/augimages/1fm/Pkg001_Z01"
    mkdir -p "$TEST_TMP_DIR/augimages/3fm/Pkg001_Z01"
    mkdir -p "$TEST_TMP_DIR/augimages/5fm/Pkg001_Z01"

    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH

    run $RUN_ALL_PREDICT_SH --procwait 1 "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 11 ]
    export PATH=$A_TEMP_PATH
}

@test "run_all_predict.sh last caffepredict.sh fails with nonzero exit in DONE file" {
    echo "#!/bin/bash" > "$TEST_TMP_DIR/PreprocessPackage.m"
    echo 'echo "$2/${5}/Pkg${3}_Z${4}/DONE"' >> "$TEST_TMP_DIR/PreprocessPackage.m"
    echo 'echo -e "success\n0" > $2/${5}/Pkg${3}_Z${4}/DONE' >> "$TEST_TMP_DIR/PreprocessPackage.m"
    chmod a+x "$TEST_TMP_DIR/PreprocessPackage.m"
    echo "#!/bin/bash" > "$TEST_TMP_DIR/caffepredict.sh"
    echo 'pkgname=`dirname ${3}`' >> "$TEST_TMP_DIR/caffepredict.sh"
    echo 'modeldir=`dirname $pkgname`' >> "$TEST_TMP_DIR/caffepredict.sh"
    echo 'model=`basename $modeldir`' >> "$TEST_TMP_DIR/caffepredict.sh"
    echo 'if [ $model == "5fm" ] ; then' >> "$TEST_TMP_DIR/caffepredict.sh"
    echo '  echo -e "fail\n1" > ${3}/DONE' >> "$TEST_TMP_DIR/caffepredict.sh"
    echo 'else' >> "$TEST_TMP_DIR/caffepredict.sh"
    echo '  echo -e "success\n0" > ${3}/DONE' >> "$TEST_TMP_DIR/caffepredict.sh"
    echo 'fi' >> "$TEST_TMP_DIR/caffepredict.sh"
    chmod a+x "$TEST_TMP_DIR/caffepredict.sh"
    echo "#!/bin/bash" > "$TEST_TMP_DIR/Merge_LargeData.m"
    echo 'echo -e "success\n0" > ${1}/DONE' >> "$TEST_TMP_DIR/Merge_LargeData.m"
    chmod a+x "$TEST_TMP_DIR/Merge_LargeData.m"

    echo "trainedmodeldir=traindir" > "$TEST_TMP_DIR/predict.config"
    echo "imagedir=imgdir" >> "$TEST_TMP_DIR/predict.config"
    echo "models=1fm,3fm,5fm" >> "$TEST_TMP_DIR/predict.config"
    echo "augspeed=4" >> "$TEST_TMP_DIR/predict.config"
    mkdir -p "$TEST_TMP_DIR/augimages"
    echo "foo" > "$TEST_TMP_DIR/augimages/de_augmentation_info.mat"
    echo -e "\nNumber of XY Packages\n1\nNumber of z-blocks\n1" > "$TEST_TMP_DIR/augimages/package_processing_info.txt"
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg001_Z01"
    mkdir -p "$TEST_TMP_DIR/3fm/Pkg001_Z01"
    mkdir -p "$TEST_TMP_DIR/5fm/Pkg001_Z01"
    mkdir -p "$TEST_TMP_DIR/augimages/1fm/Pkg001_Z01"
    mkdir -p "$TEST_TMP_DIR/augimages/3fm/Pkg001_Z01"
    mkdir -p "$TEST_TMP_DIR/augimages/5fm/Pkg001_Z01"

    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH

    run $RUN_ALL_PREDICT_SH --procwait 1 "$TEST_TMP_DIR"
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
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg001_Z01" 
    mkdir -p "$TEST_TMP_DIR/3fm/Pkg001_Z01" 
    mkdir -p "$TEST_TMP_DIR/5fm/Pkg001_Z01"
    mkdir -p "$TEST_TMP_DIR/augimages/1fm/Pkg001_Z01"
    mkdir -p "$TEST_TMP_DIR/augimages/3fm/Pkg001_Z01"
    mkdir -p "$TEST_TMP_DIR/augimages/5fm/Pkg001_Z01"
    touch "$TEST_TMP_DIR/1fm/DONE"
    touch "$TEST_TMP_DIR/1fm/Pkg001_Z01/DONE"
    touch "$TEST_TMP_DIR/3fm/DONE"
    touch "$TEST_TMP_DIR/3fm/Pkg001_Z01/DONE"
    touch "$TEST_TMP_DIR/5fm/DONE"
    touch "$TEST_TMP_DIR/5fm/Pkg001_Z01/DONE"
    
    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH

    run $RUN_ALL_PREDICT_SH --procwait 1 "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Running Prediction" ]
    [ "${lines[1]}" = "Trained Model Dir: traindir" ]
    [ "${lines[2]}" = "Image Dir: imgdir" ]
    [ "${lines[3]}" = "Models: 1fm,3fm,5fm" ]
    [ "${lines[4]}" = "Speed: 4" ]
    [ "${lines[5]}" = "Running 1fm predict 1 package(s) to process" ]
    [ "${lines[6]}" = "  Found $TEST_TMP_DIR/1fm/Pkg001_Z01/DONE. Prediction completed. Skipping..." ]
    [ "${lines[7]}" = "Found $TEST_TMP_DIR/1fm/DONE Merge completed. Skipping..." ]

    export PATH=$A_TEMP_PATH
}

@test "run_all_predict.sh success" {
    echo "#!/bin/bash" > "$TEST_TMP_DIR/PreprocessPackage.m"
    echo 'echo "$2/${5}/Pkg${3}_Z${4}/DONE"' >> "$TEST_TMP_DIR/PreprocessPackage.m"
    echo 'echo -e "success\n0" > $2/${5}/Pkg${3}_Z${4}/DONE' >> "$TEST_TMP_DIR/PreprocessPackage.m"
    chmod a+x "$TEST_TMP_DIR/PreprocessPackage.m"
    echo "#!/bin/bash" > "$TEST_TMP_DIR/caffepredict.sh"
    echo 'echo -e "success\n0" > ${3}/DONE' >> "$TEST_TMP_DIR/caffepredict.sh"
    chmod a+x "$TEST_TMP_DIR/caffepredict.sh"
    echo "#!/bin/bash" > "$TEST_TMP_DIR/Merge_LargeData.m"
    echo 'echo -e "success\n0" > ${1}/DONE' >> "$TEST_TMP_DIR/Merge_LargeData.m"
    chmod a+x "$TEST_TMP_DIR/Merge_LargeData.m"
    echo "trainedmodeldir=traindir" > "$TEST_TMP_DIR/predict.config"
    echo "imagedir=imgdir" >> "$TEST_TMP_DIR/predict.config"
    echo "models=1fm,3fm,5fm" >> "$TEST_TMP_DIR/predict.config"
    echo "augspeed=4" >> "$TEST_TMP_DIR/predict.config"
    mkdir -p "$TEST_TMP_DIR/augimages"
    echo "foo" > "$TEST_TMP_DIR/augimages/de_augmentation_info.mat"
    echo -e "\nNumber of XY Packages\n1\nNumber of z-blocks\n1" > "$TEST_TMP_DIR/augimages/package_processing_info.txt"
    mkdir -p "$TEST_TMP_DIR/1fm/Pkg001_Z01" 
    mkdir -p "$TEST_TMP_DIR/3fm/Pkg001_Z01" 
    mkdir -p "$TEST_TMP_DIR/5fm/Pkg001_Z01"
    mkdir -p "$TEST_TMP_DIR/augimages/1fm/Pkg001_Z01"
    mkdir -p "$TEST_TMP_DIR/augimages/3fm/Pkg001_Z01"
    mkdir -p "$TEST_TMP_DIR/augimages/5fm/Pkg001_Z01"

    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH

    run $RUN_ALL_PREDICT_SH --procwait 1 "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Running Prediction" ]    
    [ "${lines[1]}" = "Trained Model Dir: traindir" ]
    [ "${lines[2]}" = "Image Dir: imgdir" ]
    [ "${lines[3]}" = "Models: 1fm,3fm,5fm" ]
    [ "${lines[4]}" = "Speed: 4" ]
    [ "${lines[5]}" = "Running 1fm predict 1 package(s) to process" ]
    [ "${lines[6]}" = "  Processing Pkg001_Z01 1 of 1" ]

    export PATH=$A_TEMP_PATH
}

@test "run_all_predict.sh success multi package and multi z" {
    echo "#!/bin/bash" > "$TEST_TMP_DIR/PreprocessPackage.m"
    echo 'echo -e "success\n0" > $2/${5}/Pkg${3}_Z${4}/DONE' >> "$TEST_TMP_DIR/PreprocessPackage.m"
    chmod a+x "$TEST_TMP_DIR/PreprocessPackage.m"
    echo "#!/bin/bash" > "$TEST_TMP_DIR/caffepredict.sh"
    echo 'echo -e "success\n0" > ${3}/DONE' >> "$TEST_TMP_DIR/caffepredict.sh"
    chmod a+x "$TEST_TMP_DIR/caffepredict.sh"
    echo "#!/bin/bash" > "$TEST_TMP_DIR/Merge_LargeData.m"
    echo 'echo -e "success\n0" > ${1}/DONE' >> "$TEST_TMP_DIR/Merge_LargeData.m"
    chmod a+x "$TEST_TMP_DIR/Merge_LargeData.m"

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
    mkdir -p "$TEST_TMP_DIR/augimages/1fm/Pkg001_Z01" "$TEST_TMP_DIR/augimages/3fm/Pkg001_Z01" "$TEST_TMP_DIR/augimages/5fm/Pkg001_Z01"
    mkdir -p "$TEST_TMP_DIR/augimages/1fm/Pkg001_Z02" "$TEST_TMP_DIR/augimages/3fm/Pkg001_Z02" "$TEST_TMP_DIR/augimages/5fm/Pkg001_Z02"
    mkdir -p "$TEST_TMP_DIR/augimages/1fm/Pkg002_Z01" "$TEST_TMP_DIR/augimages/3fm/Pkg002_Z01" "$TEST_TMP_DIR/augimages/5fm/Pkg002_Z01"
    mkdir -p "$TEST_TMP_DIR/augimages/1fm/Pkg002_Z02" "$TEST_TMP_DIR/augimages/3fm/Pkg002_Z02" "$TEST_TMP_DIR/augimages/5fm/Pkg002_Z02"

    export A_TEMP_PATH=$PATH
    export PATH=$TEST_TMP_DIR:$PATH

    run $RUN_ALL_PREDICT_SH --procwait 1 "$TEST_TMP_DIR"
    echo "$status $output" 1>&2
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Running Prediction" ]
    [ "${lines[1]}" = "Trained Model Dir: traindir" ]
    [ "${lines[2]}" = "Image Dir: imgdir" ]
    [ "${lines[3]}" = "Models: 1fm,3fm,5fm" ]
    [ "${lines[4]}" = "Speed: 4" ]
    [ "${lines[5]}" = "Running 1fm predict 4 package(s) to process" ]
    [ "${lines[6]}" = "  Processing Pkg001_Z01 1 of 4" ]

    export PATH=$A_TEMP_PATH
}

