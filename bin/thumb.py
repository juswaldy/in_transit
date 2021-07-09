#!/usr/bin/python

import argparse
from PIL import Image, ImageOps, ImageDraw
import librosa
from glob import glob
import re

"""parsing and configuration"""
def parse_args():
    desc = "Count frames in scenes and prepare a thumbnail html"
    parser = argparse.ArgumentParser(description=desc)

    parser.add_argument('--inputfile', type=str, default=None, help='Input file of frame numbers', required=True)

    parser.add_argument('--outputframes', type=str, default=None, help='Output file of <scene number, frame count, frame from, frame to>', required=True)

    parser.add_argument('--outputthumbs', type=str, default='thumbs.html', help='Output scene thumbnail html file', required=True)

    parser.add_argument('--fps', type=float, default=None, help='Frame rate', required=True)

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

    # Folder setup.
    inputfolder = "original"

    # Open in/out files.
    frames = open(args.inputfile)
    frames_output = open(args.outputframes, 'w')
    thumbs_output = open(args.outputthumbs, 'w')
    thumbs_output.write("<html>\n<head>\n<link href='../../assets/style.css' rel='stylesheet' type='text/css' media='all'/>\n<script src='../../assets/util.js'></script>\n</head>\n<body>\n<table width='100%'><tr><td>\n<table width='100%'>\n<tr><td>Ordinal</td><td>Length (seconds / frames)</td><td>From-To</td><td>First</td><td>Last</td></tr>\n")

    # Go through each frame and calc.
    sentinel = 1
    i = 0
    for f in frames:
        if re.match("[^:A-Za-z]+,", f):
            f = int(f.split(',')[1])+1
        else:
            continue
        length = f - sentinel
        length_sec = length/args.fps
        from_sec = sentinel/args.fps
        to_sec = (f-1)/args.fps
        frames_output.write("{},{},{},{}\n".format(i, length, sentinel, f-1))
        thumbs_output.write("<tr><td>{}</td><td>{:.2f} / {}</td><td>{:.2f}-{:.2f} / {}-{}</td><td><img class='thumb' src='{}/{:07}.jpg' onclick='jumpTo({:.2f})'/></td><td><img class='thumb' src='{}/{:07}.jpg' onclick='jumpTo({:.2f})'/></td></tr>\n".format(i, length_sec, length, from_sec, to_sec, sentinel, f-1, inputfolder, sentinel, from_sec, inputfolder, f-1, to_sec))
        sentinel = f
        i += 1

    vidfile = glob("*{}*.mp4".format(args.inputfile.split('/')[-1].split('.')[0]))[0]
    thumbs_output.write("</table>\n</td><td width='50%' span='{}'><video controls><source src='{}' type='video/mp4'/></video></td></tr></table>\n".format(i-1, vidfile))
    thumbs_output.write("</body>\n</html>\n")

if __name__ == '__main__':
    main()
