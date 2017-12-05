#!/usr/bin/octave -qf
%
% PreprocessTraining
% Makes augmented hdf5 datafiles from raw and label images
%
% Syntax : PreprocessTraining /example/training/images/ /example/training/labels/ /savedirectory/
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

arg_list = argv ();
label_img_path = arg_list{2};

disp(label_img_path); 
trainig_img_path = arg_list{1};
outdir = arg_list{3};
tic

addpath('./scripts/')

% ----------------------------------------------------------------------------------------
%% Load train data
% ----------------------------------------------------------------------------------------

disp('Loading:');
disp(label_img_path); 
[lblstack] = imageimporter(label_img_path);


% ----------------------------------------------------------------------------------------
%% Load training images
% ----------------------------------------------------------------------------------------

disp('Loading:');
disp(trainig_img_path); 
[imgstack] = imageimporter(trainig_img_path);


% ----------------------------------------------------------------------------------------
%% Augment the data, generating 16 versions and save
% ----------------------------------------------------------------------------------------

disp('Augmenting ...');
data_arr=permute(imgstack,[3 1 2]); %from h5 to tiff /100*1000*1000
labels_arr=permute(lblstack,[3 1 2]); %from h5 to tiff /100*1000*1000

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
    %h5create(filename,'empty',[1]); 
    h5write(filename,d_details,d_tr);
    h5write(filename,l_details,l_tr); 
    %h5write(filename,d_details,d_tr); 
end

%savefile= fullfile((save_dir, 'training_full_stacks_v16.mat');
%save(savefile,'data','labels','-v7.3');
