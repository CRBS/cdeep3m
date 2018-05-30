#!/usr/bin/env python

"""
Crop image Frame
"""

import lycon
import cv2
import sys
import os


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

tempmat_outfile = str(inputarg[2])


file = open(tempmat_infile, "r")
lines = [line.rstrip('\n') for line in file]
file.close()

file = open(tempmat_outfile, "r")
outfiles = [line.rstrip('\n') for line in file]
file.close()

print lines

for x in range(0, len(lines)):
    print 'Loading:', (str(lines[x]))
    img = lycon.load(lines[x])
    type(img)
    cropped = img[in1:in2, in3:in4]
    print 'Saving:', str(outfiles[x])
    lycon.save(outfiles[x], cropped)
    print('done')