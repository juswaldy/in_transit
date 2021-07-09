#!/usr/bin/python

import argparse
from PIL import Image
from glob import glob

"""parsing and configuration"""
def parse_args():
    desc = "Transform images involving multiple sources"
    parser = argparse.ArgumentParser(description=desc)

    parser.add_argument('--sources', nargs='+', type=str, default=None, help='Which are the source folders? Order is important!', required=True)

    parser.add_argument('--outfolder', type=str, default=None, help='Where do I put the result?', required=True)

    parser.add_argument('--framefirst', type=int, default=None, help='From which frame?', required=True)

    parser.add_argument('--framelast', type=int, default=None, help='To which frame?', required=True)

    parser.add_argument('--transforms', nargs='+', type=str, default=['alpha_blend:linear'], help='What transforms to apply? Order is important!')

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

    # 
    transforms = args.transforms

    # Make transitions.
    alpha = 0
    step = 1.0 / (1 + args.framelast - args.framefirst)
    for i in range(args.framefirst, args.framelast+1):
        print("Processing {}".format(i)) if i % 10 == 0 else 0
        filename = "{:07}.jpg".format(i)
        file1 = "{}/{}".format(args.style1, filename)
        file2 = "{}/{}".format(args.style2, filename)
        outfile = "{}/{}".format(args.outfolder, filename)
        x = Image.open(file1)
        y = Image.open(file2)
        alpha = step * ((i - args.framefirst) + 1)
        result = Image.blend(x, y, alpha)
        result.save(outfile)


if __name__ == '__main__':
    main()
