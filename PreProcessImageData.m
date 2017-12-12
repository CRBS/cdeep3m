#!/usr/bin/octave -qf
% PreProcessImageData
% Run Data Augmentation only for Images to segment
% -> Makes augmented hdf5 datafiles from raw images
% -> Will break large image dataset into packages
%
% Syntax : PreProcessImageData /ImageData/EMdata1/ /ImageData/AugmentedEMData/
%
%
%----------------------------------------------------------------------------------------
%% PreProcessImageData for Deep3M -- NCMIR/NBCR, UCSD -- Author: M Haberl -- Date: 11/2017
%----------------------------------------------------------------------------------------
%
% ----------------------------------------------------------------------------------------
%% Initialize
% ----------------------------------------------------------------------------------------

disp('Starting Image Augmentation');
tic
addpath(genpath('./scripts/'));
addpath(genpath('/home/ubuntu/deep3m/scripts/'));
pkg load hdf5oct
pkg load image

arg_list = argv ();
if numel(arg_list)<2; disp('Use -> PreProcessImageData /ImageData/EMdata1/ /ImageData/AugmentedEMData/'); return; end
in_img_path = arg_list{1};
outdir = arg_list{2};

% ----------------------------------------------------------------------------------------
%% Load image data / Check if large data first
% ----------------------------------------------------------------------------------------

imagesize = check_image_size(in_img_path);
packages = break_large_img(imagesize);
num_of_pkg = numel(packages);
%num_of_pkg =1;  %Change here to enable large image files

if num_of_pkg ==1
    [d_tr] = imageimporter(in_img_path);
    checkpoint_nobinary(d_tr);
    [d_tr] = add_z_padding(d_tr); %adds 2 planes i beginning and end
    d_tr=permute(d_tr,[3 1 2]); %from tiff to h5 /xyz to z*x*y
    %% Save image data
    d_details = '/data';
    %%augment_and_save
    [data]=augment_image_data_only(d_tr);
    if ~exist(outdir,'dir'), mkdir(outdir); end
    disp('Saving Hd5 files')
    for i=1:length(data)
        d_tr=data{i};
        filename = fullfile(outdir, sprintf('test_data_full_stacks_v%s.h5', num2str(i)));
        h5write(filename,d_details,d_tr);
    end
    
    
elseif num_of_pkg > 1
    for ii = 1:num_of_pkg
        if ii ==1; t1 = tic; end
        if ii ==2; t_int = toc(t1)/60; end
        fprintf('------- Image Augmentation large data ------\n');
        fprintf('-------- Augmenting Part %s out of %s -------\n', num2str(ii), num2str(num_of_pkg));
        if ii>2
        fprintf('-> Remaining time estimated: %s min\n', num2str(round(t_int*(num_of_pkg-ii))));
        end
        %define label name
        area = packages{ii};
        [d_tr] = imageimporter_large(in_img_path,area); %load only subarea here
        checkpoint_nobinary(d_tr);
        [d_tr] = add_z_padding(d_tr); %adds 2 planes i beginning and end
        d_tr=permute(d_tr,[3 1 2]); %from tiff to h5 /xyz to z*x*y
        %% Save image data
        d_details = '/data';
        %%augment_and_save
        [data]=augment_image_data_only(d_tr);
        
        outsubdir = fullfile(outdir, sprintf('Pkg_%03', ii));
        if ~exist(outsubdir,'dir'), mkdir(outsubdir); end
        disp('Saving Hd5 files')
        for i=1:length(data)
            subdata=data{i};
            filename = fullfile(outsubdir, sprintf('test_data_full_stacks_v%s.h5', num2str(i)));
            %h5create(filename,d_details,size(subdata)); %nescessary for Matlab not for Octave
            h5write(filename,d_details,subdata);
        end
        
        if ii ==num_of_pkg
        %save(fullfile(outdir,'packages.mat'),'packages');
        save(fullfile(outdir,'de_augmentation_info.mat'),'packages','num_of_pkg');
        % To do: Write a predict file that runs through all folders in outdir
        % and write a merge file for postprocessing in outdir
        end

    end
end

% ----------------------------------------------------------------------------------------
%% Completed
% ----------------------------------------------------------------------------------------

disp('Image Augmentation completed');
toc
if exist('txts.save','file')
load('txts.save','-mat','image_info_text');
fprintf(image_info_text);
end
