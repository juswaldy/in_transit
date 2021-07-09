#!/usr/bin/python

import argparse
from PIL import Image, ImageOps, ImageDraw
import librosa
from glob import glob

"""parsing and configuration"""
def parse_args():
    desc = "Add line background to the input image"
    parser = argparse.ArgumentParser(description=desc)

    parser.add_argument('--inputfile', type=str, default=None, help='Input image', required=True)

    parser.add_argument('--outputfolder', type=str, default=None, help='Output folder for the image with the background', required=True)

    parser.add_argument('--bgcolor', type=int, default=255, help='Background color. 255=white (default), 0=black', required=True)

    parser.add_argument('--bgtype', type=str, default=None, help='Background type: all (default), radial, horz, vert', required=False)

    parser.add_argument('--density', type=int, default=5, help='Density of background lines: 5 (normal, default), 1 (sparse), 10 (max)', required=False)

    return check_args(parser.parse_args())

"""checking arguments"""
def check_args(args):
    # --density
    try:
        assert args.density >= 1
        assert args.density <= 10
    except:
        print('Density %d out of range (must be between 1 and 10)' % args.density)
        return None
    return args

def addbg(x, bgcolor, bgtype, density):
    w, h = x.size

    # Make non transparent background.
    y = Image.new("RGB", x.size, (bgcolor, bgcolor, bgcolor))
    draw = ImageDraw.Draw(y)
    outlinecolor = 255 - bgcolor
    if bgtype == "radial":
        skip = int(60/density)
        for i in range(0, 360, skip):
            draw.pieslice((-w, -w, w*2, w+h), i, i+skip/2, outline=outlinecolor)
    elif bgtype == "horz":
        skip = int(h/(10*density))
        for i in range(skip, h, skip):
            draw.chord([0, i, w, i], 0, 360, outline=outlinecolor)
    elif bgtype == "vert":
        skip = int(w/(4*density))
        for i in range(skip, w, skip):
            draw.chord([i, 0, i, h], 0, 360, outline=outlinecolor)

    # Make RGBA.
    y = y.convert("RGBA")

    # Return image with background.
    return Image.alpha_composite(y, x).convert("RGB")

"""main"""
def main():

    # Parse arguments.
    args = parse_args()
    if args is None:
        print("Problem!")
        exit()

    # Determine background color and type.
    bgcolor = args.bgcolor
    bgtype = args.bgtype if args.bgtype else "all"

    # Open input image as RGBA.
    x = Image.open(args.inputfile).convert("RGBA")
    w, h = x.size

    # Make bgcolor transparent.
    pixels = x.load()
    for i in range(w):
        for j in range(h):
            if pixels[i, j] == (bgcolor, bgcolor, bgcolor, 255):
                pixels[i, j] = (bgcolor, bgcolor, bgcolor, 0)

    # Add background image and save.
    filename = args.inputfile.split('/')[-1]
    bgtype = ["radial", "horz", "vert"] if bgtype == "all" else [bgtype]
    for t in bgtype:
        y = addbg(x, bgcolor, t, args.density)
        withbg = "{}.{}.jpg".format('.'.join(filename.split('.')[0:-1]), t)
        y.save("{}/{}".format(args.outputfolder, withbg))

if __name__ == '__main__':
    main()
