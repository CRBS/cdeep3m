#!/usr/bin/env bats



setup() {
    export COMMON_FUNCS_SH="${BATS_TEST_DIRNAME}/../commonfunctions.sh"
    export TEST_TMP_DIR="${BATS_TMPDIR}/"`uuidgen`
    /bin/mkdir -p "$TEST_TMP_DIR"
    source $COMMON_FUNCS_SH
}

teardown() {
    if [ -d "$TEST_TMP_DIR" ] ; then
        /bin/rm -rf "$TEST_TMP_DIR"
    fi
}

@test "fatal_error" {
    [ ! -f "$TEST_TMP_DIR/ERROR" ]

    fatal_error "$TEST_TMP_DIR" "hi" 
    [ -f "$TEST_TMP_DIR/ERROR" ] 
    run cat "$TEST_TMP_DIR/ERROR"
    [ "${lines[0]}" == "hi" ]

    fatal_error "$TEST_TMP_DIR" "bye"
    [ -f "$TEST_TMP_DIR/ERROR" ]  
    run cat "$TEST_TMP_DIR/ERROR"
    [ "${lines[0]}" == "hi" ]
    [ "${lines[1]}" == "bye" ]
    script="$TEST_TMP_DIR/foo.sh"
    echo "#!/bin/bash" > "$script"
    echo ". $TEST_TMP_DIR/commonfunctions.sh" >> "$script"
    echo "fatal_error \"$TEST_TMP_DIR\" yo 3" >> "$script"
    chmod a+x "$script"
    cp "$COMMON_FUNCS_SH" "$TEST_TMP_DIR/."
    run "$script"
    [ "$status" -eq 3 ]
    run cat "$TEST_TMP_DIR/ERROR"
    [ "${lines[0]}" == "hi" ]
    [ "${lines[1]}" == "bye" ]
    [ "${lines[2]}" == "yo" ]
    [ "${lines[3]}" == "3" ]

}

@test "copy_models_from_dir" {
    # non existant source
    res=$(copy_models_from_dir "$TEST_TMP_DIR/nodir" "$TEST_TMP_DIR")
    # echo "$res" 1>&2
    [ "$res" = "$TEST_TMP_DIR/nodir src dir not found" ]

    # non existant dest
    res=$(copy_models_from_dir "$TEST_TMP_DIR" "$TEST_TMP_DIR/nodir")
    # echo "$res" 1>&2
    [ "$res" = "$TEST_TMP_DIR/nodir dest dir not found" ]

    src="$TEST_TMP_DIR/src"
    mkdir -p "$src"
    dest="$TEST_TMP_DIR/dest"
    mkdir -p "$dest"

    # no files to copy
    res=$(copy_models_from_dir "$src" "$dest")
    # echo "$res" 1>&2
    [ "$res" = "ERROR $src to $dest copy failed" ]

    echo "hi" > "$src/1fm_classifer123.solverstate"
    echo "bye" > "$src/1fm_classifer123.caffemodel"

    res=$(copy_models_from_dir "$src" "$dest")

    [ "$res" = "Copy of $src to $dest success" ]

    [ -f "$dest/1fm_classifer123.solverstate" ]
    [ -f "$dest/1fm_classifer123.caffemodel" ]
}

@test "copy_trained_models 1fm" {
    src="$TEST_TMP_DIR/src"
    dest="$TEST_TMP_DIR/dest"
    
    # non existant source
    res=$(copy_trained_models "$src" "$dest")
    [ "$res" = "" ]
    
    mkdir -p "$src/1fm/trainedmodel"
    # non existant dest
    res=$(copy_trained_models "$src" "$dest")
     echo "$res" 1>&2
    [ "$res" = "" ]
   
    mkdir -p "$dest/1fm/trainedmodel"
 
    # no files to copy
    res=$(copy_trained_models "$src" "$dest")
     echo "$res" 1>&2
    [ "$res" = "ERROR $src/1fm/trainedmodel to $dest/1fm/trainedmodel copy failed" ]
    
    echo "hi" > "$src/1fm/trainedmodel/1fm_classifer123.solverstate"
    echo "bye" > "$src/1fm/trainedmodel/1fm_classifer123.caffemodel"
    
    res=$(copy_trained_models "$src" "$dest")
    echo ":$res:" 1>&2 
    [ "$res" = "Copy of $src/1fm/trainedmodel to $dest/1fm/trainedmodel success" ]
    
    [ -f "$dest/1fm/trainedmodel/1fm_classifer123.solverstate" ]
    [ -f "$dest/1fm/trainedmodel/1fm_classifer123.caffemodel" ]
}

@test "copy_trained_models 1fm 3fm 5fm" {
    src="$TEST_TMP_DIR/src"
    dest="$TEST_TMP_DIR/dest"

    mkdir -p "$src/1fm/trainedmodel"
    mkdir -p "$dest/1fm/trainedmodel"
    mkdir -p "$src/3fm/trainedmodel"
    mkdir -p "$dest/3fm/trainedmodel"
    mkdir -p "$src/5fm/trainedmodel"
    mkdir -p "$dest/5fm/trainedmodel"


    echo "hi" > "$src/1fm/trainedmodel/1fm_classifer123.solverstate"
    echo "bye" > "$src/1fm/trainedmodel/1fm_classifer123.caffemodel"

    touch "$src/3fm/trainedmodel/3fm_yo.345.solverstate"
    touch "$src/5fm/trainedmodel/5fm_ha.456.caffemodel"

    res=$(copy_trained_models "$src" "$dest")
    run echo "$res"
    [ "${lines[0]}" = "Copy of $src/1fm/trainedmodel to $dest/1fm/trainedmodel success" ]
    [ "${lines[1]}" = "Copy of $src/3fm/trainedmodel to $dest/3fm/trainedmodel success" ]
    [ "${lines[2]}" = "Copy of $src/5fm/trainedmodel to $dest/5fm/trainedmodel success" ]
    [ -f "$dest/1fm/trainedmodel/1fm_classifer123.solverstate" ]
    [ -f "$dest/1fm/trainedmodel/1fm_classifer123.caffemodel" ]

    [ -f "$dest/3fm/trainedmodel/3fm_yo.345.solverstate" ]
    [ -f "$dest/5fm/trainedmodel/5fm_ha.456.caffemodel" ]
}


@test "get_package_name valid parameters" {
    package_name=$(get_package_name "001" "02")
    [ "$package_name" == "Pkg001_Z02" ] 

    package_name=$(get_package_name "1" "2")
    [ "$package_name" == "Pkg001_Z02" ]

    package_name=$(get_package_name "008" "693")
    [ "$package_name" == "Pkg008_Z693" ]

    package_name=$(get_package_name "08000" "012345")
    [ "$package_name" == "Pkg8000_Z12345" ]

}

@test "wait_for_prediction_to_catchup" {
    augimages="$TEST_TMP_DIR/augimages"
    mkdir -p "$augimages/1fm/Pkg001_Z01" 
    wait_for_prediction_to_catchup "$augimages" "0" "0"
    touch "$augimages/1fm/Pkg001_Z01/DONE"
    echo "#!/bin/bash" > "$TEST_TMP_DIR/foo.sh"
    echo "sleep 1" >> "$TEST_TMP_DIR/foo.sh"
    echo "/bin/rm -f $augimages/1fm/Pkg001_Z01/DONE" >> "$TEST_TMP_DIR/foo.sh"
    chmod a+x "$TEST_TMP_DIR/foo.sh"
    run "$TEST_TMP_DIR/foo.sh"
    res=$(wait_for_prediction_to_catchup "$augimages" "0" "0")
    [ "$res" == "" ]
}

@test "wait_for_prediction_to_catchup KILL.REQUEST file found" {
    augimages="$TEST_TMP_DIR/augimages"
    mkdir -p "$augimages/1fm/Pkg001_Z01"
    touch "$augimages/1fm/Pkg001_Z01/DONE"
    echo "#!/bin/bash" > "$TEST_TMP_DIR/foo.sh"
    echo "sleep 1" >> "$TEST_TMP_DIR/foo.sh"
    echo "touch $augimages/KILL.REQUEST" >> "$TEST_TMP_DIR/foo.sh"
    chmod a+x "$TEST_TMP_DIR/foo.sh"
    run "$TEST_TMP_DIR/foo.sh"
    res=$(wait_for_prediction_to_catchup "$augimages" "0" "0")
    [ "$res" == "killed" ]
}

@test "get_number_done_files_in_dir" {
    res=$(get_number_done_files_in_dir "$TEST_TMP_DIR")
    [ "$res" -eq "0" ]

    touch "$TEST_TMP_DIR/DONE"
    res=$(get_number_done_files_in_dir "$TEST_TMP_DIR")
    [ "$res" -eq "1" ]

    subdir="$TEST_TMP_DIR/1fm/Pkg001_Z05/"
    mkdir -p "$subdir"
    touch "$subdir/DONE"
    res=$(get_number_done_files_in_dir "$TEST_TMP_DIR")
    [ "$res" -eq "2" ]

    touch "$TEST_TMP_DIR/1fm/NOTDONE"
    res=$(get_number_done_files_in_dir "$TEST_TMP_DIR")
    [ "$res" -eq "2" ]
}

@test "wait_for_predict_to_finish_on_package" {

    touch "$TEST_TMP_DIR/KILL.REQUEST"
    res=$(wait_for_predict_to_finish_on_package "$TEST_TMP_DIR" "$TEST_TMP_DIR" 0)
    [ "$res" == "killed" ]
    rm -f "$TEST_TMP_DIR/KILL.REQUEST"

    touch "$TEST_TMP_DIR/PREDICTDONE"
    res=$(wait_for_predict_to_finish_on_package "$TEST_TMP_DIR" "$TEST_TMP_DIR" 0)
    [ "$res" == "" ]

    touch "$TEST_TMP_DIR/KILL.REQUEST"
    res=$(wait_for_predict_to_finish_on_package "$TEST_TMP_DIR" "$TEST_TMP_DIR" 0)
    [ "$res" == "killed" ]
}

@test "wait_for_preprocess_to_finish_on_package" {
    touch "$TEST_TMP_DIR/KILL.REQUEST"
    res=$(wait_for_preprocess_to_finish_on_package "$TEST_TMP_DIR" "$TEST_TMP_DIR" 0)
    [ "$res" == "killed" ]
    rm -f "$TEST_TMP_DIR/KILL.REQUEST"

    touch "$TEST_TMP_DIR/DONE"
    res=$(wait_for_preprocess_to_finish_on_package "$TEST_TMP_DIR" "$TEST_TMP_DIR" 0)
    [ "$res" == "" ]

    touch "$TEST_TMP_DIR/KILL.REQUEST"
    res=$(wait_for_preprocess_to_finish_on_package "$TEST_TMP_DIR" "$TEST_TMP_DIR" 0)
    [ "$res" == "killed" ]

}

@test "get_models_as_space_separated_list" {
    res=$(get_models_as_space_separated_list "")
    [ "$res" == "" ] 

    res=$(get_models_as_space_separated_list "1fm")
    [ "$res" == "1fm" ]

    res=$(get_models_as_space_separated_list "1fm,3fm")
    [ "$res" == "1fm 3fm" ]

    res=$(get_models_as_space_separated_list "1fm,3fm,5fm")
    [ "$res" == "1fm 3fm 5fm" ]
}

@test "get_number_of_models" {
    res=$(get_number_of_models "")
    [ "$res" == "0" ]

    res=$(get_number_of_models "1fm")
    [ "$res" == "1" ]

    res=$(get_number_of_models "1fm,3fm")
    [ "$res" == "2" ]

    res=$(get_number_of_models "1fm,3fm,5fm")
    [ "$res" == "3" ]
}

@test "parse_package_processing_info" {
    echo "" > "$TEST_TMP_DIR/package_processing_info.txt"
    echo "Number of XY Packages" >> "$TEST_TMP_DIR/package_processing_info.txt"
    echo "4" >> "$TEST_TMP_DIR/package_processing_info.txt"
    echo "Number of z-blocks" >> "$TEST_TMP_DIR/package_processing_info.txt"
    echo "6" >> "$TEST_TMP_DIR/package_processing_info.txt"

    parse_package_processing_info "$TEST_TMP_DIR/package_processing_info.txt"
 
    [ "$num_pkgs" -eq 4 ]
    [ "$num_zstacks" -eq 6 ]
    [ "$tot_pkgs" -eq 24 ]
}

@test "parse_predict_config" {
    pconfig="$TEST_TMP_DIR/predict.config"
    echo "trainedmodeldir=tmodel" >> "$pconfig"
    echo "imagedir=imagey" >> "$pconfig"
    echo "models=1fm" >> "$pconfig"
    echo "augspeed=1" >> "$pconfig"
    parse_predict_config "$pconfig"
    [ "$trained_model_dir" == "tmodel" ]
    [ "$img_dir" == "imagey" ]
    [ "$aug_speed" == "1" ]
    [ "$model_list" == "1fm" ]

}
