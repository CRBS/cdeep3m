function [] = checkpoint_isbinary(imagestack)
%checkpoint_nobinary
%   Make sure user didn't by mistake input binaries where there should be images 
    if numel(unique(imagestack(:))) > 2
        disp('Your labels do not seem to be binary files');
        reply = input('Type S to stop label augmentation here?  Otherwise label augmentation will proceed now','s');
        if regexpi(reply ,'S')
            disp('Augmentation cancelled')
            return
        end
    end

end

