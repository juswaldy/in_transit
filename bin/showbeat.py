#!/usr/bin/python

import argparse
from PIL import Image, ImageOps
import librosa
from glob import glob

"""parsing and configuration"""
def parse_args():
    desc = "Show beats"
    parser = argparse.ArgumentParser(description=desc)

    parser.add_argument('--inputfolder', type=str, default=None, help='Input folder of the frames', required=True)

    parser.add_argument('--outputfolder', type=str, default=None, help='Output folder of frames with the beats', required=True)

    parser.add_argument('--fps', type=float, default=None, help='Frames per second', required=False)

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

        # Get beat times.
        print("Figuring out beats...")
        soundfile = glob("{}/../*.m4a".format(args.inputfolder))[0]
        wf, sr = librosa.load(soundfile, sr=44100)
        tempo, beat_frames = librosa.beat.beat_track(y=wf, sr=sr)
        beat_times = librosa.frames_to_time(beat_frames, sr=sr)
        librosa.output.times_csv("{}/../beat_times.csv".format(args.outputfolder), beat_times)

        # Mark frame for each beat.
        beat_frames = open("{}/../beat_frames.csv".format(args.outputfolder), 'w')
        for b in beat_times:
            frame = int(float(b)*float(args.fps))
            print("Beat on {}".format(frame))
            beat_frames.write("{}\n".format(frame))
            x = Image.open("{}/{:07}.jpg".format(args.inputfolder, frame))
            x = ImageOps.invert(x)
            x.save("{}/{:07}.jpg".format(args.outputfolder, frame))

if __name__ == '__main__':
    main()
