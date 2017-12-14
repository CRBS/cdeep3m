## Usage create_predict_outdir (pkgdirs,models,de_augment_file,outdir)
##
## Creates predict out directory 
## If there is an error creating directory then error() is
## invoked with message

function create_predict_outdir(pkgdirs,models,de_augment_file,outdir)
  create_dir(outdir);

  for i = 1:rows(models)
    model_dir = strcat(outdir,filesep(),char(models(i)));
    create_dir(model_dir);
    for j = 1:rows(pkgdirs)
      [d,n,e] = fileparts(char(pkgdirs(j)));
      pkgname = strcat(n,e);
      dir_to_make = strcat(model_dir,filesep(),pkgname);
      create_dir(dir_to_make);
    endfor
  endfor
%  dest_de_augment = strcat(outdir,filesep(),'de_augmentation_info.mat');
%  copyfile(de_augment_file,dest_de_augment);
endfunction

%!test
%! test_fname = tempname();
%! models = cell(3,1);
%! models(1) = ['1fm'];
%! models(2) = ['3fm'];
%! models(3) = ['5fm'];
%! pkgdirs = cell(2,1);
%! pkgdirs(1) = ['/foo/Pkg001'];
%! pkgdirs(2) = ['/foo/Pkg002'];
%! pkgnames = cell(2,1);
%! pkgnames(1) = ['Pkg001'];
%! pkgnames(2) = ['Pkg002'];
%! create_predict_outdir(pkgdirs,models,'hi',test_fname);
%! for i = 1:rows(models)
%!   model_dir = strcat(test_fname,filesep(),char(models(i)));
%!   for j = 1:rows(pkgnames)
%!      pkg_dir = strcat(model_dir,filesep(),char(pkgnames(j)));
%!      assert(isdir(pkg_dir) == 1)
%!   endfor
%! endfor
%! rmdir(test_fname,'s');

