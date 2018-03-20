function [packages, z_blocks] = break_large_img(imagesize)
%Defines how to read large images
%Note: Packages define X/Y direction only;
% z_blocks define splitting z direction

%= 1: round(imagesize(1)/1024)

%% Z-direction splitting
if imagesize(3) >100
z_blocks = [1:100:imagesize(3)];
if z_blocks(end)<imagesize(3) ; z_blocks =[z_blocks, imagesize(3)]; end
disp('Data will be split in z direction at planes:');
disp(z_blocks);
else z_blocks = [1,imagesize(3)]
end

%% Check for image dimensions, if large break in this direction
if imagesize(1) > 1024
    x_breaks = [0:1000:(imagesize(1))];
    if x_breaks(end)<imagesize(1); x_breaks = [x_breaks,imagesize(1)]; end
else x_breaks = [1, imagesize(1)];
end

if imagesize(2) > 1024
    y_breaks = [0:1000:(imagesize(2))];
    if y_breaks(end)<imagesize(2); y_breaks = [y_breaks,imagesize(2)]; end
else y_breaks = [1, imagesize(2)];
end

%% Define boundaries what to read, with certain overlap
packs = (numel(x_breaks)-1) * (numel(y_breaks)-1);
if packs>1
counter = 0;
for xx = 1:(numel(x_breaks)-1)
    if xx==1
        xstart = x_breaks(xx)+1; 
    else
        xstart = x_breaks(xx)-11;
    end
    
    if xx==numel(x_breaks)-1
        xend = x_breaks(xx+1);
    else
        xend = x_breaks(xx+1)+12;
    end
    for yy = 1:(numel(y_breaks)-1)
        counter = counter+1;
        if yy==1
            ystart = y_breaks(yy)+1;
        else
            ystart = y_breaks(yy)-11;
        end
        
        if yy==numel(y_breaks)-1
            yend = y_breaks(yy+1);
        else
            yend = y_breaks(yy+1)+12;
        end
        
        packages{counter} = [xstart, xend, ystart, yend];
        
    end
    
    
    
    
end
else
packages{1} = [1, imagesize(2), 1, imagesize(1)];
end


end
