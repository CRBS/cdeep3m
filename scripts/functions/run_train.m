## Usage run_train(arg_list)
##
## Sets up directory and scripts to run training on Deep3M model by caffe. 
## arg_list should contain two a element cell array with first value 
## set to path to augmented training data and the second argument the 
## destination output directory
##
## Example: arg_list = 
##          {
##            [1,1] = /foo/traindata
##            [2,1] = /foo/output
##          }
##

function run_train(arg_list)
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
    msg = strcat(msg,
                 sprintf('Usage: %s <Input train data directory> <output directory>\n',
                         prog_name));
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
     msg = sprintf('CreateTrainJob.m appears to already have been run in %s directory',
                   outdir);
     msg = strcat(msg,sprintf('\nRun %s to run training\n',all_train_file));
     error(msg);
  endif
  % ---------------------------------------------------------------------------
  % Examine input training data and generate list of h5 files
  % ---------------------------------------------------------------------------
  fprintf(stdout(), 'Verifying input training data is valid ... ');
  [status, errmsg, train_file] = verify_and_create_train_file(in_img_path, outdir);

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
  fprintf(stdout(),'run_all_train.sh -- Runs caffe_train.sh serially for ');
  fprintf(stdout(),'all 3 models\n\n');

  fprintf(stdout(),'To train all 3 models run this: %s %s 2000\n\n',
          all_train_file, caffe_bin);
  
endfunction

