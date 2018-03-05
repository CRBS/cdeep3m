## Usage write_train_readme(outdir)
## 
## Writes out a <outdir>/readme.txt file with text 
## describing contents of this train folder
## 

function write_train_readme(outdir)
  readme = strcat(outdir,filesep(), 'readme.txt');
  out = fopen(readme, "w");
  fprintf(out, "\nIn this directory contains files and directories needed to\n");
  fprintf(out, "run CDeep3M training using caffe. Below is a description\n");
  fprintf(out, "of the key files and directories:\n\n");
  fprintf(out, "1fm/,3fm/,5fm/ -- Model directories that contain results from training via caffe.\n");
  fprintf(out, "<model>/trainedmodel -- Contains .caffemodel files that are the actual trained models\n");
  fprintf(out, "caffe_train.sh -- Runs caffe for single model\n");
  fprintf(out, "\nrun_all_predict.sh -- Runs caffe serially for all 3 models\n");
  fprintf(out, "\n");
  fclose(out);
endfunction

%!error <undefined> write_train_config();

# test with valid directory
%!test
%! test_fname = tempname();
%! create_dir(test_fname);
%! write_predict_readme(test_fname);
%! readme_file = strcat(test_fname,filesep(),'readme.txt');
%! assert(exist(readme_file, "file"),2);
%! rmdir(test_fname,'s');
