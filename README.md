[aws]: https://aws.amazon.com/
[deepem3d]: https://github.com/divelab/deepem3d
[cdeep3mviaaws]: https://github.com/CRBS/cdeep3m/wiki/Running-CDeep3m-via-AWS-CloudFormation
[demorun]: https://github.com/CRBS/cdeep3m/wiki/Running-prediction-with-pre-trained-mito-dataset
[divelablicense]: https://github.com/CRBS/cdeep3m/blob/master/model/LICENSE
[license]: https://github.com/CRBS/cdeep3m/blob/master/LICENSE

# CDeep3M

CDeep3M provides a plug-and-play cloud based deep learning solution for image segmentation of light, electron and X-ray microscopy. CDeep3M was developped on the convolutional neural network implemented in [DeepEM3D][deepem3d]

This code is for a manuscript under revision, titled: 
"CDeep3M - Plug-and-Play cloud based deep learning for image segmentation of light, electron and X-ray microscopy"

# Run CDeep3M on the cloud

Click link below to spin up the latest release of CDeep3M on the cloud (~10 minute spin up time):

**NOTE: Running CloudFormation stack requires AWS account and will result in EC2 charges (0.9-3$ per hour runtime)**

**Oregon region:**

[![Launch Deep3m AWS CloudFormation link](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/new?stackName=cdeep3m-stack-0-14-1&templateURL=https://s3-us-west-2.amazonaws.com/cdeep3m-releases/0.14.1/cdeep3m_0.14.1_basic_cloudformation.json)


[Click here for detailed instructions on launching CDeep3M][cdeep3mviaaws]

[Click here for instructions of a CDeep3M demorun][demorun]

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
wget https://github.com/CRBS/cdeep3m/releases/download/v0.14.1/cdeep3m-0.14.1.tar.gz
```

### Step 2) Uncompress 

```Bash
tar -zxf cdeep3m-0.14.1.tar.gz
cd cdeep3m-0.14.1
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

* Support from NIH grants 5P41GM103412-29 (NCMIR), 5p41GM103426-24 (NBCR), 5R01GM082949-10 (CIL)
* The DIVE lab for making [DeepEM3D][deepem3d] publicly available.
