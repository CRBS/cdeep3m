#!/usr/bin/env python

import sys
import os
import argparse
import boto3


def _parse_arguments(desc, theargs):
    """Parses command line arguments using argparse
    """
    help_formatter = argparse.RawDescriptionHelpFormatter
    parser = argparse.ArgumentParser(description=desc,
                                     formatter_class=help_formatter)
    parser.add_argument("--ownerid", default='898082745236',
                        help="Owner id to pass to search " +
                             "(default 898082745236)")
    parser.add_argument('--namefilter',
                        default='Deep Learning AMI with Source Code v2.0',
                        help='Find only AMI image with this string in name' +
                             ' (default: Deep Learning AMI with Source ' + 
                             'Code v2.0')
    parser.add_argument('--profile',
                        default=None,
                        help='AWS profile to load from credentials. default none')
    return parser.parse_args(theargs)

def _get_running_ec2_instances(theargs):
    """Returns a string containing any ec2 instances
    """
    mapstr = ''
    if theargs.profile is not None:
        boto3.setup_default_session(profile_name=theargs.profile)
    ec2 = boto3.client('ec2', region_name='us-west-2')

    response = ec2.describe_regions()
    for region in response['Regions']:
        rname = region['RegionName']
        sys.stdout.write('Running ec2 query in region: ' + rname + '\n')
        ec2 = boto3.client('ec2', region_name=rname)
        mapstr += 'Region: ' + rname + '\n'
        respy = ec2.describe_instances()
        for reso in respy['Reservations']:
            for entry in reso['Instances']:
                namey = ''
                try:
                    for keyval in entry['Tags']:
                       if keyval['Key'] == 'Name':
                           namey = keyval['Value']
                           break
                except KeyError:
                    pass

                mapstr += ('\t\t' + entry['PublicDnsName'] + '\n' +
                           '\t\tLaunch Date: ' + str(entry['LaunchTime']) +
                           '\n' + 
                           '\t\tId: ' + entry['InstanceId'] + '\n' +
                           '\t\tType: ' + entry['InstanceType'] + '\n' +
                           '\t\tName: ' + namey + '\n' +
                           '\t\tState: ' + entry['State']['Name'] + '\n\n')
    sys.stdout.write('\nResults:\n\n')
    return mapstr


def main(arglist):
    desc = """
              This script uses AWS boto library to find running
              EC2 instances in any region.
           """
    theargs = _parse_arguments(desc, sys.argv[1:])
    sys.stdout.write('Querying AWS: \n')
    sys.stdout.write(_get_running_ec2_instances(theargs))


if __name__ == '__main__': # pragma: no cover
    sys.exit(main(sys.argv))
