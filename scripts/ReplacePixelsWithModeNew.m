function res=ReplacePixelsWithModeNew(im, pixels)
pad = padarray(im, [1 1]);
c = im2col(pad, [3 3], 'sliding');
%c(find(c==0)) = NaN;
c(c==0) = NaN;
md = mode(c);
md = reshape(md, size(im));
%md(find(isnan(md))) = 0;
md(isnan(md)) = 0;

res = im;
res(pixels) = md(pixels);
res(isnan(res)) = 0;
%res(find(isnan(res))) = 0;
