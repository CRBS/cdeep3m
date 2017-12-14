## Usage [pkgfolders] = get_train_basemodel_names ( thedir )
##
## Returns list of of *fm directories in thedir passed in.
## If there is an error creating directory then error() is
## invoked with message

function [trainfolders] = get_train_basemodel_names(thedir)
  if isdir(thedir) == 0;
    errmsg = sprintf('%s is not a directory',thedir);
    error(errmsg);
  endif

  trainfolders = glob(strcat(thedir,filesep(),'*fm'));

  % examine all entries and remove any that are NOT directories
  for i = 1:rows(trainfolders)
    if isdir(char(trainfolders(i))) == 0;
      trainfolders(strcmp(trainfolders,trainfolders(i))) = [];
    else
      [dir,name,ext] = fileparts(char(trainfolders(i)));
      trainfolders(i) = [strcat(name,ext)];
    endif
  endfor
endfunction

%!error <is not a directory> get_train_basemodel_names('');

%!error <is not a directory> get_train_basemodel_names(program_invocation_name());

%!test
%! test_fname = tempname();
%! mkdir(test_fname);
%! [res] = get_train_basemodel_names(test_fname);
%! assert(columns(res) == 0);
%! one_fm = strcat(test_fname,filesep(),'1fm');
%! mkdir(one_fm);
%! [res] = get_train_basemodel_names(test_fname);
%! assert(rows(res) == 1);
%! assert(char(res(1)) == '1fm');
%! three_fm = strcat(test_fname,filesep(),'3fm');
%! mkdir(three_fm);
%! [res] = get_train_basemodel_names(test_fname);
%! assert(rows(res) == 2);
%! de_aug_file = strcat(test_fname,filesep(),'de_augmentation_info.mat');
%! f_out = fopen(de_aug_file,'w');
%! fprintf(f_out,'hi\n');
%! fclose(f_out);
%! [res] = get_train_basemodel_names(test_fname);
%! assert(rows(res) == 2);
%! pkg_file = strcat(test_fname,filesep(),'6fm');
%! f_out = fopen(pkg_file,'w');
%! fprintf(f_out,'hi\n');
%! fclose(f_out);
%! [res] = get_train_basemodel_names(test_fname);
%! assert(rows(res) == 2);
%! rmdir(test_fname,'s');

