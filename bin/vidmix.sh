#!/bin/bash
i=0
contentvid=zoolook
subfolder=style/jus/sheepface.jpg
fps=25

modeldir=/home/jus/github/tensorflow-fast-style-transfer
rootdir=/home/jus/notebook/jus/styletransfer

rootfolder=${rootdir}/vids/${contentvid}
contentfolder=${rootfolder}/${subfolder}
mixfolder=${rootfolder}/mix

pushd $modeldir
for pair in "maya/wiggles_final.jpg common/la_muse.jpg"; do
	for style in $pair; do
		stylemodel=${rootdir}/hwalsuklee/model/${style}/final.ckpt
		outputfolder=${rootfolder}/mix/${style}
		mkdir -p $outputfolder
		if (($i % 2 == 0)); then
			python vids.py --gpu $i --style_model ${stylemodel} --content ${contentfolder} --output ${outputfolder} &
		       	i=1
		else
			python vids.py --gpu $i --style_model ${stylemodel} --content ${contentfolder} --output ${outputfolder}
		       	i=0
		fi
	done
done
popd

pushd $mixfolder
for pair in "maya/wiggles_final.jpg common/la_muse.jpg"; do
	for style in $pair; do
		rm x.mp4
		result=`echo $style|sed 's/\//./'`
		ffmpeg -framerate $fps -i $style/%05d.jpg -c:v h264_nvenc x.mp4
		ffmpeg -i x.mp4 -i $rootfolder/$contentvid*.m4a -map 0 -map 1 -c copy -shortest $result.mp4
	done
done
popd
