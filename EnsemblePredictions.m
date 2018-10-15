#!/usr/bin/octave -qf
%% EnsemblePredictions
% different predictions coming from files e.g. from 1fm 3fm and 5fm will be averaged here
% flexible number of inputs
% last argument has to be the outputdirectory where the average files are stored
%
% -----------------------------------------------------------------------------
%% NCMIR, UCSD -- Author: M Haberl -- Data: 10/2017 -- Update: 10/2018
% -----------------------------------------------------------------------------
%

%% Initialize

script_dir = fileparts(make_absolute_filename(program_invocation_name()));
addpath(genpath(script_dir));
tic

arg_list = argv ();

if numel(arg_list) < 3
  fprintf('Please specify more than one input directory to average: EnsemblePredictions ./inputdir1 ./inputdir2 ./inputdir3 ./outputdir\n');
  return
end

for i = 1:(numel(arg_list)-1)
    to_process{i} = arg_list{i};
    if ~isdir(arg_list{i})
    fprintf('%s not a directory\nPlease check if predictions ran successfully or ensure to use: EnsemblePredictions ./inputdir1 ./inputdir2 ./inputdir3 ./outputdir\n',arg_list{i});
    return
    end
    list{i} = filter_files(read_files_in_folder(to_process{i}),'.png');
end
outputdir = arg_list{numel(arg_list)};
mkdir(outputdir);
%raw_image_full_path = arg_list{end};

%% =============== Generate ensemble predictions =================================

pysemble = strcat(script_dir,filesep(),'scripts',filesep(),'functions',filesep(),'ensemble.py');

tempmat_infile = fullfile(fileparts(outputdir),'infolders.txt');
delete(tempmat_infile);

fid = fopen(tempmat_infile, 'a')
for fl = 1:numel(to_process)             
fprintf(fid, strcat(fullfile(to_process{fl}),'\n'));
end
fclose(fid);

system(sprintf('%s %s %s',pysemble, tempmat_infile, outputdir));

fprintf('Elapsed time for merging predictions is %06d seconds.\n', round(toc));
