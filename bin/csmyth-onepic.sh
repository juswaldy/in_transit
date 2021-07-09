#!/bin/bash

codedir=/home/jus/github/neural-style-tf
rootdir=/home/jus/notebook/jus/styletransfer
content_dir=${rootdir}/pics/onecontent
style_dir=${rootdir}/pics/onestyle
img_output_dir=${rootdir}/results/csmyth
device='/gpu:1'

#allstyles_dir=${rootdir}/pics
allstyles_dir=/home/jus/github/adaptive-style-transfer/data/monet_water-lilies-1914

content_weight=1e0 # 5e0
style_weight=5e11 # 1e4

pushd $codedir

for style in $allstyles_dir/0198.jpg; do # *.jpg; do
	# Clear style_dir and copy style into it.
	rm $style_dir/*
	cp $style $style_dir

	for content in 108 110 130 218 303 310 320 330 334; do
		content_file=$content.jpg
		img_output_dir=${rootdir}/results/csmyth/monet
		mkdir -p $img_output_dir
		rm $content_dir/*
		cp $rootdir/heidelberg/seattle/$content_file $content_dir

		# Stylize.
		python csmyth.py \
		  --content_img_dir "${content_dir}" \
		  --style_imgs_dir "${style_dir}" \
		  --img_output_dir "${img_output_dir}" \
		  --content_weight $content_weight \
		  --style_weight $style_weight \
		  --device "${device}" \
		  --verbose;
	done
done

popd

## Stylize.
#python csmyth.py \
#  --content_img_dir "${content_dir}" \
#  --style_imgs_dir "${style_dir}" \
#  --img_output_dir "${img_output_dir}" \
#  --content_weight $content_weight \
#  --style_weight $style_weight \
#  --device "${device}" \
#  --verbose;
