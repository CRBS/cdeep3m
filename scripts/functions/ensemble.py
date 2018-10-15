#!/usr/bin/env python

"""
EnsemblePredictions for CDeep3M
different predictions coming from files e.g. from 1fm 3fm and 5fm will be averaged here
flexible number of inputs
last argument has to be the outputdirectory where the average files will be stored

-----------------------------------------------------------------------------
 NCMIR, UCSD -- Author: M Haberl -- Data: 10/2018
 ----------------------------------------------------------------------------
 
"""
import sys
import os
import argparse
import cv2
import requests
from joblib import Parallel, delayed
# from multiprocessing import Pool, TimeoutError
# import time
import numpy as np
from PIL import Image
from time import time

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
                return 4
            if 'p3.8xlarge' in r.text:
                return 12
            if 'p3.16xlarge' in r.text:
                return 20
    except Exception as e:
        sys.stderr.write('Got exception checking instance type: ' +
                         str(e) + '\n')
    return 4
    

def _parse_arguments(desc, theargs):
    """Parses command line arguments using argparse
    """
    help_formatter = argparse.RawDescriptionHelpFormatter
    parser = argparse.ArgumentParser(description=desc,
                                     formatter_class=help_formatter)
    parser.add_argument('inputlistfile',
                        help='File containing list of paths')
    parser.add_argument('outputfolder',
                        help='Path to write output in')
    parser.add_argument('--instancetypeurl', default=INSTANCE_TYPE_URL,
                        help='URL to query for meta data instance type ' +
                             '(default ' + INSTANCE_TYPE_URL + ')')
    parser.add_argument('--instancetypeurltimeout',default='1.0',type=float,
                        help='Timeout in seconds for checking instancetypeurl' +
                             ' default 1.0')
    return parser.parse_args(theargs)

desc = """
Given a file with a list of folder (inputlistfile), 
"""

# Parse arguments
theargs = _parse_arguments(desc, sys.argv[1:])
outfolder = theargs.outputfolder;

file = open(theargs.inputlistfile, "r")
infolders = [line.rstrip('\n') for line in file]
file.close()

folder1 = infolders[0];
sys.stdout.write('Reading ' + str(folder1) + ' \n')
filelist1 = [fileb for fileb in os.listdir(folder1) if fileb.endswith('.png')]
print(infolders)
print(filelist1)
sys.stdout.write('Merging ' + str(len(filelist1)) + ' files \n')    

def average_img(x):
    sys.stdout.write('Loading: ' + str(os.path.join(infolders[0],filelist1[x])) + '\n')        
    t0 = time()    
    temp = cv2.imread(os.path.join(infolders[0],filelist1[x]))
    # img[:,:,0]
    for n in range(1, len(infolders)):
        temp = np.dstack((temp, cv2.imread(os.path.join(infolders[n],filelist1[x]))))
        print time()-t0
        print temp.shape    
    arr = np.array(np.mean(temp, axis=(2)), dtype=np.uint8)
    #aver = Image.fromarray(arr)
    cv2.imwrite(os.path.join(outfolder,filelist1[x]), arr)
    return

p_tasks = _get_number_of_tasks_to_run_based_on_instance_type(theargs)
sys.stdout.write('Running ' + str(p_tasks) + ' parallel tasks\n')
results = Parallel(n_jobs=p_tasks)(delayed(average_img)(i) for i in range(0, len(filelist1)))
