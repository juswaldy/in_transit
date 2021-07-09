#!/bin/bash

step=$1

################################################################################

vid=seeingyou
fps=23.972375
width=640
height=426
#ffmpegcrop="crop=1280:532:0:95"
styletransfer=/home/jus/notebook/jus/styletransfer

source ~/bin/vid_funcs.sh

################################################################################

pushd ${rootfolder}

################################################################################
# Get original video from youtube and process.
################################################################################
if [ $step == "get" ]; then
	# Get youtube video.
	for id in tbm-cVu-LRo s_xcZfUmhys; do
		youtube-dl -f 'bestvideo[ext=mp4],bestaudio[ext=m4a]/best[ext=mp4]/best' -o "%(title)s.%(id)s.%(ext)s" $id
		youtubevideo=`ls *$id*.mp4`

		## Get frames.
		#if [ -z $ffmpegcrop ]; then
		#	ffmpeg -i ${rootfolder}/${youtubevideo} -q:v 1 ${originalfolder}/%05d.jpg
		#else
		#	ffmpeg -i ${rootfolder}/${youtubefile} -filter:v "$ffmpegcrop" -q:v 1 ${originalfolder}/%05d.jpg
		#fi

		## Reconstruct original with frame numbers.
		#makeframes ${originalfolder}
	done

################################################################################
# Get fps.
################################################################################
elif [ $step == "fps" ]; then
	ffmpeg -i ${rootfolder}/$vid*.mp4 2>&1

################################################################################
# Stamp frame numbers and make video.
################################################################################
elif [ $step == "frame" ]; then
	makeframes ${originalfolder}
	showbeat.py --inputfolder $framefolder --outputfolder $framefolder --fps $fps
	makeframevideo $fps

################################################################################
# Mix.
################################################################################
elif [ $step == "mix" ]; then
	rm -f x.mp4 mix.mp4
	rm -f $mixfolder/*
	copyscenes.py --scenes_csv $rootfolder/scenes.csv --target_folder $mixfolder
	ffmpeg -framerate 29.97 -i $mixfolder/%07d.jpg -c:v h264_nvenc $rootfolder/x.mp4
	ffmpeg -i $rootfolder/x.mp4 -i $rootfolder/$vid*.m4a -map 0 -map 1 -c copy -shortest $rootfolder/mix.mp4

################################################################################
# Add style to the mix.
################################################################################
elif [ $step == "style" ]; then
	rm $stagingfolder/*
	#style 1 300 mix
	#style 301 450 mix style/common/starry.jpg

	#mv $stagingfolder/* $finalfolder
	#rm x.mp4 final.mp4
	#ffmpeg -framerate $fps -i $finalfolder/%05d.jpg -c:v h264_nvenc $rootfolder/x.mp4
	#ffmpeg -i $rootfolder/x.mp4 -i $rootfolder/$vid*.m4a -map 0 -map 1 -c copy -shortest $rootfolder/final.mp4

################################################################################
# Paste the style on to the content.
################################################################################
elif [ $step == "paste" ]; then
	rm $stagingfolder/*
	#withstyle 1 300 style/vid/isheworthy.jpg
	#withstyle 301 450 style/vid/isheworthy.jpg style/common/starry.jpg

	#rm $withstyle/*
	#mv $stagingfolder/* $withstyle
	#rm x.mp4 withstyle.mp4
	#ffmpeg -framerate $fps -i $withstyle/%05d.jpg -c:v h264_nvenc $rootfolder/x.mp4
	#ffmpeg -i $rootfolder/x.mp4 -i $rootfolder/$vid*.m4a -map 0 -map 1 -c copy -shortest $rootfolder/withstyle.mp4

else
	echo "Unknown option '$step'"
fi

################################################################################

popd

