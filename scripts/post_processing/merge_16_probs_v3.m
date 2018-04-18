function folder = merge_16_probs_v3(folder)
folder=fullfile(folder);
%mkdir(folder);
folder_name=fullfile(folder, 'v1');
all_files = read_files_in_folder(folder_name);
first_file = all_files(1).name;
[~,NAME,ext]  = fileparts(first_file);
%digits = regexpi(NAME, '\d');
filebasename = NAME(1:end-1); %drop the last is the digit

for  fff = 2: (numel(all_files)-3) %predictions start with 0; Ignore 0&1 and last two, since they are z-padding 
  
    loadfile = [filebasename,num2str(fff),'.h5'];
    fprintf('Merging 16 variations of file %s ... number %s of %s\n', filebasename, num2str(fff-1), num2str(numel(all_files)-3));
    image = [];
    for i=1:8  %File 1:8 are 1:100
        folder_name=[folder filesep 'v' num2str(i)];

        if exist(folder_name,'dir')==7
        filename = fullfile(folder_name,loadfile);        
        %fileinfo = h5info(filename);              
        load_im = h5read(filename, '/data');
        fprintf('H5 Dimensions: %s \n' ,num2str(size(load_im)));
        %scale = max(max(load_im(:,:,2)));
        inputim = load_im(:,:,2);
        switch(i)
            case 1
                inputim = inputim;
            case 2
                inputim = flipdim(inputim,1);
            case 3
                inputim = flipdim(inputim,2);
            case 4
                inputim = rot90(inputim, -1);
            case 5
                inputim = rot90(inputim);
            case 6
                inputim = flipdim(rot90(inputim,-1), 1);
            case 7
                inputim = flipdim(rot90(inputim,-1), 2);
            case 8
                inputim = rot90(inputim,2);
        end
        image = cat(3,image,inputim);
        end
        %prob=combinePredicctionSlice_v2(folder_name);
        %data{i}=prob;
    end

%Variations 9-16 are inverse organized    
    loadfile_revert = [filebasename,num2str(numel(all_files) - (fff+1)),'.h5'];
    for i=1:8 %File 9:16 are 100:1
        var = i+8;
        folder_name=[folder filesep 'v' num2str(var)];
        if exist(folder_name,'dir')==7               
        filename = fullfile(folder_name,loadfile_revert);
        load_im = h5read(filename, '/data');
        %scale = max(max(load_im(:,:,2)));
        inputim = load_im(:,:,2);
        switch(i)
            case 1
                inputim = inputim;
            case 2
                inputim = flipdim(inputim,1);
            case 3
                inputim = flipdim(inputim,2);
            case 4
                inputim = rot90(inputim, -1);
            case 5
                inputim = rot90(inputim);
            case 6
                inputim = flipdim(rot90(inputim,-1), 1);
            case 7
                inputim = flipdim(rot90(inputim,-1), 2);
            case 8
                inputim = rot90(inputim,2);
        end
        image = cat(3,image,inputim) ;    
        end
    end
   
    %{
    %To check if 16 variations are good uncomment here
    output_filename=fullfile(folder , sprintf('%s_%04d.tiff', filebasename,(fff+1)));
    for z = 1:16
        imwrite(sixteen_vars(:,:,z),output_filename,'WriteMode','append');
        fprintf('Saving: %s ... Image #%s   \n', output_filename, num2str(z));
    end
    %}
    image = mean(image,3);
    
    %image_stack=de_augment_data(b);    
    output_filename=fullfile(folder , sprintf('%s_%04d.png', filebasename,(fff-2)));
    %delete(filename);
    disp(['write: ' output_filename]);
    imwrite(image,output_filename);
    %tiff_file_save=[folder filesep 'ave_16.tiff'];
    
    %%tried different weighting of 16v predictions, using mode instead of average -> need to test if better but currently slow
    %{
    image2 = mode(sixteen_vars,3);
    outdir2=fullfile(folder,'de_augmented_mode_weighting');
    mkdir(outdir2);
    output_filename2=fullfile(outdir2, sprintf('%s_%04d.png', filebasename,(fff+1)));
    %delete(filename);
    disp(['write: ' output_filename2]);
    imwrite(image2,output_filename2);    
    %}
end
%{
if exist(tiff_file_save, 'file'),delete(tiff_file_save); end
mx_im=max(average(:));
for i=1:size(average,3)
    b=average(:,:,i);
    im=uint8(b*(255/mx_im)); %removed 255- inverted image values
    imwrite(im,tiff_file_save,'WriteMode','append');
    disp(['write #' num2str(i) '  image ... ' tiff_file_save]);
end
%}
disp('Deleting intermediate .h5 files');
for i = 1:16
removefolders=[folder,filesep,'v',num2str(i)];
fprintf('Deleting %s\n', removefolders);
rmdir(removefolders, 's');
end

end


function eight_vars=recover8Variation(x)
prob=x{1};
average=zeros([size(prob),8]);
for j = 1:8
    prob = x{j};
    %for j = 1:size(prob,3)
        %p=squeeze(prob(:,:,j));
        switch(j)
            case 1
                average(:,:,j) = average(:,:,j)+ prob;
            case 2
                average(:,:,j) = average(:,:,j) + flipdim(prob,1);
            case 3
                average(:,:,j) = average(:,:,j) + flipdim(prob,2);
            case 4
                average(:,:,j) = average(:,:,j) + rot90(prob, -1);
            case 5
                average(:,:,j) = average(:,:,j) + rot90(prob);
            case 6
                average(:,:,j) = average(:,:,j) + flipdim(rot90(prob,-1), 1);
            case 7
                average(:,:,j) = average(:,:,j) + flipdim(rot90(prob,-1), 2);
            case 8
                average(:,:,j) = average(:,:,j) + rot90(prob,2);
        end
    %end
    eight_vars=average;
end
end

