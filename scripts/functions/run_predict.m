## Usage run_predict(arg_list)
## Runs Deep3m prediction using caffe. 
## by first verifying first argument is path to training data and
## then copying over models under model/ directory to output directory
## suffix for hdf5 files


function run_predict(arg_list)
  H_FIVE_SUFFIX='.h5';
  prog_name = program_name();
  base_dir = fileparts(make_absolute_filename(program_invocation_name()));
  
  caffe_predict_template=strcat(base_dir,filesep(),'scripts',filesep(),
                                'caffepredict_template.sh');
  run_all_predict_template=strcat(base_dir,filesep(),'scripts',filesep(),
                                  'run_all_predict_template.sh');
  caffe_bin='/home/ubuntu/caffe_nd_sense_segmentation/build/tools/';

  if numel(arg_list)~=3; 
    fprintf('\n');
    msg = sprintf('%s expects three command line arguments\n\n', prog_name);
    msg = strcat(msg,sprintf('Usage: %s <Output of Train.m after training run> <augmented image data> <output directory>\n', prog_name));
    error(msg); 
    return; 
  endif

  train_model_path = make_absolute_filename(arg_list{1});

  if isdir(train_model_path) == 0;
    error('First argument is not a directory and its supposed to be');
  endif

  img_data = make_absolute_filename(arg_list{2});

  if isdir(img_data) == 0;
    error('Second argument is not a directory and its supposed to be');
  endif

  outdir = make_absolute_filename(arg_list{3});

  all_predict_file = strcat(outdir,filesep(),'run_all_predict.sh');

  if isdir(outdir) == 1;
     fprintf('\n');
     msg = sprintf('Predict.m appears to already have been run in %s directory',
                   outdir);
     msg = strcat(msg,sprintf('\nRun %s to run prediction\n',all_predict_file));
     error(msg);
  endif

  % ---------------------------------------------------------------------------
  % Examine input training data and generate list of h5 files
  % ---------------------------------------------------------------------------
  fprintf(stdout(), 'Verifying input training data is valid ... ');
  train_model_names = get_train_basemodel_names(train_model_path);
  fprintf(stdout(),'skipping check, TODO need to fix this.\n');

  % ---------------------------------------------------------------------------
  % Examine input image data, validate, and get list of pkg folders
  % ---------------------------------------------------------------------------
  fprintf(stdout(), 'Verifying image data and getting Pkg folders ... ');
  pkg_folders = get_pkg_folders(img_data);  
  fprintf(stdout(),'skipping check, TODO need to fix this.\n');

  % ----------------------------------------------------------------------------
  % Create output directories with 1fm,3fm,5fm model folder and packages
  % also copy over de_augment.m files.
  % ----------------------------------------------------------------------------
  fprintf(stdout(),'Creating output directories and creating run scripts ... ');
  
  de_augment_file = strcat(img_data,filesep(),'de_augmentation_info.mat');
  create_predict_outdir(pkg_folders,train_model_names,outdir);
  copyfile(de_augment_file,strcat(outdir,filesep(),'de_augmentation_info.mat'));
  caffe_predict = strcat(outdir,filesep(),'caffe_predict.sh');
  copyfile(caffe_predict_template,caffe_predict);

  all_predict_file = strcat(outdir,filesep(),'run_all_predict.sh');  
  copyfile(run_all_predict_template,all_predict_file);
  system(sprintf('chmod a+x %s',all_predict_file));
 
  fprintf(stdout(),'success\n\n');

  fprintf(stdout(),'A new directory has been created: %s\n', outdir);
  fprintf(stdout(),'In this directory are 3 directories 1fm,3fm,5fm which\n');
  fprintf(stdout(),'will contain the results from running prediction with caffe');
  fprintf(stdout(),'There are also two scripts:\n\n');
  fprintf(stdout(),'caffe_predict.sh -- Runs caffe prediction single model\n');
  fprintf(stdout(),'run_all_predict.sh -- Runs caffe_predict.sh serially for all 3 models\n\n');

  fprintf(stdout(),'To run prediction for all 3 models run this: %s %s %s %s\n\n',
          all_predict_file, train_model_path,img_data,caffe_bin);
  
endfunction

%!error <expects three command> run_predict([]);

%!function x = get_args_with_all_bad_paths();
%! x = cell(3,1);
%! x(1) = ['Predict.m'];
%! x(2) = ['asdfasdf'];
%! x(3) = ['xxxx'];
%!endfunction

%!error <First argument is not> run_predict(get_args_with_all_bad_paths());

%!function x = get_args_second_path_bad();
%! x = cell(3,1);
%! x(1) = [make_absolute_filename('.')];
%! x(2) = ['asdfasdf'];
%! x(3) = ['asdfasdf'];
%!endfunction

%!error <Second argument is not> run_predict(get_args_second_path_bad());


