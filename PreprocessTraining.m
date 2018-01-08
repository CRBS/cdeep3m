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
addpath(genpath('./scripts/'));
addpath(genpath('/home/ubuntu/deep3m/scripts/'));

arg_list = argv ();
if numel(arg_list)<3; disp('Use -> PreprocessTraining /ImageData/training/images/ /ImageData/training/labels/ /ImageData/augmentedtraining/'); return; end

tic
trainig_img_path = arg_list{1};
disp('Training Image Path:');disp(trainig_img_path); 
label_img_path = arg_list{2};
disp('Training Label Path:');disp(label_img_path); 
outdir = arg_list{3};
disp('Output Path:');disp(outdir); 



if exist('train_file.txt','file');  reply = input('Do you want delete existing <train_file.txt> File? Y/N [Y]:','s'); 
if isempty(reply); reply = 'Y'; end
if reply == 'Y'; delete('train_file.txt'); end
end
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
    %h5create(filename,'empty',[1]); 
    h5write(filename,d_details,d_tr);
    h5write(filename,l_details,l_tr); 
    
    fid = fopen('train_file.txt', 'a');
    fprintf(fid, [filename, '\n']);
    fclose(fid);
end

% ----------------------------------------------------------------------------------------
%% Completed
% ----------------------------------------------------------------------------------------

copyfile('~/deep3m/model/inception_residual_train_prediction_1fm/train1fm.sh',outdir);
copyfile('~/deep3m/model/inception_residual_train_prediction_3fm/train3fm.sh',outdir);
copyfile('~/deep3m/model/inception_residual_train_prediction_5fm/train5fm.sh',outdir);
disp('Image Augmentation completed');
toc
%if exist('txts.save')
%load('txts.save','-mat','training_info_text');
%fprintf(training_info_text);
disp('For training your model please run one of the following commands:');
fprintf([outdir '/train1fm.sh \n', outdir, '/train3fm.sh \n', outdir, '/train5fm.sh\n']);
%end
    
%savefile= fullfile((save_dir, 'training_full_stacks_v16.mat');
%save(savefile,'data','labels','-v7.3');
