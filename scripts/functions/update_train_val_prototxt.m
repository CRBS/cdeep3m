## Usage update_train_val_prototxt(outdir, model, train_file)
##
## Updates <outdir>/<model>/train_val.prototxt file
## replacing path in data_source: line with <train_file>
##

function update_train_val_prototxt(outdir,model,train_file)
  % updates data_source in train_val.prototxt file
  train_val_prototxt = strcat(outdir,filesep(),model,filesep(),
                              'train_val.prototxt');
  t_data = fileread(train_val_prototxt);
  lines = strsplit(t_data,'\n');
  train_out = fopen(train_val_prototxt,"w");
  for j = 1:columns(lines)
    if index(char(lines(j)),'data_source:') >= 1;
      fprintf(train_out,'    data_source: "%s"\n',train_file);
    else
      fprintf(train_out,'%s\n',char(lines(j)));
    endif
  endfor
  fclose(train_out);
endfunction

%!error <undefined> update_train_val_prototxt();

# test with valid train_val.prototxt
%!test
%! test_fname = tempname();
%! create_dir(test_fname);
%! model = '1fm';
%! create_dir(strcat(test_fname,filesep(),model));
%! trainv = strcat(test_fname,filesep(),model,filesep(),'train_val.prototxt');
%! f_out = fopen(trainv,'w');
%! fprintf(f_out,'hi\nThe\ntest_interval: 20\n    data_source: "hi"\n');
%! fclose(f_out);
%! update_train_val_prototxt(test_fname,model,'boo');
%! t_data = fileread(trainv);
%! lines = strsplit(t_data,'\n');
%! assert(char(lines(4)) == '    data_source: "boo"')
%! assert(char(lines(2)) == 'The');
%! rmdir(test_fname,'s');

