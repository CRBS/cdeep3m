#!/usr/bin/octave -qf
% New Postprocessing
% Syntax: StartPostprocessing /example/seg1/predict/ /example/seg2/predict/
%
% Runtime estimate 2min for 1024x1024x100 dataset
%
%------------------------------------------------------------------
%% New -- NCMIR/NBCR, UCSD -- Author: M Haberl -- Date: 10/2017
%------------------------------------------------------------------
arg_list = argv ();
script_dir = fileparts(make_absolute_filename(program_invocation_name()));
addpath(genpath(script_dir));
addpath(genpath(strcat(script_dir,filesep(),'scripts',filesep())));
addpath(genpath(strcat(script_dir,filesep(),'scripts',filesep(),'functions')));
addpath(genpath(strcat(script_dir,filesep(),'scripts',filesep(),'post_processing')));

pkg load hdf5oct
pkg load image

if ~numel(arg_list) >= 1
  disp('Please specify at least 1 input directory');  
  disp('Use -> StartPostprocessing /example/seg1/predict/ /example/seg2/predict/'); 
return 
end
tic

%% Enable batch processing all predictions
disp('Starting to merge de-augment data');
fprintf('Starting to process %d datasets \n',(numel(arg_list)));
for i = 1:floor(numel(arg_list))
inputdir = arg_list{i};

if ~isdir(inputdir)
  error(sprintf('%s not a input directory',inputdir));
  return
end

fprintf('Generating Average Prediction of %s\n',inputdir)
average_prob_folder = merge_16_probs_v2(inputdir);

end
fprintf('Elapsed runtime for data-deaugmentation: %04d seconds.\n', round(toc));

%% Run Merge Predictions now
%MergePredictions 

%% Run 3D Watershed if required
%if regexpi(arg_list{end},'water','once')
%readvars =1;   
%Run_3DWatershed_onPredictions
%end
