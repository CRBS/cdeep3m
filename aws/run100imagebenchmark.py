#!/usr/bin/env python

import sys
import stat
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
    parser.add_argument('outdir',
                        help='Directory to write out private key file')
    parser.add_argument('--template',
                        help='CloudFormation template file to use')
    parser.add_argument('--region', default='us-east-2',
                        help="Region to use" +
                             "(default us-east-2)")
    parser.add_argument('--name', default='USERNAMEstack',
                        help='Stack name to use')
    parser.add_argument('--cdeep3mversion', default='0.15.2',
                        help='Version of CDeep3M to launch (default 0.15.2)')
    parser.add_argument('--instancetype', default='p3.2xlarge',
                        choices=['p2.xlarge', 'p3.2xlarge','p3.8xlarge','p3.16xlarge'],
                        help='GPU Instance type to launch (default p3.2xlarge')
    parser.add_argument('--disksize', default='100',
                        help='GPU Disk Size in gigabytes (default 100)')
    parser.add_argument('--sshlocation', default='',
                        help='ip4 CIDR to denote ip address(s) to allow '
                             'ssh access to GPU EC2 instance. (default is ip '
                             'address of machine running this script')
    parser.add_argument('--profile',
                        default=None,
                        help='AWS profile to load from credentials. default none')

    return parser.parse_args(theargs)


def _create_key_pair(theargs):
   """Creates keypair and save private key to theargs.outdir
      :returns string: name of keypair created.
   """
   ec2 = boto3.client('ec2',region_name=theargs.region)
   name = theargs.name + 'keypair'
   res = ec2.create_key_pair(KeyName=name)
   if not os.path.isdir(theargs.outdir):
      os.makedirs(theargs.outdir, mode=0o755)
   os.chmod(theargs.outdir,stat.S_IRWXU | stat.S_IRUSR | stat.S_IXUSR)
   
   theargs.key_file = os.path.join(theargs.outdir,'private.key')
   with open(theargs.key_file, 'w') as f:
     f.write(res['KeyMaterial'])
     f.flush()
   sys.stdout.write('Wrote key: ' + name + ' to file ' + theargs.key_file + '\n')
   os.chmod(theargs.key_file,stat.S_IRWXU | stat.S_IRUSR)
   return name


def _launch_cloudformation(theargs):
    """Launches cloud formation
       :returns string: stackid
    """
    theargs.keypairname = _create_key_pair(theargs)
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
    sys.stdout.write('Creating stack. This can take 10-15 minutes...\n')
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
    return None

def _get_ssh_client_connected_to_server(hostname, theargs):
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    pkey = paramiko.RSAKey.from_private_key_file(theargs.key_file)
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

    if theargs.profile is not None:
        boto3.setup_default_session(profile_name=theargs.profile)

    sys.stdout.write('Contacting AWS: \n')
    stackid = _launch_cloudformation(theargs)
    sys.stdout.write('Stack launched: ' + str(stackid) + ' ... Waiting')
    dns = _wait_for_stack(stackid, theargs)

    if dns is None:
      return 1
    
    ssh_client = _get_ssh_client_connected_to_server(dns, theargs)

    # create a 100 image stack
    cp_cmd = '/bin/cp -r /home/ubuntu/sbem/mitochrondria/xy5.9nm40nmz/images /home/ubuntu/images'
    sys.stdout.write('Attempting to run command: ' + cp_cmd + '\n')
    sys.stdout.write(_exec_command(ssh_client, cp_cmd))

    cp2_cmd = '/bin/cp /home/ubuntu/sbem/mitochrondria/xy5.9nm40nmz/labels/mitos_3D.0[01]* /home/ubuntu/images/.'
    sys.stdout.write('Attempting to run command: ' + cp2_cmd + '\n')
    sys.stdout.write(_exec_command(ssh_client, cp2_cmd))



    cmd_to_run = 'nohup /bin/bash -ic "source /home/ubuntu/.bashrc ;/usr/bin/time -p /home/ubuntu/cdeep3m/runprediction.sh /home/ubuntu/sbem/mitochrondria/xy5.9nm40nmz/30000iterations_train_out /home/ubuntu/images /home/ubuntu/predictyoyo;touch /home/ubuntu/predictyoyo/alldone" > output.txt 2>&1 < /dev/null &'

    sys.stdout.write('Attempting to run command: ' + cmd_to_run + '\n')
    sys.stdout.write(_exec_command(ssh_client, cmd_to_run))
    sys.stdout.write('Hopefully command is running.\n')
    sys.stdout.write('Waiting for command to finish.')
    
    donecheck_cmd = '/bin/bash -c "if [ -f /home/ubuntu/predictyoyo/alldone ] ; then echo done; fi"'
    res = _exec_command(ssh_client,donecheck_cmd) 
    sys.stdout.write('Res:' + res + ':\n')
    sys.stdout.flush()
    while 'None' in res:
        sys.stdout.write('.')
        time.sleep(60)
        res = _exec_command(ssh_client,donecheck_cmd)
        sys.stdout.flush()

    sys.stdout.write('Output from output.txt\n\n')
    sys.stdout.write(_exec_command(ssh_client,'cat /home/ubuntu/output.txt'))
    sys.stdout.write('\n\n')
    sys.stdout.flush() 
   
    ssh_client.close()   


if __name__ == '__main__': # pragma: no cover
    sys.exit(main(sys.argv))
