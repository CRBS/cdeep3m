save_dir='../../hd5'
data_dir='../../data';
data_dir='/tempspace/tzeng/snmes3d/data'
raw_file ='snems3d_train_old.mat';
addpath('../../scripts')
raw_file=[data_dir filesep raw_file];
load(raw_file);
label=elm_labels{1};
lb=permute(label,[2,3,1]);

mat_train_deconv_file =[data_dir filesep 'train_average8_10.mat'];
mat_train_1fm_file=['../inception_ResNet_fcn_1fm_multiscale_classifier_1fm_2d/predict/ave_probs_train_iter_12000.mat'];
mat_train_3fm_file=['inception_multiscale_3fm_1x3_3x1_enhanced_fulltrain/ave_probs_test_iter_14522.mat'];
%train_stack_prob_dir ='predict_single/prob_train_iter_2000.mat';
mat_train_file ='predict/ave_probs_train_iter_8000.mat';
Td=load(mat_train_file);
prob=1-Td.average;

load(mat_train_deconv_file);
deconv_prob=average;

Td_1fm=load(mat_train_1fm_file);
prob_1f=1-Td_1fm.average;
prob_train=prob(:,:,21:100);
prob=prob_train;
%prob=max(prob_train);
%prob=1-prob_train;


%prob(:,:,1)=deconv_prob(:,:,1);
%prob(:,:,100)=deconv_prob(:,:,100);
th=0.086
h = fspecial('Gaussian', [6 6], 1);
prob_mask_th=0.8

ths=[0.05:0.01:0.24];
lbs=label;
lbs=permute(lbs,[2 3 1]);

% parfor i=1:length(ths)
	% th=ths(i);
	% idx_ths(i)=th
	% L = watershed(imhmin(imfilter(prob, h), th),6);
	% ARD(i)=SNEMI3D_metrics(lb(:,:,21:100),L)
	% display(sprintf('watershed threshold = %d, metric = %d', th,ARD(i)));
% end



%L = watershed(imhmin(imfilter(prob, h), 0.086),6);
% lbs=label;
% lbs=permute(lbs,[2 3 1]);
% display(sprintf('watershed threshold = %d, metric = %d', th, SNEMI3D_metrics(lbs,L)));
% %[out_map,out_map_fill,L,ws]=watershed_post_processing(prob,'3d');
% display(sprintf('watershed threshold = %d, metric = %d', th, SNEMI3D_metrics(lbs,L)));
% %display(sprintf('outmap threshold = %d, metric = %d', th, SNEMI3D_metrics(label,out_map)));