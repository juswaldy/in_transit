#!/usr/bin/python

import math
import cv2
import numpy as np
import os
from glob import glob
from PIL import Image, ImageDraw
import sys
from functools import reduce

DEBUG = True
CROPWIDTH = 3160
CROPHEIGHT = 5150

# Cut out the edges.
def crop_image(img, upperleft, cropsize):
    ulx, uly = upperleft
    width, height = cropsize
    cropped = img[uly:uly+height, ulx:ulx+width]
    print(ulx, uly) if DEBUG else None
    return cropped

# Figure out the tip of the line.
def get_tip(fn, line):
    x, y = fn(line[:,0], key = lambda x : x[0])
    return (x, y)

# Return upperleft and lowerright coordinates surrounding a point.
def get_box_frompoint(point, margin):
    x, y = point
    return ((x-margin, y-margin), (x+margin, y+margin))

# Return contour points within a box.
def get_contourpoints(contour, box):
    inbox = []
    for p in contour:
        if box[0][0] < p[0][0] < box[1][0]:
            inbox.append(p)
    return np.array(inbox)

# Return min and max y for the given contour within a box (point+margin all around).
def get_minmax_y(contour, point, margin):
    box = get_box_frompoint(point, margin)
    inbox = get_contourpoints(contour, box)
    return (min(inbox[:,0][:,1]), max(inbox[:,0][:,1]))

# Get contours in image.
def get_contours(img):
    gray = cv2.cvtColor(img.copy(), cv2.COLOR_BGR2GRAY)
    thresh = cv2.threshold(gray.copy(), 185, 255, cv2.THRESH_BINARY_INV)[1]
    edges = cv2.Canny(gray.copy(), 10, 250, apertureSize=7)
    (contours, hier) = cv2.findContours(thresh.copy(), cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
    return contours

# Get the long contours.
def get_longcontours(contours, threshold=2000.0):
    cnts = []
    for c in contours:
        arclen = cv2.arcLength(c, True)
        if arclen > threshold:
            cnts.append(c)
    longcontours = np.array(cnts)
    return longcontours

# Get the rotation angle from the hebrew reader page.
def get_rotation_angle(lines):
    # Figure out the upper and lower lines.
    if len(lines) == 1:
        upperline = lowerline = lines[0]
    else:
        miny = CROPHEIGHT
        for i in range(len(lines)):
            currentmin = min(lines[i][:,0][:,1])
            if currentmin < miny:
                upper = i
                miny = currentmin
        lower = abs(upper-1)
        upperline = lines[upper]
        lowerline = lines[lower]

    # Find the tips of the upper line.
    lefttip = get_tip(min, upperline)
    righttip = get_tip(max, upperline)

    # Get the boxes at the tips.
    margin = 7
    leftbox = get_box_frompoint(lefttip, margin)
    rightbox = get_box_frompoint(righttip, margin)

    # Get contour points within the boxes.
    inleftbox = get_contourpoints(upperline, leftbox)
    inrightbox = get_contourpoints(upperline, rightbox)

    # Get the min and max y of the tips.
    leftminy, leftmaxy = min(inleftbox[:,0][:,1]), max(inleftbox[:,0][:,1])
    rightminy, rightmaxy = min(inrightbox[:,0][:,1]), max(inrightbox[:,0][:,1])

    # Get the mean left and right y.
    lefty = (leftminy + leftmaxy) / 2.0
    righty = (rightminy + rightmaxy) / 2.0

    # Get the vertical and horizontal deltas.
    deltay = abs(lefty-righty)
    deltax = abs(lefttip[0]-righttip[0])*1.0

    # Get the direction of the rotation. -1 = clockwise
    direction = -1 if lefty < righty else 1

    # Calculate angle.
    angle = direction*math.asin(deltay/deltax)*180/math.pi

    if False:
        print(lefttip, righttip)
        print(lefty, righty)
        print(angle)

    return angle

# Rotate an image by the given angle.
def rotate_image(img, angle):
    (h, w) = img.shape[:2]
    center = (w // 2, h // 2)
    M = cv2.getRotationMatrix2D(center, angle, 1.0)
    rotated = cv2.warpAffine(img.copy(), M, (w, h), flags=cv2.INTER_CUBIC, borderMode=cv2.BORDER_REPLICATE)
    return rotated

# Get contours in blurred image.
def get_contours_blurred(img):
    kernel_length = 40
    kernel_size = (kernel_length, kernel_length)
    img = cv2.blur(img.copy(), kernel_size);
    #img = cv2.GaussianBlur(img.copy(), dstGaus, Size(kernel_length, kernel_length), 0, 0);
    #img = cv2.medianBlur(img.copy(), dstMed, kernel_length);
    #img = cv2.bilateralFilter(img.copy(), dstBila, kernel_length, kernel_length*2, kernel_length/2);
    gray = cv2.cvtColor(img.copy(), cv2.COLOR_BGR2GRAY)
    thresh = cv2.threshold(gray.copy(), 125, 255, cv2.THRESH_BINARY_INV | cv2.THRESH_OTSU)[1]
    edges = cv2.Canny(gray.copy(), 10, 250, apertureSize=7)
    (contours, hier) = cv2.findContours(thresh.copy(), cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
    return contours

# Get overall bounding box coords. (minx, miny, maxx, maxy)
def get_boundingcoords(contours):
    minx = miny = 999999
    maxx = maxy = 0
    for c in contours:
        if minx > min(c[:,0][:,0]):
            minx = min(c[:,0][:,0])
        if miny > min(c[:,0][:,1]):
            miny = min(c[:,0][:,1])
        if maxx < max(c[:,0][:,0]):
            maxx = max(c[:,0][:,0])
        if maxy < max(c[:,0][:,1]):
            maxy = max(c[:,0][:,1])
    return (minx, miny, maxx, maxy)

# Get a new bigger box coords from the given params.
def get_expandedcoords(coords, maxsize, newsize):
    print(coords, maxsize, newsize) if DEBUG else None

    # Get params.
    minx, miny, maxx, maxy = coords
    maxwidth, maxheight = maxsize
    width, height = newsize
    origwidth, origheight = (maxx - minx), (maxy - miny)

    # Get width/height diff.
    widthdiff = abs(origwidth - width)
    heightdiff = abs(origheight - height)

    # Get center point.
    centerx = (maxx - minx)//2
    centery = (maxy - miny)//2

    # Get center diff.
    centerdiffx = abs(centerx - width//2)
    centerdiffy = abs(centery - height//2)

    # Get new upper left.
    ulx = minx - centerdiffx
    uly = miny - centerdiffy

    # Fix negatives.
    ulx = 0 if ulx < 0 else ulx
    uly = 0 if uly < 0 else uly

    # Get new lower right.
    lrx = ulx + width
    lry = uly + height

    print(ulx, uly, lrx, lry) if DEBUG else None
    return (ulx, uly, lrx, lry)

################################################################################

# Check params.
if len(sys.argv) != 4:
    print("Usage: {} <rootdir> <inputdir> <outputdir>".format(__file__.split('/')[-1]))
    sys.exit(0)

rootdir = sys.argv[1]
inputdir = sys.argv[2]
outputdir = sys.argv[3]

pagewidth = 3000
pageheight = 4900

maxwidth = maxheight = 0
for filepath in sorted(glob("{}/{}/*.[Jj][Pp][Gg]".format(rootdir, inputdir))):
    filename = filepath.split('/')[-1]

    # Set cropsize and exceptions.
    cropsize = (3160, 5150)
    topexceptions = [ "none" ]
    leftexceptions = [ "none" ]
    rightexceptions = [ "none" ]

    ## Make Mishle exceptions.
    #leftexceptions = [ "014", "032" ]
    #rightexceptions = [ "001", "015", "017", "019", "021", "023", "031", "035", "037" ]

    ## Make Bereshit exceptions.
    #topexceptions = [ "005" ]
    #leftexceptions = [ "035" ]

    ## Make Shemot exceptions.
    #rightexceptions = [ "061" ]

    # Make Vayyiqra exceptions.
    #rightexceptions = [ "008", "022", "026", "032" ]
    #topexceptions = [ "021", "023", "035", "037", "039", "041", "045" ]

    # Make Bemidbar exceptions.
    #rightexceptions = [ "004", "008", "014", "026", "028", "066" ]

    # Make Devarim exceptions.
    rightexceptions = [ "009", "014" ]

    # Only process exceptions.
    if filename not in ["devarim0{}.jpg".format(x) for x in rightexceptions]:
        continue

    if reduce((lambda x, y: x or y), list(map(lambda x: x in filename, topexceptions))):
        upperleft = (170, 150)
    elif reduce((lambda x, y: x or y), list(map(lambda x: x in filename, leftexceptions))):
        upperleft = (120, 110)
    elif reduce((lambda x, y: x or y), list(map(lambda x: x in filename, rightexceptions))):
        upperleft = (320, 110)
    else:
        upperleft = (170, 110)

    # Read the file, crop and get rotation angle.
    img = cv2.imread(filepath)
    cropped = crop_image(img, upperleft, cropsize)
    contours = get_contours(cropped)
    lines = get_longcontours(contours)
    angle = get_rotation_angle(lines)

    # Rotate by the opposite angle.
    rotated = rotate_image(cropped.copy(), -angle)

    # Get bounding box and expand to final size.
    contours = get_contours_blurred(rotated)
    boundingcoords = get_boundingcoords(contours)
    expandedcoords = get_expandedcoords(boundingcoords, cropsize, (pagewidth, pageheight))
    ulx, uly, lrx, lry = expandedcoords
    final = crop_image(rotated, (ulx, uly), (pagewidth, pageheight))

    #rotated = cv2.rectangle(rotated.copy(), ulx, uly, (255, 0, 0))

    print(filename, angle, ulx, uly, lrx, lry)

    x = Image.fromarray(final)
    x.save("{}/{}/{}".format(rootdir, outputdir, filename))

    #maxwidth = width if width > maxwidth else maxwidth
    #maxheight = height if height > maxheight else maxheight

    #wc = cv2.drawContours(cropped.copy(), lines, -1, (255, 0, 0), 7)
    #x = Image.fromarray(wc)
    #x.save("{}/rotato/{}".format(rootdir, filename))

#print("Max width height: ", maxwidth, maxheight) if DEBUG else None

