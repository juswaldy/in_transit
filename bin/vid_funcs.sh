#!/bin/bash

# Check argument.
if [ -z $step ]; then
	echo "Usage: $0 <get|frame|mix|style|paste>"
	exit
fi

# These variables must be defined in the caller: vid and fps.
rootfolder=${styletransfer}/vids/${vid}
originalfolder=${rootfolder}/original
stylefolder=${rootfolder}/style
mixfolder=${rootfolder}/mix
stagingfolder=${rootfolder}/staging
framefolder=${rootfolder}/frame
finalfolder=${rootfolder}/final
withstyle=${rootfolder}/withstyle

mkdir -p $rootfolder
mkdir -p $originalfolder
mkdir -p $stylefolder
mkdir -p $mixfolder
mkdir -p $stagingfolder
mkdir -p $framefolder
mkdir -p $finalfolder
mkdir -p $withstyle

################################################################################
# Copy the specified frames from one folder to another.
################################################################################
copy() {
	folderfrom=$1
	folderto=$2
	framefrom=$3
	frameto=$4
	offset=$5
	if [ -z $offset ]; then offset=0; fi
	for i in `seq $framefrom $frameto`; do
		f=`printf "%07d.jpg" $i`
		g=`printf "%07d.jpg" $((i+$offset))`
		echo $f - $g
		cp $folderfrom/$f $folderto/$g
	done
}

################################################################################
# Generate a "sine wave" of frame numbers, given the original frames.
################################################################################
backandforth() {
	folderfrom=$1
	folderto=$2
	framefrom=$3
	frameto=$4
	targetframe=$5
	repeat=$6
	first=$framefrom
	last=$frameto
	inc=1
	for i in `seq 1 $repeat`; do
		for j in `seq $first $inc $last`; do
			f=`printf "%07d.jpg" $j`
			g=`printf "%07d.jpg" $targetframe`
			echo $f - $g
			cp $folderfrom/$f $folderto/$g
			let targetframe-=1
			if (($i % 2 == 0)); then first=$framefrom; last=$frameto; inc=1; else first=$frameto; last=$framefrom; inc=-1; fi
		done
	done
}

################################################################################
# Copy style images or transition from one style to another.
################################################################################
style() {
	framefrom=$1
	frameto=$2
	stylefrom=$3
	styleto=$4
	if [ -z $styleto ]; then
		copy $rootfolder/$stylefrom $stagingfolder $framefrom $frameto
	else
		transition.sh isheworthy $stylefrom $styleto $framefrom $frameto
	fi
}

################################################################################
# Paste the style image onto the content image.
################################################################################
withstyle() {
	framefrom=$1
	frameto=$2
	stylefrom=$styletransfer/$3
	if [ -z $4 ]; then
		withstyle.py --framefirst $framefrom --framelast $frameto --contentfolder $finalfolder --stylefrom $stylefrom --outputfolder $stagingfolder
	else
		styleto=$styletransfer/$4
		withstyle.py --framefirst $framefrom --framelast $frameto --contentfolder $finalfolder --stylefrom $stylefrom --styleto $styleto --outputfolder $stagingfolder
	fi
}

################################################################################
# Get frames with numbers.
################################################################################
makeframes() {
	inputfolder=$1
	sourceimage=$2
	if [ -z $sourceimage ]; then
		sourceimage=original
	fi
	stampimage.py --stampinfo filename --inputfolder $inputfolder --outputfolder $framefolder --sourceimage $sourceimage
}

################################################################################
# Get frames with numbers.
################################################################################
makeframevideo() {
	fps=$1
	rm x.mp4 frame.mp4
	ffmpeg -framerate $fps -i $framefolder/%07d.jpg -c:v h264_nvenc $rootfolder/x.mp4
	ffmpeg -i $rootfolder/x.mp4 -i $rootfolder/$vid.*.m4a -map 0 -map 1 -c copy -shortest $rootfolder/frame.mp4
}


################################################################################
# Get fps from video.
################################################################################
getfps() {
	## Figure out length and framerate.
	ffmpeg -i $vid.*.mp4 2>&1 | grep Duration
	# Duration: 00:04:43.95, start: 0.000000, bitrate: 1963 kb/s
	# 283.95 seconds
	# 6807 frames
	# 23.972530 fps
}

