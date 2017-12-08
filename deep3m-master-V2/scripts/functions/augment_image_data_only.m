function [D]=augment_image_data_only(raw_images)%,y)

disp('create V1-8')  
idx=0;
[data1]=create8Variation(raw_images,idx);
slices=size(raw_images,1);
%sweep Z dimension
disp('Sweep Z dimension')
	for i=1:slices/2 
	    temp_x=raw_images(slices-i+1,:,:);
		raw_images(slices-i+1,:,:)=raw_images(i,:,:);
		raw_images(i,:,:)=temp_x;

    end
disp('create V9-16')
idx=8;
[data2]=create8Variation(raw_images,idx);

D=[data1 data2];

end

function [D]=create8Variation(x,idx)  % without any label, just data
for j = 1:8
    fprintf('\nCreate variation %s\n',num2str(j+idx));
	for i = 1:size(x,1)
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
		data(i,:,:) = original;


	end
	D{j} = data;

	clear data;

end
end


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