#!/usr/bin/octave -qf


script_dir = fileparts(make_absolute_filename(program_invocation_name()));

dist_dir=make_absolute_filename(strcat(script_dir,filesep(),'..'));

old_dir = cd(dist_dir);

addpath(genpath(dist_dir));
addpath(genpath(strcat(dist_dir,filesep(),'scripts',filesep())));
addpath(genpath(strcat(dist_dir,filesep(),'scripts',filesep(),'functions')));

test_files = vertcat(glob('*.m'), glob('*/*.m'),glob('*/*/*.m'));
numfailed=0;
for x = 1:rows(test_files)
  t_file = char(test_files(x));
  t_file_data = fileread(t_file);
  lines = strsplit(t_file_data,'\n');
  run_test = 0;
  for j = 1:columns(lines)
    if index(char(lines(j)),'%!') == 1;
      run_test = 1;
      break;
    endif
  endfor
  if run_test == 1;
    success = test(t_file,"quiet",stdout());
    if success == 0;
      numfailed+=1;
    endif
  endif
endfor

cd(old_dir);

if numfailed > 0;
  error(sprintf('%d tests failed', numfailed));
endif
