function prob=de_augment_data(D)
d_size=length(D);
prob1_sum=recover8Variation(D(1:8));
if d_size ==16
	prob2_sum=recover8Variation(D(9:16));
	temp_sum2=prob2_sum;

	slices=size(temp_sum2,3);
	%sweep Z dimension
	for i=1:slices/2
		temp=temp_sum2(:,:,slices-i+1);
		temp_sum2(:,:,slices-i+1)=temp_sum2(:,:,i);
		temp_sum2(:,:,i)=temp;
	end
	prob2_sum=temp_sum2;
	prob=(prob1_sum+prob2_sum)/16;
else
   prob=prob1_sum/d_size;
end

function sum=recover8Variation(x)
prob=x{1};
average=zeros(size(prob));
for i = 1:8
	prob = x{i};
  for j = 1:size(prob,3)
	p=squeeze(prob(:,:,j));
	switch(i)
			case 1
				average(:,:,j) = average(:,:,j)+p(:,:,1);
			case 2
				average(:,:,j) = average(:,:,j) + flipdim(p(:,:,1),1);
			case 3
				average(:,:,j) = average(:,:,j) + flipdim(p(:,:,1),2);
			case 4
				average(:,:,j) = average(:,:,j) + rot90(p(:,:,1), -1);
			case 5
				average(:,:,j) = average(:,:,j) + rot90(p(:,:,1));
			case 6
				average(:,:,j) = average(:,:,j) + flipdim(rot90(p(:,:,1),-1), 1);
			case 7
				average(:,:,j) = average(:,:,j) + flipdim(rot90(p(:,:,1),-1), 2);
			case 8
				average(:,:,j) = average(:,:,j) + rot90(p(:,:,1),2);
    end
    xxx=1;
  end
  	sum=average;
end
