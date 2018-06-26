function [imgstack, lblstack] = check_img_dims(imgstack, lblstack, minsize)
%
% Check Canvas Size of training images and training labels
% to match same size and to fullfill min canvas size
%
%----------------------------------------------------------------------------------------
%% CDeep3M -- NCMIR/NBCR, UCSD -- Author: M Haberl -- Date: 03/2018
%----------------------------------------------------------------------------------------
%

disp('Checking image dimensions');
if ~(size(imgstack,1) == size(lblstack,1)) | ~(size(imgstack,2) == size(lblstack,2))
error('Image dimension mismatch in x/y between images and labels');
return
end
if ~(size(imgstack,3) == size(lblstack,3))
error('Image dimension mismatch in z between images and labels');
return
end

x1 = size(imgstack,1);
y1 = size(imgstack,2);

if x1<minsize
imgstack(x1+1:minsize,:,:) = 0;
lblstack(x1+1:minsize,:,:) = 0;
end

if y1<minsize
imgstack(:,y1+1:minsize,:) = 0;
lblstack(:,y1+1:minsize,:) = 0;
end


end