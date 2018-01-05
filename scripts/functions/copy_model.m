## Usage copy_model( base_dir, the_model, dest_dir )
##
## Starting from base_dir directory this function
## copies *txt files from model/inception_residual_train_prediction_<the_model>
## to directory specified by dest_dir argument. If copy fails
## error() is invoked describing the issue
## 

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

%!error <undefined near> copy_model();

%!error <copyfile: no files to move> copy_model('.','weroijef','.');

%!test
%! test_fname = tempname();
%! mkdir(test_fname);
%! copy_model('.','1fm',test_fname);
%! test_dir = strcat(test_fname,filesep());
%! assert(exist(strcat(test_dir,'deploy.prototxt'),'file'), 2);
%! assert(exist(strcat(test_dir,'solver.prototxt'),'file'), 2);
%! rmdir(test_fname,'s');
