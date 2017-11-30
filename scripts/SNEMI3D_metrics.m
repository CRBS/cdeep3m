%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SNEMI3D challenge: 3D segmentation of neurites in EM images
% 
% Script to calculate the segmentation error between some 3D 
% original labels and their corresponding proposed labels. 
% 
% The evaluation metric is:
%  - Rand error: 1 - F-score of adapted Rand index
% 
% author: Ignacio Arganda-Carreras (iarganda@mit.edu)
% More information at http://brainiac.mit.edu/SNEMI3D
%
% This script released under the terms of the General Public 
% License in its latest edition.
%
% Input: 
%       segA - ground truth (16-bit labels, 0 = background)
%       segB - proposed labels (16-bit labels, 0 = background)
% Output:
%       re - adapated Rand error (1.0 - F-score of adapted Rand index)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [re] = SNEMI3D_metrics( segA, segB )

segA = double(segA)+1;
segB = double(segB)+1;
n = numel(segA);

n_labels_A = max(segA(:));
n_labels_B = max(segB(:));

% compute overlap matrix
p_ij = sparse(segA(:),segB(:),1,n_labels_A,n_labels_B);

% a_i
a_i = sum(p_ij(2:end,:), 2);

% b_j
b_j = sum(p_ij(2:end,2:end), 1);

p_i0 = p_ij(2:end,1);	% pixels marked as BG in segB which are not BG in segA
p_ij = p_ij(2:end,2:end);

sumA = sum(a_i.*a_i);
sumB = sum(b_j.*b_j) +  sum(p_i0)/n;
sumAB = sum(sum(p_ij.^2)) + sum(p_i0)/n;

% Rand index
%ri = full(1 - (sumA + sumB - 2*sumAB)/ n^2);

% precision
prec = sumAB / sumB;

% recall
rec = sumAB / sumA;

% F-score
fScore = 2.0 * prec * rec / (prec + rec);

re = 1.0 - fScore;

end

