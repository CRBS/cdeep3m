#!/usr/bin/octave -qf
% Histmatch
% Match Histogram of 1 Dataset to another Dataset
% E.g. to use a model that has already been trained on another dataset
% to this end the average histogram of the second image stack will be used
% as a reference
%
% Syntax: Histmatch ~/Dataset1/ ~/Reference_Dataset2/ ~/Histomatched_Dataset1/
% Positional arguments:
% - Input dataset
% - Reference dataset
% - Output folder
% 
% Expected runtime 3min for 1024x1024x100 dataset
%
%------------------------------------------------------------------
%% CDeep3M -- NCMIR/NBCR, UCSD -- Author: M Haberl -- Date: 11/2017
%------------------------------------------------------------------

arg_list = argv ();
pkg load hdf5oct
pkg load image

if ~numel(arg_list) >= 2
  error('Please specify 1 input images/folders, 1 input reference image(s)/folders and 1 outputname');
  return
end
tic
disp('Starting Histogram matching');

%-----------------------------------------
%% Input arguments / Loading data
%-----------------------------------------
fprintf('Starting to process %d datasets \n',floor(numel(arg_list)/2));

inputdir_raw = arg_list{1};
inputdir_ref = arg_list{2};
outputfolder = arg_list{3};

%-----------------------------------------
%% Check with user before overwriting/deleting any files
%-----------------------------------------

if ~exist(outputfolder,'folder')
mkdir(outputfolder);
end

%-----------------------------------------
%% Loading data
%-----------------------------------------

raw_stack = imageimporter(inputdir_raw);
ref_stack = imageimporter(inputdir_ref);

ref_image = mean(ref_stack,3);

%-----------------------------------------
%% Histmatching and Saving
%-----------------------------------------

disp('Saving ...')
for i=1:size(raw_stack,3)
fprintf('.');
    outputfile = fullfile(outputfolder, sprintf('Image_%04d.png',i));
    hist_matched_imgs = imhistmatch(raw_stack(:,:,i),ref_image);
    imwrite(hist_matched_imgs,outputfile);    
end

toc
