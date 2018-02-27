[aws]: https://aws.amazon.com/
[deepem3d]: https://github.com/divelab/deepem3d
[deep3mviaaws]: https://github.com/slash-segmentation/cdeep3m/wiki/Running-Deep3m-via-AWS-CloudFormation
[divelablicense]: https://github.com/slash-segmentation/cdeep3m/blob/master/model/LICENSE
[license]: https://github.com/slash-segmentation/cdeep3m/blob/master/LICENSE

# CDeep3M

CDeep3M is a plug-and-play cloud based deep learning for image segmentation of light, electron and X-ray microscopy derived from [DeepEM3D][deepem3d]

This is the code for the paper submitted to Nature methods titled: 

"CDeep3M - Plug-and-Play cloud based deep learning for image segmentation of light, electron and X-ray microscopy"

# Run CDeep3M in the cloud

Click link below to spin up CDeep3M on the cloud:

**WARNING: Running the CloudFormation stack described below will result in EC2 charges**

**Oregon region:**

[![Launch Deep3m AWS CloudFormation link](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/new?stackName=cdeep3m-stack-0-12-0rc3&templateURL=https://s3-us-west-2.amazonaws.com/cdeep3m-releases/0.12.0rc3/cdeep3m_0.12.0rc3_basic_cloudformation.json)


[Click here for detailed instructions][deep3mviaaws]

## Training with test dataset on Cloud

### Step 1) Connect via ssh to instance created from link above

```Bash
ssh ubuntu@PublicDNS_VALUEFROM_WEBPAGE_ABOVE
```

### Step 2) Run PreprocessTrainingData.m

```Bash
cd ~
PreprocessTrainingData.m ~/cdeep3m/mito_testsample/training/images/ ~/cdeep3m/mito_testsample/training/labels/ ~/mito_testaugtrain

```

Output:

```Bash
octave: X11 DISPLAY environment variable not set
octave: disabling GUI features
Starting Training data Preprocessing
Training Image Path:
/home/ubuntu/cdeep3m/mito_testsample/training/images/
Training Label Path:
/home/ubuntu/cdeep3m/mito_testsample/training/labels/
Output Path:
/home/ubuntu/mito_testaugtrain
Loading:
/home/ubuntu/cdeep3m/mito_testsample/training/images/
Image importer loading ... 
/home/ubuntu/cdeep3m/mito_testsample/training/images/
Reading file: /home/ubuntu/cdeep3m/mito_testsample/training/images/images.010.png
.
.
/home/ubuntu/cdeep3m/mito_testsample/training/labels/
Image importer loading ... 
/home/ubuntu/cdeep3m/mito_testsample/training/labels/
Reading file: /home/ubuntu/cdeep3m/mito_testsample/training/labels/mitos_3D.010.png
.
.
Create variation 8 and 16
Saving: /home/ubuntu/mito_testaugtrain/training_full_stacks_v8.h5
Elapsed time is 15.1134 seconds.
-> Training data augmentation completed
Training data stored in /home/ubuntu/mito_testaugtrain
For training your model please run CreateTrainJob.m /home/ubuntu/mito_testaugtrain <desired output directory>
```


### Step 3) Run runtraining.sh 

```Bash
runtraining.sh --numiterations 100 ~/mito_testaugtrain ~/train_out
```

Output:

```Bash
octave: X11 DISPLAY environment variable not set
octave: disabling GUI features
Verifying input training data is valid ... success
Copying over model files and creating run scripts ... success

A new directory has been created: /home/ubuntu/train_out
In this directory are 3 directories 1fm,3fm,5fm which
correspond to 3 caffe models that need to be trainedas well as two scripts:

caffe_train.sh -- Runs caffe for a single model
run_all_train.sh -- Runs caffe_train.sh serially for all 3 models

Running 1fm train, this could take a while
real 540.15
user 460.86
sys 79.90
Running 3fm train, this could take a while
real 181.50
user 166.45
sys 30.35
Running 5fm train, this could take a while
real 112.99
user 102.26
sys 20.05
Training has completed. Have a nice day!
Training has completed. Results are stored in /home/ubuntu/train_out
Have a nice day!
```

### Step 4) Run PreprocessImageData.m

```Bash
PreprocessImageData.m ~/cdeep3m/mito_testsample/testset/ ~/mito_testaugimages
```

Output:

```Bash
octave: X11 DISPLAY environment variable not set
octave: disabling GUI features
Starting Image Augmentation
Check image size of: 
/home/ubuntu/cdeep3m/mito_testsample/testset/
Reading file: /home/ubuntu/cdeep3m/mito_testsample/testset/images.040.png
warning: your version of GraphicsMagick limits images to 16 bits per pixel
Reading file: /home/ubuntu/cdeep3m/mito_testsample/testset/images.044.png
Padding images
.
.
.
Saving: /home/ubuntu/mito_testaugimages/Pkg001_Z01/test_data_full_stacks_v16.h5
Elapsed time is 1.75296 seconds.
Image Augmentation completed
Created 1 packages in x/y with 1 z-stacks
Data stored in:
 /home/ubuntu/mito_testaugimages
```

### Step 5) Run runprediction.sh

```Bash
runprediction.sh ~/train_out/ ~/mito_testaugimages/ ~/predictout
```

Output:

```Bash
octave: X11 DISPLAY environment variable not set
octave: disabling GUI features
Verifying input training data is valid ... skipping check, TODO need to fix this.
Verifying image data and getting Pkg folders ... skipping check, TODO need to fix this.
Creating output directories and creating run scripts ... success

A new directory has been created: /home/ubuntu/predictout
In this directory are 3 directories 1fm,3fm,5fm which
will contain the results from running prediction with caffeThere are also two scripts:

caffe_predict.sh -- Runs caffe prediction single model
run_all_predict.sh -- Runs caffe_predict.sh serially for all 3 models

To run prediction for all 3 models run this: /home/ubuntu/predictout/run_all_predict.sh


Running Prediction

Trained Model Dir: /home/ubuntu/train_out/
Image Dir: /home/ubuntu/mito_testaugimages/

Running 1fm predict 1 package(s) to process

```

### Step 6) Run EnsemblePredictions.m



## For advanced users/developers, installation requirements for local install

**NOTE:** Getting the following software and configuration setup is not trivial. To try out CDeep3M it is suggested one try CDeep3M in the cloud, desribed above, which eliminates all the following steps.

* Nvidia K40 GPU or better (needs 12gb+ ram) with CUDA 7.5 or higher

* Special forked version of caffe found here: https://github.com/Xiaomi2008/caffe_nd_sense_segmentation

* Linux OS, preferably Ubuntu with Nvidia drivers installed and working correctly

* Octave 4.0+ with image package (ie under ubuntu: sudo apt install octave octave-image octave-pkg-dev)

* hdf5oct: https://github.com/stegro/hdf5oct/archive/b047e6e611e874b02740e7465f5d139e74f9765f.zip

* bats (for testing): https://github.com/bats-core/bats-core/archive/v0.4.0.tar.gz

## For advanced users/developers, install locally

### Step 1) Download release tarball

```Bash
wget https://github.com/slash-segmentation/cdeep3m/releases/download/v0.12.0rc/cdeep3m-0.12.0rc.tar.gz
```

### Step 2) Uncompress 

```Bash
tar -zxf cdeep3m-0.12.0rc.tar.gz
cd cdeep3m-0.12.0rc
```

### Step 3) Add to path

```Bash
export PATH=$PATH:`pwd`
```

### Step 4) Verify

```Bash
runtraining.sh --version
```

## License

[LICENSE for CDeep3M][license]

For contents of **model/** see [model/LICENSE file][divelablicense] for license


## Acknowledgements

* Tao Zen for making [DeepEM3D][deepem3d] publicly available.

* Support from NIH grants 5P41GM103412-29 (NCMIR), 5p41GM103426-24 (NBCR), 5R01GM082949-10 (CIL)
