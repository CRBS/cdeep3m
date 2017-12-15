function [D]=augment_image_data_only(raw_images, outsubdir)%,y)
% Update: inserted saving here to save

disp('Create V1-8')
idx=0;
%% V1-8:
create8Variation(raw_images,idx,outsubdir);
disp('V1-8 Saved')
slices=size(raw_images,1);
%% V9-16: sweep Z dimension
disp('Sweep Z dimension')
for i=1:slices/2
    temp_x=raw_images(slices-i+1,:,:);
    raw_images(slices-i+1,:,:)=raw_images(i,:,:);
    raw_images(i,:,:)=temp_x;
    
end
disp('Create V9-16')
idx=8;
create8Variation(raw_images,idx,outsubdir);
disp('V9-16 Saved')
end

function [D]=create8Variation(x,idx,outsubdir)  % without any label, just data
for j = 1:8
    variation=j+idx;
    %fprintf('\nCreate variation %s\n',num2str(variation));
    for i = 1:size(x,1)  %go through every plane
        original = squeeze(x(i,:,:));        
        switch(j)
            case 1
            case 2
                original = flipdim(original,1);
                
            case 3
                original = flipdim(original,2);
                
            case 4
                original = rot90(original);
                
            case 5
                original = rot90(original, -1);
                
            case 6
                original = rot90(flipdim(original, 1));
                
            case 7
                original = rot90(flipdim(original,2));
                
            case 8
                original = rot90(original, 2);                
        end
        dat(i,:,:) = original;             
    end
        %fprintf('Saving Hd5 file V%s\n',num2str(variation))
        d_details = '/data';
        filename = fullfile(outsubdir, sprintf('test_data_full_stacks_v%s.h5', num2str(variation)));
        %h5create(filename,d_details,size(i_stack)); %nescessary for Matlab not for Octave
        h5write(filename,d_details,dat);
        clear -v i_stack
           

    %D{j} = data;    
    clear dat;
    
end
end

%{
function [D,L,Seg_L]=create8Variation_withSeglabel(x,y,segY)
for j = 1:8
    for i = 1:size(x,1)
        original = squeeze(x(i,:,:));
        lb = squeeze(y(i,:,:));
        seg_lb= squeeze(segY(i,:,:));
        switch(j)
            case 1
            case 2
                original = flipdim(original,1);
                lb = flipdim(lb,1);
                seg_lb=flipdim(seg_lb,1)
            case 3
                original = flipdim(original,2);
                lb = flipdim(lb,2);
                seg_lb = flipdim(seg_lb,2);
            case 4
                original = rot90(original);
                lb = rot90(lb);
                seg_lb = rot90(seg_lb);
            case 5
                original = rot90(original, -1);
                lb = rot90(lb, -1);
                seg_lb = rot90(seg_lb, -1);
            case 6
                original = rot90(flipdim(original, 1));
                lb = rot90(flipdim(lb, 1));
                seg_lb = rot90(flipdim(seg_lb, 1));
            case 7
                original = rot90(flipdim(original,2));
                lb = rot90(flipdim(lb,2));
                seg_lb = rot90(flipdim(seg_lb, 2));
            case 8
                original = rot90(original, 2);
                lb = rot90(lb, 2);
                seg_lb = rot90(seg_lb, 2);
        end
        data(i,:,:) = original;
        label(i,:,:) =lb;
        seg_label(i,:,:)=seg_lb
        %elm_labels(i,:,:) = label;
    end
    D{j} = data;
    L{j}=label;
    Seg_L{j}=seg_label;
    clear data;
    clear label;
    clear Seg_L;
end
end
%}
