#!/usr/bin/env python

import sys
import os
import argparse
import boto3
from ipify import get_ip


def _parse_arguments(desc, theargs):
    """Parses command line arguments using argparse
    """
    help_formatter = argparse.RawDescriptionHelpFormatter
    parser = argparse.ArgumentParser(description=desc,
                                     formatter_class=help_formatter)
    parser.add_argument('--template', required=True,
                        help='CloudFormation template file to use')
    parser.add_argument('--region', default='us-east-2',
                        help="Region to use" +
                             "(default us-east-2)")
    parser.add_argument('--name', default='USERNAMEstack',
                        help='Stack name to use')
    parser.add_argument('--cdeep3mversion', default='0.15.1',
                        help='Version of CDeep3M to launch (default 0.15.1)')
    parser.add_argument('--keypairname', default='id_rsa',
                        help='AWS EC2 KeyPair Name')
    parser.add_argument('--instancetype', default='p3.2xlarge',
                        choices=['p2.xlarge', 'p3.2xlarge'],
                        help='GPU Instance type to launch (default p3.2xlarge')
    parser.add_argument('--disksize', default='100',
                        help='GPU Disk Size in gigabytes (default 100)')
    parser.add_argument('--sshlocation', default='',
                        help='ip4 CIDR to denote ip address(s) to allow '
                             'ssh access to GPU EC2 instance. (default is ip '
                             'address of machine running this script')
    return parser.parse_args(theargs)


def _launch_cloudformation(theargs):
    """Launches cloud formation
    """
    cloudform = boto3.client('cloudformation', region_name=theargs.region)
    template = theargs.template
    with open(template, 'r') as f:
        template_data = f.read()

    if theargs.sshlocation is None or theargs.sshlocation is '':
        theargs.sshlocation = str(get_ip()) + '/32'

    params = [
        {
            'ParameterKey': 'KeyName',
            'ParameterValue': theargs.keypairname
        },
        {
            'ParameterKey': 'GPUInstanceType',
            'ParameterValue': theargs.instancetype
        },
        {
            'ParameterKey': 'GPUDiskSize',
            'ParameterValue': theargs.disksize
        },
        {
            'ParameterKey': 'SSHLocation',
            'ParameterValue': theargs.sshlocation
        }
    ]

    tags = [
        {
            'Key': 'Name',
            'Value': theargs.name
        }
    ]

    resp = cloudform.create_stack(
        StackName=theargs.name,
        TemplateBody=template_data,
        Parameters=params,
        TimeoutInMinutes=25,
        Tags=tags
    )
    """
    Example successful response:
    {u'StackId': 'arn:aws:cloudformation:us-east-2:063349100599:stack/chris-autolaunch/7d639570-20c3-11e8-80ea-50a68a270856',
     'ResponseMetadata': {'RetryAttempts': 0,
                          'HTTPStatusCode': 200,
                          'RequestId': '7d5bcdb5-20c3-11e8-9b7f-cf77c73ccdc2',
                          'HTTPHeaders': {'x-amzn-requestid': 
                                          '7d5bcdb5-20c3-11e8-9b7f-cf77c73ccdc2',
                                          'date': 'Mon, 05 Mar 2018 22:21:02 GMT',
                                          'content-length': '386',
                                          'content-type': 'text/xml'}
                          }
    }
    """
    return str(resp)


def main(arglist):
    desc = """
              Launches CloudFormation template
           """
    theargs = _parse_arguments(desc, sys.argv[1:])
    sys.stdout.write('Contacting AWS: \n')
    sys.stdout.write(_launch_cloudformation(theargs))


if __name__ == '__main__': # pragma: no cover
    sys.exit(main(sys.argv))
