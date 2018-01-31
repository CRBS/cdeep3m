#!/usr/bin/octave -qf
%
% PreprocessTraining
% Makes augmented hdf5 datafiles from raw and label images
%
% Syntax : PreprocessTraining /ImageData/training/images/ /ImageData/training/labels/ /ImageData/augmentedtraining/
%
%
%----------------------------------------------------------------------------------------
%% PreprocessTraining for Deep3M -- NCMIR/NBCR, UCSD -- Author: M Haberl -- Date: 10/2017
%----------------------------------------------------------------------------------------
%
% Runtime ~20min for 1024x1024x100 dataset
%


% ----------------------------------------------------------------------------------------
%% Initialize
% ----------------------------------------------------------------------------------------

disp('Starting Training data Preprocessing');
pkg load hdf5oct
pkg load image
script_dir = fileparts(make_absolute_filename(program_invocation_name()));
addpath(genpath(script_dir));
addpath(genpath(strcat(script_dir,filesep(),'scripts',filesep())));
addpath(genpath(strcat(script_dir,filesep(),'scripts',filesep(),'functions')));



arg_list = argv ();
if numel(arg_list)<3; disp('Use -> PreprocessTraining /ImageData/training/images/ /ImageData/training/labels/ /ImageData/augmentedtraining/'); return; end

tic
trainig_img_path = arg_list{1};
disp('Training Image Path:');disp(trainig_img_path); 
label_img_path = arg_list{2};
disp('Training Label Path:');disp(label_img_path); 
outdir = arg_list{3};
disp('Output Path:');disp(outdir); 

% ----------------------------------------------------------------------------------------
%% Load train data
% ----------------------------------------------------------------------------------------

disp('Loading:');
disp(label_img_path); 
[lblstack] = imageimporter(label_img_path);
checkpoint_isbinary(lblstack);

% ----------------------------------------------------------------------------------------
%% Load training images
% ----------------------------------------------------------------------------------------

disp('Loading:');
disp(trainig_img_path); 
[imgstack] = imageimporter(trainig_img_path);
checkpoint_nobinary(imgstack);

% ----------------------------------------------------------------------------------------
%% Augment the data, generating 16 versions and save
% ----------------------------------------------------------------------------------------

%imshow(labels_arr(:,:,1))
disp('Augmenting ...');
data_arr=permute(imgstack,[3 1 2]); %from tiff to h5 /100*1000*1000
labels_arr=permute(lblstack,[3 1 2]); %from tiff to h5 /100*1000*1000

d_tr =single(data_arr);
l_tr =single(labels_arr);
[data,labels]=augment_data(d_tr,l_tr); 

%[outdir,name,ext] = fileparts(save_file);

d_details = '/data'; 
l_details = '/label'; 
if ~exist(outdir,'dir'), mkdir(outdir); end
ext = '.h5';
    
disp('Saving ...');
for i=1:length(data)
    d_tr=data{i};
    l_tr=labels{i};
    filename = fullfile(outdir, sprintf('training_full_stacks_v%s%s', num2str(i), ext));
    disp(filename); 
    h5write(filename,d_details,d_tr);
    h5write(filename,l_details,l_tr); 
end

% ----------------------------------------------------------------------------------------
%% Completed
% ----------------------------------------------------------------------------------------

disp('Image Augmentation completed');
toc
fprintf('For training your model please run ./CreateTrainJob.m %s < ~/outputdirectory >\n', outdir);
