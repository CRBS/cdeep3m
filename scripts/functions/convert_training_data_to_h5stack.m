## Usage [status,errmsg] = convert_training_data_to_h5stack(training_images_path, training_labels_path, out_dir)
##
## Makes augmented hdf5 datafiles from raw and label images
##  
## Runtime ~20min for 1024x1024x100 dataset
##

function [status,errmsg] = convert_training_data_to_h5stack(training_images_path,
                                                            training_labels_path,
                                                            out_dir)
  tic

  % ---------------------------------------------------------------------------
  %% Load train data
  % ---------------------------------------------------------------------------
  status = 0;
  errmsg = '';

  disp('Loading:');
  disp(training_labels_path); 
  [lblstack] = imageimporter(training_labels_path);
  checkpoint_isbinary(lblstack);

  % ---------------------------------------------------------------------------
  %% Load training images
  % ---------------------------------------------------------------------------

  disp('Loading:');
  disp(training_images_path); 
  [imgstack] = imageimporter(training_images_path);
  checkpoint_nobinary(imgstack);

  % ---------------------------------------------------------------------------
  %% Augment the data, generating 16 versions and save
  % ---------------------------------------------------------------------------

  disp('Augmenting ...');
  data_arr=permute(imgstack,[3 1 2]); %from tiff to h5 /100*1000*1000
  labels_arr=permute(lblstack,[3 1 2]); %from tiff to h5 /100*1000*1000

  d_tr =single(data_arr);
  l_tr =single(labels_arr);
  [data,labels]=augment_data(d_tr,l_tr); 

  d_details = '/data'; 
  l_details = '/label'; 
  if ~exist(out_dir,'dir');
    mkdir(out_dir); 
  endif
  ext = '.h5';
    
  disp('Saving ...');
  for i=1:length(data)
    d_tr=data{i};
    l_tr=labels{i};
    filename = fullfile(out_dir, sprintf('training_full_stacks_v%s%s',
                                         num2str(i), ext));
    disp(filename); 
    h5write(filename,d_details,d_tr);
    h5write(filename,l_details,l_tr); 
  endfor
endfunction
% -----------------------------------------------------------------------------
%% Completed
% -----------------------------------------------------------------------------

toc
