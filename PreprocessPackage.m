#!/usr/bin/octave -qf
% preprocess_package
% receives package index numbers to process
% requires data_packagedef to have run before
% -> Makes augmented hdf5 datafiles from raw images based on defining parameters
%
% Syntax : preprocess_package indir outdir xy_package z_stack augmentation speed 
% Example: preprocess_package ~/EMdata1/ ~/AugmentedEMData/ 15 2 1fm 10
%
% Speed: supported values 1,2,4 or 10 
% speeds up processing potentially with a negative effect on accuracy (speed of 1 equals highest accuracy)
%
%
%----------------------------------------------------------------------------------------
%% preprocess_package for Deep3M -- NCMIR/NBCR, UCSD -- Author: M Haberl -- Date: 04/2018
%----------------------------------------------------------------------------------------
%
% ----------------------------------------------------------------------------------------
%% Initialize
% ----------------------------------------------------------------------------------------

disp('Starting Image Augmentation');
tic
script_dir = fileparts(make_absolute_filename(program_invocation_name()));
addpath(genpath(script_dir));

pkg load hdf5oct
pkg load image

arg_list = argv ();
%if numel(arg_list)<2; disp('Use -> PreProcessImageData /ImageData/EMdata1/ /ImageData/AugmentedEMData/'); return; end
in_img_path = arg_list{1};
outdir = arg_list{2};
ii = str2num(arg_list{3});
zz = str2num(arg_list{4});
fmtype = arg_list{5};
fmnumber = str2num(fmtype(1));
speed = str2num(arg_list{6});

fmdir = fullfile(outdir,[num2str(fmnumber),'fm']);
if ~exist(fmdir,'dir'), mkdir(fmdir); end
load(fullfile(outdir,'de_augmentation_info.mat'),'packages','num_of_pkg','imagesize','z_blocks');
% ----------------------------------------------------------------------------------------
%% 
% ----------------------------------------------------------------------------------------
if zz == 1
z_stack = [z_blocks(zz), z_blocks(zz+1)]
else
z_stack = [z_blocks(zz)+1, z_blocks(zz+1)]
end

%if ii ==1; t1 = tic; end
%if ii ==2; t_int = toc(t1)/60; end
%fprintf('------- Image Augmentation large data ------\n');
%fprintf('-------- Augmenting Part %s out of %s -------\n', num2str(ii), num2str(num_of_pkg));
%if ii>2
%fprintf('-> Remaining time estimated: %s min\n', num2str(round(t_int*(num_of_pkg-ii))));
%end
%define label name

area = packages{ii};
[stack] = imageimporter_large(in_img_path,area,z_stack); %load only subarea here
checkpoint_nobinary(stack);
disp('Padding images');
[stack] = add_z_padding(stack); %adds 2 planes i beginning and end
            
%% augment_and_saveSave image data
outsubdir = fullfile(fmdir, sprintf('Pkg%03d_Z%02d',ii, zz));
if ~exist(outsubdir,'dir'), mkdir(outsubdir); end            
augment_package(stack, outsubdir,fmnumber,speed);
clear -v stack
clear -v data

done_file = fopen(strcat(outsubdir, filesep(),"DONE"), "w");
fprintf(done_file,"0\n");
fclose(done_file);
