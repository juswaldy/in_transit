#!/bin/bash

gpuid=$1
style=$2
dreams=$3
layers=$4
network=$5

codedir=/home/jus/github/deepdreamer
fps=20

rootdir=/home/jus/notebook/jus/deepdream/results/kesara

video_basename=`echo $style | sed 's/\//-/g'`
video_path=$rootdir/$video_basename.mp4

################################################################################
## Create dream sequences.
################################################################################
output_path=$rootdir/$style/frames
style_path=/home/jus/notebook/jus/styletransfer/pics/$style

# Ensure output folder.
mkdir -p $output_path

# Run dreamer.
pushd $codedir
python deepdreamer.py --zoom true --scale 0.02 --zoomdirection in --zoomlocation right --gpuid $gpuid --network $network --layers $layers --dreams $dreams --output_path $output_path $style_path
popd

# Make video.
rm -f $video_path
ffmpeg -framerate $fps -i $output_path/%07d.jpg -c:v h264_nvenc $video_path

################################################################################
## Try out all layers.
################################################################################
#
#style_path=/home/jus/notebook/jus/styletransfer/pics/$style
#
#pushd $codedir
#for layer in `grep name deploy_$network.prototxt | cut -d'"' -f2`; do
#	basename=`echo $layer | sed 's/\//./g'`
#	output_path=$rootdir/$style/$network/$basename
#	mkdir -p $output_path
#	python deepdreamer.py --zoom false --gpuid $gpuid --network $network --dreams $dreams --output_path $output_path --layers $layer "$style_path"
#	numfiles=`find $output_path -type f | wc -l`
#	if [[ $numfiles -eq 0 ]]; then
#		rmdir $output_path
#	fi
#done
#popd

################################################################################
## Make html.
################################################################################
#output_file=$network.html
#pushd $rootdir/$style
#printf "<html>\n<body>\n<table width='1800'>\n" > $output_file
#for d in `find $network -type d | sort | cut -d'/' -f2 | grep -ve 'ipynb\|^\.$'`; do
#	printf "<tr><td>$d</td>\n" >> $output_file
#	for n in `seq 0 9`; do
#		printf "<td width='10%%'>" >> $output_file
#		filename=`printf '%07d.jpg' $n`
#		imgsrc=$network/$d/$filename
#		echo $imgsrc
#		printf "<img src='$imgsrc'/>" >> $output_file
#		printf "</td>" >> $output_file
#	done
#	printf "<td>$d</td></tr>\n" >> $output_file
#done
#printf "</table>\n</body>\n</html>\n" >> $output_file
#popd

