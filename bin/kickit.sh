#!/bin/bash

step=$1

################################################################################

vid=kickit
fps=29.969574
width=640
height=426
#ffmpegcrop="crop=$width:$height:0:28"
styletransfer=/home/jus/notebook/jus/styletransfer

source ~/bin/vid_funcs.sh

################################################################################

pushd ${rootfolder}

################################################################################
# Get original video from youtube and process.
################################################################################
if [ $step == "get" ]; then
	# Get youtube video.
	id=O3pyCGnZzYA
	#youtube-dl -f 'bestvideo[ext=mp4],bestaudio[ext=m4a]/best[ext=mp4]/best' -o "$vid.%(id)s.%(ext)s" -- $id
	youtubevideo=`ls *$id*.mp4`

	# Get frames.
	if [ -z $ffmpegcrop ]; then
		ffmpeg -i ${rootfolder}/${youtubevideo} -q:v 1 ${originalfolder}/%05d.jpg
	else
		ffmpeg -i ${rootfolder}/${youtubevideo} -filter:v "$ffmpegcrop" -q:v 1 ${originalfolder}/%05d.jpg
	fi

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
	#copy $stylefolder/soccer $mixfolder 156 475 -155
	#copy $stylefolder/soccer $mixfolder 455 475 -134
	#copy $stylefolder/soccer $mixfolder 469 475 -128
	##copy $rootfolder/enlarged $mixfolder 348 948
	#copy $stylefolder/soccer2018 $mixfolder 2064 2137 -1115
	#copy $stylefolder/soccer2018 $mixfolder 12606 12754 -11583

	ffmpeg -framerate $fps -i $mixfolder/%07d.jpg -c:v h264_nvenc $rootfolder/x.mp4
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

