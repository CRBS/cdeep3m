[aws]: https://aws.amazon.com/

# Deep3M

## Required environment:
C++, bash shell, matlab/octave, Cuda7.5

## Quickstart

Click here for quick start instructions:

https://github.com/slash-segmentation/deep3m/wiki/Running-Deep3m-via-AWS-CloudFormation

## Code

#### Step 1: PreprocessTrainingData
- Makes augmented hdf5 datafiles from raw and label images
- Syntax : PreprocessTrainingData.m \<training images directory\> \<training labels directory\> \<save directory\>

```Bash
PreprocessTrainingData.m ~/training/images ~/training/labels ~/augtraindata
```

#### Step 2: runtraining.sh
- Training the ConvNet 
- Syntax : runtraining.sh \<output directory from PreprocessTrainingData.m\> \<output directory\>

```Bash
runtraining.sh ~/augtraindata ~/trainout
```

#### Step 3: PreprocessImageData
- Preprocessing / Data augmentation of images to segment
- Syntax : PreprocessImageData.m \<images to segment\> <\output directory\>

```Bash
PreprocessImageData.m ~/images ~/augimages
```

#### Step 4: runprediction.sh
- Predict image segmentation
- Data post-processing (data de-augmentation) directly launched by predict script
- Syntax : runprediction.sh \<output directory from runtraining.sh\> <\output directory from PreprocessImageData.m\> \<output directory\>

```Bash
runprediction.sh ~/trainout ~/augimages ~/predictout
```
 
#### Step 5: Generate ensemble prediction

- Syntax : TODO

```Bash
EnsemblePredictions.m
```


## Data format
Expected data:
### A) Training data: Images together with matching binary labels -> For steps 1&2
### B) Image data to segment -> for steps 3&4 
- Input data format, PNGs, TIFs or TIF stack
- Data is converted to h5 file during augmentation

## Further reading:
This is an implementation developped off from the deep learning code released together with the paper published in Bioinformatics: **"DeepEM3D: Approaching human-level performance on 3D anisotropic EM image segmentation "**
