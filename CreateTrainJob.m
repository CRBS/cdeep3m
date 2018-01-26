#!/usr/bin/octave -qf

% CreateTrainJob
% Generates Training job that uses caffe on3 models, 1fm, 3fm, and 5fm
% -> Outputs trained caffe model to output directory
%
% Syntax : CreateTrainJob.m <Input train data directory> <Output directory>
%
%
%-------------------------------------------------------------------------------
%% Train for Deep3M -- NCMIR/NBCR, UCSD -- Author: C Churas -- Date: 12/2017
%-------------------------------------------------------------------------------
%
% ------------------------------------------------------------------------------
%% Initialize
% ------------------------------------------------------------------------------

script_dir = fileparts(make_absolute_filename(program_invocation_name()));
addpath(genpath(script_dir));
addpath(genpath(strcat(script_dir,filesep(),'scripts',filesep())));
addpath(genpath(strcat(script_dir,filesep(),'scripts',filesep(),'functions')));
tic
pkg load hdf5oct
pkg load image

run_train(argv());

