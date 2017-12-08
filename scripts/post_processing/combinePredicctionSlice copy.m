function prob=combinePredicctionSlice(folder_name, threshold)
if ~exist(folder_name,'dir')
	disp(['Can''t find folder:  ' folder_name]);
	return
end
a = dir([folder_name filesep '*.h5']);
names={a.name};
f_idx=[cellfun(@(x) x(end)=='5',names,'UniformOutput',false)];

%name_list = {};
%len_list = [];
%return
% if strcmp(a(3).name , 'Thumbs.db')
    % a = a(4:end);
% else
    % a = a(3:end);
% end
% for i  = 1: length(a) 
   % name_list{i,1} = a(i).name;
   % len_list = [ len_list; length(name_list{i,1})];
% end

% [~, idx] = min(len_list);
% name_temp = name_list{idx}

f_idx=[f_idx{:}];
name_temp=names{f_idx}
%names
%return
name_temp = name_temp(1:end-4) 

tiff_file_save = strcat(folder_name, filesep,'prediction_result.tif');
delete(tiff_file_save);
mx=0;

%length(f_idx)
for i =  0: length(f_idx)-1
    %i
    filename = strcat(folder_name, filesep, name_temp, num2str(i),'.h5')
    
    b = h5read(filename,'/data');
	mx_s=max(size(size(b)));
	
	if mx_s==4
    b = squeeze(b(1,:,:,2));
	elseif mx_s==3
	b = squeeze(b(:,:,2));
	end
    c = zeros(size(b));
	%minn=min(b(:));
	%b=b-minn;
    mx_c=max(max(b));
	if mx<mx_c
		mx=mx_c;
	end
	
end

%prob=zeros(1024,1024,length(f_idx));
for i =  0: length(f_idx)-1
	filename = strcat(folder_name, filesep, name_temp, num2str(i),'.h5')
    b = h5read(filename,'/data');
	mx_s=max(size(size(b)));
	
	if mx_s==4
    b = squeeze(b(1,:,:,2));
	elseif mx_s==3
	b = squeeze(b(:,:,2));
	end
	prob(:,:,i+1)=b;
	im=255-uint8(b*(255/mx));
	imwrite(im,tiff_file_save,'WriteMode','append');
	disp(['write #' num2str(i) '  image ... ' tiff_file_save]);
   
end


