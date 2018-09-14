[aws]: https://aws.amazon.com/
[deepem3d]: https://github.com/divelab/deepem3d
[cdeep3mviaaws]: https://github.com/CRBS/cdeep3m/wiki/Launching-CDeep3m-via-AWS-CloudFormation
[demorun1]: https://github.com/CRBS/cdeep3m/wiki/Demorun-1-Running-prediction-with-pre-trained-model
[demorun2]: https://github.com/CRBS/cdeep3m/wiki/Demorun-2-Running-small-training-and-prediction-with-mito-testsample-dataset
[ownmodel]: https://github.com/CRBS/cdeep3m/wiki/Run-CDeep3M-training-and-prediction
[gpunodeaccess]: https://github.com/CRBS/cdeep3m/wiki/Check-and-increase-AWS-EC2-limits
[deletestack]: https://github.com/CRBS/cdeep3m/wiki/Shutting-down-CDeep3M-AWS-CloudFormation
[sshkey]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair
[divelablicense]: https://github.com/CRBS/cdeep3m/blob/master/model/LICENSE
[license]: https://github.com/CRBS/cdeep3m/blob/master/LICENSE
[cloudaccess]: https://github.com/CRBS/cdeep3m/wiki/How-to-access-CDeep3M-cloud
[speedup]: https://github.com/CRBS/cdeep3m/wiki/Speed-up
[parallel]: https://www.gnu.org/software/parallel/
[validation]: https://github.com/CRBS/cdeep3m/wiki/Add-Validation-to-training
[retrain]: https://github.com/CRBS/cdeep3m/wiki/How-to-retrain-a-pretrained-network
[runtraining.sh]: https://github.com/CRBS/cdeep3m/wiki/runtraining.sh
[cdeep3mbiorxiv]: https://www.biorxiv.org/content/early/2018/06/21/353425
[cdeep3mnaturemethods]: https://rdcu.be/5zIF

# CDeep3M

[![Build Status](https://travis-ci.org/CRBS/cdeep3m.svg?branch=master)](https://travis-ci.org/CRBS/cdeep3m)

CDeep3M provides a plug-and-play cloud based deep learning solution for image segmentation of light, electron and X-ray microscopy. 


## Quickstart CDeep3M on the cloud

Click launch button to spin up the latest release of CDeep3M on the cloud (~20 minute spin up time):
**(Oregon region)** 

[![Launch Deep3m AWS CloudFormation link](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/new?stackName=cdeep3m-stack-1-5-0&templateURL=https://s3-us-west-2.amazonaws.com/cdeep3m-releases/1.5.0/cdeep3m_1.5.0_basic_cloudformation.json)

**NOTE: Running will result in EC2 charges (0.9-3$ per hour runtime)**

  
## First time users

### Sign up for AWS Account

Just opened your AWS account? Request access to GPU nodes before starting: [follow instructions here][gpunodeaccess]

### SSH key

Follow the instructions on how to [link your SSH key][sshkey]. You can directly create the SSH key on AWS.

### Launch cloudformation stack

Once approved, launch cloudformation stack using the launch button. [Click here for detailed instructions on launching CDeep3M.][cdeep3mviaaws]
**NOTE: Running CloudFormation stack requires AWS account and will result in EC2 charges (0.9-3$ per hour runtime)**

### Access your cloud

Click here for instruction how to [access your cloudstack][cloudaccess]

### Once you launched the stack:
* [Click here for instructions of a CDeep3M demorun 1][demorun1]
  
  Running segmentation with a pretrained model (Runtime ~5min)
  
* [Click here for instructions of a CDeep3M demorun 2][demorun2]
  
  Running short training and segmentation using data already loaded on the cloud (Runtime ~1h)
* [How to train your own model and segment with CDeep3M][ownmodel]

  This will guide you step-by-step through training a network and the prediction on your own data. 

### Shutting AWS cloud down

Done with your segmentation? Don't forget to [delete your Cloud Stack][deletestack]
  

# Additional info for more experienced users
* How to [retrain][retrain] a pretrained network
* How to [speed up][speedup] processing time
* How to insert and use a [validation dataset][validation] 

Hyperparameters can be adjusted by passing flags to [runtraining.sh][runtraining.sh]

# References

If you use CDeep3M for your research please cite:

```
@article{,
  title={CDeep3M - Plug-and-Play cloud based deep learning for image segmentation},
  author={Haberl M., Churas C., Tindall L., Boassa D., Phan S., Bushong E.A., Madany M., Akay R., Deerinck T.J., Peltier S., and Ellisman M.H.},
  journal={Nature Methods},
  year={2018}
  DOI = {10.1038/s41592-018-0106-z}
}
```
Further reading:
* CDeep3M [open access][cdeep3mnaturemethods] article in NatureMethods
* CDeep3M [preprint][cdeep3mbiorxiv]
* CDeep3M was developped based off a convolutional neural network implemented in [DeepEM3D][deepem3d]


# Support

Please email to cdeep3m@gmail.com for additional questions.

# Local install, for advanced users/developers only

## Installation requirements for local install

**NOTE:** Getting the following software and configuration setup is not trivial. To try out CDeep3M it is suggested one try CDeep3M in the cloud, desribed above, which eliminates all the following steps.

* Nvidia K40 GPU or better (needs 12gb+ ram) with CUDA 7.5 or higher

* Special forked version of caffe found here: https://github.com/Xiaomi2008/caffe_nd_sense_segmentation

* Linux OS, preferably Ubuntu with Nvidia drivers installed and working correctly

* Octave 4.0+ with image package (ie under ubuntu: sudo apt install octave octave-image octave-pkg-dev)

* hdf5oct: https://github.com/stegro/hdf5oct/archive/b047e6e611e874b02740e7465f5d139e74f9765f.zip

* bats (for testing): https://github.com/bats-core/bats-core/archive/v0.4.0.tar.gz

* [GNU Parallel][parallel]

## How to install locally

#### Step 1) Download release tarball

```Bash
wget https://github.com/CRBS/cdeep3m/archive/v1.5.0.tar.gz
```

#### Step 2) Uncompress 

```Bash
tar -zxf v1.5.0.tar.gz
cd cdeep3m-1.5.0
```

#### Step 3) Add to path

```Bash
export PATH=$PATH:`pwd`
```

#### Step 4) Verify

```Bash
runtraining.sh --version
```

## License

[LICENSE for CDeep3M][license]

For contents of **model/** see [model/LICENSE file][divelablicense] for license


## Acknowledgements

* CDeep3M was developped based off a convolutional neural network implemented in [DeepEM3D][deepem3d]

* Support from NIH grants 5P41GM103412-29 (NCMIR), 5p41GM103426-24 (NBCR), 5R01GM082949-10 (CIL)
* The DIVE lab for making [DeepEM3D][deepem3d] publicly available.

* O. Tange (2011): GNU Parallel - The Command-Line Power Tool,
;login: The USENIX Magazine, February 2011:42-47.

* This research benefitted from the use of credits from the National Institutes of Health (NIH) Cloud Credits Model Pilot, a component of the NIH Big Data to Knowledge (BD2K) program.

