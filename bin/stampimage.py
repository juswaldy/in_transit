#!/usr/bin/python

import argparse
from PIL import Image, ImageDraw, ImageFont, ImageOps
from glob import glob

"""parsing and configuration"""
def parse_args():
    desc = "Stamp info on image"
    parser = argparse.ArgumentParser(description=desc)

    parser.add_argument('--stampinfo', type=str, default='filename', help='Stamp type', required=True)

    parser.add_argument('--inputfolder', type=str, default=None, help='Input folder', required=True)

    parser.add_argument('--outputfolder', type=str, default=None, help='Output folder', required=True)

    parser.add_argument('--sourceimage', type=str, default=None, help='Use this image for all frames, or "original"', required=False)

    parser.add_argument('--textcolor', nargs='+', type=int, default=[128, 128, 128], help='Text color in RGB', required=False)

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

    # Stamp frame number.
    i = 1
    for f in sorted(glob("{}/*.[Jj][Pp][Gg]".format(args.inputfolder))):

        filename = f.split('/')[-1]

        # Read original or specified source.
        if args.sourceimage == "original":
            x = Image.open(f)
        else:
            x = Image.open(args.sourceimage)

        # Draw frame number.
        font = ImageFont.truetype("/usr/share/fonts/dejavu/DejaVuSans.ttf", 40)
        d = ImageDraw.Draw(x)
        if x.mode == "L":
            d.text((0,0), filename, 128, font=font)
        else:
            R, G, B = args.textcolor
            #d.text((0,0), filename, (128,128,128), font=font)
            d.text((0,0), filename, (R, G, B), font=font)
        x.save("{}/{}".format(args.outputfolder, filename))
        print("Processing {}".format(i)) if i % 100 == 0 else 0
        i += 1

if __name__ == '__main__':
    main()
