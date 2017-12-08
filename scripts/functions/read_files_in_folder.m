function [fileList, file_list_length] = read_files_in_folder(input_directory)
%Read_files_in_folder
%   Get the complete list of good excluding hidden Files, excluding any subfolders in the input folder
%   
%
%   INPUT FORMAT
%   --------------------------
%   (InputDirectory)
%
%   OUTPUT FORMAT
%   --------------------------
%   [fileList, file_list_length]
%
%   
%   --------------------------
%   -- National Center for Microscopy and Imaging Research, NCMIR
%   -- Matthias Haberl -- San Diego, 02/2016

fileList = dir(input_directory);

%# remove all folders
isBadFile = cat(1,fileList.isdir); %# all directories are bad

%# loop to identify hidden files 
for iFile = find(~isBadFile)' %'# loop only non-dirs
   %# on OSX, hidden files start with a dot
   isBadFile(iFile) = strcmp(fileList(iFile).name(1),'.');
   if ~isBadFile(iFile) && ispc
   %# check for hidden Windows files - only works on Windows
   [~,stats] = fileattrib(fullfile(input_directory,fileList(iFile).name));
   if stats.hidden
      isBadFile(iFile) = true;
   end
   end
end

%# remove bad files
fileList(isBadFile) = [];

file_list_length = length(fileList);


end

