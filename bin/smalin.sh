#!/bin/bash

step=$1

# gymnopedie3 - color-triangles - phoneix1
i=0
content=satie-gymnopedie3
rootfolder=/home/jus/music
contentvid=$rootfolder/$content/original
subfolder=$rootfolder/$content/style
musicfile=satie-gymnopedie3.Vue5fk8vWEc.m4a
fps=60

pushd $subfolder

#for pair in "nets/color-simple-small.jpg nets/color-triangles.jpg"; do
#for pair in "nets/color-concentricsquares-small.jpg nets/color-flatcreatures-small.jpg"; do
#for pair in "nets/color-randomswirls.jpg nets/color-threads-small.jpg"; do
#for pair in "common/wave.jpg common/udnie.jpg"; do
#for pair in "maya/wiggles_final.jpg nets/color-flatcreatures.jpg"; do
#for pair in "mira/phoenix1.jpg other/tremblay-Whats-he-building-in-there.jpg"; do
for pair in "nets/color-simple-small.jpg nets/color-triangles.jpg"; do

	################################################################################
	# Generate frames.
	################################################################################
	if [ $step == "frames" ]; then
		# Generate frames.
		for style in $pair; do
			mkdir -p $subfolder/$style

			if (($i % 2 == 0)); then
				hwalsuklee-vids.sh $i $style $contentvid $subfolder/$style $fps &
				i=1
			else
				hwalsuklee-vids.sh $i $style $contentvid $subfolder/$style $fps
				i=0
			fi
		done

	################################################################################
	# Make video.
	################################################################################
	elif [ $step == "video" ]; then
		# Collect into new video.
		for style in $pair; do
			base=`echo $style | cut -d'/' -f2`
			ffmpeg -framerate $fps -i $style/%07d.jpg -c:v h264_nvenc x.mp4
			#ffmpeg -framerate $fps -i $style/%07d.jpg x.mp4
			ffmpeg -i x.mp4 -i ../$musicfile -map 0 -map 1 -c copy -shortest $base.mp4
			rm x.mp4
		done

	fi
done

