# DeepEM3D
This is the implementation code for paper submitted to Bioinformatics: **"DeepEM3D: Approaching human-level performance on 3D anisotropic EM image segmentation "**

# Required environment:
C++, bash shell, matlab, Cuda7.5

# Data
(1). Register at:
http://brainiac2.mit.edu/SNEMI3D/user/register

(2). Login in and download data at:
http://brainiac2.mit.edu/SNEMI3D/downloads

(3) Convert image files into h5 file that contains **\data** and **\label** sets.

# Code
1. To generate boundary labels:
run matlab scripts:  */scripts/create_new_vertical_closed_label.m*
2. To generate all data h5 files (train, valid, test)
run matlab scripts: */scripts/read_data_write_data_with_enhanced_labels.m*
3. To train and predict netwroks models:
run shell scripts:  */model/inception_residual_train_prediction_xfm/train.sh* **or** *predict.sh*

