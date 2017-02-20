gt_labels=h5read('../hd5/train_labelEM.h5','/label');
%bw_labels=h5read('../data/snemi3d_train_full_stacks_widen_label100.h5','/label');
bw_labels=h5read('../data/snemi3d_train_full_stacks_label100.h5','/label');

gt_labels=permute( gt_labels, [2 3 1]);
bw_labels=permute( bw_labels, [2 3 1]);

fun =@my_border_labeling
new_labels_1 =zeros(size(gt_labels));
new_labels_2 =zeros(size(gt_labels));
parfor i=1:1024
  gt_2d=squeeze(gt_labels(i,:,:));
  new_labels_1_1(i,:,:) = nlfilter(gt_2d,[1 3],fun);
  new_labels_1_2(i,:,:) = nlfilter(gt_2d,[3 1],fun);
end

parfor i=1:1024
  gt_2d=squeeze(gt_labels(:,i,:));
  new_labels_2_1(:,i,:) = nlfilter(gt_2d,[1 3],fun);
  new_labels_2_2(:,i,:) = nlfilter(gt_2d,[3 1],fun);
end


bw_labels(1:2,:,:)=1;
bw_labels(1023:1024,:,:)=1;

bw_labels(:,1:2,:)=1;
bw_labels(:,1023:1024,:,:)=1;
combine_new_labels= (1-new_labels_1_1)+(1-new_labels_1_2)+(1-new_labels_2_1)+(1-new_labels_2_2)+(1-bw_labels);
combine_new_labels(combine_new_labels>1)=1;

combine_new_labels=1-combine_new_labels;
save_h5_file='../data/vertical_enhanced_thin_label3x3.h5'
d_details.location = '/';
d_details.Name = 'labels';
hdf5write(save_h5_file,d_details,combine_new_labels);

