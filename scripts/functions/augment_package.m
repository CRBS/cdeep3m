function augment_package(original, outsubdir,fmnumber,speed);
% Updates: 
% removed memory limiting steps
% All vectorized
% Optimized for reducing time of processing
%
%
%------------------------------------------------
%% augment_package for CDeep3M -- NCMIR/NBCR, UCSD
%------------------------------------------------

allowed_speed = [1,2,4,10];
if ~ismember(speed,allowed_speed)
[~,I] = min(abs(allowed_speed-speed));
speed = allowed_speed(I)
end

if speed == 10
        switch(fmnumber)
            case 1
            do_var = [1];
            case 3
            do_var = [11];
            case 5
            do_var = [4];
         endswitch
         
elseif speed == 1 
        switch(fmnumber)
            case 1
            do_var = [1:8];
            case 3
            do_var = [1:16];
            case 5
            do_var = [1:16];
         endswitch
         
elseif speed == 2 
        switch(fmnumber)
            case 1
            do_var = [1, 6, 11, 15];
            case 3
            do_var = [1:4, 13:16];
            case 5
            do_var = [5:12];
         endswitch        
         
elseif speed == 4 
        switch(fmnumber)
            case 1
            do_var = [2, 3, 6, 7 ];
            case 3
            do_var = [7, 8, 10, 12];
            case 5
            do_var = [1, 6, 11, 15];
         endswitch
end
         

for i = do_var(do_var<9)

    fprintf('Create Hd5 file Variation %s\n',num2str(i));     
        switch(i)
            case 1
                stack = original;
            case 2
                stack = flipdim(original,1);
                
            case 3
                stack = flipdim(original,2);
                
            case 4
                stack = rot90(original);
                
            case 5
                stack = rot90(original, -1);
                
            case 6
                stack = rot90(flipdim(original, 1));
                
            case 7
                stack = rot90(flipdim(original,2));
                
            case 8
                stack = rot90(original, 2);                
        end 
        
        stack_out=permute(stack,[3 1 2]); %from tiff to h5 /xyz to z*x*y
        d_details = '/data';
        filename = fullfile(outsubdir, sprintf('image_stacks_v%s.h5', num2str(i)));
        fprintf('Saving: %s\n',filename)
        %h5create(filename,d_details,size(i_stack)); %nescessary for Matlab not for Octave
        h5write(filename,d_details,stack_out);
        %clear -v stack   
end

if max(do_var)>8
%% V9-16: sweep Z dimension
disp('Sweep Z dimension')
original = flip(original,3);


for i = do_var(do_var>8)
    fprintf('Create Hd5 file Variation %s\n',num2str(i));     
        switch(i)
            case 9
                stack = original;
            case 10
                stack = flipdim(original,1);
                
            case 11
                stack = flipdim(original,2);
                
            case 12
                stack = rot90(original);
                
            case 13
                stack = rot90(original, -1);
                
            case 14
                stack = rot90(flipdim(original, 1));
                
            case 15
                stack = rot90(flipdim(original,2));
                
            case 16
                stack = rot90(original, 2);                
        end 
        
        stack_out=permute(stack,[3 1 2]); %from tiff to h5 /xyz to z*x*y
        d_details = '/data';
        filename = fullfile(outsubdir, sprintf('image_stacks_v%s.h5', num2str(i)));
        fprintf('Saving: %s\n',filename)
        %h5create(filename,d_details,size(i_stack)); %nescessary for Matlab not for Octave
        h5write(filename,d_details,stack_out);
        %clear -v stack
    
end
endif
end
