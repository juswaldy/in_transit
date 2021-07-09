#!/bin/bash

theme=$1
name=$2
id=$3
action=$4

# Default is make frames, scene detect, and then make thumbnail html.
if [ -z $action ]; then
	action=all
fi

if [ -z $id ]; then
	id=$name
fi

# Setup.
rootfolder=/home/jus/notebook/jus/styletransfer/vids/${theme}/${name}
originalfolder=${rootfolder}/original
mkdir -p ${originalfolder}

pushd ${rootfolder}

################################################################################
get() {

	# Get from youtube.
	youtube-dl -f 'bestvideo[ext=mp4],bestaudio[ext=m4a]/best[ext=mp4]/best' -o "$name.%(id)s.%(ext)s" -- $id
}
fps() {
	# Get fps.
	#fps=`ffmpeg -i ${rootfolder}/*$name*.mp4 2>&1 | grep Stream.*fps | sed "s/.*, \([^,]*\) fps,.*/\1/"`
	framerate=`ffprobe -v 0 -of csv=p=0 -select_streams v:0 -show_entries stream=r_frame_rate ${rootfolder}/*$name*.mp4`
	fps=`echo "scale=40;$framerate" | bc`
	echo "${fps} fps"
}
frame() {
	thevideo=`ls *$id*.mp4`

	# Make original frames.
	ffmpeg -codec:v h264_cuvid -i ${thevideo} -q:v 1 ${originalfolder}/%07d.jpg

	# For MOV.
	#ffmpeg -i ${thevideo} -qscale 0 ${originalfolder}/%07d.jpg
}
scene() {
	# Detect scenes.
	# scenedetect -i ${rootfolder}/*$id*.mp4 --csv-output ${rootfolder}/$id.scenes.csv -d content -si -df 4 # older version.
	# scenedetect -i ${rootfolder}/*$id*.mp4 detect-content -t 20 -m 40 list-scenes
	scenedetect -i ${rootfolder}/*$id*.mp4 detect-content list-scenes

	# Clean up.
	rm -f ${rootfolder}/*.jpg
}
thumb() {
	# Get fps.
	fps
	# Make thumbnails of scenes.
	# thumb.py --id "$id" --inputfile ${rootfolder}/$id.scenes.csv --outputframes ${rootfolder}/$id.frames.csv --outputthumbs ${rootfolder}/$id.thumb.html --fps $fps
	thumb.py --inputfile ${rootfolder}/${name}*-Scenes.csv --outputframes ${rootfolder}/$name.frames.csv --outputthumbs ${rootfolder}/$name.thumb.html --fps $fps
}
audio() {
	ffmpeg -i ${rootfolder}/*$id*.mp4 -vn -c:a copy $id.m4a
}
audiovideo() {
	inputfolder=$1
	outputfile=$2
	internal=$3

	fps
	rm -f $rootfolder/x.mp4
	if [ -z $internal ]; then ffmpeg -framerate $fps -i ${inputfolder}/%07d_${name}.jpg -c:v h264_nvenc ${rootfolder}/x.mp4
	else ffmpeg -framerate $fps -i ${inputfolder}/%07d.jpg -c:v h264_nvenc ${rootfolder}/x.mp4; fi
	ffmpeg -i ${rootfolder}/x.mp4 -i ${rootfolder}/${name}*.m4a -map 0 -map 1 -c copy -shortest ${rootfolder}/${outputfile}
	rm -f $rootfolder/x.mp4
}
beats() {
	# Get fps.
	fps

	# Make beats folder and copy original frames into it.
	beatsfolder=$rootfolder/beats
	mkdir -p $beatsfolder
	cp $originalfolder/*.jpg $beatsfolder

	# Generate beats images.
	showbeat.py --inputfolder $originalfolder --outputfolder $beatsfolder --fps $fps

	# Make beats video.
	audiovideo $beatsfolder beats.mp4 internal
}
stamp() {
	# Get fps.
	fps

	# Make frame folder.
	framefolder=${rootfolder}/frame
	mkdir -p ${framefolder}

	# Stamp with frame number and save in frame folder.
	stampimage.py --stampinfo filename --inputfolder $originalfolder --outputfolder $framefolder --sourceimage original

	# Make frame video.
	audiovideo $framefolder frame.mp4 internal
}
################################################################################


################################################################################
# Get original video from youtube and process.
################################################################################
if [ $action == "get" ]; then
	get

################################################################################
# Get fps.
################################################################################
elif [ $action == "fps" ]; then
	#ffmpeg -i ${rootfolder}/$name*.mp4 2>&1 | grep Stream | sed "s/.*, \([^,]*\) fps,.*/\1/"
	fps

################################################################################
# Stamp frame numbers.
################################################################################
elif [ $action == "stamp" ]; then
	stamp

################################################################################
# Make frames.
################################################################################
elif [ $action == "frame" ]; then
	frame

################################################################################
# Detect scenes.
################################################################################
elif [ $action == "scene" ]; then
	scene

################################################################################
# Make scene thumbnail html.
################################################################################
elif [ $action == "thumb" ]; then
	thumb

################################################################################
# Get from youtube, make frames, detect scenes, make scene thumbnail html, stamp with frame nums.
################################################################################
elif [ $action == "all" ]; then
	get
	frame
	scene
	thumb
	stamp

################################################################################
# Get from youtube, make frames, detect scenes, and make scene thumbnail html.
################################################################################
elif [ $action == "getframescenethumb" ]; then
	get
	frame
	scene
	thumb

################################################################################
# Make original frames, detect scenes, and make scene thumbnail html.
################################################################################
elif [ $action == "framescenethumb" ]; then
	frame
	scene
	thumb

################################################################################
# Get m4a audio.
################################################################################
elif [ $action == "audio" ]; then
	audio

################################################################################
# Make video with audio.
################################################################################
elif [ $action == "audiovideo" ]; then
	inputfolder=$5
	outputfile=$6
	internal=$7
	audiovideo $inputfolder $outputfile $internal

################################################################################
# Show beats.
################################################################################
elif [ $action == "beats" ]; then
	beats

################################################################################
# Replace original pics with 0.jpg.
################################################################################
elif [ $action == "empty" ]; then
	for f in ${rootfolder}/original/*.jpg; do
		echo cp /home/jus/notebook/jus/styletransfer/pics/0.jpg $f
		cp /home/jus/notebook/jus/styletransfer/pics/0.jpg $f
	done

################################################################################
# Combine and shrink to given height.
################################################################################
elif [ $action == "shrink" ]; then
	height=$5
	fps
	#ffmpeg -y -i ${name}*.mp4 -vf scale=-1:$height;fps=fps=20 -filter:v fps=fps=20 -c:v h264_nvenc x.mp4
	ffmpeg -y -i ${name}*.mp4 -vf scale=-1:$height -c:v h264_nvenc x.mp4
	#ffmpeg -y -i x.mp4 -i ${name}*.m4a -map 0 -map 1 -c copy -shortest -c:v h264_nvenc ${name}.mp4
	rm x.mp4

################################################################################
# Make styled video.
################################################################################
elif [ $action == "styled" ]; then
	ckpt_nmbr=$5
	mkdir -p $rootfolder/style
	fps
	if [ -z $ckpt_nmbr ]; then
		for ckpt_nmbr in `seq 150000 15000 300000`; do
			ffmpeg -y -framerate $fps -i /mnt/d2/renders/$theme/$name/$id/$ckpt_nmbr/%07d_${id}.jpg -c:v h264_nvenc $rootfolder/style/$id.mp4
			ffmpeg -y -i $rootfolder/style/$id.mp4 -i $rootfolder/$name*.m4a -map 0 -map 1 -c copy -shortest $rootfolder/$id.$ckpt_nmbr.mp4
		done
	elif [ "$ckpt_nmbr" == "gju" ]; then # gatys-johnson-ulyanov
		outfile=`echo $id | sed 's/\//_/'`
		ffmpeg -framerate $fps -i /mnt/d2/renders/$theme/$name/$id/%07d.jpg -c:v h264_nvenc $rootfolder/style/$outfile.mp4
		ffmpeg -y -i $rootfolder/style/$outfile.mp4 -i $rootfolder/$name*.m4a -map 0 -map 1 -c copy -shortest $rootfolder/gju.$outfile.mp4
	elif [ -z `echo $ckpt_nmbr | sed 's/.*\(random\|sequence\).*//'` ]; then # mixed styles
		ffmpeg -y -framerate $fps -i /mnt/d2/renders/$theme/$name/$id/$ckpt_nmbr/%07d.jpg -c:v h264_nvenc $rootfolder/style/$id.mp4
		ffmpeg -y -i $rootfolder/style/$id.mp4 -i $rootfolder/$name*.m4a -map 0 -map 1 -c copy -shortest $rootfolder/$id.$ckpt_nmbr.mp4
	else
		if [ $ckpt_nmbr == "last" ]; then
			ckpt_nmbr=`ls -1 /mnt/d2/renders/$theme/$name/$id | tail -1`
		fi
		ffmpeg -y -framerate $fps -i /mnt/d2/renders/$theme/$name/$id/$ckpt_nmbr/%07d_${id}.jpg -c:v h264_nvenc $rootfolder/style/$id.mp4
		ffmpeg -y -i $rootfolder/style/$id.mp4 -i $rootfolder/$name*.m4a -map 0 -map 1 -c copy -shortest $rootfolder/$id.$ckpt_nmbr.mp4
	fi

################################################################################
fi

popd
