#!/usr/bin/octave -qf
%
%
% Upload a directory with sequential PNG files to save traffic
% Used to convert .tif or .png image files to .h5 files
%
% Use: Images2H5 input output (can add where it saves in h5 file, such as label)
% input: Can be folder containing png images, tif images or a tif stack
% output: specify directory and filename for output, will always be .h5 file
%
%------------------------------------------------------------------
%% NCMIR/NBCR, UCSD -- Author: M Haberl -- Date: 10/2017
%------------------------------------------------------------------

%% Initialize
arg_list = argv ();
pkg load hdf5oct
pkg load image

userinput = arg_list{1};
useroutput = arg_list{2};

%% Load data
if isdir(userinput)
    file_list = read_files_in_folder(userinput);
    png_list = filter_files(file_list,'png');
    tif_list = filter_files(file_list,'tif');
    if size(tif_list,1)+size(png_list,1) == 0, disp('No Tifs or PNGs found in directory');return;
    else
        [~, type] = max([size(tif_list,1),size(png_list,1)]); %only read tif or pngs if ambiguous
        if type==1, file_list = tif_list; elseif type==2, file_list = png_list; end
        for idx =1:size(file_list,1)
            filename = fullfile(userinput,file_list(idx).name);
            imgstack(:,:,idx) = imread(filename);
        end
    end
    
else
    info = inmfinfo(userinput);
    fprintf('Reading image stack with %d images\n',size(info,1));
    for idx =1:size(info,1)
        imgstack(:,:,idx) = imread(userinput,'index',idx);
    end
end

%tiffs are loaded in matlab in the order [Y X Z]
%possibly need to permute for the overlay later @MH 10/27/17
%tiffImg = permute(tiffImg, [2 1 3]);

%% User error prevention
[Dir,name,ext] = fileparts(useroutput); 
ext = '.h5'; %overwrite extension, has to be .h5 file
if ~exist(Dir,'dir')
    mkdir(Dir)
end
save_h5_file=fullfile(Dir,name,ext);

%% Check if saving as data, image or labelfile
if numel(arg_list>2)
    datatype = arg_list{3};
    d_details.Name = datatype;
else
d_details.Name = 'data';
end
%% Write file
d_details.location = '/';
h5write(save_h5_file,d_details,imgstack);