#!/bin/bash

rootfolder=/home/jus/github/adaptive-style-transfer
inputfolder=$rootfolder/input
outputroot=$rootfolder/output
modelroot=./models
ptcd=/home/jus/datasets/data_large
#ptcd=/home/jus/datasets/WIDER_train

step=$1

pushd $rootfolder

################################################################################
# Training.
################################################################################
if [ $step == "train" ]; then

	model_name=$2
	imagesize=$3
	max=$4
	lr=$5
	gpu=$6

	#max=300000
	#lr=0.0002
	dlw=1.0
	tlw=100
	flw=100
	dsr=0.8
	batch_size=1
	CUDA_VISIBLE_DEVICES=$gpu python main.py \
		 --model_name=${model_name} \
		 --batch_size=$batch_size \
		 --total_steps=$max \
		 --phase=train \
		 --image_size=$imagesize \
		 --lr=$lr \
		 --dlw=$dlw \
		 --tlw=$tlw \
		 --flw=$flw \
		 --dsr=$dsr \
		 --ptcd=$ptcd \
		 --ptad=$rootfolder/data/$model_name

################################################################################
# Training with stops
################################################################################
elif [ $step == "trainwithstops" ]; then

	currentmodel=maya_liney
	sleepseconds=1
	max=300000
	nextstop=1000
	while [ $nextstop -le $max ]; do
		CUDA_VISIBLE_DEVICES=1 python main.py \
			 --model_name=model_${currentmodel} \
			 --batch_size=1 \
			 --total_steps=$nextstop \
			 --phase=train \
			 --image_size=768 \
			 --lr=0.0002 \
			 --dsr=0.8 \
			 --ptcd=$ptcd \
			 --ptad=$rootfolder/data/$currentmodel
		let "nextstop = nextstop + 1000"
		sleep $sleepseconds
	done

################################################################################
# Eval.
################################################################################
elif [ $step == "eval" ]; then

	name=$2
	model_name=$3
	image_size=$4 # 1280 recommended
	gpu=$5
	model_root=$6
	ckpt_nmbr=$7
	inputfolder=$8
	outputfolder=$9

	modelroot=$model_root

	if [ -z $inputfolder ]; then
		inputfolder=/home/jus/notebook/jus/styletransfer/vids/$name/original
	fi
	if [ -z $outputfolder ]; then
		outputfolder=/mnt/d2/renders/$name/$model_name
	fi

	if [ -z $ckpt_nmbr ]; then
		from=150000
		to=300000
		step=15000

		for ckpt_nmbr in `seq $from $step $to`; do
			CUDA_VISIBLE_DEVICES=$gpu python main.py \
				--model_root_dir=$modelroot \
				--model_name=$model_name \
				--phase=inference \
				--image_size=$image_size \
				--ii_dir $inputfolder \
				--save_dir=$outputfolder \
				--ckpt_nmbr=$ckpt_nmbr
			mkdir -p $outputfolder/$ckpt_nmbr
			mv $outputfolder/*.jpg $outputfolder/$ckpt_nmbr
		done
	else
		if [ $ckpt_nmbr == "last" ]; then
			lastckpt=`find $modelroot/${model_name} -type f -name '*.meta' -printf '%T+%p\n' | sort -r | head -1`
			ckpt_nmbr=`echo $lastckpt | sed 's/.*-\([0-9]\+\).meta/\1/'`
		fi
		CUDA_VISIBLE_DEVICES=$gpu python main.py \
			--model_root_dir=$modelroot \
			--model_name=$model_name \
			--phase=inference \
			--image_size=$image_size \
			--ii_dir $inputfolder \
			--save_dir=$outputfolder \
			--ckpt_nmbr=$ckpt_nmbr
		mkdir -p $outputfolder/$ckpt_nmbr
		mv $outputfolder/*.jpg $outputfolder/$ckpt_nmbr
	fi

################################################################################
# Eval frames.
################################################################################
elif [ $step == "evalframes" ]; then

	name=$2
	frame_from=$3
	frame_to=$4
	model_root=$5
	model_name=$6
	image_size=$7 # 1280 recommended
	gpu=$8
	ckpt_nmbr=$9

	sourcefolder=/home/jus/notebook/jus/styletransfer/vids/$name/original
	inputfolder=/home/jus/notebook/jus/styletransfer/vids/$name/staging
	outputfolder=/mnt/d2/renders/$name/heidelberg

	mkdir -p $inputfolder
	rm -rf $inputfolder/*
	for n in `seq $frame_from 1 $frame_to`; do
		filename=`printf "%07d.jpg" $n`
		cp $sourcefolder/$filename $inputfolder
	done

	if [ $ckpt_nmbr == "last" ]; then
		lastckpt=`find $model_root/${model_name} -type f -name '*.meta' -printf '%T+%p\n' | sort -r | head -1`
		ckpt_nmbr=`echo $lastckpt | sed 's/.*-\([0-9]\+\).meta/\1/'`
	fi
	echo CUDA_VISIBLE_DEVICES=$gpu python main.py \
		--model_root_dir=$model_root \
		--model_name=$model_name \
		--phase=inference \
		--image_size=$image_size \
		--ii_dir $inputfolder \
		--save_dir=$outputfolder \
		--ckpt_nmbr=$ckpt_nmbr
	CUDA_VISIBLE_DEVICES=$gpu python main.py \
		--model_root_dir=$model_root \
		--model_name=$model_name \
		--phase=inference \
		--image_size=$image_size \
		--ii_dir $inputfolder \
		--save_dir=$outputfolder \
		--ckpt_nmbr=$ckpt_nmbr

################################################################################
# Eval single folder.
################################################################################
elif [ $step == "evalsingle" ]; then

	name=$2
	model_name=$3
	image_size=$4 # 1280 recommended
	gpu=$5
	model_root=$6
	inputfolder=$7
	ckpt_nmbr=$8

	modelroot=./$model_root

	outputfolder=$outputroot/$name

	mkdir -p $outputfolder

	if [ -z $ckpt_nmbr ]; then
		lastckpt=`find $modelroot/${model_name} -type f -name '*.meta' -printf '%T+%p\n' | sort -r | head -1`
		ckpt_nmbr=`echo $lastckpt | sed 's/.*-\([0-9]\+\).meta/\1/'`
	fi

	CUDA_VISIBLE_DEVICES=$gpu python main.py \
		--model_root_dir=$modelroot \
		--model_name=$model_name \
		--phase=inference \
		--image_size=$image_size \
		--ii_dir $inputfolder \
		--save_dir=$outputfolder \
		--ckpt_nmbr=$ckpt_nmbr

################################################################################
# Eval monet 150.
################################################################################
elif [ $step == "monet" ]; then

	name=$2
	gpu=$3
	model=monet
	#image_size=1024
	for image_size in `seq 800 50 3000`; do
	#for size in s m l o; do
		for size in s; do
			rm input/*
			cp resized/$name-$size.jpg input
			outputfolder=$outputroot/seattle
			CUDA_VISIBLE_DEVICES=$gpu python main.py \
				--model_root_dir=$modelroot \
				--model_name=model_$model \
				--phase=inference \
				--image_size=$image_size \
				--ii_dir $inputfolder \
				--save_dir=$outputfolder
			mv $outputfolder/${name}-${size}_${model}.jpg $outputroot/z/${name}-`printf '%04d' ${image_size}`.jpg
		done
	done

	pushd $outputroot
	echo '<img src="../seattle/'$name'.jpg" width="500" />' > z.html
	ls -1t z | sed 's/\(.*\)/<img src="z\/\1" width="500" \/>/' >> z.html
	popd

################################################################################
# Video.
################################################################################
elif [ $step == "vids" ]; then

	gpu=1
	fps=29.97
	size=720
	model=picasso

	rootdir=/home/jus/notebook/jus/styletransfer/vids/rock/ladylike
	inputfolder=$rootdir/original
	outputfolder=$rootdir/style/picasso
	mkdir -p $outputfolder
	CUDA_VISIBLE_DEVICES=$gpu python main.py --model_name=model_$model --phase=inference --image_size=$size --ii_dir $inputfolder --save_dir=$outputfolder
	ffmpeg -framerate $fps -i $outputfolder/%07d_$model.jpg -c:v h264_nvenc $rootdir/style/$model.mp4

################################################################################
# Show.
################################################################################
elif [ $step == "show" ]; then

	rootdir=/mnt/d1/models/styletransfer/sanakoyeu-kotovenko/vacation
	imgwidth=640

	pushd $rootdir
	for dir in flw100_tlw100_dsr0.8_dlw0.5; do
		echo $dir
		for model in $dir/*; do
			echo $model
			ls -t1 $model/output/*.jpg | sed "s/\(.*\)/<img src='\1' width='$imgwidth'\/>/" >> $dir.html
		done
	done
	popd

	#find output/seattle -name $2*.jpg | sort | sed 's/\(.*\)/<img src="\1" width="640"\/>/' > show.html

################################################################################
# Unknown.
################################################################################
else
	echo "Available tasks: train | trainwithstops | eval | vids | show"
fi
################################################################################

popd


#for model in cezanne el-greco gauguin kandinsky kirchner monet morisot munch peploe picasso pollock roerich van-gogh; do
#	outputfolder=$outputroot/seattle
#	mkdir -p $outputfolder
##	CUDA_VISIBLE_DEVICES=1 python main.py --model_name=model_${model} --phase=inference --image_size=1280 --ii_dir $inputfolder --save_dir=$outputfolder
#	cd $outputroot
#	ls -1 seattle/*_$model.jpg | sed 's/^/<img src="/;s/$/" width="640"\/>/' > seattle_$model.html
#done

