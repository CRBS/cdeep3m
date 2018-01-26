#!/usr/bin/octave -qf
% Predict
% Sets up prediction of user image dataset with 3 models, 1fm, 3fm, and 5fm using caffe
% -> Sets up prediction jobs in  output directory
%
% Syntax : Predict.m <Output of Train.m after training run> <augmented image data> <output directory>
%
%
%-------------------------------------------------------------------------------
%% Prediction for Deep3M -- NCMIR/NBCR, UCSD -- Author: C Churas -- Date: 12/2017
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

run_predict(argv());

