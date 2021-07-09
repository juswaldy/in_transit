#!/bin/bash
modeldir=/home/jus/github/tensorflow-fast-style-transfer
rootdir=/home/jus/notebook/jus/styletransfer
gpu=$1
style=$2
content_weight=1e1 # 7.5e0
style_weight=5e2 # 5e2
tv_weight=2e2 # 2e2
pushd $modeldir
outputfolder=${rootdir}/hwalsuklee/model/${style}
mkdir -p $outputfolder
python run_train.py --gpu $gpu --style ${rootdir}/style/${style} \
  --output ${outputfolder} \
  --trainDB train2014 \
  --content_weight $content_weight \
  --style_weight $style_weight \
  --tv_weight $tv_weight \
  --vgg_model pre_trained_model
popd
