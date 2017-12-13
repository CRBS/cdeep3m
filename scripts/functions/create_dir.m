## Usage create_dir( thedir )
##
## Creates directory thedir if it does not already exist.
## If there is an error creating directory then error() is
## invoked with message

function create_dir(thedir)
  if isdir(thedir) == 0;
    mkdir_result = mkdir(thedir);
    if mkdir_result(1) == 0;
      errmsg = sprintf('Error making directory: %s : %s\n', mkdir_result(1),
                       mkdir_result(2));
      error(errmsg);
    endif
  endif
endfunction

%!test
%! test_fname = tempname();
%! create_dir(test_fname);
%! assert(isdir(test_fname),'expected a directory to be created');
%! rmdir(test_fname);
