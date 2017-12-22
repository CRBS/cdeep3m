function list = filter_files(list,fileformat) 
%filter_files
% Reducing the factors that are not the 'fileformat' in 'list' 
for i=1:length(list)
clear -v ext
[~,~,ext] = fileparts(list(i).name);
list(i).fileformat = strcmpi(ext,fileformat);
if isempty(list(i).fileformat)
    list(i).fileformat = 0;
end   
fileformats(i) = list(i).fileformat;
end
fileformats_in_folder = find(fileformats);
list = list(fileformats_in_folder);
end
