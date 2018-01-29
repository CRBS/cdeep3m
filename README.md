# Deep3M

## Required environment:
C++, bash shell, matlab/octave, Cuda7.5

## Quickstart

Step 1: Create AWS account

Step 2: Launch Deep3m via EC2 cloud instance 

**WARNING: ** Running this will cause AWS charges!!!!

[![Launch Deep3m AWS CloudFormation link](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/new?stackName=deep3m-stack-v0-1-0&templateURL=https://s3-us-west-2.amazonaws.com/deep3m-releases/0.1.0/deep3m_v0.1.0_basic_cloudformation.json)

Step 3: Run Deep3m

Step 4: Be sure to Delete/Terminate stack

## Code

Step 1: PreprocessTraining
- Makes augmented hdf5 datafiles from raw and label images
- Syntax : PreprocessTraining /example/training/images/ /example/training/labels/ /savedirectory/

Step 2: train.sh
- Training the ConvNet (steps 2 and 4 are run separately for 1fm, 3fm and 5fm)

Step 3: PreprocessImages
- Preprocessing / Data augmentation of images to segment

Step 4: predict.sh
- Predict image segmentation
 - Data post-processing (data de-augmentation) directly launched by predict script
 
 Step 5: Generate ensemble prediction


## Data format
Expected data:
### A) Training data: Images together with matching binary labels -> For steps 1&2
### B) Image data to segment -> for steps 3&4 
- Input data format, PNGs, TIFs or TIF stack
- Data is converted to h5 file during augmentation

## Further reading:
This is an implementation developped off from the deep learning code released together with the paper published in Bioinformatics: **"DeepEM3D: Approaching human-level performance on 3D anisotropic EM image segmentation "**
