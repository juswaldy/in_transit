#!/usr/bin/python

import argparse
from PIL import Image, ImageOps, ImageDraw
import librosa
from glob import glob
import re

"""parsing and configuration"""
def parse_args():
    desc = "Count number of frames"
    parser = argparse.ArgumentParser(description=desc)

    parser.add_argument('--inputfile', type=str, default=None, help='Input file of frame numbers', required=True)

    parser.add_argument('--outputfile', type=str, default=None, help='Output file of frame count, frame from, frame to', required=True)

    parser.add_argument('--inputtype', type=str, default='librosa', help='librosa (default), or scenedetect', required=False)

    parser.add_argument('--fps', type=float, default=None, help='Frame rate', required=False)

    return check_args(parser.parse_args())

"""checking arguments"""
def check_args(args):
    return args

"""main"""
def main():

    # Parse arguments.
    args = parse_args()
    if args is None:
        print("Problem!")
        exit()

    # Open input file.
    frames = open(args.inputfile)
    frames_output = open(args.outputfile, 'w')

    # Go through each frame and calc.
    sentinel = 1
    i = 1
    for f in frames:
        if args.inputtype == "scenedetect":
            if re.match("[^:A-Za-z]+,", f):
                f = int(f.split(',')[1])+1
            else:
                continue
        else:
            f = int(float(f) * args.fps)
        length = f - sentinel
        frames_output.write("{},{},{},{}\n".format(i, length, sentinel, f-1))
        sentinel = f
        i += 1

if __name__ == '__main__':
    main()
