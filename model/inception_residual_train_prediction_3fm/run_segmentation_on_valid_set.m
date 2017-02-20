save_dir='../../hd5'
data_dir='../../data';
data_dir='/tempspace/tzeng/snmes3d/data'
raw_file ='snems3d_train_old.mat';
raw_file=[data_dir filesep raw_file];
load(raw_file);
label=elm_labels{1};
lb=permute(label,[2,3,1]);

mat_train_deconv_file =[data_dir filesep 'train_average8_10.mat'];

mat_train_file_1fm='../inception_ResNet_fcn_1fm_multiscale_classifier_1fm_2d/predict/ave_probs_train_iter_12000.mat'


mat_train_file_5fm=['../inception_5m_multiscale_classfier_thin_1x3_3x1_v_label_fullstack_train/predict/ave_probs_train_iter_32000.mat'];

mat_train_file_3fm=['../inception_multiscale_3fm_1x3_3x1_enhanced_fulltrain/predict/ave_probs_train_iter_14522.mat'];


mat_train_file ='predict/ave_probs_train_iter_50000.mat';
Td=load(mat_train_file);
prob=1-Td.average;


load(mat_train_file_1fm);
prob_train_1fm=1-average;

load(mat_train_file_5fm);
prob_train_5fm=1-average;

load(mat_train_file_3fm);
prob_train_3fm=1-average;

%prob=max(max(max(prob_train_1fm,prob_train_5fm),prob),prob_train_3fm);
prob=max(max(prob_train_5fm,prob),prob_train_3fm);
%prob=1-prob_train;

load(mat_train_deconv_file);
deconv_prob=average;
%prob(:,:,1)=deconv_prob(:,:,1);
%prob(:,:,100)=deconv_prob(:,:,100);
th=0.086
h = fspecial('Gaussian', [6 6], 2);
prob_mask_th=0.8

% ths=[0.14:0.002:0.24];
% lbs=label;
% lbs=permute(lbs,[2 3 1]);
% parfor i=1:length(ths)
	% th=ths(i);
	% L = watershed(imhmin(imfilter(prob, h), th),6);
	% display(sprintf('watershed threshold = %d, metric = %d', th, SNEMI3D_metrics(lb,L)));
% end



hs=[0.05:0.1:1]
ths=[0.14:0.02:2.4]
parfor i=1:length(hs)
     h=fspecial('Gaussian', [6 6], hs(i));
	 B=zeros(size(prob));
	 B(prob>0.45)=1;
	 for j=1:length(ths)
		 th=ths(j);
		 L = watershed(imhmin(imfilter(prob, h), th),6);
		 display(sprintf('watershed threshold = %d, h = %d, metric = %d', th,hs(i), SNEMI3D_metrics(lb,L)));
		 %L_Bf=watershed(imhmin(imfilter(B, h), th),6);
		 %display(sprintf('watershed threshold = %d, h = %d, metric = %d', th,hs(i), SNEMI3D_metrics(lb,L_Bf)));
	 end
end




%L = watershed(imhmin(imfilter(prob, h), 0.086),6);
% lbs=label;
% lbs=permute(lbs,[2 3 1]);
% display(sprintf('watershed threshold = %d, metric = %d', th, SNEMI3D_metrics(lbs,L)));
% %[out_map,out_map_fill,L,ws]=watershed_post_processing(prob,'3d');
% display(sprintf('watershed threshold = %d, metric = %d', th, SNEMI3D_metrics(lbs,L)));
% %display(sprintf('outmap threshold = %d, metric = %d', th, SNEMI3D_metrics(label,out_map)));