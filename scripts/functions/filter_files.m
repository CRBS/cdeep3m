function list = filter_files(list,fileformat) 
%filter_files
% Reducing the factors that are not the 'fileformat' in 'list' 
for i=1:length(list)
list(i).fileformat = strfind(list(i).name,fileformat);
if isempty(list(i).fileformat)
    list(i).fileformat = 0;
end    
fileformats(i) = double(list(i).fileformat);
end
fileformats_in_folder = find(fileformat);
list = list(fileformats_in_folder);
end
