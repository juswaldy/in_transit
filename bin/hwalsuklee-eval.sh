#!/bin/bash
modeldir=/home/jus/github/tensorflow-fast-style-transfer
rootdir=/home/jus/notebook/jus/styletransfer
gpu=$1
style=$2
contentfolder=$3
outputfolder=$4
framefrom=$5
frameto=$6

stylemodel=${rootdir}/hwalsuklee/model/${style}/final.ckpt
mkdir -p $outputfolder

python $modeldir/eval.py --gpu $gpu --style_model ${stylemodel} --contentfolder ${contentfolder} --outputfolder ${outputfolder} --framefrom $framefrom --frameto $frameto

