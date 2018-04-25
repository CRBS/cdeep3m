#!/usr/bin/env python

import sys
import os
import argparse
import time
import boto3
import logging
import paramiko
import getpass
from ipify import get_ip


logger = logging.getLogger(__name__)


def _parse_arguments(desc, theargs):
    """Parses command line arguments using argparse
    """
    help_formatter = argparse.RawDescriptionHelpFormatter
    parser = argparse.ArgumentParser(description=desc,
                                     formatter_class=help_formatter)
    parser.add_argument('--usestackid', default=None,
                        help='If set use stackid instead')
    parser.add_argument('--privatekeyfile', default=os.path.join(os.path.expanduser('~'),'.ssh','id_rsa'),
                        help='Private key file to use')
    parser.add_argument('--template',
                        help='CloudFormation template file to use')
    parser.add_argument('--region', default='us-east-2',
                        help="Region to use" +
                             "(default us-east-2)")
    parser.add_argument('--name', default='USERNAMEstack',
                        help='Stack name to use')
    parser.add_argument('--cdeep3mversion', default='0.15.2',
                        help='Version of CDeep3M to launch (default 0.15.2)')
    parser.add_argument('--keypairname', default='id_rsa',
                        help='AWS EC2 KeyPair Name')
    parser.add_argument('--instancetype', default='p3.2xlarge',
                        choices=['p2.xlarge', 'p3.2xlarge','p3.8xlarge','p3.16xlarge'],
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
       :returns string: stackid
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
    return resp['StackId']


def _wait_for_stack(stackid, theargs):
   cloudform = boto3.client('cloudformation', region_name=theargs.region)
   dns = _is_stack_complete(stackid, cloudform)
   while dns is None:
     sys.stdout.write('.')
     time.sleep(30)
     dns = _is_stack_complete(stackid, cloudform)
   sys.stdout.write('\n')
   return dns


def _is_stack_complete(stackid, cloudform):
    """Waits for stack to launch"""
    
    resp = cloudform.describe_stacks(StackName=stackid)
    for stack in resp['Stacks']:
      if 'CREATE_COMPLETE' in stack['StackStatus']:
        for output in stack['Outputs']:
          if output['OutputKey'] == 'PublicDNS':
            return output['OutputValue']
    return None

def _get_ssh_client_connected_to_server(hostname, theargs):
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    pkey = paramiko.RSAKey.from_private_key_file(theargs.privatekeyfile,
                                                 getpass.getpass('Passphrase for key: ', sys.stdout))
    ssh_client.connect(hostname=hostname,
                       username='ubuntu',
                       pkey=pkey,
                       timeout=30)
    return ssh_client


def _exec_command(ssh_client, command):
    bufsize = 1024
    alldata = None
    std_in, std_out, std_err = ssh_client.exec_command(command)
    while not std_out.channel.exit_status_ready():
        if std_out.channel.recv_ready():
            alldata = std_out.channel.recv(bufsize)
            prevdata = b"1"
            while prevdata:
                prevdata = std_out.channel.recv(bufsize)
                alldata += prevdata
    return str(alldata)


def main(arglist):
    desc = """
              Launches CloudFormation template
           """
    sys.stdout.write('WARNING: THIS IS NOT COMPLETED\n')
    theargs = _parse_arguments(desc, sys.argv[1:])
    if theargs.usestackid is None:
      sys.stdout.write('Contacting AWS: \n')
      stackid = _launch_cloudformation(theargs)
      sys.stdout.write('Stack launched: ' + str(stackid) + ' ... Waiting')
    else:
      stackid = theargs.usestackid
      sys.stdout.write('Using existing stackid: ' + str(stackid) +
                       ' ... Checking')
    dns = _wait_for_stack(stackid, theargs)

    if dns is None:
      return 1

    ssh_client = _get_ssh_client_connected_to_server(dns, theargs)

    sys.stdout.write(_exec_command(ssh_client, 'nohup /bin/bash -ic "source /home/ubuntu/.bashrc ;/usr/bin/time -p /home/ubuntu/cdeep3m/runprediction.sh /home/ubuntu/sbem/mitochrondria/xy5.9nm40nmz/30000iterations_train_out /home/ubuntu/sbem/mitochrondria/xy5.9nm40nmz/images /home/ubuntu/predictyoyo" > output.txt 2>&1 < /dev/null &'))
    
 
    ssh_client.close()   


if __name__ == '__main__': # pragma: no cover
    sys.exit(main(sys.argv))
