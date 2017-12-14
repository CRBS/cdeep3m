## Usage [pkgfolders] = get_pkg_folders ( thedir )
##
## Returns list of of package folders in thedir passed in.
## If there is an error creating directory then error() is
## invoked with message

function [pkgfolders] = get_pkg_folders(thedir)
  if isdir(thedir) == 0;
    errmsg = sprintf('%s is not a directory',thedir);
    error(errmsg);
  endif

  pkgfolders = glob(strcat(thedir,filesep(),'Pkg*'));

  % examine all entries and remove any that are NOT directories
  for i = 1:rows(pkgfolders)
    if isdir(char(pkgfolders(i))) == 0;
      pkgfolders(strcmp(pkgfolders,pkgfolders(i))) = [];
    endif
  endfor
endfunction

%!error <is not a directory> get_pkg_folders('');

%!error <is not a directory> get_pkg_folders(program_invocation_name());

%!test
%! test_fname = tempname();
%! mkdir(test_fname);
%! [res] = get_pkg_folders(test_fname);
%! assert(columns(res) == 0);
%! one_pkg = strcat(test_fname,filesep(),'Pkg001');
%! mkdir(one_pkg);
%! [res] = get_pkg_folders(test_fname);
%! assert(rows(res) == 1);
%! assert(char(res(1)) == one_pkg);
%! two_pkg = strcat(test_fname,filesep(),'Pkg002');
%! mkdir(two_pkg);
%! [res] = get_pkg_folders(test_fname);
%! assert(rows(res) == 2);
%! de_aug_file = strcat(test_fname,filesep(),'de_augmentation_info.mat');
%! f_out = fopen(de_aug_file,'w');
%! fprintf(f_out,'hi\n');
%! fclose(f_out);
%! [res] = get_pkg_folders(test_fname);
%! assert(rows(res) == 2);
%! pkg_file = strcat(test_fname,filesep(),'Pkg003');
%! f_out = fopen(pkg_file,'w');
%! fprintf(f_out,'hi\n');
%! fclose(f_out);
%! [res] = get_pkg_folders(test_fname);
%! assert(rows(res) == 2);
%! rmdir(test_fname,'s');

