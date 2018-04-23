## Usage [vfolders] = get_variation_folders ( thedir )
##
## Returns list of variation folders found within thedir
## variable passed in. The vfolders is a struct following
## same layout as that returned by isdir.

## If thedir is not a directory, error() is invoked

function [vfolders] = get_variation_folders(thedir)
  if isdir(thedir) == 0;
    errmsg = sprintf('%s is not a directory',thedir);
    error(errmsg);
  endif

  folder=fullfile(thedir);
  folderlist = dir(folder);
  vfolders = struct("name",{},"date",{},"bytes",{},"isdir",{},"datenum",{},"statinfo",{});
  vcntr = 1;
  for i = 1:rows(folderlist)
    if folderlist(i).isdir == 1;
      if strcmp(folderlist(i).name(1:1),'v') == 1;
        vfolders(vcntr++) = folderlist(i);
      endif
    endif
  endfor
endfunction

%!error <is not a directory> get_variation_folders('');

%!error <is not a directory> get_variation_folders(program_invocation_name());

