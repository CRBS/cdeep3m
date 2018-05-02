#!/usr/bin/octave -qf

% arg_list =
% {
%   [1,1] = train_output.csv
%   [2,1] = test_output.csv
%   [3,1] = output_dir
% }
arg_list = argv ();

% NumIters,Seconds,LearningRate,loss_deconv_all
train_output = csvread(arg_list{1,1},1,0); 
test_output = csvread(arg_list{2,1},1,0); 


plt = figure; 
plot(train_output(:,1),train_output(:,4), test_output(:,1), test_output(:,6)); 
grid on; 
set(gca, 'xlabel', 'Number of Iterations'); 
set(gca, 'ylabel', 'Loss'); 
set(gca, 'Title', 'Training vs Validation Loss'); 
set(gca, 'YMinorTick','on', 'YMinorGrid','on'); 
set(gca,'YScale','log'); 
legend("Training","Validation"); 


output_img_path = strcat(arg_list{3,1},filesep(),'train_vs_val.png')
print(plt,output_img_path, "-dpngcairo"); 

