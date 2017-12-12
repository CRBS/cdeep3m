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

script_dir = fileparts(make_absolute_filename(program_invocation_name()));

addpath(genpath(strcat(script_dir,filesep(),'scripts',filesep())));
tic
pkg load hdf5oct
pkg load image


function create_dir(thedir)
  % Creates directory set in argument thedir only if directory does not already exist
  % If directory exists then code will just return
  % If mkdir call fails error() is invoked with a message about the failure.
  if isdir(thedir) == 0;
    mkdir_result = mkdir(thedir);
    if mkdir_result(1) == 0;
      errmsg = sprintf('Error making directory: %s : %s\n', mkdir_result(1),
                       mkdir_result(2));
      error(errmsg);
    endif
  endif
endfunction

function copy_model(base_dir, the_model, dest_dir)
  % Copies *txt files from model/inception_residual_train_prediction_<the_model>  %directory
  % to directory specified by dest_dir argument. If copy fails error() is 
  % invoked describing
  % the issue
  src_files = strcat(base_dir,filesep(),'model',filesep(),
                     'inception_residual_train_prediction_',the_model,
                     filesep(),'*txt');
  res = copyfile(src_files,dest_dir);
  if res(1) == 0;
    errmsg = sprintf('Error copying model %s : %s\n',the_model,res(2));
    error(errmsg);
  endif 
endfunction

function [onefm_dest, threefm_dest, fivefm_dest] = copy_over_allmodels(base_dir, outdir)
  % ----------------------------------------------------------------------------
  % Create output directory and copy over model files and 
  % adjust configuration files
  % ----------------------------------------------------------------------------

  create_dir(outdir);

  % copy over 1fm, 3fm, and 5fm model data to separate directories
  onefm_dest = strcat(outdir,filesep(),'1fm');
  create_dir(onefm_dest);
  copy_model(base_dir,'1fm',onefm_dest);

  threefm_dest = strcat(outdir,filesep(),'3fm');
  create_dir(threefm_dest);
  copy_model(base_dir,'3fm',threefm_dest);

  fivefm_dest = strcat(outdir,filesep(),'5fm');
  create_dir(fivefm_dest);
  copy_model(base_dir,'5fm',fivefm_dest);
endfunction

function [train_model_dest] = update_solverproto_txt_file(outdir,model,
                                                          max_iterations)
  % Open solver.prototxt and adjust the line snapshot_prefix to be 
  % <model>_model/<model>_classifier'
  solver_prototxt = strcat(outdir,filesep(),model,filesep(), 'solver.prototxt');
  s_data = fileread(solver_prototxt);
  solver_out = fopen(solver_prototxt,"w");
  lines = strsplit(s_data,'\n');
  model_dir = strcat(outdir,filesep(),model,filesep(),'trainedmodel');
  create_dir(model_dir);
  train_model_dest = strcat(model_dir,
                            filesep(),model,'_classifer');
  for j = 1:columns(lines)
    if index(char(lines(j)),'snapshot_prefix:') == 1;
      fprintf(solver_out,'snapshot_prefix: "%s"\n',train_model_dest);
    else
      if index(char(lines(j)),'max_iter:') == 1;
        fprintf(solver_out,'max_iter: %d\n',max_iterations); 
      else
        fprintf(solver_out,'%s\n',char(lines(j)));
      endif
    endif
  endfor
  fclose(solver_out);
endfunction

function update_train_val_prototxt(outdir,model,train_file)
  % updates data_source in train_val.prototxt file
  train_val_prototxt = strcat(outdir,filesep(),model,filesep(),
                              'train_val.prototxt');
  t_data = fileread(train_val_prototxt);
  lines = strsplit(t_data,'\n');
  train_out = fopen(train_val_prototxt,"w");
  for j = 1:columns(lines)
    if index(char(lines(j)),'data_source:') >= 1;
      fprintf(train_out,'    data_source: "%s"\n',train_file);
    else
      fprintf(train_out,'%s\n',char(lines(j)));
    endif
  endfor
endfunction


function runtrain(arg_list)
  % Runs Deep3m train using caffe. 
  % Usage runtrain(cell array of strings) 
  % by first verifying first argument is path to training data and
  % then copying over models under model/ directory to output directory
  % suffix for hdf5 files
  H_FIVE_SUFFIX='.h5';
  prog_name = program_name();
  base_dir = fileparts(make_absolute_filename(program_invocation_name()));
  
  caffe_train_template=strcat(base_dir,filesep(),'scripts',filesep(),
                              'caffetrain_template.sh');
  caffe_bin='/home/ubuntu/caffe_nd_sense_segmentation/build/tools/';

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
    fprintf(stderr(),'Expecting 16 .h5 files, but found a different count.\n');
    return;
  endif

  train_file = strcat(in_img_path,filesep(),'train_file.txt');
  if ~exist(train_file);
    errmsg = sprintf('%s file not found',train_file);
    error(errmsg);
  endif

  % ----------------------------------------------------------------------------
  % Create output directory and copy over model files and 
  % adjust configuration files
  % ----------------------------------------------------------------------------
  [onefm_dest,threefm_dest,fivefm_dest] = copy_over_allmodels(base_dir,outdir);
  max_iterations = 10000;
  update_solverproto_txt_file(outdir,'1fm',max_iterations);
  update_solverproto_txt_file(outdir,'3fm',max_iterations);
  update_solverproto_txt_file(outdir,'5fm',max_iterations);

  update_train_val_prototxt(outdir,'1fm',train_file);
  update_train_val_prototxt(outdir,'3fm',train_file);
  update_train_val_prototxt(outdir,'5fm',train_file);
  caffe_train = strcat(outdir,filesep(),'caffe_train.sh');
  copyfile(caffe_train_template,caffe_train);
  % ----------------------------------------------------------------------------
  % Run train 1fm, 3fm, 5fm
  % ----------------------------------------------------------------------------
  fprintf(stdout(),'Running Training for 1fm\n');

  
  models = {"1fm","3fm","5fm"};
  for i = 1:columns(models)
    the_cmd = sprintf('%s %s %s %s\n',caffe_train,char(models(i)),
                      caffe_bin,'all');
    try
      res = system(the_cmd,0,'async');
      if res == 0;
        fprintf(stderr(),'Process id returned was zero');
      else
        waitpid();
      endif
    catch
        kill(res,SIG().("INT"));
    end_try_catch
  endfor
  
endfunction

runtrain(argv());

%!error runtrain()

%!error runtrain({'./nonexistdir'})

%!error runtrain({'./nonexistdir','./yo'})
