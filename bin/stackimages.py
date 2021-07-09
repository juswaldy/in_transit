#!/usr/bin/python

import argparse
import numpy as np
from PIL import Image, ImageDraw, ImageFont
from glob import glob
import multiprocessing as mp
from multiprocessing import Queue
from tqdm import tqdm

"""parsing and configuration"""
def parse_args():
	desc = "Stack up images in subfolder"
	parser = argparse.ArgumentParser(description=desc)

	parser.add_argument('--wh', type=int, default=200, help='Cell width/height', required=False)
	parser.add_argument('--inputroot', type=str, default=None, help='Input root folder', required=True)
	parser.add_argument('--outputfolder', type=str, default=None, help='Output folder', required=True)

	return check_args(parser.parse_args())

"""checking arguments"""
def check_args(args):
	return args

"""read a row of images"""
def get_image_row(inputroot, framenumber, rownumber, models, queue):
	images = [ Image.open("{}/{}/{:07}_{}.jpg".format(inputroot, x, framenumber, x)).resize((200,112)) for x in models ]
	image_row = np.hstack(np.asarray(i) for i in images)
	queue.put(image_row)

"""read a row of images and put it in its queue"""
def process_row(first_frame, last_frame, inputroot, models, queue):
	for i in tqdm(range(first_frame, last_frame+1), initial=first_frame, total=last_frame):
		images = [ Image.open("{}/{}/{:07}_{}.jpg".format(inputroot, x, i, x)).resize((200,112)) for x in models ]
		image_row = np.hstack(np.asarray(i) for i in images)
		queue.put(image_row)

"""main"""
def main():

	# Parse arguments.
	args = parse_args()
	if args is None:
		print("Problem!")
		exit()

	# Arrange the models.
	models = []
	models.append([ "0", "akira", "cezanne", "el-greco", "gauguin" ])
	models.append([ "kandinsky", "kirchner", "maya_all", "maya_liney", "maya_painty" ])
	models.append([ "maya_sketchy", "monet", "morisot", "munch", "pablo-picasso" ])
	models.append([ "peploe", "picasso", "pollock", "roerich", "van-gogh" ])

	# Make queues to handle the rows.
	queue = []
	for i in range(4):
		queue.append(Queue(maxsize=20))

	# Get last frame number from the first folder.
	first_folder = sorted(glob("{}/*".format(args.inputroot)))[0]
	last_file = sorted(glob("{}/*.[Jj][Pp][Gg]".format(first_folder)))[-1]
	last_frame = int(last_file.split('/')[-1].split('_')[0])

	# Go through each frame, resize, and stack.
	jobs = []
	for i in range(4):
		p = mp.Process(target=process_row, args=(1, last_frame, args.inputroot, models[i], queue[i]))
		p.start()
		jobs.append(p)

	for i in tqdm(range(1, last_frame+1), initial=1, total=last_frame):
		vert_images = []
		for j in range(4):
			## Use single thread.
			#images = [ Image.open("{}/{}/{:07}_{}.jpg".format(args.inputroot, x, i, x)).resize((200,112)) for x in models[j] ]
			#horz_images = np.hstack(np.asarray(i) for i in images)
			#vert_images.append(horz_images)

			## Use multi threads, blocking.
			#horz_images = pool.apply_async(get_image_row, (args.inputroot, i, j, models[j], queue[j]))
			#vert_images.append(horz_images.get(timeout=1))

			## Use multi queues.
			horz_images = queue[j].get()
			vert_images.append(horz_images)
		stacked_images = np.vstack(np.asarray(v) for v in vert_images)
		final = Image.fromarray(stacked_images)
		final.save("{}/{:07}.jpg".format(args.outputfolder, i))

	for p in jobs:
		p.join(0.1)
		p.terminate()

if __name__ == '__main__':
	main()
