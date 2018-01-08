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
addpath(genpath(script_dir));
addpath(genpath(strcat(script_dir,filesep(),'scripts',filesep())));
addpath(genpath(strcat(script_dir,filesep(),'scripts',filesep(),'functions')));
tic
pkg load hdf5oct
pkg load image

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
  run_all_train_template=strcat(base_dir,filesep(),'scripts',filesep(),
                              'run_all_train_template.sh');
  caffe_bin='/home/ubuntu/caffe_nd_sense_segmentation/build/tools/';

  if numel(arg_list)~=2; 
    fprintf('\n');
    msg = sprintf('%s expects two command line arguments\n\n', prog_name);
    msg = strcat(msg,sprintf('Usage: %s <Input train data directory> <output directory>\n', prog_name));
    error(msg); 
    return; 
  endif

  in_img_path = make_absolute_filename(arg_list{1});

  if isdir(in_img_path) == 0;
    error('First argument is not a directory and its supposed to be');
  endif

  outdir = make_absolute_filename(arg_list{2});

  all_train_file = strcat(outdir,filesep(),'run_all_train.sh');

  if exist(all_train_file) == 2;
     fprintf('\n');
     msg = sprintf('Train.m appears to already have been run in %s directory',
                   outdir);
     msg = strcat(msg,sprintf('\nRun %s to run training\n',all_train_file));
     error(msg);
  endif
  % ---------------------------------------------------------------------------
  % Examine input training data and generate list of h5 files
  % ---------------------------------------------------------------------------
  fprintf(stdout(), 'Verifying input training data is valid ... ');
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
  
  fprintf(stdout(),'success\n');

  % ----------------------------------------------------------------------------
  % Create output directory and copy over model files and 
  % adjust configuration files
  % ----------------------------------------------------------------------------
  fprintf(stdout(),'Copying over model files and creating run scripts ... ');

  [onefm_dest,threefm_dest,fivefm_dest] = copy_over_allmodels(base_dir,outdir);
  max_iterations = 10000;
  update_solverproto_txt_file(outdir,'1fm');
  update_solverproto_txt_file(outdir,'3fm');
  update_solverproto_txt_file(outdir,'5fm');

  update_train_val_prototxt(outdir,'1fm',train_file);
  update_train_val_prototxt(outdir,'3fm',train_file);
  update_train_val_prototxt(outdir,'5fm',train_file);
  caffe_train = strcat(outdir,filesep(),'caffe_train.sh');
  copyfile(caffe_train_template,caffe_train);
  
  copyfile(run_all_train_template,all_train_file);
  system(sprintf('chmod a+x %s',all_train_file));
 
  fprintf(stdout(),'success\n\n');

  fprintf(stdout(),'A new directory has been created: %s\n', outdir);
  fprintf(stdout(),'In this directory are 3 directories 1fm,3fm,5fm which\n');
  fprintf(stdout(),'correspond to 3 caffe models that need to be trained');
  fprintf(stdout(),'as well as two scripts:\n\n');
  fprintf(stdout(),'caffe_train.sh -- Runs caffe for a single model\n');
  fprintf(stdout(),'run_all_train.sh -- Runs caffe_train.sh serially for all 3 models\n\n');

  fprintf(stdout(),'To train all 3 models run this: %s %s 2000\n\n',all_train_file, caffe_bin);
  
endfunction



runtrain(argv());

