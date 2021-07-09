#!/usr/bin/python

import argparse
from PIL import Image, ImageOps
import librosa
from glob import glob
import random

"""parsing and configuration"""
def parse_args():
    desc = "Jumble up the clips"
    parser = argparse.ArgumentParser(description=desc)

    parser.add_argument('--beatfile', type=str, default=None, help='Beat times', required=True)

    parser.add_argument('--outputfolder', type=str, default=None, help='Output folder of frames with the beats', required=True)

    parser.add_argument('--fps', type=float, default=None, help='Frames per second', required=True)

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

    # Estimate beats and mark frames.
    if args.fps:

        beat_times = open(args.beatfile)

        # Mark frame for each beat.
        frames = []
        for b in beat_times:
            frames.append(int(float(b)*float(args.fps)))

        # Group frames into clips of 1, 2, 4 beats.
        f1 = frames[0] # From frame number.
        n = 4
        sentinel = 5 # First segment is 4 beats.
        clips = dict()
        for n in [1, 2, 4]:
            clips[n] = []
        for f in frames:
            if sentinel == 1:
                clips[n].append([f1, f-1])
                f1 = f
                n = sentinel = 2 ** random.randint(0, 2)
            else:
                sentinel -= 1
                continue

        # Write random frames to file.
        randomfile = open("randomfile.csv", "w")

        # Randomly go through clips.
        numclips = 0
        for n in [1, 2, 4]:
            numclips += len(clips[n])
        for i in range(numclips):
            numbeats = 2 ** random.randint(0, 2)
            index = random.randint(0, len(clips[numbeats])-1)
            clip = clips[numbeats].pop(index)
            randomfile.write("{},{},{}\n".format(clip[1]-clip[0]+1, clip[0], clip[1]))
        randomfile.close()

if __name__ == '__main__':
    main()
