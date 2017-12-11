#!/usr/bin/octave -qf

test_files = glob('*.m');

test_files = vertcat(test_files, glob('*/*.m'));

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
    fprintf(stdout(),'%s -- ',t_file);
    test(t_file,"quiet",stdout());
  endif
endfor

