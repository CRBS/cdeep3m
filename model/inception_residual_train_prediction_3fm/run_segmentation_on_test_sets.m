addpath('../../scripts/');
hd_dir='../../hd5'
data_dir='../../data'

hd5_raw_image_file ='snemi3d_test_v1.h5';
hd5_raw_image_file =[data_dir filesep hd5_raw_image_file];
Raw_img=h5read(hd5_raw_image_file,'/data');
Raw_img=permute(Raw_img,[2 3 1]);

mat_test_file ='predict/ave_probs_test_iter_50000.mat';
mat_test_deconv_file =[data_dir filesep 'test_average8_10.mat'];

mat_test_file_1fm='../inception_ResNet_fcn_1fm_multiscale_classifier_1fm_2d/predict/ave_probs_test_iter_50000.mat'

mat_test_file_5fm=['../inception_5m_multiscale_classfier_thin_1x3_3x1_v_label_fullstack_train/predict/ave_probs_test_iter_50000.mat'];

mat_test_file_3fm=['../inception_multiscale_3fm_1x3_3x1_enhanced_fulltrain/predict/ave_probs_test_iter_48000.mat'];

mat_test_3x3filter_5fm_file=['../inception_5fm_multiscale_classfiier_enhanced3x3_fullstak_train/predict/ave_probs_test_iter_50000.mat'];

mat_test_file_fullstack_test_fm=['../inception_5fm_multiscale_classfiier_enhanced_fullstak_train/predict/ave_probs_test_iter_46394.mat'];




%load(mat_test_deconv_file);
%deconv_prob_test=average;



load(mat_test_file_1fm);
prob_test_1fm=1-average;

load(mat_test_file_5fm);
prob_test_5fm=1-average;

load(mat_test_file_3fm);
prob_test_3fm=1-average;


load(mat_test_file);
prob_test3x3=1-average;


load(mat_test_file_fullstack_test_fm);
prob_test_full=1-average;


load(mat_test_3x3filter_5fm_file);
prob_test_3x3_5fm=1-average;



%% =============== ensemble models =================================
prob_test=max(max(prob_test_1fm,prob_test_5fm),prob_test_3fm);
prob_test_full(:,:,1)=max(prob_test(:,:,1),prob_test_3x3_5fm(:,:,1));
prob_test_full(:,:,2:99)=max(prob_test_1fm(:,:,2:99),prob_test_full(:,:,2:99));
prob_test(:,:,1:10)=prob_test_full(:,:,1:10);
prob_test(:,:,30)=max(max(prob_test(:,:,29),prob_test(:,:,31)),prob_test(:,:,31));
prob_test(:,:,31:34)=max(prob_test_1fm(:,:,31:34),prob_test_full(:,:,31:34));
prob_test(:,:,60:63)=max(prob_test_full(:,:,60:63),prob_test_1fm(:,:,60:63));



%% =============== perform 3D  watershed =================================
h= fspecial('Gaussian', [6 6], 0.105);
imhm_th_3d=0.19;
prob_mask_th=0.8;
disp('3D watershed ...')
L = watershed(imhmin(imfilter(prob_test, h), imhm_th_3d),6);



L_fill_merge=L;
L_fill_merge(deconv_prob_test>=prob_mask_th) = 0;
L_fill_merge=double(L_fill_merge);
parfor i=1:size(L_fill_merge,3)
 disp(['disp ' num2str(i)])
 f = full_fill(L_fill_merge(:,:,i));
 out_map(:,:,i)=f;
end

%% ============================== Make submission Files ===============================
make_submit_tiff(out_map,'iter_50000_1fm3fm5fm_correctByFull_outmap_th019_slice1')
write_label2rgb_image(out_map,Raw_img,'segmentation_test_iter_50000_1fm3fm5fm_correctByFull_outmap_th019_slice_1')

%make_submit_tiff(out_map,'Best_iter_50000_1fm3fm5fm_correctByFull_outmap_th020_rindx0064745019')
%write_label2rgb_image(out_map,Raw_img,'Best_segmentation_test_iter_50000_1fm3fm5fm_correctByFull_outmap_th020_rindx0064745019');
% write_label2rgb_image(L);

