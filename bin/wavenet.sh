#!/bin/bash

contentvid=$1
modelfolder=/home/jus/github/wavenet
contentfolder=/home/jus/notebook/jus/styletransfer/vids/$contentvid
m4afile=$contentfolder/$contentvid*.m4a
inputwav=$contentfolder/$contentvid.wav
outputwav=$contentfolder/vocals.wav

pushd $contentfolder
ffmpeg -i $m4afile $inputwav
popd

pushd $modelfolder
python eval.py --inputfile $inputwav --outputfile $outputwav
popd
