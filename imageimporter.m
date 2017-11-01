function [img_stack] = imageimporter(img_path)
%imageimporter: loads image data from folder or from an individual stack
%
%  
%  
%-----------------------------------------------------------------------------
%% Adapted for Deep3M -- NCMIR/NBCR, UCSD -- Author: M Haberl -- Date: 10/2017
%-----------------------------------------------------------------------------

% check if a folder of png/tif files or a single stack to load
[Dir,name,ext] = fileparts(img_path);
if ~isempty(ext)
    if ~isempty(strfind(ext,'h5')) %overwrite extension, has to be .h5 file
        %h5read
        disp('H5 currently not supported as input');
        return
    elseif ~isempty(strfind(ext,'tif'))
        info = imfinfo(img_path);
        fprintf('Reading image stack with %d images\n',size(info,1));
        for idx =1:size(info,1)
            imgstack(:,:,idx) = imread(img_path,'index',idx);
        end
        
    end
    
elseif isdir(label_img_path)
    file_list = read_files_in_folder(img_path);
    png_list = filter_files(file_list,'png');
    tif_list = filter_files(file_list,'tif');
    if size(tif_list,1)+size(png_list,1) == 0, disp('No Tifs or PNGs found in training directory');return;
    else
        [~, type] = max([size(tif_list,1),size(png_list,1)]); %only read tif or pngs if ambiguous
        if type==1, file_list = tif_list; elseif type==2, file_list = png_list; end
        for idx =1:size(file_list,1)
            filename = fullfile(img_path,file_list(idx).name);
            imgstack(:,:,idx) = imread(filename);
        end
    end
    
else
    error('No images found');
    return
end

end

