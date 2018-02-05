function [img_out,lb_out]=augment_data(img_in,lbl_in,i)
fprintf('\nCreate variation %s and %s\n',num2str(i),num2str(i+8));
switch(i)
    case 1
        img_out = img_in;
        lb_out = lbl_in;
    case 2
        img_out = flipdim(img_in,1);
        lb_out = flipdim(lbl_in,1);
    case 3
        img_out = flipdim(img_in,2);
        lb_out = flipdim(lbl_in,2);
    case 4
        img_out = rot90(img_in);
        lb_out = rot90(lbl_in);
    case 5
        img_out = rot90(img_in, -1);
        lb_out = rot90(lbl_in, -1);
    case 6
        img_out = rot90(flipdim(img_in, 1));
        lb_out = rot90(flipdim(lbl_in, 1));
    case 7
        img_out = rot90(flipdim(img_in,2));
        lb_out = rot90(flipdim(lbl_in,2));
    case 8
        img_out = rot90(img_in, 2);
        lb_out = rot90(lbl_in, 2);
end

end
