#!/usr/bin/env python

"""
Crop image frame for CDeep3M


NCMIR/NBCR, UCSD -- Authors: M Haberl / C Churas -- Date: 5/2018

"""
import sys
import os
import argparse
import cv2
from joblib import Parallel, delayed
from multiprocessing import Pool, TimeoutError
import time

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


#print lines
'''
>>>>>>> master
for x in range(0, len(lines)):
    print 'Loading:', (str(lines[x]))
    #img = lycon.load(lines[x])
    img = cv2.imread(lines[x], cv2.IMREAD_UNCHANGED)
<<<<<<< HEAD
    type(img)
=======
    #type(img)
>>>>>>> master
    cropped = img[in1:in2, in3:in4]
    print 'Saving:', str(outfiles[x])
    #lycon.save(outfiles[x], cropped)
    cv2.imwrite(outfiles[x], cropped)
    #print('done')
<<<<<<< HEAD
=======
'''
def processInput(x):
    sys.stdout.write('Loading: ' + str(lines[x]) + '\n')
    img = cv2.imread(lines[x], cv2.IMREAD_UNCHANGED)
    cropped = img[in1:in2, in3:in4]
    sys.stdout.write('Saving: ' + str(outfiles[x]) + '\n')
    cv2.imwrite(outfiles[x], cropped)
    return

results = Parallel(n_jobs=2)(delayed(processInput)(i) for i in range(0, len(lines)))
