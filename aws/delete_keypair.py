#!/usr/bin/env python

import sys
import os
import argparse
import datetime
from datetime import tzinfo, timedelta
import json
from dateutil.tz import tzutc
import boto3
from ipify import get_ip


def _parse_arguments(desc, theargs):
    """Parses command line arguments using argparse
    """
    help_formatter = argparse.RawDescriptionHelpFormatter
    parser = argparse.ArgumentParser(description=desc,
                                     formatter_class=help_formatter)
    parser.add_argument('name', help='name of keypair to delete')
    parser.add_argument('--region', default='us-east-2',
                        help="Region to use" +
                             "(default us-east-2)")
    parser.add_argument('--profile',
                        default=None,
                        help='AWS profile to load from credentials. default none')

    return parser.parse_args(theargs)


def _delete_keypair(theargs):
    """Delete key pair by name
    """
    if theargs.profile is not None:
        boto3.setup_default_session(profile_name=theargs.profile)

    ec2 = boto3.client('ec2', region_name=theargs.region)

    resp = ec2.delete_key_pair(KeyName=theargs.name)

    return str(resp)


def main(arglist):
    desc = """
              Gets list of users
           """
    theargs = _parse_arguments(desc, sys.argv[1:])
    sys.stdout.write('Contacting AWS: \n')
    sys.stdout.write(_delete_keypair(theargs))


if __name__ == '__main__': # pragma: no cover
    sys.exit(main(sys.argv))
