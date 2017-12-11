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

addpath(genpath('~/deep3m/scripts/'));
tic
pkg load hdf5oct
pkg load image


function create_dir(thedir)
  if isdir(thedir) == 0;
    mkdir_result = mkdir(thedir);
    if mkdir_result(1) == 0;
      errmsg = sprintf('Error making directory: %s : %s\n', mkdir_result(1),
                       mkdir_result(2));
      error(errmsg);
    endif
  endif
endfunction

function copy_model(the_model, dest_dir)
  src_files = strcat('./model',filesep(),
                     'inception_residual_train_prediction_',the_model,
                     filesep(),'*txt');
  res = copyfile(src_files,dest_dir);
  if res(1) == 0;
    errmsg = sprintf('Error copying model %s : %s\n',the_model,res(2));
    error(errmsg);
  endif 
endfunction


function runtrain(arg_list)
  
  % suffix for hdf5 files
  H_FIVE_SUFFIX='.h5';

  prog_name = program_name();
  program_invocation_name();
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

  % ---------------------------------------------------------------------------
  % Examine input training data and generate list of h5 files
  % ---------------------------------------------------------------------------

  train_files = glob(strcat(in_img_path, filesep(),'*', H_FIVE_SUFFIX));

  if rows(train_files) != 16;
    fprintf(stderr(),'Expecting 16 .h5 files, but found a different count.\n')
    return;
  endif

  % ----------------------------------------------------------------------------
  % Create output directory and copy over model files and 
  % adjust configuration files
  % ----------------------------------------------------------------------------

  create_dir(outdir);

  % copy over 1fm, 3fm, and 5fm model data to separate directories
  onefm_dest = strcat(outdir,filesep(),'1fm');
  create_dir(onefm_dest);
  
  threefm_dest = strcat(outdir,filesep(),'3fm');
  create_dir(threefm_dest);

  fivefm_dest = strcat(outdir,filesep(),'5fm');
  create_dir(fivefm_dest);
  
  copy_model('1fm',onefm_dest);
  copy_model('3fm',threefm_dest);
  copy_model('5fm',fivefm_dest);

  % ----------------------------------------------------------------------------
  % Run train 1fm, 3fm, 5fm
  % ----------------------------------------------------------------------------
endfunction

runtrain(argv());

%!error runtrain()

%!error runtrain({'./nonexistdir'})

%!error runtrain({'./nonexistdir','./yo'})
