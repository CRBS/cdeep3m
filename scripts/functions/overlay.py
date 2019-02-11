#!/usr/bin/env python

"""
Overlay image frame for CDeep3M
NCMIR/NBCR, UCSD -- Authors: M Haberl -- Date: 2/2019


Example:
python overlay.py ~/rawimage/image_001.png ~/pediction/segmented_001.png ~/overlay_001.png


"""

import sys
import cv2
import numpy as np
import argparse


def _parse_arguments(desc, theargs):
    """Parses command line arguments using argparse
    """
    help_formatter = argparse.RawDescriptionHelpFormatter
    parser = argparse.ArgumentParser(description=desc,
                                     formatter_class=help_formatter)
    parser.add_argument('inputrawimage_name',
                        help='File containing list of input raw image name')
    parser.add_argument('inputsegmentedimage_name',
                        help='File containing list of input segmented image name')
    parser.add_argument('outputoverlayimage_name',
                        help='File containing list of output overlay image name')
    return parser.parse_args(theargs)

desc = """
"""

# Parse arguments
theargs = _parse_arguments(desc, sys.argv[1:])


raw_image = cv2.imread(theargs.inputrawimage_name, cv2.IMREAD_UNCHANGED)
#raw_stack = np.dstack((raw_image,raw_image,raw_image))

segmented = cv2.imread(theargs.inputsegmentedimage_name, cv2.IMREAD_UNCHANGED)

# overlay
alpha = 0.45
overlayed = cv2.addWeighted(segmented, alpha , raw_image, 1 - alpha, 0)

sys.stdout.write('Saving: ' + str(theargs.outputoverlayimage_name) + '\n')
cv2.imwrite(theargs.outputoverlayimage_name, overlayed)


