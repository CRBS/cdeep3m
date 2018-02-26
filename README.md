[aws]: https://aws.amazon.com/
[deepem3d]: https://github.com/divelab/deepem3d
[deep3mviaaws]: https://github.com/slash-segmentation/cdeep3m/wiki/Running-Deep3m-via-AWS-CloudFormation
[divelablicense]: https://github.com/slash-segmentation/cdeep3m/blob/master/model/LICENSE
[license]: https://github.com/slash-segmentation/cdeep3m/blob/master/LICENSE

# CDeep3M

CDeep3M is a plug-and-play cloud based deep learning for image segmentation of light, electron and X-ray microscopy derived from [DeepEM3D][deepem3d]

This is the code for the paper submitted to Nature methods titled: 

"CDeep3M - Plug-and-Play cloud based deep learning for image segmentation of light, electron and X-ray microscopy"

## Quickstart

Click link below to spin up CDeep3M on the cloud:

**WARNING: Running the CloudFormation stack described below will result in EC2 charges**

**Oregon region:**

[![Launch Deep3m AWS CloudFormation link](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/new?stackName=deep3m-stack-0-11-0rc4&templateURL=https://s3-us-west-2.amazonaws.com/deep3m-releases/0.11.0rc4/deep3m_0.11.0rc4_basic_cloudformation.json)


[Click here for detailed instructions][deep3mviaaws]

## License

[LICENSE for CDeep3M][license]

For contents of **model/** see [model/LICENSE file][divelablicense] for license


## Acknowledgements

* Tao Zen for making [DeepEM3D][deepem3d] publicly available.

* Support from NIH grants 5P41GM103412-29 (NCMIR), 5p41GM103426-24 (NBCR), 5R01GM082949-10 (CIL)
