function [im_stack] = add_z_padding(im_stack)
%adds 2 planes in the begin and end of the image stack
im_stack = cat(3,im_stack(:,:,3),im_stack(:,:,2),im_stack,im_stack(:,:,end-1),im_stack(:,:,end-2));
end

