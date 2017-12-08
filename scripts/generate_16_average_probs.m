function average=generate_16_average_probs(folder)
    %addpath('../../script')
	for i=1:16
		folder_name=[folder filesep 'v' num2str(i)];
		prob=combinePredicctionSlice(folder_name);
		data{i}=prob;
	end
	
	average=de_augment_data(data);
	tiff_file_save=[folder filesep 'ave_16.tiff'];
    if exist(tiff_file_save, 'file'),delete(tiff_file_save); end
    
	mx_im=max(average(:));
	for i=1:size(average,3)
	    b=average(:,:,i);
		im=255-uint8(b*(255/mx_im));
		imwrite(im,tiff_file_save,'WriteMode','append');
		disp(['write #' num2str(i) '  image ... ' tiff_file_save]);
	end
end