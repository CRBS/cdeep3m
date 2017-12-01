# Deep3M

# Required environment:
C++, bash shell, matlab/octave, Cuda7.5

# Code
Step 1: PreprocessTraining
- Makes augmented hdf5 datafiles from raw and label images
- Syntax : PreprocessTraining /example/training/images/ /example/training/labels/ /savedirectory/

Step 2: train.sh
- Training the ConvNet (steps 2 and 4 are run separately for 1fm, 3fm and 5fm)

Step 3: PreprocessImages
- Preprocessing / Data augmentation of images to segment

Step 4: predict.sh
- Predict image segmentation

Step 5: StartPostprocessing 
Data post-processing (includes data de-augmentation and ensemble prediction)


# Data format
Expected data:
A) Training data: Images together with matching binary labels -> For steps 1&2
B) Input data format, PNGs, TIFs or TIF stack
Data is converted to h5 file during augmentation

# Further reading:
This is an implementation developped off from the deep learning code released together with the paper published in Bioinformatics: **"DeepEM3D: Approaching human-level performance on 3D anisotropic EM image segmentation "**
