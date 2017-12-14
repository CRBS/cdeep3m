## Usage create_dir( thedir )
##
## Creates directory thedir if it does not already exist.
## If there is an error creating directory then error() is
## invoked with message

function create_dir(thedir)
  if isdir(thedir) == 0;
    [status,msg,msgid] = mkdir(thedir);
    if status == 0;
      errmsg = sprintf('Error making directory: %s : %s\n', status,
                       msg);
      error(errmsg);
    endif
  endif
endfunction

%!test
%! test_fname = tempname();
%! create_dir(test_fname);
%! assert(isdir(test_fname),'expected a directory to be created');
%! rmdir(test_fname);

