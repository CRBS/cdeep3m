#!/usr/bin/env python
"""
Crop image Frame
"""

import os
import lycon
import sys
#import scipy.io as sio
#import csv
from joblib import Parallel, delayed
inputarg = (sys.argv)

print 'Number of arguments:', len(inputarg), 'arguments.'

sys.stdout.write('Args: ' + ' '.join(sys.argv) + '\n')
in1 = int(inputarg[3])
in2 = int(inputarg[4])
in3 = int(inputarg[5])
in4 = int(inputarg[6])
sys.stdout.write('in1 => ' + str(in1) + '\n')
sys.stdout.write('in2 => ' + str(in2) + '\n')
sys.stdout.write('in3 => ' + str(in3) + '\n')
sys.stdout.write('in4 => ' + str(in4) + '\n')
            
tempmat_infile = str(inputarg[1])

file = open(tempmat_infile, "r")
all_infiles = file.readlines()
print(len(all_infiles))

tempmat_outfile = str(inputarg[2])

file = open(tempmat_outfile, "r")
all_outfiles = file.readlines()
print(len(all_outfiles))

for x in range(0, len(all_infiles)):
    print 'Loading:', os.path.abspath(all_infiles[x])
    img = lycon.load(os.path.abspath(all_infiles[x]))
    sys.stdout.write('img => ' + str(img) + '\n')
    cropped = img[in1:in2, in3:in4]
    print 'Saving:', os.path.abspath(all_outfiles[x]) + ' with crop '
    lycon.save(os.path.abspath(all_outfiles[x]), cropped)
    print('done')
