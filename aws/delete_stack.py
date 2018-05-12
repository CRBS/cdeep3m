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
    parser.add_argument('--profile',
                        default=None,
                        help='AWS profile to load from credentials. default none')

    return parser.parse_args(theargs)


def _delete_stack(theargs):
    """Launches cloud formation
    """
    if theargs.profile is not None:
        boto3.setup_default_session(profile_name=theargs.profile)
   
    cloudform = boto3.client('cloudformation', region_name=theargs.region)

    resp = cloudform.delete_stack(
        StackName=theargs.stackid
    )
    """
    Example successful response:
    """
    return str(resp)


def main(arglist):
    desc = """
              Deletes CloudFormation Stack
           """
    theargs = _parse_arguments(desc, sys.argv[1:])
    sys.stdout.write('Contacting AWS: \n')
    sys.stdout.write(_delete_stack(theargs))


if __name__ == '__main__': # pragma: no cover
    sys.exit(main(sys.argv))
