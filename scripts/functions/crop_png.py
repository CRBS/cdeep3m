#!/usr/bin/env python

"""
Crop image Frame
"""

import lycon
import sys
#import scipy.io as sio
#import csv
from joblib import Parallel, delayed

inputarg = (sys.argv)
print 'Number of arguments:', len(inputarg), 'arguments.'
in1 = int(inputarg[3])
in2 = int(inputarg[4])
in3 = int(inputarg[5])
in4 = int(inputarg[6])
print(in1)
print(in2)
print(in3)
print(in4)
            
tempmat_infile = str(inputarg[1])

file = open(tempmat_infile, "r")
all_infiles = file.readlines()
print(len(all_infiles))

tempmat_outfile = str(inputarg[2])

file = open(tempmat_outfile, "r")
all_outfiles = file.readlines()
print(len(all_outfiles))

for x in range(0, len(all_infiles)):
    print 'Loading:', (str(all_infiles[x]))
    img = lycon.load(str(all_infiles[x])),
    cropped = img[in1: in2, in3: in4],
    print 'Saving:', str(all_outfiles[x])
    lycon.save(str(all_outfiles[x]), cropped),
    print('done')