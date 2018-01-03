function [imagesize] = check_image_size(img_path)
%check_image_size: to see how to break large image data
%
%  
%  
%-----------------------------------------------------------------------------
%% Deep3M -- NCMIR/NBCR, UCSD -- Author: M Haberl -- Date: 11/2017
%-----------------------------------------------------------------------------

disp('Check image size of: '); 
disp(img_path); 
% check if a folder of png/tif files or a single stack to load
[Dir,name,ext] = fileparts(img_path);
if ~isempty(ext)
    if ~isempty(strfind(ext,'h5'))
        disp('Reading H5 image file');
        hinfo = h5info(img_path);
        try
        imagesize = hinfo.Datasets.Dataspace.MaxSize;
        catch
        imagesize = hinfo.Datasets.ChunkSize;
        end
        %hinfo.Datasets.ChunkSize;
        imagesize=[imagesize(2:3),imagesize(1)];
    elseif ~isempty(strfind(ext,'tif'))
        info = imfinfo(img_path);
        fprintf('Reading image stack with %d images\n',size(info,1));
        imagesize = [info(1).Height, info(1).Width, size(info,1)];
        
    end
    
elseif isdir(img_path)
    file_list = read_files_in_folder(img_path);
    png_list = filter_files(file_list,'.png');
    tif_list = filter_files(file_list,'.tif');
    if size(tif_list,1)+size(png_list,1) == 0, disp('No Tifs or PNGs found in the directory');return;
    else
        [~, type] = max([size(tif_list,1),size(png_list,1)]); %only read tif or pngs if ambiguous
        if type==1, file_list = tif_list; elseif type==2, file_list = png_list; end
        for idx =1
            filename = fullfile(img_path,file_list(idx).name);
            fprintf('Reading file: %s\n', filename); 
            info = imfinfo(filename);
            imagesize = [info(1).Height, info(1).Width, size(file_list,1)];
        end
    end
    
else
    error('No images found');
    return
end


        
end

