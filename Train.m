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
prog_name = program_name();
program_invocation_name();

addpath(genpath('~/deep3m/scripts/'));
tic
pkg load hdf5oct
pkg load image

% suffix for hdf5 files
H_FIVE_SUFFIX='.h5';

arg_list = argv();

if numel(arg_list)<2; 
  msg = sprintf('%s <Input train data directory> <output dir>\n', prog_name);
  error(msg); 
  return; 
endif

in_img_path = make_absolute_filename(arg_list{1});

if isdir(in_img_path) == 0;
  disp('First argument is not a directory and its supposed to be')
  return;
endif

outdir = make_absolute_filename(arg_list{2});

% ------------------------------------------------------------------------------
% Examine input training data and generate list of h5 files
% ------------------------------------------------------------------------------

train_files = glob(strcat(in_img_path, filesep(),'*', H_FIVE_SUFFIX));

if rows(train_files) != 16;
  fprintf(stderr(),'Expecting 16 .h5 files, but found a different count.\n')
  return;
endif

% ------------------------------------------------------------------------------
% Create output directory and copy over model files and 
% adjust configuration files
% ------------------------------------------------------------------------------

if isdir(outdir) == 0;
  mkdir_result = mkdir(outdir)
  if mkdir_result(1) == 0;
    fprintf(stderr(),'Error making directory\n');
    error('yo');
    return;
  endif
endif

% ------------------------------------------------------------------------------
% Run train 1fm, 3fm, 5fm
% ------------------------------------------------------------------------------

