#!/usr/bin/octave -qf
% Train
% Runs training for the 3 models, 1fm, 3fm, and 5fm using caffe
% -> Outputs trained caffe model to output directory
%
% Syntax : PreProcessImageData /ImageData/AugmentedEMData/ /TrainedModel/
%
%
%----------------------------------------------------------------------------------------
%% Train for Deep3M -- NCMIR/NBCR, UCSD -- Author: C Churas -- Date: 12/2017
%----------------------------------------------------------------------------------------
%
% ----------------------------------------------------------------------------------------
%% Initialize
% ----------------------------------------------------------------------------------------

disp('Starting Train');
addpath(genpath('~/deep3m/scripts/'));
tic
pkg load hdf5oct
pkg load image

arg_list = argv ();
if numel(arg_list)<2; disp('Use -> Train /ImageData/AugmentedEMData/ /TrainedModel/'); return; end
in_img_path = arg_list{1};
outdir = arg_list{2};

% ----------------------------------------------------------------------------------------
% Examine input training data and generate list of h5 files
% ----------------------------------------------------------------------------------------



% ----------------------------------------------------------------------------------------
% Create output directory and copy over model files and adjust configuration files
% ----------------------------------------------------------------------------------------



% ----------------------------------------------------------------------------------------
% Run train 1fm, 3fm, 5fm
% ----------------------------------------------------------------------------------------

