#!/usr/bin/python

import argparse
import shutil
import random
import csv
from PIL import Image
from glob import glob

"""parsing and configuration"""
def parse_args():
	desc = "Assemble frames for video"
	parser = argparse.ArgumentParser(description=desc)
	parser.add_argument('--contentfolder', type=str, default=None, help='Where is the unstyled content folder?', required=True)
	parser.add_argument('--rendersroot', type=str, default=None, help='Where is the renders root folder?', required=True)
	parser.add_argument('--renders', type=str, default=None, help='Where is the config.renders file? (Line number is the id)', required=True)
	parser.add_argument('--instructions', type=str, default=None, help='Where is the config.instructions file? (Use line numbers from config.renders)', required=True)
	parser.add_argument('--lastframe', type=int, default=None, help='What is the last frame number?', required=True)
	parser.add_argument('--beats', type=str, default=None, help='Where is the config.beats file?', required=True)
	parser.add_argument('--outfolder', type=str, default=None, help='Where do I put the result?', required=True)
	return check_args(parser.parse_args())

"""checking arguments"""
def check_args(args):
	return args

"""transformations"""
def transform(frame_from, frame_to, sourcefolders, transforms, outfolder):
	print("transform: ", frame_from, frame_to, sourcefolders, transforms, outfolder)
	for t in transforms:
		if t == "linear":
			alpha = 0
			step = 1.0 / (1 + frame_to - frame_from)
			for n in range(frame_from, frame_to + 1):
				print("Processing {}".format(n)) if n % 10 == 0 else 0
				filename = "{:07}.jpg".format(n)
				source1 = glob("{}/{:07d}*.jpg".format(sourcefolders[0], n))[0]
				source2 = glob("{}/{:07d}*.jpg".format(sourcefolders[1], n))[0]
				outfile = "{}/{}".format(outfolder, filename)
				x = Image.open(source1)
				y = Image.open(source2)
				alpha = step * ((n - frame_from) + 1)
				result = Image.blend(x, y, alpha)
				result.save(outfile)
	return frame_to

"""finalize: gather into the final target folder"""
def finalize(frame_from, frame_to, sourcefolder, targetfolder):
	print("finalize: ", frame_from, frame_to, sourcefolder, targetfolder)
	for n in range(frame_from, frame_to + 1):
		print("Processing {}".format(n)) if n % 10 == 0 else 0
		sourcefile = glob("{}/{:07d}*.jpg".format(sourcefolder, n))[0]
		targetfile = "{}/{:07d}.jpg".format(targetfolder, n)
		shutil.copy(sourcefile, targetfile)
	return frame_to

"""main"""
def main():

	# CSV field separator.
	fs = '|'

	# Parse arguments.
	args = parse_args()
	if args is None:
		print("Problem!")
		exit()

	# Read configs: render locations, instructions, beat frames.
	with open(args.renders) as r, open(args.instructions) as i, open(args.beats) as b:
		renders = [ "{}/{}".format(args.rendersroot, x) for l in list(csv.reader(r, delimiter=fs)) for x in l ]
		instructions = list(csv.reader(i, delimiter=fs))
		beats = list(csv.reader(b, delimiter=fs))

	renders.insert(0, args.contentfolder)
	random.seed()
	frame_from = frame_to = 1
	for i in instructions:
		frame_to = int(i[0])
		sources = i[1].split(',') if len(i[1]) > 0 else []
		transforms = i[2].split(',') if len(i[2]) > 0 else []
		if len(sources) > 0:
			sourcefolders = []
			for s in sources:
				sourcefolders.append(renders[int(s)])
			if len(transforms) > 0:
				n = transform(frame_from, frame_to, sourcefolders, transforms, args.outfolder)
			else:
				n = finalize(frame_from, frame_to, sourcefolders[0], args.outfolder)
		else:
			randomchoice = random.randint(1, len(renders)-1)
			n = finalize(frame_from, frame_to, renders[randomchoice], args.outfolder)
		frame_from = n + 1
	randomchoice = random.randint(0, len(renders)-1)
	finalize(frame_from, args.lastframe+1, renders[randomchoice], args.outfolder)

if __name__ == '__main__':
	main()
