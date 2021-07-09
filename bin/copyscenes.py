#!/usr/bin/python

import argparse
import csv
from shutil import copyfile

def parse_args():
    desc = "Copy scenes from different sources into a single target folder"
    parser = argparse.ArgumentParser(description=desc)
    parser.add_argument('--scenes_csv', type=str, default=None, help='CSV file for the scene source folder/frame numbers', required=True)
    parser.add_argument('--target_folder', type=str, default=None, help='Target folder to copy the frames to', required=True)
    return check_args(parser.parse_args())

def check_args(args):
    return args

def copy_scene(sentinel, source_folder, frame_from, frame_to, target_folder):
    diff = frame_from - sentinel
    for n in range(frame_from, frame_to+1):
        sentinel = n - diff
        from_file = "/home/jus/notebook/jus/styletransfer/vids/{}/{:07}.jpg".format(source_folder, n)
        to_file = "{}/{:07}.jpg".format(target_folder, sentinel)
        copyfile(from_file, to_file)
    return sentinel+1

"""main"""
def main():

    # Parse arguments.
    args = parse_args()
    if args is None:
        print("Problem!")
        exit()

    # Process scenes.
    with open(args.scenes_csv) as csvfile:
        scenes = list(csv.reader(csvfile, delimiter=','))

        # Process the first scene.
        sentinel = 1
        source_folder, frame_from, frame_to = scenes[0]
        sentinel = copy_scene(sentinel, source_folder, int(frame_from), int(frame_to), args.target_folder)

        # Process the rest of the scenes.
        for scene in scenes[1:]:
            source_folder, frame_from, frame_to = scene
            sentinel = copy_scene(sentinel, source_folder, int(frame_from), int(frame_to), args.target_folder)

if __name__ == '__main__':
    main()
