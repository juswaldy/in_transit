#!/bin/bash

mode=$1
modelfolder=/home/jus/github/pix2pix-tensorflow

pushd $modelfolder
if [[ $mode == "train" ]]; then
	python pix2pix.py \
	  --mode train \
	  --output_dir facades_train \
	  --max_epochs 400 \
	  --input_dir facades/train \
	  --which_direction BtoA
else
	python pix2pix.py \
	  --mode test \
	  --output_dir facades_test \
	  --input_dir facades/val \
	  --checkpoint facades_train
fi
popd

