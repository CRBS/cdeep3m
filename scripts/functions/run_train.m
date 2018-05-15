## Usage run_train(arg_list)
##
## Sets up directory and scripts to run training on CDeep3M model by caffe. 
## arg_list should contain two a element cell array with first value 
## set to path to augmented training data and the second argument the 
## destination output directory
##
## Example: arg_list = 
##          {
##            [1,1] = /foo/traindata
##            [2,1] = /foo/output
##            [3,1] = /foo/validationdata
##          }
##

function run_train(arg_list)
  % Runs CDeep3M train using caffe. 
  % Usage runtrain(cell array of strings) 
  % by first verifying first argument is path to training data and
  % then copying over models under model/ directory to output directory
  % suffix for hdf5 files
  H_FIVE_SUFFIX='.h5';
  prog_name = program_name();
  base_dir = fileparts(make_absolute_filename(program_invocation_name()));

  if numel(arg_list) < 2; 
    fprintf('\n');
    msg = sprintf('%s expects at least two command line arguments\n\n', prog_name);
    msg = strcat(msg,
                 sprintf('Usage: %s <Input train data directory> <output directory> <validatoin data directory> (validation data is optional)\n',
                         prog_name));
    error(msg); 
    return; 
  endif

  in_img_path = make_absolute_filename(arg_list{1});

  if isdir(in_img_path) == 0;
    error('First argument is not a directory and its supposed to be');
  endif

  outdir = make_absolute_filename(arg_list{2});

  validation_img_path = make_absolute_filename(arg_list{3});

  if isdir(validation_img_path) == 0;
    error('Third argument is not a directory and its supposed to be');
  endif
  % ---------------------------------------------------------------------------
  % Examine input training data and generate list of h5 files
  % ---------------------------------------------------------------------------
  fprintf(stdout(), 'Verifying input training data is valid ... ');
  [status, errmsg, train_file, valid_file] = verify_and_create_train_file(in_img_path, outdir, validation_img_path);

  if status != 0;
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

  update_train_val_prototxt(outdir,'1fm',train_file,valid_file);
  update_train_val_prototxt(outdir,'3fm',train_file,valid_file);
  update_train_val_prototxt(outdir,'5fm',train_file,valid_file);
 
  copy_version(base_dir, outdir);
  write_train_readme(outdir); 
  fprintf(stdout(),'success\n\n');

  fprintf(stdout(),'A new directory has been created: %s\n', outdir);
  fprintf(stdout(),'In this directory are 3 directories 1fm,3fm,5fm which\n');
  fprintf(stdout(),'correspond to 3 caffe models that need to be trained\n');
  
endfunction

