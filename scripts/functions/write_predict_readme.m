## Usage write_predict_readme(outdir)
## 
## Writes out a <outdir>/readme.txt file with text 
## describing contents of this prediction folder
## 

function write_predict_readme(outdir)
  readme = strcat(outdir,filesep(), 'readme.txt');
  out = fopen(readme, "w");
  fprintf(out, "\nThis directory contains files and directories needed to\n");
  fprintf(out, "run Deep3M prediction using caffe. Below is a description\n");
  fprintf(out, "of the key files and directories:\n\n");
  fprintf(out, "1fm/,3fm/,5fm/ -- contains results from running prediction\n");
  fprintf(out, "\npredict.config -- contains path to trained model and\n");
  fprintf(out, "                    augmented images to segment\n\n");
  fprintf(out, "caffepredict.sh -- Runs prediction on individual .h5 file\n");
  fprintf(out, "\nrun_all_predict.sh -- Runs caffepredict.sh on all .h5\n");
  fprintf(out, "                        This should be what you invoke\n");
  fprintf(out, "\n");
  fclose(out);
endfunction

%!error <undefined> write_predict_config();

# test with valid directory
%!test
%! test_fname = tempname();
%! create_dir(test_fname);
%! write_predict_readme(test_fname);
%! readme_file = strcat(test_fname,filesep(),'readme.txt');
%! assert(exist(readme_file, "file"),2);
%! rmdir(test_fname,'s');
