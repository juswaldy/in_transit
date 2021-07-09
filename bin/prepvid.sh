#!/bin/bash

vid=isheworthy
rootfolder=/home/jus/notebook/jus/styletransfer/vids/${vid}
originalfolder=${rootfolder}/original
stylefolder=${rootfolder}/style

pushd ${rootfolder}

for vid in other/dawes.milllakepark.jpg.mp4 other/lecoy.trypophobia.jpg.mp4 other/tremblay-Whats-he-building-in-there.jpg.mp4 other/ygartua.portofino1-small.jpg.mp4 other/ygartua.sunmask-small.jpg.mp4 skies/kyle_1-small.jpg.mp4 skies/samantha-smaller.jpg.mp4; do
	vidname=`echo $vid|sed 's/\//./'`
	ffmpeg -i $stylefolder/$vid -i $rootfolder/isheworthy.m4a -map 0 -map 1 -c copy -shortest $rootfolder/all/$vidname
done

popd

