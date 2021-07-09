#!/bin/bash

theme=$1
name=$2
style=$3
gpu=$4

gpu_fraction=1.0

modeldir=/home/jus/github/tensorflow-fast-style-transfer
rootdir=/home/jus/notebook/jus/styletransfer

rootfolder=$rootdir/vids/$theme/$name
stylemodel=/mnt/d1/models/styletransfer/gatys-johnson-ulyanov/${style}/final.ckpt
inputfolder=$rootfolder/resized
outputfolder=/mnt/d2/renders/$theme/$name/$style

mkdir -p $outputfolder
python ${modeldir}/vids.py --gpu $gpu --gpu_fraction $gpu_fraction --style_model ${stylemodel} --content ${inputfolder} --output ${outputfolder}

#pushd $outputfolder/..
#rm $allfolder/x.mp4
#filename=`basename ${style}`
#ffmpeg -framerate $fps -i $filename/%05d.jpg -c:v h264_nvenc $allfolder/x.mp4
#ffmpeg -i $allfolder/x.mp4 -i $rootfolder/$vid*.m4a -map 0 -map 1 -c copy -shortest $allfolder/$filename.mp4
#popd
