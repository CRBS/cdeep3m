function [imgstack] = imageimporter_large(img_path,area)
%imageimporter_large: loads subarea of large image data 
% from folder or from an individual image stack
%
%  
%  
%-----------------------------------------------------------------------------
%% Deep3M -- NCMIR/NBCR, UCSD -- Author: M Haberl -- Date: 11/2017
%-----------------------------------------------------------------------------
disp('Image importer loading ... '); 
disp(img_path); 
% check if a folder of png/tif files or a single stack to load
[Dir,name,ext] = fileparts(img_path);
rows = [area(1), area(2)];
cols = [area(3), area(4)];
if ~isempty(ext)
    if ~isempty(strfind(ext,'h5'))
        fprintf('Reading H5 image file %s\n', img_path);
        hinfo = h5info(img_path);
        start = [1, rows(1), cols(1)];
        count = [Inf, rows(2)-rows(1), cols(2)-cols(1)];
        %h5read(img_path, hinfo.GroupHierarchy.Datasets.Name);  
        imgstack = h5read(img_path, ['/', hinfo.Datasets.Name],start,count);
        imgstack=permute(imgstack,[2 3 1]); %To match the same format as TIF or PNG images
    elseif ~isempty(strfind(ext,'tif'))
        info = imfinfo(img_path);
        fprintf('Reading image stack with %d images\n',size(info,1));
        for idx =1:size(info,1)
            imgstack(:,:,idx) = imread(img_path,'index',idx,'PixelRegion', {rows, cols});
        end
        
    end
    
elseif isdir(img_path)
    file_list = read_files_in_folder(img_path);
    png_list = filter_files(file_list,'png');
    tif_list = filter_files(file_list,'tif');
    if size(tif_list,1)+size(png_list,1) == 0, disp('No Tifs or PNGs found in training directory');return;
    else
        [~, type] = max([size(tif_list,1),size(png_list,1)]); %only read tif or pngs if ambiguous
        if type==1, file_list = tif_list; elseif type==2, file_list = png_list; end
        for idx =1:size(file_list,1)
            filename = fullfile(img_path,file_list(idx).name);
            fprintf('Reading file: %s\n', filename); 
            if type==1
            imgstack(:,:,idx) = imread(filename,'PixelRegion', {rows, cols}); %tif allows to read subarea
            else
            rect = [area(1), area(3), area(2)-area(1), area(4)-area(3)];
            imgstack(:,:,idx) = imcrop(imread(filename),rect);    %otherwise need to crop the area here
            end
        end
    end
    
else
    error('No images found');
    return
end

end

