function make_submit_tiff(vol,prefix)
submit_dir ='submit';
if ~exist(submit_dir,'dir')
mkdir(submit_dir);
end
for i=1:size(vol,3)
	meta_file=[prefix num2str(i) '.mha'];
	meta_file=[submit_dir filesep meta_file];
	
	writemeta(meta_file,squeeze(vol(:,:,i)));
end
read_prefix=[submit_dir filesep prefix];
write32bitTiff(read_prefix);

end