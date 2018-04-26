## Usage [status, errmsg, train_file, valid_file] = verify_and_create_train_file ( train_input, outdir, valid_input="" )
##
## 1st Looks for files ending with .h5 in train_input directory
## and verifies there are 16 of them. 2nd code creates a
## train_file.txt in the outdir directory that has a list
## of full paths to these h5 files. 
##
## Upon success train_file will have the path to the train_file.txt created
## by this function.
##
## If there is an error status will be set to a non zero numeric
## value and errmsg will explain the issue. 

function [status,errmsg, train_file, valid_file] = verify_and_create_train_file (train_input, outdir, valid_input="")
  errmsg = '';
  train_file = '';
  valid_file = ''; 
  status = 0;
  H_FIVE_SUFFIX='.h5';

  if isdir(train_input) == 0;
    errmsg = sprintf('%s is not a directory', train_input);
    status = 1;
    return;
  endif

  train_files = glob(strcat(train_input, filesep(),'*', H_FIVE_SUFFIX));

  if rows(train_files) != 16;
    errmsg = sprintf('Expecting 16 .h5 files, but got: %d', rows(train_files));
    status = 3;
    return;
  endif

  create_dir(outdir);
 
  train_file = strcat(outdir, filesep(),'train_file.txt');
  train_out = fopen(train_file, "w");
  for i = 1:rows(train_files)
     fprintf(train_out,'%s\n',char(train_files(i)));
  endfor
  fclose(train_out);

  % If user specified validation file 
  if !isempty(valid_input); 

    if isdir(valid_input) == 0;
      errmsg = sprintf('%s is not a directory', valid_input);
      status = 1;
      return;
    endif
    
    valid_files = glob(strcat(valid_input, filesep(),'*', H_FIVE_SUFFIX));
    
    if rows(valid_files) != 16;
      errmsg = sprintf('Expecting 16 .h5 files, but got: %d', rows(valid_files));
      status = 3;
      return;
    endif
    
    
    valid_file = strcat(outdir, filesep(),'valid_file.txt');
    valid_out = fopen(valid_file, "w");
    for i = 1:rows(valid_files)
      fprintf(valid_out,'%s\n',char(valid_files(i)));
    endfor
    fclose(valid_out);

  else
    valid_file = train_file; 
  endif
endfunction

%!test
%! [status,errmsg, tf] = verify_and_create_train_file('','');
%! assert(status, 1);

%!test
%! test_fname = tempname();
%! mkdir(test_fname);
%! dest_dir = strcat(test_fname,filesep(),'out');
%! mkdir(dest_dir);
%! for i = 1:16
%!   hfile = sprintf('%s%sfoo_v%d.h5',test_fname,filesep(),i);
%!   fout = fopen(hfile, "w");
%!   fprintf(fout,"hi\n");
%!   fclose(fout);
%! endfor
%! [status,errmsg, tf] = verify_and_create_train_file(test_fname,dest_dir);
%! assert(status, 0);
%! assert(errmsg, '');
%! assert(tf, strcat(dest_dir,filesep(),"train_file.txt"));
%! rmdir(test_fname, 's');
