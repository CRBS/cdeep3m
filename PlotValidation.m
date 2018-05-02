#!/usr/bin/octave -qf


% PlotValidation
% Generates traing vs validation loss plot. 
%
% Syntax : PlotValidation.m <train_output.csv> <validation_output.csv> <output_filepath.png>
%
%
%-------------------------------------------------------------------------------
%% Validation for Deep3M -- NCMIR/NBCR, UCSD -- Author: L Tindall -- Date: 5/2018
%-------------------------------------------------------------------------------
%

% arg_list =
% {
%   [1,1] = train_output.csv
%   [2,1] = test_output.csv
%   [3,1] = output_filepath.png
% }
arg_list = argv ();

% column format for train_output csv (NumIters,Seconds,LearningRate,loss_deconv_all)
train_output = csvread(arg_list{1,1},1,0); 

% column format for test_output csv (NumIters,Seconds,LearningRate,accuracy_conv,class_Acc,loss_deconv_all)
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


print(plt, arg_list{3,1}, "-dpngcairo"); 

