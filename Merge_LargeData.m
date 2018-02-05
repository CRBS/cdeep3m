#!/usr/bin/octave -qf
% Merge LargeData
%
% After segmentation of smaller image packages this
% script will stitch the initial dataset back together
% Assumes Packages are in the subdirectories of the ld_org.mat file.
%
% Use: Merge_LargeData /folder/ld_org.mat
% Optional input: output directory
%
%------------------------------------------------------------------
%% NCMIR/NBCR, UCSD -- Author: M Haberl -- Date: 10/2017
%------------------------------------------------------------------

% Beforehands StartPostProcessing already gets rid of z-padding (1&2 in
% beginning and last 2 in the end)

disp('Starting to merge large image dataset');
%pkg load hdf5oct
pkg load image
addpath(genpath('./scripts/'));
addpath(genpath('/home/ubuntu/deep3m/scripts/'));

arg_list = argv ();

if numel(arg_list)<1;
disp('Use -> Merge_LargeData /folder/ld_org.mat /outputdirectory'); 
return; 
elseif numel(arg_list)==2;
if isdir(arg_list{2}), outdir =  arg_list{2}; mkdir(outdir); else error('Not a valid direcory'); end   
elseif numel(arg_list)~=2
disp('Please define output directory');
disp('Use -> Merge_LargeData /folder/ld_org.mat /outputdirectory');
    %outdir = ('/home/ubuntu/ImageData/segmentation')    %or define
    %standard output directory here, but then need to distinguish 1fm, 3fm
    %and 5fm somewhere...
    return
end

ld_org_file = arg_list{1};
disp('Processing:');disp(ld_org_file); 
load(ld_org_file,'packages','num_of_pkg','imagesize','zplanes','z_blocks');
tic
[parentdir,~,ext] = fileparts(ld_org_file);

%% Merge Z-sections   
 % first combine images from the same x/y areas through all z-planes
 disp('Combining image stacks');
 if numel(z_blocks) > 2 %z_blocks defines beginning and end of blocks
     for x_y_num = 1:numel(packages)
         imcounter = 0; %Reset imagecounter to combine next Package
         combined_folder = fullfile(parentdir, sprintf('Pkg_%03d',x_y_num));
         mkdir(combined_folder);
         for z_plane = 1:(numel(z_blocks)-1)
             in_folder = fullfile(parentdir, sprintf('Pkg%03d_Z%02d',x_y_num, z_plane));
             disp(['Reading:', in_folder]);
             imlist =  read_files_in_folder(in_folder);
             imlist =  filter_files(imlist,'.png');
             for file = 1:numel(imlist)
                 imcounter = imcounter + 1;
                 in_filename = fullfile(in_folder,imlist(file).name);
                 out_filename = fullfile(combined_folder, sprintf('segmentation_%04d.png', imcounter));
                 movefile(in_filename, out_filename);
             end
             
         end
     end
 end

z_found = numel(filter_files(read_files_in_folder(fullfile(parentdir, sprintf('Pkg_001'))),'.png'));
fprintf('Expected number of planes: %s ... Found: %s planes\n', num2str(z_blocks(end)),num2str(z_found));
%% Now stitch individual sections
for z_plane = 1:z_found%one z-plane at a time
fprintf('Merging image no. %s\n', num2str(z_plane));
clear -v images
for x_y_num = 1:numel(packages)
packagedir = fullfile(parentdir, sprintf('Pkg_%03d',x_y_num));
filename = fullfile(packagedir, filelist(z_plane).name);
image_patch = NaN(imagesize(1:2)); %Initialize empty image inx/y not z
small_patch = imread(filename);
area = packages{x_y_num};
image_patch(area(1):area(2),area(3):area(4)) = small_patch; %insert image onto NaN blank image
image_stack(:,:,x_y_packg) = image_patch;
end

%image_stack = cat(3,images);
combined_plane = nanmean(image_stack,3);
outfile = fullfile(outdir, sprintf('Segmented_%04d.png',z_plane));
fprintf('Saving image %s\n', outfile);
imwrite(combined_plane,outfile);

end
disp('Merging large image dataset completed');
toc
fprintf('Your results are in: %s\n', outdir);
