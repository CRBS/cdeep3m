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
    parser.add_argument('stackid',
                        help='id of stack')
    parser.add_argument('--region', default='us-east-2',
                        help="Region to use" +
                             "(default us-east-2)")
    return parser.parse_args(theargs)


def _describe_stack(theargs):
    """Launches cloud formation
    """
    cloudform = boto3.client('cloudformation', region_name=theargs.region)

    resp = cloudform.describe_stacks(
        StackName=theargs.stackid
    )
    """
    Example successful response:
    {'ResponseMetadata': {'HTTPHeaders': {'content-length': '2990',
                                      'content-type': 'text/xml',
                                      'date': 'Fri, 09 Mar 2018 22:39:15 GMT',
                                      'vary': 'Accept-Encoding',
                                      'x-amzn-requestid': 'b31139ea-23ea-11e8-8b15-e51fdee770f9'},
                      'HTTPStatusCode': 200,
                      'RequestId': 'b31139ea-23ea-11e8-8b15-e51fdee770f9',
                      'RetryAttempts': 0},
 u'Stacks': [{u'CreationTime': datetime.datetime(2018, 3, 9, 22, 13, 16, 339000, tzinfo=tzutc()),
              u'Description': 'AWS CloudFormation Deep3m template. Creates an EC2 ubuntu instance off of a base Amazon Deep Learning AMI and installs necessary software to run Deep3M image segmentation. This template provides ssh access to the machine created. **WARNING** This template creates an Amazon EC2 instance. You will be billed for the AWS resources used if you create a stack from this template.',
              u'DisableRollback': False,
              u'EnableTerminationProtection': False,
              u'NotificationARNs': [],
              u'Outputs': [{u'Description': 'InstanceId of the newly created EC2 instance',
                            u'OutputKey': 'InstanceId',
                            u'OutputValue': 'i-09330dc3e3869d2f5'},
                           {u'Description': 'Public IP address of the newly created EC2 instance',
                            u'OutputKey': 'PublicIP',
                            u'OutputValue': '18.217.233.149'},
                           {u'Description': 'Availability Zone of the newly created EC2 instance',
                            u'OutputKey': 'AZ',
                            u'OutputValue': 'us-east-2c'},
                           {u'Description': 'Public DNSName of the newly created EC2 instance',
                            u'OutputKey': 'PublicDNS',
                            u'OutputValue': 'ec2-18-217-233-149.us-east-2.compute.amazonaws.com'}],
              u'Parameters': [{u'ParameterKey': 'KeyName',
                               u'ParameterValue': 'id_rsa'},
                              {u'ParameterKey': 'SSHLocation',
                               u'ParameterValue': '1.2.3.4/32'},
                              {u'ParameterKey': 'GPUInstanceType',
                               u'ParameterValue': 'p2.xlarge'},
                              {u'ParameterKey': 'GPUDiskSize',
                               u'ParameterValue': '100'}],
              u'RollbackConfiguration': {u'RollbackTriggers': []},
              u'StackId': 'arn:aws:cloudformation:us-east-2:063349100599:stack/banana/10b8e390-23e7-11e8-af27-503f3157b0d1',
              u'StackName': 'banana',
              u'StackStatus': 'CREATE_COMPLETE',
              u'Tags': []}]}

    """
    # import pprint
    # pp = pprint.PrettyPrinter()
    # pp.pprint(resp)
    str_res = ''

    for stack in resp['Stacks']:
      str_res = 'Name: ' + stack['StackName'] + '\n' 
      str_res += 'Status: ' + stack['StackStatus'] + '\n'
      if 'CREATE_COMPLETE' in stack['StackStatus']:
        for output in stack['Outputs']:
          if output['OutputKey'] == 'PublicDNS':
            str_res += 'PublicDNS: ' + output['OutputValue'] + '\n'
    return '\n' + str_res + '\n'


def main(arglist):
    desc = """
              Describes CloudFormation Stack
           """
    theargs = _parse_arguments(desc, sys.argv[1:])
    sys.stdout.write('Contacting AWS: \n')
    sys.stdout.write(_describe_stack(theargs))


if __name__ == '__main__': # pragma: no cover
    sys.exit(main(sys.argv))
