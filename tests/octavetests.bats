#!/usr/bin/env bats

@test "test octave scripts" {
   run $BATS_TEST_DIRNAME/RunUnitTests.m
   echo "$output" 1>&2
   [ "$status" -eq 0 ]
}

