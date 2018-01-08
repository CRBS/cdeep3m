#!/usr/bin/octave -qf
% New Postprocessing
% Syntax: StartPostprocessing /example/seg1/predict/ outputfilename /example/seg2/predict/ outputfilename2
% You can call a subsequent script with the last command e.g. AndWatershed
% In this case all predictions will be merged and used for Watershed
% subsequently
% Runtime 3min for 1024x1024x100 dataset
%
%------------------------------------------------------------------
%% New -- NCMIR/NBCR, UCSD -- Author: M Haberl -- Date: 10/2017
%------------------------------------------------------------------
arg_list = argv ();
addpath(genpath('./scripts/'));
addpath(genpath('/home/ubuntu/deep3m/scripts/'));
pkg load hdf5oct
pkg load image

if ~numel(arg_list) >= 2
  disp('Please specify at least 1 input directory and 1 outputname');  
  disp('Use -> StartPostprocessing /example/seg1/predict/ outputfilename /example/seg2/predict/ outputfilename2'); 
return 
end
tic

%% Enable batch processing all predictions
disp('Starting to merge de-augment data');
fprintf('Starting to process %d datasets \n',floor(numel(arg_list)/2));
for i = 1:floor(numel(arg_list)/2)
inputdir = arg_list{(2*i)-1};
outputname = arg_list{(2*i)};

if ~isdir(inputdir)
  error(sprintf('%s not a input directory',inputdir));
  return
end


%addpath(genpath('./PostProcessing'))
%load("-ascii",filename);
%addpath(fullfile(program_dir,'scripts'));

fprintf('Generating Average Prediction of %s\n',inputdir)
average_prob_folder = merge_16_probs_v2(inputdir);


%save_mat_file=fullfile(inputdir,['ave_probs_',outputname, '.mat']);
%save_h5_file=fullfile(inputdir, ['ave_probs_',outputname,'.h5']);
%save(save_mat_file,'average','-V7');
%p=single(average);
%d_details = '/probabilities';
%hdf5write(save_h5_file,d_details,p);

end
fprintf('Elapsed runtime for data-deaugmentation: %04d seconds.\n', round(toc));
tic

%% Run Merge Predictions now
%MergePredictions 

%% Run 3D Watershed if required
if regexpi(arg_list{end},'water','once')
readvars =1;   
Run_3DWatershed_onPredictions
end
