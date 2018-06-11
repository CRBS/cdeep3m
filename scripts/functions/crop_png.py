#!/usr/bin/env python

"""
Crop image frame for CDeep3M


NCMIR/NBCR, UCSD -- Authors: M Haberl / C Churas -- Date: 5/2018

"""
import sys
import os
import argparse
import cv2
import requests
from joblib import Parallel, delayed
from multiprocessing import Pool, TimeoutError
import time

INSTANCE_TYPE_URL = 'http://169.254.169.254/latest/meta-data/instance-type'

def _get_number_of_tasks_to_run_based_on_instance_type(theargs):
    """Gets instance type and returns number of parallel
       tasks to run based on that value. If none are found then
       default value of 2 is used.
    """
    try:
        r = requests.get(theargs.instancetypeurl,
                         timeout=theargs.instancetypeurltimeout)
        if r.status_code is 200:
            if 'p3.2xlarge' in r.text:
                return 6
            if 'p3.8xlarge' in r.text:
                return 12
            if 'p3.16xlarge' in r.text:
                return 20
    except Exception as e:
        sys.stderr.write('Got exception checking instance type: ' +
                         str(e) + '\n')
    return 2
    

def _parse_arguments(desc, theargs):
    """Parses command line arguments using argparse
    """
    help_formatter = argparse.RawDescriptionHelpFormatter
    parser = argparse.ArgumentParser(description=desc,
                                     formatter_class=help_formatter)
    parser.add_argument('inputlistfile',
                        help='File containing list of input image paths')
    parser.add_argument('outputlistfile',
                        help='File containing list of output image paths')
    parser.add_argument('leftxcoord', type=int, help='Left x pixel coordinate')
    parser.add_argument('rightxcoord', type=int,
                        help='Right x pixel coordinate')
    parser.add_argument('topycoord', type=int, help='Top y pixel coordinate')
    parser.add_argument('bottomycoord', type=int,
                        help='Bottom y pixel coordinate')
    parser.add_argument('instancetypeurl', default=INSTANCE_TYPE_URL,
                        help='URL to query for meta data instance type ' +
                             '(default ' + INSTANCE_TYPE_URL + ')')
    parser.add_argument('instancetypeurltimeout',default='1.0',type=float,
                        help='Timeout in seconds for checking instancetypeurl' +
                             ' default 1.0')
    return parser.parse_args(theargs)


desc = """
Given a file with a list of images (inputlistfile 1st arg), 
this program will extract a subimage at coordinates specified
on the command line and save that subimage to the file on the
same line in the file with list of output images 
(outputlistfile 2nd arg) 
"""

# Parse arguments
theargs = _parse_arguments(desc, sys.argv[1:])

in1 = theargs.leftxcoord
in2 = theargs.rightxcoord
in3 = theargs.topycoord
in4 = theargs.bottomycoord

sys.stdout.write(str(in1) + '\n')
sys.stdout.write(str(in2) + '\n')
sys.stdout.write(str(in3) + '\n')
sys.stdout.write(str(in4) + '\n')

file = open(theargs.inputlistfile, "r")
lines = [line.rstrip('\n') for line in file]
file.close()

file = open(theargs.outputlistfile, "r")
outfiles = [line.rstrip('\n') for line in file]
file.close()


def processInput(x):
    sys.stdout.write('Loading: ' + str(lines[x]) + '\n')
    img = cv2.imread(lines[x], cv2.IMREAD_UNCHANGED)
    cropped = img[in1:in2, in3:in4]
    sys.stdout.write('Saving: ' + str(outfiles[x]) + '\n')
    cv2.imwrite(outfiles[x], cropped)
    return


p_tasks = _get_number_of_tasks_to_run_based_on_instance_type(theargs)

results = Parallel(n_jobs=p_tasks)(delayed(processInput)(i) for i in range(0, len(lines)))
