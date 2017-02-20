addpath('../../scripts/');
hd_dir='../../hd5'
data_dir='../../data'

hd5_raw_image_file ='snemi3d_test_v1.h5';
hd5_raw_image_file =[data_dir filesep hd5_raw_image_file];
Raw_img=h5read(hd5_raw_image_file,'/data');
Raw_img=permute(Raw_img,[2 3 1]);
mat_test_file ='predict/ave_probs_test_iter_32000.mat';
mat_test_deconv_file =[data_dir filesep 'test_average8_10.mat'];
mat_test_1fm_file=['../inception_ResNet_fcn_1fm_multiscale_classifier_1fm_2d/predict/ave_probs_test_iter_30000.mat'];
mat_test_3fm_file=['../inception_multiscale_3fm_1x3_3x1_enhanced_fulltrain/predict/ave_probs_test_iter_14522.mat'];
h_fill = fspecial('Gaussian', [12 12], 8);
load(mat_test_deconv_file);
deconv_prob_test=average;
load(mat_test_file);
prob_test=1-average;
load(mat_test_1fm_file);
prob_test_1fm=1-average;

load(mat_test_3fm_file);
prob_test_3fm=1-average;
fix_slice_num =[1:100];
prob_test(:,:,fix_slice_num)=max(max(prob_test(:,:,fix_slice_num),prob_test_1fm(:,:,fix_slice_num)),prob_test_3fm(:,:,fix_slice_num));
prob_test(:,:,30)=prob_test(:,:,29)*0.5+prob_test(:,:,31)*0.5;
h= fspecial('Gaussian', [12 12], 8);
imhm_th_3d=0.23;
L = watershed(imhmin(imfilter(prob_test, h), imhm_th_3d),6);
%prob_deconv_merge=max(deconv_prob_test,prob_test);
%L

% figure,imshow(label2rgb(L(:,:,30)))



% disp('merge region on 3d watershed ...')	
%merge_iters=20;
%L_merge=merge_seg2(L,merge_iters);


disp('fill background and remove 0 on  3d watershed ...')
%L_fill_merge=L_merge;
L_fill_merge=L;
prob_mask_th=0.80;
%L_fill_merge=L;
L_fill_merge(find(deconv_prob_test>=prob_mask_th)) = 0;

L_fill_merge=double(L_fill_merge);
 parfor i=1:size(L_fill_merge,3)
	 disp(['disp ' num2str(i)])
	 f = full_fill(L_fill_merge(:,:,i));
	 out_map_test(:,:,i)=f;
end


% run 2d binary watershed on prob map and merge slice based on 3d watershed
% D=prob_test;
% D(prob_test>=0.6)=1;
% D(prob_test<0.6)=0;
% L_2d=watershed(D,8) % 8 specify 2d Watershed.
% L_2d=gpuArray(L_2d);
% num_2d_reg=size(unique(L_2d))
% for i=1:num_2d_reg-1
	% idx=(L_2d==i);
	% %idx_array=L_18(idx);
    % L_2d(idx)=mode(out_map(idx));
	% %uq=unique(idx_array);
	% disp(['process ' num2str(i)])
% end
% L_f=gather(L_2d);

%make_submit_tiff(out_map_test,'three_5fm3fm1fm_thin_fuse_th023_filter_12_12_8_outmap')
















%write_label2rgb_image(out_map,Raw_img,'incep_1x3_thin_boundary_out_map_w3d_th0175_mask095');



% make_submit_tiff(L_f,'iter_22000_2d_3d_ws_fuse_outmap')
write_label2rgb_image(out_map_test,Raw_img,'three_5fm3fm1fm_thin_fuse_th023_filter_12_12_8_outmap');
write_label2rgb_image(L);


%display(sprintf('watershed threshold = %d, metric = %d', th, SNEMI3D_metrics(label,ws)));
%display(sprintf('outmap threshold = %d, metric = %d', th, SNEMI3D_metrics(label,out_map)));
%[out_map,L,ws]=watershed_post_processing(prob,'3d');