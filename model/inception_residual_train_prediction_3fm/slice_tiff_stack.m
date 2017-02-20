function write_mtiff_2_stiff(filename,out_folder)
    
	Imf=imfinfo(filename);
	
	if ~exist(out_folder,'dir')
		mkdir(out_folder)
	end
	
	mImage=Imf(1).Width
	nImage=Imf(1).Height
	NumberImages=length(Imf)
	color_dim = length(Imf(1).BitsPerSample)
    if  color_dim>1
	FinalImage=zeros(nImage,nImage,color_dim,NumberImages);
	else
	 FinalImage=zeros(nImage,nImage,NumberImages);
	 end
	for i=1:NumberImages
	   if color_dim>1
		FinalImage(:,:,:,i)=imread(filename,i);
	   else 
	    FinalImage(:,:,i)=imread(filename,i);
	   end
	end
    filename_base ='t';
	for i=1:NumberImages
		%im=labels(:,:,i);
		filename=[out_folder filesep filename_base num2str(i) '.tiff'];
		if color_dim>1
		im =FinalImage(:,:,:,i);
		else
		im=FinalImage(:,:,i);
		end
		
		imwrite(uint8(im),filename);
		disp(['write #' num2str(i) '  image ... ' filename]);
	end