#!/usr/bin/octave -qf
%% Adjust3DWateshed
%
%
% Syntax : Adjust3DWateshed /example/training/labels.tiff /training/predict/ensemble.tiff
%
% This requires to run predict on the original raw training images first!
% Performance will be determined and optimized using Rand error on the prediction of this
% versus the ground truth training labels.
% Therefore make sure StartPostprocessing and EnsemblePredictions ran first on the raw training images which
% created the 'ensemble.tiff'
%
% -> Argument 1: ground truth training labels  (either as a tiff stack or as a h5 file)
% -> Argument 2: location of the 'ensemble.tiff' of training files
% -> Output: display parameters of best performance for hm3d and
% connectivity
%
% -> Output: Graphs showing the Rand error at different parameter
% settings of hm3d and connectivity settings.
%
% Output graphs are written into the folder of the trainig ground truth image.
%
% -----------------------------------------------------------------------------
%% CDeep3M -- NCMIR, UCSD -- Author: M Haberl -- Data: 11/2017
% -----------------------------------------------------------------------------
%
fprintf('Adjust3DWateshed Starting \n');

%% Initialize
pkg load hdf5oct
pkg load image

arg_list = argv ();
gtlabels_image_full_path = arg_list{1}; 

train_merged_file_saved = arg_list{2};
outfolder = fileparts(train_merged_file_saved);

% -------------------------------------------------------------------------
%% ------ load ensemble model and ground truth labels----------------------
% -------------------------------------------------------------------------

%merged_file_saved=fullfile(folder, 'ensemble.tiff');
fprintf('Loading: %s ...\n', train_merged_file_saved);
try
        [trainMod] = imageimporter(train_merged_file_saved)
catch
    error('%s not found',train_merged_file_saved);
    return
end
fprintf('Loading: %s ...\n', gtlabels_image_full_path);
try
        [gt] = imageimporter(gtlabels_image_full_path)
catch
    error('%s not found',gtlabels_image_full_path);
    return
end


% -------------------------------------------------------------------------
%% ---------------- Vary 3D watershed parameters --------------------------
% -------------------------------------------------------------------------

disp('Starting iterative optimization process');

h= fspecial('Gaussian', [6 6], 0.105);

if size(trainMod,3)==1
connectivities = [4,8];
disp('Processing 2D');
else
connectivities = [6,18,26];	
disp('Processing 3D');
end

for ccc=connectivities

stepsize = 0.05;
startpoint = 0.10;endpoint = 0.2;
iterate =1;
hm_x = [];
new_hm_x = [startpoint:stepsize:endpoint];
hm_y = [];
while iterate == 1

hm_x = [hm_x,new_hm_x];
parfor ite = 1:length(new_hm_x)
i_hm = new_hm_x(ite);
h= fspecial('Gaussian', [6 6], 0.105);
fprintf('Applying 3D watershed %s...\n',num2str(i_hm));
test_lbl = watershed(hmtransf(imfilter(trainMod,h), i_hm,6),6);  %applying first a gaussian filter then a H-minima transform
new_hm_y(ite) = SNEMI3D_metrics( gt, test_lbl ); %Test Rand Error
fprintf('Rand Error for %s: %s\n',num2str(new_hm_x(ite)),num2str(new_hm_y(ite)));
end
hm_y = [hm_y, new_hm_y]; %add this error
clearvars new_hm_x new_hm_y
%% Re-organize to match
[hm_x,new_order] = sort(hm_x);
hm_y = hm_y(new_order);

[~,best_idx] = max(hm_y); %find max values
[~,worst_idx] = min(hm_y);
%% Decide which datapoints to add next
%If first or last are performing best, add till crossing the peak of the curve
%otherwise decrease stepsize and increase sampling density closer in between
if worst_idx == best_idx
    fprintf('No optimization achieved at hm3d parameters: %s\n',num2str([hm_x]));
    iterate=0; %No Performance difference whatsoever, stop here     
elseif (best_idx == 1)  %lowest value performs best, so add more values below
    new_hm_x = hm_x(1) - stepsize;
elseif best_idx==hm_y(end)  %highest value performs best, so add more values above
    new_hm_x = hm_x(end) + stepsize;
else            %fill between the peak and the higher value next to it
    stepsize = stepsize/2;
    if stepsize > 0.01
    fprintf('Decreasing stepsize to: %s\n', num2str(stepsize));
    [~,fff] = max([hm_y(best_idx-1), hm_y(best_idx+1)]);  %is peak closer to value before or after peak
    if fff==1, new_hm_x = hm_y(best_idx) - stepsize; end
    if fff==2, new_hm_x = hm_y(best_idx) + stepsize; end
    
    else
        iterate=0; %Done
    end
end
end

fprintf('Iterative process completed\n');
fig1 = figure()
plot(hm_x,hm_y,'r*--')
title('Rand Error Watershed Performance');
graphsavenm = fullfile(outfolder, sprintf('watershed_performance_conn%s.pdf',num2str(ccc)));
print(fig1, '-dpdf', graphsavenm)

%% Determine max_for_ccc(ccc)  
[best_Rand(ccc),best_idx] = max(hm_y); 
best_hm3d(ccc) = hm_x(best_idx);

fprintf('Best Rand error at connectivity %s at hm3d:%s = %s\n',num2str(ccc),num2str(best_hm3d(ccc)),num2str(best_Rand(ccc)));

end

[grouped_Rand,best_idx] = max(best_Rand);
all_hm3d = best_hm3d(best_idx);
fprintf('Best Performance accomplished at connectivity %s and hm3d %s\nRand error = %s\n',num2str(best_idx),num2str(all_hm3d),num2str(grouped_Rand));

%{
h= fspecial('Gaussian', [6 6], 0.105);
hm3d=all_hm3d;  %imhm_th_3d=0.19;

disp('Applying 3D watershed ...')
L = watershed(hmtransf(imfilter(trainMod, h), hm3d),best_idx);  %applying first a gaussian filter then a H-minima transform
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


fprintf('Elapsed time is %06d seconds.\n', round(toc))

%% ============================== Make submission Files ===============================

fprintf('Colorizing segmented images \n');
overlay = fullfile(outfolder,sprintf('Deep3M_colored_hm3D%s.tif',num2str(hm3d)));
write_label2rgb_image(out_map,Raw_img,overlay)
}%
fprintf('Adjust3DWateshed Completed \n');
%% END
