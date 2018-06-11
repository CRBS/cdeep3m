function [imgstack] = imageimporter_large(img_path,area,z_stack)
%imageimporter_large: loads subarea of large image data
% from folder or from an individual image stack
%
%
%
%-----------------------------------------------------------------------------
%% CDeep3M -- NCMIR/NBCR, UCSD -- Author: M Haberl -- Date: 11/2017
%-----------------------------------------------------------------------------
warning ("off")
disp('Image importer loading ... ');
script_dir = fileparts(make_absolute_filename(program_invocation_name()));
crop_png = strcat(script_dir,filesep(),'scripts',filesep(),'functions',filesep(),'crop_png.py');

fprintf('crop_png.py path: %s\n',crop_png);

disp(img_path);
% check if a folder of png/tif files or a single stack to load
[Dir,name,ext] = fileparts(img_path);
rows = [area(1), area(2)];
cols= [area(3), area(4)];
all_zs =  [z_stack(1):z_stack(2)];

if ~isempty(ext)
    if ~isempty(strfind(ext,'h5'))
        fprintf('Reading H5 image file %s\n', img_path);
        hinfo = h5info(img_path);
        start = [z_stack(1), rows(1), cols(1)];
        count = [z_stack(2), rows(2)-rows(1), cols(2)-cols(1)];
        %h5read(img_path, hinfo.GroupHierarchy.Datasets.Name);
        imgstack = h5read(img_path, ['/', hinfo.Datasets.Name],start,count);
        imgstack=permute(imgstack,[2 3 1]); %To match the same format as TIF or PNG images
    elseif ~isempty(strfind(ext,'tif'))
        info = imfinfo(img_path);
        fprintf('Reading %s planes from image stack with %d planes\n', num2str(z_stack(2)+1-z_stack(1)),size(info,1));
        for iii =1:numel(all_zs)
            fprintf('.');
            idx = all_zs(iii);
            imgstack(:,:,iii) = imread(img_path,'index',idx,'PixelRegion', {cols, rows});
        end
        fprintf('\n');
    end
    
elseif isdir(img_path)
    file_list = read_files_in_folder(img_path);
    png_list = filter_files(file_list,'.png');
    tif_list = filter_files(file_list,'.tif');
    if size(tif_list,1)+size(png_list,1) == 0, disp('No Tifs or PNGs found in training directory');return;
    else
        [~, type] = max([size(tif_list,1),size(png_list,1)]); %only read tif or pngs if ambiguous
        if type==1, file_list = tif_list; elseif type==2, file_list = png_list; end
        
        zdims = numel(all_zs);
        %if type==1
        %    for iii =1:zdims
        %        idx = all_zs(iii);
        %        filename = fullfile(img_path,file_list(idx).name);
        %        fprintf('Reading file: %s\n', filename);
        %        imgstack(:,:,iii) = imread(filename,'PixelRegion', {cols, rows}); %tif allows to read subarea
        %    end
        %else
            tempdir = fullfile(img_path,'temp');
            mkdir(tempdir);
            %num_cores = 4;
            %all_files = str2mat(file_list.name);
            %regions = [(area(1)), (area(1)+area(2)), (area(3)), (area(3)+area(4))];
            %disp(regions)
            input_files = [];
            tempmat_infile = fullfile(tempdir,'infiles.txt');
            delete(tempmat_infile);
            fid = fopen(tempmat_infile, 'a')
            for fl = 1:zdims           
            %input_files = strcat(input_files, ',', fullfile(img_path,file_list(fl).name));
            fprintf(fid, strcat(fullfile(img_path,file_list(fl).name),'\n'));
	    end
            fclose(fid);

            tempmat_outfile = fullfile(tempdir,'outfiles.txt');
            delete(tempmat_outfile);
            fid = fopen(tempmat_outfile, 'a')
            for fl = 1:zdims
            %input_files = strcat(input_files, ',', fullfile(img_path,file_list(fl).name))
            outfilename = fullfile(tempdir,file_list(fl).name);
            temp_files(fl).name = [outfilename(1:end-3),'png'];
            fprintf(fid, strcat(temp_files(fl).name,'\n'));
            end
            fclose(fid);

            %tempmatfile = fullfile(tempdir,'params.csv');
            %delete(tempmatfile)
	    %csvwrite(tempmatfile,input_files)
            %save(tempmatfile,"-v6",'input_files','temp_files','regions','zdims');
   system(sprintf('%s %s %s %s %s %s %s',crop_png, tempmat_infile, tempmat_outfile, num2str(area(1)-1), num2str(area(2)-1), num2str(area(3)-1), num2str(area(4)-1)))
            %save(fullfile(tempdir,'done1'),'zdims');
            clear imgstack
            for ttt = 1:zdims
              image1 = imread(temp_files(ttt).name);
              fprintf('Reading image %s\n', temp_files(ttt).name);
            %  disp(size(image1))
              imgstack(:,:,ttt) = image1(:,:,1);
            end
            delete(tempmat_outfile)  
            %save(fullfile(tempdir,'doneall'),'zdims','-append');
        %end
    end
    
else
    error('No images found');
    return
end

%% Add padding
%% Left and upper side
if area(1)==1 && size(imgstack,1)<=1012; %first in y
    imgstack = cat(1,flipud(imgstack(2:13,:,:)),imgstack);
end
if area(3)==1 && size(imgstack,2)<=1012 %then in x
    imgstack = cat(2,fliplr(imgstack(:,2:13,:)),imgstack);
end
x_size=size(imgstack,1);y_size=size(imgstack,2);
%% Right and lower end
if x_size<1024
    max_padsize = 1024 - x_size;max_padsize = min(max_padsize,12);
    imgstack = cat(1,imgstack,flipud(imgstack(x_size-max_padsize:x_size-1,:,:)));
end
if y_size<1024
    max_padsize = 1024 - y_size;max_padsize = min(max_padsize,12);
    imgstack = cat(2,imgstack,fliplr(imgstack(:,y_size-max_padsize:y_size-1,:)));
end


%% Add zeros to fill 1024*1024 Image size
x_size=size(imgstack,1);y_size=size(imgstack,2);
if x_size<1024 || y_size<1024
    temp_img = zeros(1024,1024,size(imgstack,3));
    temp_img(1:size(imgstack,1),1:size(imgstack,2),:) = imgstack;
    imgstack = temp_img;
end

end
