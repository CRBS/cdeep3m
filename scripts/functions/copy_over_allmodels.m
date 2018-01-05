## Usage [onefm_dest, threefm_dest, fivefm_dest] = copy_over_allmodels( base_dir, outdir )
##
## Create outdir directory and copy over model files for
## 1fm, 3fm, and 5fm models. It is assumed that
## base_dir directory contains the deep3m source tree
## and there exists model/inception_residual_train_prediction_<model>
## directories
##
## Upon success three directory paths are returned,
## one for each model

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

%!error <undefined near> copy_over_allmodels();

%!test
%! test_fname = tempname()
%! mkdir(test_fname);
%! [one, three, five] = copy_over_allmodels('.', test_fname);
%! one_dir = strcat(one,filesep());
%! three_dir = strcat(three,filesep());
%! five_dir = strcat(five,filesep());
%! assert(exist(strcat(one_dir,'deploy.prototxt'),'file'), 2);
%! assert(exist(strcat(three_dir,'solver.prototxt'),'file'), 2);
%! assert(exist(strcat(five_dir,'solver.prototxt'),'file'), 2);
%! rmdir(test_fname,'s');

