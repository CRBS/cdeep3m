#!/usr/bin/octave -qf 

% Run Postprocessing -- Step 1
%
% Runtime 3min for 1024x1024x100 dataset
%
%------------------------------------------------------------------
%% Adapted -- NCMIR/NBCR, UCSD -- Author: M Haberl -- Date: 10/2017
%------------------------------------------------------------------
pkg load hdf5oct
arg_list = argv ()
if ~size(arg_list) >= 1
  error('Please specify input directory');
  return
end

inputdir = arg_list{1}

if ~isdir(inputdir)
  error('Please specify input directory'); 
  return
end

fprintf('Input directory is: %s\n',inputdir)

%labelfilename = arg_list{2};
tic
addpath(genpath(pwd));  % Not sure about the datastructure on AWS

%addpath(genpath('./PostProcessing'))
%load("-ascii",filename);
%addpath(fullfile(program_dir,'scripts'));

cd(inputdir)
fprintf('Generating Average Prediction of %s\n',inputdir)
average=generate_16_average_probs(inputdir);
save_mat_file=fullfile(inputdir,'ave_probs.mat');
save_h5_file=fullfile(inputdir, 'ave_probs.h5');
save(save_mat_file,'average','-v7');
p=single(average);
d_details.location = '/';
d_details.Name = 'probabilities';
h5write(save_h5_file,d_details,p);
rmpath(genpath(pwd));
fprintf('Elapsed runtime is %04d seconds.\n', round(toc));
