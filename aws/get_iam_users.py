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
    parser.add_argument('stackid',
                        help='id of stack')
    parser.add_argument('--region', default='us-east-2',
                        help="Region to use" +
                             "(default us-east-2)")
    return parser.parse_args(theargs)


def _get_iam_users(theargs):
    """Launches cloud formation
    """
    iam = boto3.client('iam', region_name=theargs.region)

    resp = iam.list_users()

    #import pprint
    #pp = pprint.PrettyPrinter()
    #pp.pprint(resp)
    result = 'User name,Groups,Policies,Last activity\n'
    for user in resp['Users']:
        pass_last_used = 'Never'
        try:
            if isinstance(user['PasswordLastUsed'], datetime.datetime):
                time_del = datetime.datetime.now(user['PasswordLastUsed'].tzinfo) - user['PasswordLastUsed']
                pass_last_used_in_days = str(int(time_del.total_seconds() / 3600 / 24)) + ' days'
        except KeyError:
            pass

        user_groups = iam.list_groups_for_user(UserName=user['UserName'])
        grp_str = ''
        try:
            for group in user_groups['Groups']:
                grp_str += group['GroupName'] + ' '
        except KeyError:
            grp_str = 'NA'

        user_policy = iam.list_attached_user_policies(UserName=user['UserName'])

        user_p_list = ''
        for policy in user_policy['AttachedPolicies']:
            user_p_list += policy['PolicyName'] + ' '

        if len(grp_str) is 0:
            grp_str = 'None'

        result += user['UserName'] + ',' + grp_str + ',' + user_p_list + ',' + pass_last_used_in_days + '\n'

    """
    Example successful response:
    
    """

    return str(result)


def main(arglist):
    desc = """
              Gets list of users
           """
    theargs = _parse_arguments(desc, sys.argv[1:])
    sys.stdout.write('Contacting AWS: \n')
    sys.stdout.write(_get_iam_users(theargs))


if __name__ == '__main__': # pragma: no cover
    sys.exit(main(sys.argv))
