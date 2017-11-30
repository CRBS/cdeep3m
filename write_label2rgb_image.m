function write_label2rgb_image(L,fuse_im,file_prefix)
label_rgb = label2rgb3d(L,'hsv',[1,1,1],'Shuffle');'w'
for K=1:length(L(1, 1, :))
   %outputFileName = sprintf('img_%d.tif',K);
   %imwrite(label2rgb(L_test(:, :, K)), outputFileName);
   
   %imwrite(squeeze(lable_rgb(:,:,K,:),outoutFiileName));
   im=squeeze(label_rgb(:,:,K,:));
   if nargin >1
   f_im=squeeze(fuse_im(:,:,K,:));
   im = imfuse(im,f_im,'blend','Scaling','joint');
   end
   if nargin >2
      file=[file_prefix '.tiff'];
   else
		file='img.tiff';
   end
      imwrite(im,file,'WriteMode','append');
end
