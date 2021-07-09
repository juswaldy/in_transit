#!/bin/bash
codedir=/home/jus/github/tensorflow-fast-style-transfer
rootdir=/home/jus/notebook/jus/styletransfer
style=$1
content=$2
outputfile=$3
gpu=$4
pushd $codedir
python run_test.py --content ${content} --style_model ${rootdir}/hwalsuklee/model/${style}/final.ckpt --output $outputfile --gpu $gpu
popd
