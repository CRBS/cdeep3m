folder='predict'
average=generate_16_average_probs(folder);
save_mat_file=[folder filesep 'ave_probs.mat'];
save_h5_file=[folder filesep 'ave_probs.h5'];
save(save_mat_file,'average','-v7.3');
p=single(average);
d_details.location = '/';
d_details.Name = 'probabilities';
hdf5write(save_h5_file,d_details,p);