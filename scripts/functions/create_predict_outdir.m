## Usage create_predict_outdir (pkgdirs,de_augment_file,outdir)
##
## Creates predict out directory 
## If there is an error creating directory then error() is
## invoked with message

function create_predict_outdir(pkgdirs,models,de_augment_file,outdir)
  create_dir(outdir);

  for i = 1:rows(models)
    for j = 1:rows(pkgfolders)
      dir_to_make = strcat(outdir,filesep(),char(models(i)),filesep(),
                           char(pkgfolders(j)));
      create_dir(dir_to_make);
    endfor
  endfor
  dest_de_augment = strcat(outdir,filesep(),'de_augmentation_info.mat');
  copyfile(de_augment_file,dest_de_augment);
endfunction

