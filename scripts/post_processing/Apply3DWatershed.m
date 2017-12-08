#!/usr/bin/octave -qf
%% Apply3DWatershed
%
%
% Syntax : Apply3DWateshed /example/rawimage/image.tiff predict/ensemble.tiff hm3d:0.15
% make sure StartPostprocessing and EnsemblePredictions ran first which
% created the 'ensemble.tiff'
%
% -> Argument 1: raw image file  (either as a tiff stack or as a h5 file)
% -> Argument 2: location of the 'ensemble.tiff'
% -> optional input: hm3d:0.15
%
% Output is written into the folder of the raw image input, as one
% segmented file, and the subsequently colorized segmented file.
%
% -----------------------------------------------------------------------------
%% Deep3M -- NCMIR, UCSD -- Author: M Haberl -- Data: 10/2017
% -----------------------------------------------------------------------------
%

%% Initialize
pkg load hdf5oct
pkg load image


if exist('readvars','var') %ran StartPostprocessing before, using output and variables from here
    for i = 1:floor(numel(arg_list)/2)
        filelist{i} = arg_list{(2*i)+1};
        raw_img_missing =1;
    end
    
else    %% Regular call of this script
    arg_list = argv ();
    raw_image_full_path = arg_list{1}; %fist is the raw img file, then all folders are input directories
    outfolder = fileparts(raw_image_full_path); %use the directory of the rawimage for the output
    merged_file_saved = arg_list{2};
    %{
    for i = 2:(numel(arg_list))
        if isdir(arg_list{i})
        to_process{i-1} = arg_list{i};
        end
    end
    %}
    
end

% -------------------------------------------------------------------------
%%  ---------------- Input parameters -------------------------------------
% -------------------------------------------------------------------------

h= fspecial('Gaussian', [6 6], 0.105);
ishm3dparam = regexpi(arg_list,'hm3d');
if isempty([ishm3dparam])
    hm3d=0.15; %standard setting, if no user input
else
    for rr = 1:numel(arg_list)
        found_ahm = strfind(arg_list{rr},'hm3d')
        if ~isempty(found_ahm)
            found_hm = arg_list{rr};
            m = regexp(arg_list{rr}, ':') ;
            hm3d = str2num(found_hm(m+1:end));   %use everything after the semicolon as input for hminima transf value
        end
        
    end
end

% -------------------------------------------------------------------------
%% ---------------- load ensemble model -----------------------------------
% -------------------------------------------------------------------------

%merged_file_saved=fullfile(folder, 'ensemble.tiff');
fprintf('Loading: %s ...\n', merged_file_saved);
if exist(merged_file_saved, 'file'),
    for z = 1:size(prob,3)
        ensMod(:,:,proc) = imread(merged_file_saved,z)
    end
else
    error('%s not found',merged_file_saved);
    return
end

% -------------------------------------------------------------------------
%% ---------------- perform 3D  watershed ---------------------------------
% -------------------------------------------------------------------------

h= fspecial('Gaussian', [6 6], 0.105);
hm3d=0.15;  %imhm_th_3d=0.19;
prob_mask_th=0.8;
disp('Applying 3D watershed ...')
L = watershed(hmtransf(imfilter(ensMod, h), hm3d),6);  %applying first a gaussian filter then a H-minima transform
disp('Saving 3D watershed ...')
segmented_filename = fullfile(outfolder,sprintf('Deep3M_segmented_out_hm3D%s.tif',num2str(hm3d)));
if exist(segmented_filename, 'file'),delete(segmented_filename); end
for i=1:size(L,3)
    imwrite(L(:,:,i),segmented_filename,'WriteMode','append')
end

%{
L_fill_merge=L;
%L_fill_merge(deconv_prob_test>=prob_mask_th) = 0;
L_fill_merge=double(L_fill_merge);
parfor i=1:size(L_fill_merge,3)
    disp(['disp ' num2str(i)])
    f = full_fill(L_fill_merge(:,:,i));
    out_map(:,:,i)=f;
end
%}

% -------------------------------------------------------------------------
%% ---------------- Load raw data for overlay -----------------------------
% -------------------------------------------------------------------------
if raw_img_missing
    raw_image_full_path = input('\nPlease insert raw image file location:','s');
end

if strcmpi('.h5',raw_data_file(end-2:end))
    Raw_img=h5read(raw_image_full_path,'/data');
    Raw_img=permute(Raw_img,[2 3 1]);
elseif strcmpi('.tif',raw_data_file(end-3:end)) || strcmpi('.tiff',raw_data_file(end-3:end))  
    info = inmfinfo(raw_image_full_path);
    fprintf('Reading image stack with %d images\n',size(info,1));
    for idx =1:size(info,1)
        Raw_img(:,:,i)=imread(raw_image_full_path,'index',idx);
    end
else
    errordlg('Cannot open other format than h5 or tiff');
end


helpdlg(sprintf('Elapsed time is %06d seconds.', round(toc)))

%% ============================== Make submission Files ===============================
%make_submit_tiff(out_map,'iter_50000_1fm3fm5fm_correctByFull_outmap_th019_slice1')
fprintf('Colorizing segmented images \n');
overlay = fullfile(outfolder,sprintf('Deep3M_colored_hm3D%s.tif',num2str(hm3d)));
write_label2rgb_image(out_map,Raw_img,overlay)

%make_submit_tiff(out_map,'Best_iter_50000_1fm3fm5fm_correctByFull_outmap_th020_rindx0064745019')
%write_label2rgb_image(out_map,Raw_img,'Best_segmentation_test_iter_50000_1fm3fm5fm_correctByFull_outmap_th020_rindx0064745019');
% write_label2rgb_image(L);

%% END