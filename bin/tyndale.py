#!/usr/bin/python

import argparse
import math
import cv2
import numpy as np
import os
from glob import glob
from PIL import Image, ImageDraw
import sys
from functools import reduce
import inspect
import pandas as pd
import re

TARGETNUM = ''

DEBUG = False
UPPERLEFT = (600, 200)
CROPWIDTH = 2200
CROPHEIGHT = 3300
DOCWIDTH = 1712
DOCHEIGHT = 2832
CROPGAMMA = 0.5
SAVEGAMMA = 0.7

KSIZE = 5
EROSIONS = 10
PADDING = 15
THRESHOLD_BINARY = 170

ROOTFOLDER = "/home/jus/notebook/jus/bible/tyndale"

"""Params"""
params = {
	'01.john': {
		'upperleft': (600, 200),
		'moveup': 170,
		'exceptions_rotate': { 43: 0 },
		'exceptions_finalize': { 9: (125, 343), 20: (260, 265) }
	},
	'02.mark': {
		'upperleft': (600, 200),
		'moveup': 170,
		'exceptions_rotate': { 2: 0, 42: 0 },
		'exceptions_finalize': { 2: (163, 348), 29: (264, 252) }
	},
	'03.matthew': {
		'upperleft': (600, 200),
		'moveup': 140,
		'exceptions_rotate': { 43: -0.9 },
		'exceptions_finalize': { 68: (331, 260) }
	},
	'04.luke': {
		'upperleft': (600, 200),
		'moveup': 170,
		'exceptions_rotate': { 7: 0.1, 20: -0.1 },
		'exceptions_finalize': { 18: (57, 283), 20: (77, 296) }
	},
	'05.acts': {
		'upperleft': (600, 200),
		'moveup': 170,
		'exceptions_rotate': { 47: 0.9, 68: 0.3, 91: 0.5 },
		'exceptions_finalize': { 7: (225, 232), 48: (105, 350), 59: (345, 305), 68: (169, 366), 73: (271, 326), 77: (260, 242), 80: (111, 325) }
	},
	'06.revelation': {
		'upperleft': (500, 200),
		'moveup': 170,
		'exceptions_rotate': { 1: 0.7 },
		'exceptions_finalize': { 44: (248, 321) }
	},
	'07.12peter': {
		'upperleft': (600, 200),
		'moveup': 170,
		'exceptions_rotate': { 1: 0.3, 8: -0.2, 11: 0.7, 12: -0.5 },
		'exceptions_finalize': { }
	},
	'08.123john': {
		'upperleft': (600, 200),
		'moveup': 170,
		'exceptions_rotate': { 11: 0 },
		'exceptions_finalize': { 11: (134, 316) }
	},
	'09.james_jude': {
		'upperleft': (600, 200),
		'moveup': 170,
		'exceptions_rotate': { 5: 0.2 },
		'exceptions_finalize': { 1: (120, 314), 9: (76, 270) }
	},
	'10.hebrews': {
		'upperleft': (600, 200),
		'moveup': 170,
		'exceptions_rotate': { 24: -0.4 },
		'exceptions_finalize': { 7: (289, 230), 12: (119, 294), 16: (83, 250), 19: (254, 215), 20: (90, 298), 24: (92, 253), 25: (245, 236), 26: (115, 285), 27: (246, 230) }
	},
	'11.romans': {
		'upperleft': (600, 200),
		'moveup': 170,
		'exceptions_rotate': { },
		'exceptions_finalize': { }
	},
	'12.1corinthians': {
		'upperleft': (450, 200),
		'moveup': 170,
		'exceptions_rotate': { },
		'exceptions_finalize': { }
	},
	'13.2corinthians': {
		'upperleft': (600, 200),
		'moveup': 170,
		'exceptions_rotate': { },
		'exceptions_finalize': { 22: (107, 300) }
	},
	'14.galatians': {
		'upperleft': (600, 200),
		'moveup': 170,
		'exceptions_rotate': { },
		'exceptions_finalize': { }
	},
	'15.ephesians_philippians': {
		'upperleft': (600, 200),
		'moveup': 170,
		'exceptions_rotate': { },
		'exceptions_finalize': { 1: (242, 283), 20: (111, 308) }
	},
	'16.colossians': {
		'upperleft': (600, 200),
		'moveup': 170,
		'exceptions_rotate': { },
		'exceptions_finalize': { }
	},
	'17.12thessalonians': {
		'upperleft': (550, 200),
		'moveup': 170,
		'exceptions_rotate': { },
		'exceptions_finalize': { }
	},
	'18.12timothy': {
		'upperleft': (600, 200),
		'moveup': 170,
		'exceptions_rotate': { },
		'exceptions_finalize': { }
	},
	'19.titus_philemon': {
		'upperleft': (600, 200),
		'moveup': 170,
		'exceptions_rotate': { },
		'exceptions_finalize': { 2: (226, 280), 5: (140, 307) }
	},
	'20.ToTheReder': {
		'upperleft': (600, 200),
		'moveup': 170,
		'exceptions_rotate': { },
		'exceptions_finalize': { }
	}
}

"""Parse arguments"""
def parse_args():
	desc = "Processing Tyndale's 1526 New Testament"
	parser = argparse.ArgumentParser(description=desc)
	parser.add_argument('--bookname', type=str, default=None, help='What is the bookname?', required=True)
	parser.add_argument('--action', type=str, default=None, help='What do you want to do?', required=True)
	return check_args(parser.parse_args())

"""Check arguments"""
def check_args(args):
	return args

"""Adjust gamma of the given image"""
def adjust_gamma(image, gamma=1.0):
	invGamma = 1.0 / gamma
	table = np.array([((i / 255.0) ** invGamma) * 255
		for i in np.arange(0, 256)]).astype("uint8")
	return cv2.LUT(image, table)

"""Break up data into consecutive groups. Return only the first item of the group"""
def consecutive_groups(x, stepsize=1):
	return [ i for i in range(1, len(x), stepsize) if x[i] != x[i-1] ]

"""Get the angle of line between 2 points"""
def getangle(pt1, pt2):
	x1, y1 = pt1
	x2, y2 = pt2
	return np.rad2deg(np.arctan2(y2 - y1, x2 - x1))

"""Get average angle of margin lines in the given eroded image"""
def getangle_lines(eroded):
	angles = []
	height, width = np.shape(eroded)

	# Make np array and transposed to process vertical and horizontal lines.
	a = np.array(eroded)
	b = np.transpose(a)

	# Do this for both vertical and horizontal.
	for x in [a, b]:
		multiplier = 1 if len(x[0]) == width else -1 # 1 for normal, -1 for transposed.
		top = consecutive_groups(x[0])
		bottom = consecutive_groups(x[-1])

		# Only look at the first and last pair.
		for i in [0, 1, -2, -1]:
			angle = multiplier * (getangle((top[i], 0), (bottom[i], len(x))) - 90) if top and bottom else 0
			# Only take angles < 2 degrees.
			angles.append(angle) if abs(angle) < 2 else None

	avg_angle = sum(angles)/len(angles)

	print(avg_angle, angles) if DEBUG else None
	return avg_angle

"""Rotate given image by angle"""
def rotate_image(img, angle):
	(h, w) = img.shape[:2]
	center = (w // 2, h // 2)
	M = cv2.getRotationMatrix2D(center, angle, 1.0)
	rotated = cv2.warpAffine(img.copy(), M, (w, h), flags=cv2.INTER_CUBIC, borderMode=cv2.BORDER_REPLICATE)
	return rotated

"""Get horizontal and vertical margin points"""
def get_horz_vert(inpath, kernel, threshold_binary, erosion_iterations, gamma=1.0):
	img = cv2.imread(inpath, cv2.IMREAD_GRAYSCALE)
	img = adjust_gamma(img, gamma) if gamma != 1.0 else img
	ret, thresh = cv2.threshold(img.copy(), threshold_binary, 255, cv2.THRESH_BINARY)
	eroded = cv2.erode(thresh, kernel, iterations = erosion_iterations)
	horizontal = consecutive_groups(eroded[0])
	vertical = consecutive_groups(np.transpose(eroded)[0])
	return horizontal, vertical

"""Save the cropped image"""
def save_cropped(inpath, outpath, y1, y2, x1, x2):
	img = cv2.imread(inpath)
	img = adjust_gamma(img, SAVEGAMMA) if SAVEGAMMA != 1.0 else img
	img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
	framed = img[y1:y2, x1:x2]
	z = Image.fromarray(framed)
	z.save(outpath)

"""Crop original images and place in cropped folder"""
def crop(bookname):
	x, y = params[bookname]['upperleft']
	width = CROPWIDTH
	height = CROPHEIGHT

	print('Cropping...')
	for f in sorted(glob('{}/0.original/{}.*{}.jpg'.format(ROOTFOLDER, bookname, TARGETNUM))):
		filename = f.split('/')[-1]
		outpath = '{}/1.cropped/{}'.format(ROOTFOLDER, filename)
		img = cv2.imread(f)
		img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
		cropped = img[y:y+height, x:x+width]
		output = Image.fromarray(cropped)
		output.save(outpath)
		print('{} ==> {}'.format(f, outpath))

"""Rotate cropped images and place in rotated folder"""
def rotate(bookname):
	ksize = KSIZE
	kernel_size = (ksize, ksize)
	erosion_iterations = EROSIONS
	kernel = cv2.getStructuringElement(cv2.MORPH_RECT, kernel_size)

	exceptions = params[bookname]['exceptions_rotate']

	print('Rotating...')
	for f in sorted(glob('{}/1.cropped/{}.*{}.jpg'.format(ROOTFOLDER, bookname, TARGETNUM))):
		filename = f.split('/')[-1]
		outpath = '{}/2.rotated/{}'.format(ROOTFOLDER, filename)

		img = cv2.imread(f, cv2.IMREAD_GRAYSCALE)
		ret, thresh = cv2.threshold(img, THRESHOLD_BINARY, 255, cv2.THRESH_BINARY)
		eroded = cv2.erode(thresh, kernel, iterations=erosion_iterations)
		angle = getangle_lines(eroded)

		# Process exceptions.
		if len(exceptions) > 0:
			for e in exceptions.keys():
				if re.match(".*{:07}.*".format(e), filename):
					angle = exceptions[e]

		img = cv2.imread(f)
		img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
		rotated = rotate_image(img, angle)

		y = Image.fromarray(rotated)
		y.save(outpath)
		print('{} ==> {}'.format(f, outpath))

"""Final cropping"""
def finalize(bookname):
	ksize = KSIZE
	kernel_size = (ksize, ksize)
	erosions = EROSIONS
	kernel = cv2.getStructuringElement(cv2.MORPH_RECT, kernel_size)

	padding = PADDING
	moveup = params[bookname]['moveup']
	exceptions = params[bookname]['exceptions_finalize']

	print('Finalizing...')
	for f in sorted(glob('{}/2.rotated/{}.*{}.jpg'.format(ROOTFOLDER, bookname, TARGETNUM))):
		filename = f.split('/')[-1]
		outpath = '{}/3.final/{}'.format(ROOTFOLDER, filename)

		horizontal, vertical = get_horz_vert(f, kernel, THRESHOLD_BINARY, erosions)

		# If failed, decrease gamma.
		if len(horizontal) < 4 or len(vertical) < 4:
			horizontal, vertical = get_horz_vert(f, kernel, THRESHOLD_BINARY, erosions, gamma=CROPGAMMA)

		# Get the first item from horz and vert.
		x, y = horizontal[0], vertical[0]

		# Process exceptions.
		if len(exceptions) > 0:
			for e in exceptions.keys():
				if re.match(".*{:07}.*".format(e), filename):
					x, y = exceptions[e]

		# By this point we should be within range of these conditions.
		if len(exceptions) > 0 or (len(horizontal) >= 4 and len(vertical) >= 4 and x < 500 and y < 500):
			print('x, y, horz, vert: {}, {}, {}, {}'.format(x, y, horizontal, vertical)) if DEBUG else None
			save_cropped(f, outpath, y-moveup, y+DOCHEIGHT-padding, x+padding, x+DOCWIDTH-padding)
			print('{} ==> {}'.format(f, outpath))
		else:
			print('!'*40, ' FAILED ', filename, horizontal, vertical)


"""main"""
def main():

	# Parse arguments.
	args = parse_args()
	if args is None:
		print("Problem!")
		exit()

	globals()[args.action](args.bookname)


if __name__ == '__main__':
    main()
