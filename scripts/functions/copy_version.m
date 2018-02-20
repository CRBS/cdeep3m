## Usage [errmsg] = copy_version( base_dir, dest_dir )
##
## Starting from base_dir directory this function
## copies the VERSION from to directory specified 
## by dest_dir argument. If copy fails errmsg is set
## to string describing error otherwise its empty string
## 

function [errmsg] = copy_version(base_dir, dest_dir)
  % Copies VERSION from base_dir/ directory to dest_dir directory  
  % If copy fails errmsg set to string describing
  % the issue, otherwise an empty string is returned.

  errmsg = '';
  src_file = strcat(base_dir, filesep(), 'VERSION');
  res = copyfile(src_file, dest_dir);
  if res(1) == 0;
    errmsg = sprintf('Error copying VERSION %s : %s\n', src_file, res(2));
  endif
endfunction

%!error <undefined near> copy_version();

%!test
%! test_fname = tempname();
%! mkdir(test_fname);
%! copy_version('.',test_fname);
%! test_dir = strcat(test_fname,filesep());
%! rmdir(test_fname,'s');
