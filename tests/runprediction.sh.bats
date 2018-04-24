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

  run $RUNPREDICTION_SH --augspeed 2 trainoutdir augimages "$TEST_TMP_DIR"
  echo "$status $output" 1>&2
  [ "$status" -eq 3 ]

  run $RUNPREDICTION_SH --augspeed 4 trainoutdir augimages "$TEST_TMP_DIR"
  echo "$status $output" 1>&2
  [ "$status" -eq 3 ]

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

@test "runprediction.sh verify correct input to DefDataPakcages.m" {
   ln -s /bin/echo "$TEST_TMP_DIR/DefDataPackages.m"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNPREDICTION_SH trainoutdir augimages $TEST_TMP_DIR/predictout
   echo "$status $output" 1>&2
   [ "$status" -eq 5 ]
   [ "${lines[0]}" = "augimages $TEST_TMP_DIR/predictout/augimages" ]
   export PATH=$A_TEMP_PATH
}

@test "runprediction.sh fails" {
   ln -s /bin/true "$TEST_TMP_DIR/DefDataPackages.m"
   mkdir -p "$TEST_TMP_DIR/predictoutdir"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNPREDICTION_SH trainoutdir augimages "$TEST_TMP_DIR/predictoutdir"
   echo "$output" 1>&2
   [ "$status" -eq 5 ]

   export PATH=$A_TEMP_PATH
}

@test "runprediction.sh success" {
   ln -s /bin/true "$TEST_TMP_DIR/DefDataPackages.m"
   ln -s /bin/echo "$TEST_TMP_DIR/run_all_predict.sh"
   mkdir -p "$TEST_TMP_DIR/predictoutdir"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNPREDICTION_SH trainoutdir augimages "$TEST_TMP_DIR/predictoutdir"
   echo "$output" 1>&2
   [ "$status" -eq 0 ]
   [ "${lines[0]}" = "$TEST_TMP_DIR/predictoutdir" ]
   [ "${lines[1]}" = "Prediction has completed. Results are stored in $TEST_TMP_DIR/predictoutdir" ]
   [ "${lines[2]}" = "Have a nice day!" ]

   run cat "$TEST_TMP_DIR/predictoutdir/predict.config"
   echo "$output" 1>&2
   [ "$status" -eq 0 ]
   [ "${lines[0]}" = "[default]" ]
   [ "${lines[1]}" = "trainedmodeldir=trainoutdir" ] 
   [ "${lines[2]}" = "imagedir=augimages" ]
   [ "${lines[3]}" = "models=1fm,3fm,5fm" ]
   [ "${lines[4]}" = "augspeed=1" ]

   export PATH=$A_TEMP_PATH
}

@test "runprediction.sh success --models and --augspeed set" {
   ln -s /bin/true "$TEST_TMP_DIR/DefDataPackages.m"
   ln -s /bin/echo "$TEST_TMP_DIR/run_all_predict.sh"
   mkdir -p "$TEST_TMP_DIR/predictoutdir"
   export A_TEMP_PATH=$PATH
   export PATH=$TEST_TMP_DIR:$PATH
   run $RUNPREDICTION_SH --models 1fm --augspeed 4 trainoutdir augimages "$TEST_TMP_DIR/predictoutdir"
   echo "$output" 1>&2
   [ "$status" -eq 0 ]
   [ "${lines[0]}" = "$TEST_TMP_DIR/predictoutdir" ]
   [ "${lines[1]}" = "Prediction has completed. Results are stored in $TEST_TMP_DIR/predictoutdir" ]
   [ "${lines[2]}" = "Have a nice day!" ]

   run cat "$TEST_TMP_DIR/predictoutdir/predict.config"
   echo "$output" 1>&2
   [ "$status" -eq 0 ]
   [ "${lines[0]}" = "[default]" ]
   [ "${lines[1]}" = "trainedmodeldir=trainoutdir" ]
   [ "${lines[2]}" = "imagedir=augimages" ]
   [ "${lines[3]}" = "models=1fm" ]
   [ "${lines[4]}" = "augspeed=4" ]

   export PATH=$A_TEMP_PATH
}


