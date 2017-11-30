if ~ispc
    train_dir='../images/train-input';
    train_lb_dir='../images/train-label2d_widen';
    save_dir ='../data';
	test_dir='../images/test-input';
else
    train_dir='..\images\train-input';
    train_lb_dir='..\images\train-label2d_widen';
	test_dir='..\images\test-input';
    save_dir ='..\data';
end
d_details.location = '/';
d_details.Name = 'data';
l_details.location = '/';
l_details.Name = 'label';

d_file_name_base='train-input_slice_';
l_file_name_base='label2d_widen_';


enhanced_label_file='../data/vertical_enhanced_thin_label3x3.h5';

enhanced_label = hdf5read(enhanced_label_file,'/labels');
size(enhanced_label)
enhanced_label=permute(enhanced_label,[3 1 2]);


%%-----------------------train full 100 stacks -----------------------------------
data_arr=zeros(100,1024,1024);
elm_labels_arr=zeros(100,1024,1024);
for i=1:100
    d_filename= [d_file_name_base num2str(i) '.tif'];
    d_file_full_name=[train_dir filesep d_filename];
    tr_img_data=imread(d_file_full_name);
    data_arr(i,:,:)=tr_img_data;
    
    l_filename= [l_file_name_base num2str(i) '.tif'];
    l_file_full_name=[train_lb_dir filesep l_filename];
    tr_img_lb_data=imread(l_file_full_name);
    elm_labels_arr(i,:,:)=tr_img_lb_data;
    disp(['reading ' num2str(i) ' images ...' ]);
    
end
%elm_labels_arr(elm_labels_arr==255)=1;



elm_labels_arr=enhanced_label;
data{1}=data_arr;
elm_labels{1}=elm_labels_arr;



size(data_arr)
d_tr =single(data_arr);
l_tr =single(elm_labels_arr);

figure,imshow(uint8(squeeze(d_tr(50,:,:))))
figure,imshow(squeeze(l_tr(50,:,:)))

[data,labels]=augment_data(d_tr,l_tr)
for i=1:length(data)
  d_tr=data{i};
  l_tr=labels{i};
  hdf5write([save_dir filesep 'snemi3d_train_full_stacks_v' num2str(i) '.h5'],d_details,d_tr,l_details,l_tr);
end

savefile=[save_dir filesep 'snemi3d_train_full_stacks_v16.mat'];
save(savefile,'data','labels','-v7.3');

%---------------------------------------------------------------------------------------------








% %----------first 20 as valid stacks -------------------------------------------------------


data_arr=zeros(20,1024,1024);
elm_labels_arr=zeros(20,1024,1024);
for i=1:20
    d_filename= [d_file_name_base num2str(i) '.tif'];
    d_file_full_name=[train_dir filesep d_filename];
    tr_img_data=imread(d_file_full_name);
    data_arr(i,:,:)=tr_img_data;
    
    l_filename= [l_file_name_base num2str(i) '.tif'];
    l_file_full_name=[train_lb_dir filesep l_filename];
    tr_img_lb_data=imread(l_file_full_name);
    elm_labels_arr(i,:,:)=tr_img_lb_data;
    disp(['reading ' num2str(i) ' images ...' ]);
    
end
%elm_labels_arr(elm_labels_arr==255)=1;
elm_labels_arr=enhanced_label(1:20,:,:);
data{1}=data_arr;
elm_labels{1}=elm_labels_arr;


d_tr =single(data_arr);
l_tr =single(elm_labels_arr);

[data,labels]=augment_data(d_tr,l_tr)
for i=1:length(data)
  d_tr=data{i};
  l_tr=labels{i};
  hdf5write([save_dir filesep 'snemi3d_valid_v' num2str(i) '.h5'],d_details,d_tr,l_details,l_tr);
end

savefile=[save_dir filesep 'snemi3d_valid_v8.mat'];
save(savefile,'data','labels','-v7.3');


clear data_arr
clear elm_labels_arr

data_arr=zeros(80,1024,1024);
elm_labels_arr=zeros(80,1024,1024);
for i=21:100
    d_filename= [d_file_name_base num2str(i) '.tif'];
    d_file_full_name=[train_dir filesep d_filename];
    tr_img_data=imread(d_file_full_name);
    data_arr(i-20,:,:)=tr_img_data;
    
    l_filename= [l_file_name_base num2str(i) '.tif'];
    l_file_full_name=[train_lb_dir filesep l_filename];
    tr_img_lb_data=imread(l_file_full_name);
     elm_labels_arr(i-20,:,:)=tr_img_lb_data;
    disp(['reading ' num2str(i) ' images ...' ]);
    
end
%elm_labels_arr(elm_labels_arr==255)=1;
elm_labels_arr=enhanced_label(21:end,:,:);
%data{1}=data_arr;
elm_labels{1}=elm_labels_arr;
%savefile=[save_dir filesep 'snemi3d_train.mat'];
%save(savefile,'data','elm_labels','-v7.3');
d_te =single(data_arr);
l_te =single(elm_labels_arr);


[data,labels]=augment_data(d_te,l_te)
for i=1:length(data)
  d_te=data{i};
  l_te=labels{i};
  hdf5write([save_dir filesep 'snemi3d_train_v' num2str(i) '.h5'],d_details,d_te,l_details,l_te);
end


savefile=[save_dir filesep 'snemi3d_train_v8.mat'];
save(savefile,'data','labels','-v7.3');



clear data_arr
data_arr=zeros(10,1024,1024);



%----------------- small test 10 slice  ------------------------------------
d_file_name_base='test-input_slice_';
for i=90:100
	d_filename= [d_file_name_base num2str(i) '.tif'];
    d_file_full_name=[test_dir filesep d_filename];
    te_img_data=imread(d_file_full_name);
    data_arr(i-89,:,:)=te_img_data;
    disp(['reading ' num2str(i) ' testing images ...' ]);

end

%data{1}=data_arr;
%savefile=[save_dir filesep 'snemi3d_test.mat'];
%save(savefile,'data','-v7.3');
d_te =single(data_arr);

l_te =single(elm_labels_arr);


[data,labels]=augment_data(d_te,l_te)
for i=1:length(data)
  d_te=data{i};
  l_te=labels{i};
  hdf5write([save_dir filesep 'snemi3d_test_last10slice_v' num2str(i) '.h5'],d_details,d_te);
end

savefile=[save_dir filesep 'snemi3d_test_last10slice_v8.mat'];
save(savefile,'data','-v7.3');
%hdf5write([save_dir filesep 'snemi3d_test_last10slice.h5'],d_details,d_te);



clear data_arr
data_arr=zeros(100,1024,1024);
elm_labels_arr=zeros(100,1024,1024);
%----------------- full test slice  ------------------------------------
d_file_name_base='test-input_slice_';
for i=1:100
	d_filename= [d_file_name_base num2str(i) '.tif'];
    d_file_full_name=[test_dir filesep d_filename];
    te_img_data=imread(d_file_full_name);
    data_arr(i,:,:)=te_img_data;
    disp(['reading ' num2str(i) ' testing images ...' ]);

end

%data{1}=data_arr;
%savefile=[save_dir filesep 'snemi3d_test.mat'];
%save(savefile,'data','-v7.3');
elm_labels_arr=enhanced_label;
d_te =single(data_arr);

l_te =single(elm_labels_arr);


[data,labels]=augment_data(d_te,l_te);
for i=1:length(data)
  d_te=data{i};
  %l_te=labels{i};
  disp(['writing ' num2str(i) ' file ...']);
  hdf5write([save_dir filesep 'snemi3d_test_v' num2str(i) '.h5'],d_details,d_te);
end

savefile=[save_dir filesep 'snemi3d_test_v8.mat'];
save(savefile,'data','-v7.3');
%hdf5write([save_dir filesep 'snemi3d_test_last10slice.h5'],d_details,d_te);
