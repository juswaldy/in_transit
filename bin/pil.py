#!/usr/bin/python

import argparse
from PIL import Image, ImageOps
from glob import glob
import numpy as np
import cv2
import mahotas
import os

"""our helper class"""
class Pil:

    def histo(self, args):
        files = glob("{}/*.[Jj][Pp][Gg]".format(args.modelname))

        # Gather all histograms.
        H = []
        for f in sorted(files):
            x = Image.open(f)
            h = np.array(x.histogram()).astype(np.float32)
            H.append(h)

        # Get a mean histogram.
        hmean = np.mean(H, axis=0)

        # Make a flat histo.
        hmean = np.array([np.sum(H[0])/768] * 768).astype(np.float32)

        # Get comparison against hmean.
        d = {}
        for i in range(len(H)):
            #d[i] = cv2.compareHist(H[i], hmean, cv2.HISTCMP_CORREL)
            #d[i] = cv2.compareHist(H[i], hmean, cv2.HISTCMP_CHISQR)
            d[i] = cv2.compareHist(H[i], hmean, cv2.HISTCMP_INTERSECT)
            #d[i] = cv2.compareHist(H[i], hmean, cv2.HISTCMP_BHATTACHARYYA)

        for i in sorted(d, key=d.get):
            print('<img src="{}/231_{}_{}000.jpg" width="640"/>'.format(args.modelname, args.modelname, i+1))

    def pcb(self, args):
        files = sorted(glob("/home/jus/datasets/pcb/*/*.jpg"))
        for f in files:
            pcbnum = f.split('/')[5]
            basename = os.path.basename(f)
            dirname = os.path.dirname(f)
            recname = basename.split('.')[0]
            newname = "/home/jus/github/adaptive-style-transfer/data/pcb/{}_{}".format(pcbnum, basename)
            maskname = "{}/{}-mask.png".format(dirname, recname)
            print(newname)

            mask = Image.open(maskname).convert("1")
            im1 = Image.open(f)
            im2 = Image.open(maskname).convert("RGB")

            x = Image.composite(im1, im2, mask)
            y = np.asarray(x)
            b = mahotas.bbox(y)
            z = Image.fromarray(y[b[0]:b[1], b[2]:b[3]])
            z.save(newname)

    def rotatemirror(self, args):
        f = args.inputfile
        dirname = os.path.dirname(f)
        basename = os.path.basename(f)
        name = '.'.join(basename.split('.')[0:-1])
        img = Image.open(args.inputfile)

        # Rotate 4 x 90 degrees, save image and its mirror (horz flip).
        for n in range(0, 360, 90):
            name1 = "{}/{}.{}.1.jpg".format(dirname, name, n)
            name2 = "{}/{}.{}.2.jpg".format(dirname, name, n)
            img1 = img.rotate(n, expand=1)
            img1.save(name1)
            img2 = ImageOps.mirror(img1)
            img2.save(name2)

"""parsing and configuration"""
def parse_args():
    desc = "PIL tasks"
    parser = argparse.ArgumentParser(description=desc)
    parser.add_argument('--task', type=str, default=None, help='Which task?', required=True, choices=['histo', 'pcb', 'rotatemirror'])
    parser.add_argument('--modelname', type=str, default=None, help='Model name')
    parser.add_argument('--inputfile', type=str, default=None, help='Path to input file')

    return check_args(parser.parse_args())

"""checking arguments"""
def check_args(args):
    return args

if __name__ == '__main__':
    # Parse arguments.
    args = parse_args()
    if args is None:
        print("Problem!")
        exit()

    f = getattr(Pil(), args.task)
    f(args)

