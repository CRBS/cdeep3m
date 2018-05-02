#!/usr/bin/octave -qf


% PlotValidation
% Generates traing vs validation loss plot. 
%
% Syntax : PlotValidation.m <train_output.csv> <validation_output.csv> <output_filepath.png>
%
% or can be run directly on a log folder of CDeep3M
% Syntax : PlotValidation.m ~/trainingdata/1fm/log
% => Will create csv files in same log folder and plot of loss.png in same directory
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

if numel(arg_list) == 1
logdir = arg_list{1,1};
  if exist(logdir,'dir')==7
  disp('Parsing log file');
  system(sprintf('python ~/caffe_nd_sense_segmentation/tools/extra/parse_log.py %s %s',fullfile(logdir, 'out.log'), logdir));
  train_file = fullfile(logdir, 'out.log.train'); delete(train_file);
  test_file = fullfile(logdir, 'out.log.test');  delete(test_file);
  else
  disp('Invalid argument');
  return
  end
  
else
train_file = arg_list{1,1};
test_file = arg_list{2,1};
end

disp('Reading CSV files');
% column format for train_output csv (NumIters,Seconds,LearningRate,loss_deconv_all)
train_output = csvread(train_file,1,0); 

% column format for test_output csv (NumIters,Seconds,LearningRate,accuracy_conv,class_Acc,loss_deconv_all)
test_output = csvread(test_file,1,0); 

plt = figure; 
plot(train_output(:,1),train_output(:,4), test_output(:,1), test_output(:,6)); 
grid on; 
set(gca, 'xlabel', 'Number of Iterations'); 
set(gca, 'ylabel', 'Loss'); 
set(gca, 'Title', 'Training vs Validation Loss'); 
set(gca, 'YMinorTick','on', 'YMinorGrid','on'); 
set(gca,'YScale','log'); 
legend("Training","Validation"); 

if numel(arg_list)==3
outfile = arg_list{3,1};
elseif numel(arg_list)==1
outfile = fullfile(logdir, 'loss.png');
end
print(plt,outfile, "-dpngcairo"); 
fprintf('Your outputfile is saved as: %s\n', outfile');
