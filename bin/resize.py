#!/usr/bin/python

import argparse
from PIL import Image
from glob import glob

"""parsing and configuration"""
def parse_args():
    desc = "Resize images into the specified width x height. Black padding will be added at the end"
    parser = argparse.ArgumentParser(description=desc)

    parser.add_argument('--inputfolder', type=str, default=None, help='Input folder', required=True)

    parser.add_argument('--outputfolder', type=str, default=None, help='Output folder', required=True)

    parser.add_argument('--newwidth', type=int, default=None, help='New image width', required=True)

    parser.add_argument('--newheight', type=int, default=None, help='New image height', required=True)

    parser.add_argument('--filetype', type=str, default='jpg', help='jpg or png?', required=False)

    parser.add_argument('--padonly', action='store_true', required=False)

    return check_args(parser.parse_args())

"""figure out ratio"""
def ratio(w, h, nw, nh):
    hratio = nh / h
    w = int(hratio * w)
    w -= 0 if w % 2 == 0 else 1
    h = int(hratio * h)
    h -= 0 if h % 2 == 0 else 1
    result.thumbnail((w, h))
    return result

"""convert float to int after shifting decimals"""
def float2int(f, decimals):
    return int(f * 10**decimals)

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

    # Get filetype.
    imagetype = 'RGB' if args.filetype == 'jpg' else 'RGBA'

    # Get original size from the first image.
    files = sorted(glob("{}/*.{}".format(args.inputfolder, args.filetype)))
    x = Image.open(files[0])
    w, h = x.size

    # Figure out ratios.
    nw, nh = args.newwidth, args.newheight
    whratio = float(w/h)
    nwhratio = float(nw/nh)
    if float2int(nwhratio, 2) == float2int(whratio, 2):
        newsize = (nw, nh)
        upperleft = (0, 0)
    elif float2int(nwhratio, 2) > float2int(whratio, 2):
        newwidth = int(nh*whratio)
        newsize = (newwidth, nh)
        upperleft = (int((nw-newwidth)/2), 0)
    else:
        newheight = int(nw*whratio)
        newsize = (nw, newheight)
        upperleft = (0, int((nh-newheight)/2))

    print("old size: {}\nwhratio: {}\nnew whratio: {}\nnew size: {}\nupperleft: {}".format((w, h), whratio, nwhratio, newsize, upperleft))

    # Go through each file and resize/pad.
    i = 1
    for f in files:
        # Paste image into a black background.
        x = Image.new(imagetype, (nw, nh))
        y = Image.open(f)
        if not args.padonly:
            y = y.resize(newsize, resample=Image.LANCZOS)
        x.paste(im=y, box=upperleft)

        # Save image.
        filename = f.split('/')[-1]
        x.save("{}/{}".format(args.outputfolder, filename))
        print("Processing {}".format(i)) if i % 100 == 0 else 0
        i += 1

if __name__ == '__main__':
    main()
