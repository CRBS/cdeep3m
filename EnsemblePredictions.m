#!/usr/bin/octave -qf
%% EnsemblePredictions
% different predictions coming from files e.g. from 1fm 3fm and 5fm will be averaged here
% flexible number of inputs
% last argument has to be the outputdirectory where the average files are stored
%
% -----------------------------------------------------------------------------
%% NCMIR, UCSD -- Author: M Haberl -- Data: 10/2017
% -----------------------------------------------------------------------------
%

%% Initialize
pkg load hdf5oct
pkg load image

addpath(genpath('./scripts/'));
tic

arg_list = argv ();

if numel(arg_list) < 3
  fprintf('Please specify more than one input directory to average: EnsemblePredictions ./inputdir1 ./inputdir2 ./inputdir3 ./outputdir\n',arg_list{i});
  return
end

for i = 1:(numel(arg_list)-1)
    to_process{i} = arg_list{i};
    if ~isdir(arg_list{i})
    fprintf('%s not a directory\nPlease use: EnsemblePredictions ./inputdir1 ./inputdir2 ./inputdir3 ./outputdir\n',arg_list{i});
    return
    end
    list{i} = read_files_in_folder(to_process{i});
end
outputdir = arg_list{numel(arg_list)};
mkdir(outputdir);
%raw_image_full_path = arg_list{end};

%% =============== Generate ensemble predictions =================================

%merged_file_save=fullfile(outfolder, 'EnsemblePredict.tiff');
%if exist(merged_file_save, 'file'),delete(merged_file_save); end
%outputdir =  fileparts(to_process{1}); % Writes automatically in the parent directory of the first prediction folder 
total_zplanes = size(list{1},1);
for z = 1:total_zplanes
    for proc = 1:numel(to_process)                
        image_name = fullfile(to_process{proc}, list{proc}(z).name);
        cumul_plane(:,:,proc) = imread(image_name);   %Cumulate all average predictions of this plane
    end    
        prob_map = mean(cumul_plane,3);
        save_file_save = fullfile(outputdir, list{1}(z).name);
        fprintf('Saving Image # %s of %s: %s\n', num2str(z), num2str(total_zplanes),save_file_save);
 		imwrite(prob_map, save_file_save);   
end

fprintf('Elapsed time for merging predictions is %06d seconds.\n', round(toc));
