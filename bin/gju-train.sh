#!/bin/bash
codedir=/home/jus/github/tensorflow-fast-style-transfer
pushd $codedir

stylefolder=/home/jus/github/adaptive-style-transfer/data/akira

gpu=1
content_weight=1e1 # 7.5e0
style_weight=5e2 # 5e2
tv_weight=2e2 # 2e2

i=1
div=12
for f in $stylefolder/*; do
	if [ $(($i%$div)) -eq 0 ]; then
		stylename=`basename $f`
		echo $stylename
		outputfolder=/mnt/d1/models/styletransfer/gatys-johnson-ulyanov/akira/${stylename}
		mkdir -p $outputfolder
		python run_train.py --gpu $gpu --style ${stylefolder}/${stylename} \
			--output ${outputfolder} \
			--trainDB train2014 \
			--content_weight $content_weight \
			--style_weight $style_weight \
			--tv_weight $tv_weight \
			--vgg_model pre_trained_model

	fi
	let "i++"

done

popd
