function lb=my_border_labeling(data)
  b_size=size(data);
  x=round(b_size(1)/2);
  y=round(b_size(2)/2);
  
  if data(x,y)==0
	lb =0;
	return
  end
  
  uq=unique(data);
  if uq(1)==0 
	 uq(1)=[];
  end
  
  
  if ~isempty(uq) && length(uq)>1
	 lb= 0;
  else
     lb=1;
  end
  
  %data(data~=0)=1;
  %

	
end