#!/usr/bin/env python

import sys
import os
import argparse
import boto3
import time
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
    parser.add_argument('--profile', default=None,
                        help='AWS profile to load from credentials. default none')
    # parser.add_argument('--cdeep3mversion', default='0.15.2',
    #                     help='Version of CDeep3M to launch (default 0.15.2)')
    parser.add_argument('--keypairname', default='id_rsa',
                        help='AWS EC2 KeyPair Name')
    parser.add_argument('--wait', action='store_true',
                        help='If set wait for cloudformation to complete')
    parser.add_argument('--instancetype', default='p3.2xlarge',
                        choices=['p2.xlarge', 'p3.2xlarge','p3.8xlarge','p3.16xlarge'],
                        help='GPU Instance type to launch (default p3.2xlarge')
    parser.add_argument('--disksize', default='100',
                        help='GPU Disk Size in gigabytes (default 100)')
    parser.add_argument('--sshlocation', default='',
                        help='ip4 CIDR to denote ip address(s) to allow '
                             'ssh access to GPU EC2 instance. (default is ip '
                             'address of machine running this script')
    parser.add_argument('--dataseturl', default='',
                        help='url of file to download during initialization of ec2 instance')
    return parser.parse_args(theargs)


def _launch_cloudformation(theargs):
    """Launches cloud formation
    """
    if theargs.profile is not None:
        boto3.setup_default_session(profile_name=theargs.profile)

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

    if theargs.dataseturl!='':
        params.append({ 
                       'ParameterKey': 'DatasetURL',
                       'ParameterValue': theargs.dataseturl
                      })
    

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
    return resp


def _wait_for_stack(stackid, theargs):
   cloudform = boto3.client('cloudformation', region_name=theargs.region)
   dns = _is_stack_complete(stackid, cloudform)
   while dns is None:
     sys.stdout.write('.')
     sys.stdout.flush()
     time.sleep(30)
     dns = _is_stack_complete(stackid, cloudform)
   sys.stdout.write('\n')
   time.sleep(30)
   return dns


def _is_stack_complete(stackid, cloudform):
    """Waits for stack to launch"""

    resp = cloudform.describe_stacks(StackName=stackid)
    for stack in resp['Stacks']:
      if 'CREATE_COMPLETE' in stack['StackStatus']:
        for output in stack['Outputs']:
          if output['OutputKey'] == 'PublicDNS':
            return output['OutputValue']
      if not 'CREATE_IN_PROGRESS' in stack['StackStatus']:
          return 'Error, stack status: ' + str(stack['StackStatus'])
    return None


def main(arglist):
    desc = """
              Launches CloudFormation template
           """
    theargs = _parse_arguments(desc, sys.argv[1:])
    sys.stdout.write('Contacting AWS: \n')
    res = _launch_cloudformation(theargs)
    sys.stdout.write(str(res))
    sys.stdout.flush()
    if theargs.wait is True:
        dns = _wait_for_stack(res['StackId'], theargs)
        sys.stdout.write('\nStack created, DNS => ' + str(dns) + '\n')


if __name__ == '__main__': # pragma: no cover
    sys.exit(main(sys.argv))
