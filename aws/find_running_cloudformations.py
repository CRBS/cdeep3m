#!/usr/bin/env python

import sys
import os
import argparse
import boto3
import pprint

def _parse_arguments(desc, theargs):
    """Parses command line arguments using argparse
    """
    help_formatter = argparse.RawDescriptionHelpFormatter
    parser = argparse.ArgumentParser(description=desc,
                                     formatter_class=help_formatter)
    parser.add_argument('--namefilter',
                        default='Deep Learning AMI with Source Code v2.0',
                        help='Find only AMI image with this string in name' +
                             ' (default: Deep Learning AMI with Source ' + 
                             'Code v2.0')
    return parser.parse_args(theargs)

def _get_running_cloudformations(theargs):
    """Finds all running cloudformations
    """
    mapstr = ''
    ec2 = boto3.client('ec2')
    response = ec2.describe_regions()
    for region in response['Regions']:
        rname = region['RegionName']
        sys.stdout.write('Running cloudformation query in region: ' + rname + '\n')
        ec2 = boto3.client('cloudformation', region_name=rname)
        mapstr += '\nRegion: ' + rname + '\n'
        respy = ec2.describe_stacks()
        pp = pprint.PrettyPrinter(indent=4)

        for stack in respy['Stacks']:
            pp.pprint(stack)
            mapstr += ('\t\tName: ' + stack['StackName'] + '\n' +
                       '\t\tStackId: ' + stack['StackId'] + '\n' +
                       '\t\tStackStatus: ' + stack['StackStatus'] + '\n' +
                       '\t\tLaunch Date: ' + str(stack['CreationTime']) + '\n')
            if 'CREATE_COMPLETE' in stack['StackStatus']:
              for output in stack['Outputs']:
                if output['OutputKey'] == 'PublicDNS':
                  mapstr += '\t\tPublicDNS: ' + output['OutputValue'] + '\n'

        """
            for entry in reso['Instances']:
                mapstr += ('\t\t' + entry['PublicDnsName'] + '\n' +
                           '\t\tLaunch Date: ' + str(entry['LaunchTime']) +
                           '\n' + 
                           '\t\tId: ' + entry['InstanceId'] + '\n' +
                           '\t\tType: ' + entry['InstanceType'] + '\n' +
                           '\t\tState: ' + entry['State']['Name'] + '\n\n')
        """
    sys.stdout.write('\nResults:\n\n')
    return mapstr


def main(arglist):
    desc = """
              This script uses AWS boto library to find running
              Cloudformations instances in any region.
           """
    theargs = _parse_arguments(desc, sys.argv[1:])
    sys.stdout.write('Querying AWS: \n')
    sys.stdout.write(_get_running_cloudformations(theargs))


if __name__ == '__main__': # pragma: no cover
    sys.exit(main(sys.argv))
