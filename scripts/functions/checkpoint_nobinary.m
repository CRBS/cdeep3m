function [] = checkpoint_nobinary(imagestack)
%checkpoint_nobinary
%   Make sure user didn't by mistake input binaries where there should be images 
    if numel(unique(imagestack(:))) < 3
        disp('Images are not 8 or 16bit');
        disp('Please be sure you did not use binary labels by mistake here'); 
        reply = input('Type S to stop image augmentation?  Otherwise images will be augmented now','s');
        if regexpi(reply ,'S')
            disp('Augmentation cancelled')
            return
        end
    end

end

