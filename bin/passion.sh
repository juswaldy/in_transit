#!/bin/bash

# Reconstruct original mp4 video only.
#ffmpeg -framerate 23.972036 -i original/%05d.jpg -c:v h264_nvenc original.mp4

# Figure out length and framerate.
#ffmpeg -i original.mp4 2>&1 | grep Duration
# Duration: 00:04:50.38, start: 0.000000, bitrate: 1931 kb/s
# 290.38 seconds
# 6961 frames

vid=passion
rootfolder=/home/jus/notebook/jus/styletransfer/vids/${vid}
originalfolder=${rootfolder}/original
stylefolder=${rootfolder}/style
stagingfolder=${rootfolder}/staging
finalfolder=${rootfolder}/final

passionfolder=/home/jus/notebook/jus/styletransfer/vids/passion

copy() {
	folderfrom=$1
	folderto=$2
	framefrom=$3
	frameto=$4
	for i in `seq $framefrom $frameto`; do
		f=`printf "%05d.jpg" $i`
		echo $f
		cp $folderfrom/$f $folderto/$f
	done
}

move() {
	folderfrom=$1
	folderto=$2
	framefrom=$3
	frameto=$4
	offset=$5
	for i in `seq $framefrom $frameto`; do
		f=`printf "%05d.jpg" $i`
		g=`printf "%05d.jpg" $((i+$offset))`
		echo $f
		mv $folderfrom/$f $folderto/$g
	done
}

################################################################################

# Get cropped frames.
ffmpeg -i ${rootfolder}/Beautiful\ Passion\ of\ the\ Christ\ montage\ cut\ to\ inspired\ music-GH-bY-U014M.mp4 -filter:v "crop=1280:532:0:90" -q:v 1 ${originalfolder}/%05d.jpg

# Get m4a audio.
ffmpeg -i ${rootfolder}/Beautiful\ Passion\ of\ the\ Christ\ montage\ cut\ to\ inspired\ music-GH-bY-U014M.mp4 -vn -acodec copy ${rootfolder}/${vid}.m4a

# Reconstruct original mp4 video only.
ffmpeg -framerate 23.972036 -i ${originalfolder}/%05d.jpg -c:v h264_nvenc ${rootfolder}/original.mp4
