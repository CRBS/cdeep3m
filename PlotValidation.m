#!/usr/bin/octave -qf


% PlotValidation
% Generates traing vs validation loss plot. 
%
% Syntax : PlotValidation.m <train_output.csv> <validation_output.csv> <log dir>
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
%   [3,1] = output dir
% }
arg_list = argv ();
if numel(arg_list) == 0
fprintf('\nSyntax:\n PlotValidation.m <train_output.csv> <validation_output.csv> <output_filepath.png>\nor\nPlotValidation.m ~/trainingdata/1fm/log\n');return
elseif numel(arg_list) == 1
logdir = arg_list{1,1};
  if exist(logdir,'dir')==7
  disp('Parsing log file');
  train_file = fullfile(logdir, 'out.log.train'); 
  test_file = fullfile(logdir, 'out.log.test'); 
  system(sprintf('python ~/caffe_nd_sense_segmentation/tools/extra/parse_log.py %s %s',fullfile(logdir, 'out.log'), logdir));
  else
  disp('Invalid argument');
  return
  end
  
else
logdir = arg_list{3,1}; 
train_file = arg_list{1,1};
test_file = arg_list{2,1};
end

disp('Reading CSV files');
% column format for train_output csv (NumIters,Seconds,LearningRate,loss_deconv_all)
train_output = csvread(train_file,1,0); 

% column format for test_output csv (NumIters,Seconds,LearningRate,accuracy_conv,class_Acc,loss_deconv_all)
test_output = csvread(test_file,1,0); 


% Plot loss
plt_loss = figure; 
plot(train_output(:,1),train_output(:,4), test_output(:,1), test_output(:,6)); 
grid on; 
set(gca, 'xlabel', 'Number of Iterations'); 
set(gca, 'ylabel', 'Loss'); 
set(gca, 'Title', 'Training vs Validation Loss'); 
set(gca, 'YMinorTick','on', 'YMinorGrid','on'); 
set(gca,'YScale','log'); 
legend("Training","Validation"); 

outfile = fullfile(logdir, 'loss');

%print(plt_loss,outfile, "-dpngcairo"); 
print(plt_loss,outfile, "-dpdfcairo");
fprintf('Your loss output file is saved as: %s.pdf\n', outfile);




% Plot accuracy 
plt_accuracy = figure; 
plot(test_output(:,1), test_output(:,4)); 
grid on; 
set(gca, 'xlabel', 'Number of iterations'); 
set(gca, 'ylabel', 'Accuracy'); 
set(gca, 'Title', 'Validation Accuracy'); 



outfile = fullfile(logdir, 'accuracy');
print(plt_accuracy,outfile, "-dpdfcairo");
fprintf('Your accuracy output file is saved as: %s.pdf\n', outfile);

