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
    [ "${lines[0]}" = "usage: runprediction.sh [-h] [--1fmonly]" ]
}


@test "runprediction.sh mkdir of augimages directory fails" {
  aug_images="$TEST_TMP_DIR/augimages"
  touch "$aug_images"
  run $RUNPREDICTION_SH trainoutdir augimages "$TEST_TMP_DIR"
  echo "$status $output" 1>&2
  [ "$status" -eq 6 ]
  [ "${lines[1]}" = "ERROR, a non-zero exit code (1) was received from: mkdir -p \"$aug_images\"" ]
}

@test "runprediction.sh DefDataPackages.m fails" {
  ln -s /bin/false "$TEST_TMP_DIR/DefDataPackages.m"
  export A_TEMP_PATH=$PATH
  export PATH=$TEST_TMP_DIR:$PATH
  run $RUNPREDICTION_SH trainoutdir augimages $TEST_TMP_DIR/predictout
  echo "$status $output" 1>&2
  [ "$status" -eq 5 ]
  [ "${lines[0]}" = "ERROR, a non-zero exit code (1) was received from: DefDataPackages.m \"augimages\" \"$TEST_TMP_DIR/predictout/augimages\"" ]
}

@test "runprediction.sh verify correct input to CreatePredictJob.m and DefDataPakcages.m" {
   ln -s /bin/echo "$TEST_TMP_DIR/CreatePredictJob.m"
   ln -s /bin/echo "$TEST_TMP_DIR/DefDataPackages.m"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNPREDICTION_SH trainoutdir augimages $TEST_TMP_DIR/predictout
   echo "$status $output" 1>&2
   [ "$status" -eq 3 ]
   [ "${lines[0]}" = "augimages $TEST_TMP_DIR/predictout/augimages" ]
   [ "${lines[1]}" = "trainoutdir $TEST_TMP_DIR/predictout/augimages $TEST_TMP_DIR/predictout" ]
   [ "${lines[2]}" = "ERROR, either $TEST_TMP_DIR/predictout/run_all_predict.sh is missing or non-executable" ] 
   export PATH=$A_TEMP_PATH
}

@test "runprediction.sh success" {
   ln -s /bin/true "$TEST_TMP_DIR/CreatePredictJob.m"
   ln -s /bin/true "$TEST_TMP_DIR/DefDataPackages.m"
   mkdir -p "$TEST_TMP_DIR/predictoutdir"
   ln -s /bin/echo "$TEST_TMP_DIR/predictoutdir/run_all_predict.sh"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNPREDICTION_SH trainoutdir augimages "$TEST_TMP_DIR/predictoutdir"
   [ "$status" -eq 0 ]
   echo "$output" 1>&2
   [ "${lines[1]}" = "Prediction has completed. Results are stored in $TEST_TMP_DIR/predictoutdir" ]

   export PATH=$A_TEMP_PATH
}

@test "runprediction.sh success --1fmonly set" {
   ln -s /bin/true "$TEST_TMP_DIR/CreatePredictJob.m"
   ln -s /bin/true "$TEST_TMP_DIR/DefDataPackages.m"
   mkdir -p "$TEST_TMP_DIR/predictoutdir"
   ln -s /bin/echo "$TEST_TMP_DIR/predictoutdir/run_all_predict.sh"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNPREDICTION_SH --1fmonly trainoutdir augimages "$TEST_TMP_DIR/predictoutdir"
   [ "$status" -eq 0 ]
   echo "$output" 1>&2
   [ "${lines[0]}" = "--1fmonly --augspeed 1" ]
   [ "${lines[1]}" = "Prediction has completed. Results are stored in $TEST_TMP_DIR/predictoutdir" ]

   export PATH=$A_TEMP_PATH
}

@test "runprediction.sh success --augspeed set" {
   ln -s /bin/true "$TEST_TMP_DIR/CreatePredictJob.m"
   ln -s /bin/true "$TEST_TMP_DIR/DefDataPackages.m"
   mkdir -p "$TEST_TMP_DIR/predictoutdir"
   ln -s /bin/echo "$TEST_TMP_DIR/predictoutdir/run_all_predict.sh"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNPREDICTION_SH --augspeed 4 trainoutdir augimages "$TEST_TMP_DIR/predictoutdir"
   [ "$status" -eq 0 ]
   echo "$output" 1>&2
   [ "${lines[0]}" = "--augspeed 4" ]
   [ "${lines[1]}" = "Prediction has completed. Results are stored in $TEST_TMP_DIR/predictoutdir" ]

   export PATH=$A_TEMP_PATH
}

@test "runprediction.sh run_all_predict.sh fails" {
   ln -s /bin/true "$TEST_TMP_DIR/CreatePredictJob.m"
   ln -s /bin/true "$TEST_TMP_DIR/DefDataPackages.m"
   mkdir -p "$TEST_TMP_DIR/predictoutdir"
   ln -s /bin/false "$TEST_TMP_DIR/predictoutdir/run_all_predict.sh"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNPREDICTION_SH trainoutdir augimages "$TEST_TMP_DIR/predictoutdir"
   echo "$status $output" 1>&2
   [ "$status" -eq 4 ]
   [ "${lines[0]}" = "ERROR, a non-zero exit code (1) was received from: \"$TEST_TMP_DIR/predictoutdir/run_all_predict.sh\"  --augspeed 1" ]

   export PATH=$A_TEMP_PATH
}

