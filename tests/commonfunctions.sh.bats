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

@test "get_package_name valid parameters" {
    package_name=$(get_package_name "001" "02")
    [ "$package_name" == "Pkg001_Z02" ] 

    package_name=$(get_package_name "1" "2")
    [ "$package_name" == "Pkg001_Z02" ]
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
