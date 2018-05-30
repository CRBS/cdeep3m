#!/usr/bin/env python

"""
Crop image Frame
"""

import cv2
import sys
import os
from joblib import Parallel, delayed


inputarg = (sys.argv)
print 'Number of arguments:', len(inputarg), 'arguments.'

from joblib import Parallel, delayed

from multiprocessing import Pool, TimeoutError
import time
import os

inputarg = (sys.argv)
#print 'Number of arguments:', len(inputarg), 'arguments.'
in1 = int(inputarg[3])
in2 = int(inputarg[4])
in3 = int(inputarg[5])
in4 = int(inputarg[6])
print(in1)
print(in2)
print(in3)
print(in4)
#print 'Argument List:', str(inputarg[2])
            
tempmat_infile = str(inputarg[1])
#print 'Opening:', tempmatfile, '...'

tempmat_outfile = str(inputarg[2])
#print 'Opening:', tempmatfile, '...'

file = open(tempmat_infile, "r")
lines = [line.rstrip('\n') for line in file]
file.close()

file = open(tempmat_outfile, "r")
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
    print 'Loading:', (str(lines[x]))
    #img = lycon.load(lines[x])
    img = cv2.imread(lines[x], cv2.IMREAD_UNCHANGED)
    #type(img)
    cropped = img[in1:in2, in3:in4]
    print 'Saving:', str(outfiles[x])
    #lycon.save(outfiles[x], cropped)
    cv2.imwrite(outfiles[x], cropped)
    return

results = Parallel(n_jobs=2)(delayed(processInput)(i) for i in range(0, len(lines)))
