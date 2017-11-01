#!/usr/bin/octave -qf
%
% PreprocessTraining
% Makes augmented hdf5 datafiles from raw and label images
%
% Syntax : PreprocessTraining /example/training/images/ /example/training/labels/ /savedirectory/trainingfilename
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

pkg load hdf5oct
pkg load image

arg_list = argv ();
label_img_path = arg_list{1};
trainig_img_path = arg_list{2};
save_file = arg_list{3};
tic

% ----------------------------------------------------------------------------------------
%% Load train data
% ----------------------------------------------------------------------------------------

[lblstack] = imageimporter(label_img_path);


% ----------------------------------------------------------------------------------------
%% Load training images
% ----------------------------------------------------------------------------------------

[imgstack] = imageimporter(trainig_img_path);


% ----------------------------------------------------------------------------------------
%% Augment the data, generating 16 versions and save
% ----------------------------------------------------------------------------------------

data_arr=permute(imgstack,[3 1 2]); %from h5 to tiff /100*1000*1000
labels_arr=permute(lblstack,[3 1 2]); %from h5 to tiff /100*1000*1000

d_tr =single(data_arr);
l_tr =single(labels_arr);
[data,labels]=augment_data(d_tr,l_tr)

[outdir,name,ext] = fileparts(save_file);
if ~exist(outdir,'dir'), mkdir(outdir); end
ext = '.h5';
for i=1:length(data)
    d_tr=data{i};
    l_tr=labels{i};
    filename = fullfile(outdir, name, sprintf('training_full_stacks_v%s%s', num2str(i), ext));
    h5write(filename,d_details,d_tr,l_details,l_tr);
end

%savefile= fullfile((save_dir, 'training_full_stacks_v16.mat');
%save(savefile,'data','labels','-v7.3');