function x=full_fill(x)
count =0;
%while(length(find(x==0)) > 0)
while(sum(x(:)==0) > 0)
	%x = ReplacePixelsWithModeNew(x, find(x==0));
	x = ReplacePixelsWithModeNew(x, x==0);
    count =count+1;
    %disp(['count loop  = ' num2str(count)])
    %imshow(label2rgb(x))
end





