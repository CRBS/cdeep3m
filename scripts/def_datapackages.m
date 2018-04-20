#!/usr/bin/octave -qf
% def_datapackages
%
% -> Defines size of datapackages used for augmentation of image data
% Input: Image folder and output directory to store de_augmentation file
% Output: de_augmentation_info.mat
%
% Syntax : def_datapackages /ImageData/EMdata1/ /ImageData/AugmentedEMData/
%
%
%----------------------------------------------------------------------------------------
%% PreProcessImageData for CDeep3M -- NCMIR/NBCR, UCSD -- Author: M Haberl
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
%% 
% ----------------------------------------------------------------------------------------

imagesize = check_image_size(in_img_path);
[packages,z_blocks] = break_large_img(imagesize);
num_of_pkg = numel(packages);
save(fullfile(outdir,'de_augmentation_info.mat'),'packages','num_of_pkg','imagesize','z_blocks');

document = fullfile(outdir,'package_processing_info.txt');
opendoc = fopen(document, "w");
fprintf(opendoc, '\nNumber of XY Packages\n%s\nNumber of z-blocks\n%s',  num2str(num_of_pkg),num2str(numel(z_blocks)-1));
fclose(opendoc);
