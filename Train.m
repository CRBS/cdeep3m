#!/usr/bin/octave -qf
% Train
% Runs training for the 3 models, 1fm, 3fm, and 5fm using caffe
% -> Outputs trained caffe model to output directory
%
% Syntax : Train.m <Input train data directory> <Output directory>
%
%
%-------------------------------------------------------------------------------
%% Train for Deep3M -- NCMIR/NBCR, UCSD -- Author: C Churas -- Date: 12/2017
%-------------------------------------------------------------------------------
%
% ------------------------------------------------------------------------------
%% Initialize
% ------------------------------------------------------------------------------

disp('Starting Train');
addpath(genpath('~/deep3m/scripts/'));
tic
pkg load hdf5oct
pkg load image

arg_list = argv ();

if numel(arg_list)<2; 
  disp('Use -> Train <Input train data directory> <Output directory>'); 
  return; 
end

in_img_path = make_absolute_filename(arg_list{1});

if isdir(in_img_path) == 0;
  disp('First argument is not a directory and its supposed to be')
  return;
end

outdir = make_absolute_filename(arg_list{2});

% ------------------------------------------------------------------------------
% Examine input training data and generate list of h5 files
% ------------------------------------------------------------------------------

train_files = glob(strcat(in_img_path, filesep(),'*.h5'))

if rows(tf) != 16;
  disp('Expecting 16 .h5 files, but found a different count.')
  return;
end

% ------------------------------------------------------------------------------
% Create output directory and copy over model files and adjust configuration files
% ------------------------------------------------------------------------------



% ------------------------------------------------------------------------------
% Run train 1fm, 3fm, 5fm
% ------------------------------------------------------------------------------

