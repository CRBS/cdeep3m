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
script_dir = fileparts(make_absolute_filename(program_invocation_name()));
addpath(genpath(script_dir));
addpath(genpath(strcat(script_dir,filesep(),'scripts',filesep())));
addpath(genpath(strcat(script_dir,filesep(),'scripts',filesep(),'functions')));


pkg load hdf5oct
pkg load image

arg_list = argv ();
if numel(arg_list)<2; disp('Use -> PreProcessImageData /ImageData/EMdata1/ /ImageData/AugmentedEMData/'); return; end
in_img_path = arg_list{1};
outdir = arg_list{2};
if ~exist(outdir,'dir'), mkdir(outdir); end

% ----------------------------------------------------------------------------------------
%% Load image data / Check if large data first
% ----------------------------------------------------------------------------------------

imagesize = check_image_size(in_img_path);
[packages,z_blocks] = break_large_img(imagesize);
num_of_pkg = numel(packages);
%num_of_pkg =1;  %Change here to enable large image files
%{
if num_of_pkg==1 && numel(z_blocks)==2
    [stack] = imageimporter(in_img_path);
    checkpoint_nobinary(stack);
    disp('Padding images');
    [stack] = add_z_padding(stack); %adds 2 planes i beginning and end
    stack=permute(stack,[3 1 2]); %from tiff to h5 /xyz to z*x*y
    %% Augment and save:
    augment_image_data_only(stack,outdir);
    %disp('Saving Hd5 files')
    %for i=1:length(augdata)
    %    stack=augdata{i};
    %    filename = fullfile(outdir, sprintf('test_data_full_stacks_v%s.h5', num2str(i)));
    %    h5write(filename,d_details,stack);
    %end
    
    
else
 %}   
    for zz = 1:numel(z_blocks)-1
        if zz == 1
            z_stack = [z_blocks(zz), z_blocks(zz+1)]
        else
            z_stack = [z_blocks(zz)+1, z_blocks(zz+1)]
        end
        
        
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
            [stack] = imageimporter_large(in_img_path,area,z_stack); %load only subarea here
            checkpoint_nobinary(stack);
            disp('Padding images');
            [stack] = add_z_padding(stack); %adds 2 planes i beginning and end
            
            %% augment_and_saveSave image data
            outsubdir = fullfile(outdir, sprintf('Pkg%03d_Z%02d',ii, zz));
            if ~exist(outsubdir,'dir'), mkdir(outsubdir); end            
            augment_image_data_only(stack, outsubdir);
            clear -v stack
            clear -v data
            if ii ==num_of_pkg
                %save(fullfile(outdir,'packages.mat'),'packages');
                save(fullfile(outdir,'de_augmentation_info.mat'),'packages','num_of_pkg','imagesize','z_blocks');
                % To do: Write a predict file that runs through all folders in outdir
                % and write a merge file for postprocessing in outdir
            end
        end % pkgs
    end %z-block
%end

% ----------------------------------------------------------------------------------------
%% Completed
% ----------------------------------------------------------------------------------------

toc
disp('Image Augmentation completed');
fprintf('Created %s packages in x/y with %s z-stacks\n', num2str(num_of_pkg),num2str((numel(z_blocks))-1));
fprintf('Data stored in:\n %s\n', outdir);

if exist('txts.save','file')
    load('txts.save','-mat','image_info_text');
    fprintf(image_info_text);
end
