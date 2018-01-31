function [D,L]=augment_data(x,y)
disp('augmenting'); 
disp('create V1-8');
idx=0;
[data1,label1]=create8Variation(x,y,idx);

slices=size(x,1);
%sweep Z dimension
	for i=1:slices/2
	    temp_x=x(slices-i+1,:,:);
		x(slices-i+1,:,:)=x(i,:,:);
		x(i,:,:)=temp_x;
		
		temp_y=y(slices-i+1,:,:);
		y(slices-i+1,:,:)=y(i,:,:);
		y(i,:,:)=temp_y;
    end
disp('create V9-16')
idx=8;
[data2,label2]=create8Variation(x,y,idx);

D=[data1 data2];
L=[label1 label2];
end

function [D,L]=create8Variation(x,y,idx)
for j = 1:8
fprintf('\nCreate variation %s\n',num2str(j+idx));	
	for i = 1:size(x,1)
	fprintf('.');
		original = squeeze(x(i,:,:));
		lb = squeeze(y(i,:,:));
		switch(j)
            case 1
            case 2
                original = flipdim(original,1);
				lb = flipdim(lb,1);
            case 3
                original = flipdim(original,2);
				lb = flipdim(lb,2);
            case 4
                original = rot90(original);
                lb = rot90(lb);
            case 5
                original = rot90(original, -1);
				lb = rot90(lb, -1);
            case 6
                original = rot90(flipdim(original, 1));
				lb = rot90(flipdim(lb, 1));
            case 7
                original = rot90(flipdim(original,2));
				lb = rot90(flipdim(lb,2));
            case 8
                original = rot90(original, 2);
				lb = rot90(lb, 2);
        end
		data(i,:,:) = original;
		label(i,:,:) =lb;
		%elm_labels(i,:,:) = label;
	end
	D{j} = data;
	L{j}=label;
	clear data;
	clear label;
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
				seg_lb=flipdim(seg_lb,1); 
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
		seg_label(i,:,:)=seg_lb; 
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
