#!/usr/bin/octave -qf
%
% PreprocessValidation
% Makes hdf5 validation file from raw images and corresponding labels 
%
% Syntax : PreprocessValidation ~/validation/images/ ~/validation/labels/ ~/validation/combined
%
%
%----------------------------------------------------------------------------------------
%% PreprocessTraining for Deep3M -- NCMIR/NBCR, UCSD -- Author: M Haberl -- Date: 04/2018
%----------------------------------------------------------------------------------------
%
% Runtime: <1 min
%


% ----------------------------------------------------------------------------------------
%% Initialize
% ----------------------------------------------------------------------------------------

disp('Starting Validation data Preprocessing');
pkg load hdf5oct
pkg load image
script_dir = fileparts(make_absolute_filename(program_invocation_name()));
addpath(genpath(script_dir));

arg_list = argv ();
if numel(arg_list)<3; disp('Use -> PreprocessValidation /validation/images/ /validation/labels/ /validdation/combined'); return; end

tic
trainig_img_path = arg_list{1};
disp('Validation Image Path:');disp(trainig_img_path); 
label_img_path = arg_list{2};
disp('Validation Label Path:');disp(label_img_path); 
outdir = arg_list{3};
disp('Output Path:');disp(outdir); 

% ----------------------------------------------------------------------------------------
%% Load images
% ----------------------------------------------------------------------------------------

disp('Loading:');
disp(trainig_img_path);
[imgstack] = imageimporter(trainig_img_path);
disp('Verifying images');
checkpoint_nobinary(imgstack);

% ----------------------------------------------------------------------------------------
%% Load labels
% ----------------------------------------------------------------------------------------

disp('Loading:');
disp(label_img_path);
[lblstack] = imageimporter(label_img_path);
disp('Verifying labels');
checkpoint_isbinary(lblstack);

% ----------------------------------------------------------------------------------------
%% Convert and save
% ----------------------------------------------------------------------------------------

img_v1 =single(imgstack);
lb_v1 =single(lblstack);

d_details = '/data';
l_details = '/label';
if ~exist(outdir,'dir'), mkdir(outdir); end
ext = '.h5';

    img=permute(img_v1,[3 1 2]); %from tiff to h5 /100*1000*1000
    lb=permute(lb_v1,[3 1 2]); %from tiff to h5 /100*1000*1000
    filename = fullfile(outdir, sprintf('validation_stack_v%s%s', num2str(1), ext));
    fprintf('Saving: %s\n', filename);
    h5write(filename,d_details,img);
    h5write(filename,l_details,lb);
    clear img lb

% ----------------------------------------------------------------------------------------
%% Completed
% ----------------------------------------------------------------------------------------

toc
fprintf('Validation data stored in %s\n', outdir);
