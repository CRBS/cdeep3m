## Usage [train_model_dest] = update_solverproto_txt_file(outdir,model)
## 
## Updates solver.prototxt file in <outdir> by adjusting the 
## snapshot_prefix path. The new path is set to 
## <model>_model/<model>_classifer
##
## Function also creates a trainedmodel directory under <model> directory
## like so:
## <outdir>/<model>/trainedmodel
##
## The <model>_model/<model>_classifierpath is returned 
## via <train_model_dest> variable
##

function [train_model_dest] = update_solverproto_txt_file(outdir,model)
  solver_prototxt = strcat(outdir,filesep(),model,filesep(), 'solver.prototxt');
  s_data = fileread(solver_prototxt);
  solver_out = fopen(solver_prototxt,"w");
  lines = strsplit(s_data,'\n');
  model_dir = strcat(outdir,filesep(),model,filesep(),'trainedmodel');
  create_dir(model_dir);
  train_model_dest = strcat(model_dir,
                            filesep(),model,'_classifer');
  for j = 1:columns(lines)
    if index(char(lines(j)),'snapshot_prefix:') == 1;
      fprintf(solver_out,'snapshot_prefix: "%s"\n',train_model_dest);
    else
      fprintf(solver_out,'%s\n',char(lines(j)));
    endif
  endfor
  fclose(solver_out);
endfunction

%!error <undefined> update_solverproto_txt_file();

# test with valid solver.prototxt
%!test
%! test_fname = tempname();
%! create_dir(test_fname);
%! model = '1fm';
%! create_dir(strcat(test_fname,filesep(),model));
%! solver = strcat(test_fname,filesep(),model,filesep(),'solver.prototxt');
%! f_out = fopen(solver,'w');
%! fprintf(f_out,'#hi\n#The\ntest_interval: 20\nsnapshot_prefix: "hi"\n');
%! fprintf(f_out,'#solver\nsolver mdoe: GPU\n');
%! fclose(f_out);
%! tmd = update_solverproto_txt_file(test_fname,model);
%! tdir = strcat(test_fname,filesep(),model,filesep(),'trainedmodel');
%! assert(isdir(tdir));
%! s_data = fileread(solver);
%! lines = strsplit(s_data,'\n');
%! assert(char(lines(4)) == strcat('snapshot_prefix: "',tmd,'"'));
%! rmdir(test_fname,'s');
