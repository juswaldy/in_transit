#!/bin/bash

musicfolder=/home/jus/notebook/jus/music

action=$1

################################################################################
## Make html for thumbnails.
################################################################################
if [ $action == "thumbhtml" ]; then
	for d in *.jpg; do
		f=$d.html
		echo > $f
		ls $d/*.jpg | sed "s/\(.*\)/\1:<br\/><img src='\1' width='1280'\/><br\/>/" >> $f
	done

################################################################################
## Shuffle and rename as sequences.
################################################################################
elif [ $action == "shuffle" ]; then
	i=1
	sequenced_dir=./sequenced
	rm $sequenced_dir/*
	for f in `find $stamped_dir -type f -name '*.jpg'|shuf`; do
		n=`printf "%07d" $i`
		echo $f $sequenced_dir/$n.jpg
		cp $f $sequenced_dir/$n.jpg
		let "i++"
	done

################################################################################
## Make mp4 from sequenced files.
################################################################################
elif [ $action == "sequenced" ]; then
	ffmpeg -framerate 0.25 -i $sequenced_dir/%07d.jpg -c:v h264_nvenc color.mp4

################################################################################
## csmyth
################################################################################
elif [ $action == "csmyth" ]; then
	rootdir=/home/jus/notebook/jus/styletransfer/results/csmyth
	pushd $rootdir

	content_name=GSITree

	# Bring files into the accompanying folders and rename accordingly.
	for source_dir in "5e0-1e4 1e0-5e11"; do
		for params in "$content_name *.jpg.png  " "${content_name}-original *.jpgoc.png s/color/original/"; do
			target_dir=`echo $params | cut -d' ' -f1`
			file_pattern=`echo $params | cut -d' ' -f2`
			sed_extra=`echo $params | cut -d' ' -f3`
			echo $target_dir
			echo $file_pattern
			echo $sed_extra

			for f in `find $source_dir -name "${file_pattern}"`; do
				echo $f | sed "s/\(.*\)\/\(.*\)\/.*/\1-\2/g;${sed_extra}"
				newf=`echo $f | sed "s/\(.*\)\/\(.*\)\/.*/\1-\2/g;${sed_extra}"`
				base=`basename $newf .jpg`
				output_file=$target_dir/$newf
				echo $f $output_file
				convert $f $output_file
			done
		done
	done

################################################################################
## Stamp images with filename, and then make and eval a melt script.
################################################################################
elif [ $action == "stampmelt" ]; then
	stamped_dir=./stamped
	rm $stamped_dir/*
	for params in "${content_name} miralight.m4a" "${content_name}-original MakeYouFeelMyLove.m4a"; do
		inputfolder=`echo $params | cut -d' ' -f1`
		musicfile=`echo $params | cut -d' ' -f2`

		stampimage.py --stampinfo filename --inputfolder $inputfolder --outputfolder $stamped_dir --sourceimage original --textcolor 255 255 255
		meltscript="melt -verbose -profile atsc_1080p_25 `find $stamped_dir -name '*.jpg' | shuf | sed 's/$/ out=100 -mix 25 -mixer luma/'` -consumer avformat:x.mp4 vcodec=h264_nvenc an=1"
		eval $meltscript
		rm $inputfolder.mp4
		ffmpeg -i x.mp4 -i $musicfolder/$musicfile -map 0 -map 1 -c copy -shortest $inputfolder.mp4
		rm x.mp4
	done
	popd

################################################################################
## hwalsuklee
################################################################################
elif [ $action == "hwalsuklee" ]; then
	rootdir=/home/jus/notebook/jus/styletransfer
	modeldir=$rootdir/hwalsuklee/model

	gpu=0
	content=$rootdir/pics/GSITree.jpg
	outputfolder=$rootdir/hwalsuklee/results/GSITree.jpg
	mkdir -p $outputfolder

	pushd $modeldir
	for style in `find . -name '*.jpg' -type d | sort | sed 's/^\.\///'`; do
		stylename=`echo $style | sed 's/\//./'`
		outputfile=$outputfolder/$stylename
		echo $outputfile
		hwalsuklee-test.sh $style $content $outputfile $gpu
	done
	popd


################################################################################
## kesara
################################################################################
elif [ $action == "kesara" ]; then
	style=GSITree.jpg
	for f in `find ~/github/places365 -name '*.caffemodel'`; do
		network=`echo $f | cut -d'/' -f6 | cut -d'.' -f1`
		kesara.sh 1 $style 10 all $network
	done
	for f in `find ~/github/bvlc-caffe -name '*.caffemodel'`; do
		network=`echo $f | cut -d'/' -f6 | cut -d'.' -f1`
		echo $network
		kesara.sh 1 $style 10 all $network
	done

	for f in *maya_[0-9]*; do newname=231_maya_all_`echo $f | cut -f3 -d'_'`; echo $f $newname; mv $f $newname; done

################################################################################
## corenlp
################################################################################
elif [ $action == "corenlp" ]; then
	rootdir=/home/jus/notebook/jus/ling/stanford-corenlp-full-2018-10-05
	pushd $rootdir
	./corenlp.sh -annotators tokenize,ssplit,pos,lemma,ner,parse,sentiment -file $2
	popd

################################################################################
## Get histogram of pics.
################################################################################
elif [ $action == "histo" ]; then
	rootdir=/home/jus/notebook/jus/heidelberg/output
	model=$2
	pushd $rootdir/$model
	
	popd


################################################################################
## Heidelberg experiment with different hyper params.
################################################################################
elif [ $action == "heidelbergexp" ]; then
	rootfolder=/home/jus/github/adaptive-style-transfer
	modelroot=/mnt/d1/models/styletransfer/sanakoyeu-kotovenko/vacation
	ptcd=/mnt/d1/datasets/data_large

	currentmodel=monet_water-lilies-1914
	imagesize=768
	gpu=0
	max=150000
	lr=0.0002
	tlw=100
	flw=100
	dsr=0.8
	dlw=1.0

	pushd $rootfolder
	for tlw in 100 1000 10 10000 1; do
		for flw in 100 1000 10 10000 1; do
			for dsr in 0.4 0.9 0.7 0.85; do # 0.8
				for dlw in 1.0 0.8 1.2; do # 10.0 5.0 very broken; 0.1 very unbroken; 0.5 ok
					for currentmodel in monet_water-lilies-1914 pablo-picasso paul-cezanne; do
						if (($gpu % 2 == 0)); then
							gpu=1
						else
							gpu=0
						fi
						CUDA_VISIBLE_DEVICES=$gpu python main.py \
							--model_name=model_${currentmodel} \
							--batch_size=1 \
							--total_steps=$max \
							--phase=train \
							--image_size=$imagesize \
							--lr=$lr \
							--dlw=$dlw \
							--tlw=$tlw \
							--flw=$flw \
							--dsr=$dsr \
							--ptcd=$ptcd \
							--ptad=$rootfolder/data/$currentmodel

						newdir=flw${flw}_tlw${tlw}_dsr${dsr}_dlw${dlw}
						mkdir -p $modelroot/$newdir
						echo "Moving model to vacation/$newdir"
						mv ./models/model_${currentmodel} $modelroot/$newdir/$currentmodel
						echo "Done"
					done
				done
			done
		done
	done
	popd


################################################################################
## Finish up short heidelberg.
################################################################################
elif [ $action == "shortheidelberg" ]; then
	rootfolder=/home/jus/github/adaptive-style-transfer
	modelroot=/mnt/d1/models/styletransfer/sanakoyeu-kotovenko/vacation
	ptcd=/mnt/d1/datasets/data_large

	currentmodel=monet_water-lilies-1914
	imagesize=768
	gpu=0
	max=150000
	lr=0.0002
	tlw=100
	flw=100
	dsr=0.8
	dlw=0.5

	pushd $rootfolder
	for currentmodel in pablo-picasso; do
		if (($gpu % 2 == 0)); then
			gpu=1
		else
			gpu=0
		fi
		CUDA_VISIBLE_DEVICES=$gpu python main.py \
			--model_name=model_${currentmodel} \
			--batch_size=1 \
			--total_steps=$max \
			--phase=train \
			--image_size=$imagesize \
			--lr=$lr \
			--dlw=$dlw \
			--tlw=$tlw \
			--flw=$flw \
			--dsr=$dsr \
			--ptcd=$ptcd \
			--ptad=$rootfolder/data/$currentmodel

		newdir=flw${flw}_tlw${tlw}_dsr${dsr}_dlw${dlw}
		mkdir -p $modelroot/$newdir
		echo "Moving model to vacation/$newdir"
		mv ./models/model_${currentmodel} $modelroot/$newdir/$currentmodel
		echo "Done"
	done
	popd


################################################################################
# Eval heidelberg long.
################################################################################
elif [ $action == "heidelberglong" ]; then

	rootfolder=/home/jus/github/adaptive-style-transfer
	inputfolder=$rootfolder/input
	modelroot=/mnt/d1/models/styletransfer/sanakoyeu-kotovenko/vacation
	modelroot=$rootfolder/models

	pushd $rootfolder

	name=231
	image_size=1280
	gpu=0

	from=15000
	to=180000
	step=15000

	rm input/*
	cp seattle/$name.jpg input

	#for d in $modelroot/*/*; do
	#for d in $modelroot/flw100_tlw100_dsr0.8_dlw0.5/pablo-picasso; do
	for d in $modelroot/monet_convweightnorm; do
		model=`basename $d`
		model_root_dir=`dirname $d`
		for ckpt_nmbr in `seq $from $step $to`; do
			outputfolder=$d/output
			mkdir -p $outputfolder
			CUDA_VISIBLE_DEVICES=$gpu python main.py \
				--model_root_dir=$model_root_dir \
				--model_name=$model \
				--phase=inference \
				--image_size=$image_size \
				--ii_dir $inputfolder \
				--save_dir=$outputfolder \
				--ckpt_nmbr=$ckpt_nmbr
			mv $outputfolder/${name}_${model}.jpg $outputfolder/${name}_${ckpt_nmbr}.jpg
		done
	done

################################################################################
## Copy random frames for heidelberg.
################################################################################
elif [ $action == "heidelbergrandom" ]; then
	sourcedir=/mnt/d1/renders/ffmpeg/anime/akira/original
	targetdir=/home/jus/github/adaptive-style-transfer/data/akira
	for n in `shuf -i 2425-173472 -n 999 | sort -n`; do
		filename=`printf '%07d.jpg' $n`
		echo $filename
		cp $sourcedir/$filename $targetdir
	done

################################################################################
## Heidelberg jobs.
################################################################################
elif [ $action == "htrain" ]; then
	heidelberg.sh train antoine-blanchard 864 195000 0.0002 1
	heidelberg.sh train antoine-blanchard 864 300000 0.0001 0
elif [ $action == "heval" ]; then
	theme=$2
	name=$3
	modelroot=$4 # published
	model=$5
	vres=$6
	gpu=$7
	checkpoint=$8
	heidelberg.sh eval $theme/$name $model $vres $gpu $modelroot $checkpoint $infolder $outfolder
	singles.sh $theme $name $model styled $checkpoint 
elif [ $action == "hevalcopy" ]; then
	nohup nice job.sh heval rock copyofa.tension published el-greco 768 1 last
	for infolder in `ls -d /mnt/d2/renders/rock/copyofa.tension/akira/*.jpg`; do
		base=`basename $infolder`
		outfolder=/mnt/d2/renders/rock/copyofa.tension/el-greco/akira/$base
		mkdir -p $outfolder
		heidelberg.sh eval rock/copyofa.tension el-greco 768 1 published last $infolder $outfolder
		singles.sh rock copyofa.tension el-greco audiovideo $outfolder el-greco.akira.${base}.mp4
	done

################################################################################
## Make folder and copy 200k checkpoints.
################################################################################
elif [ $action == "200k" ]; then
	pushd /mnt/d1/models/styletransfer/heidelberg
	for m in akira maya_all maya_liney maya_painty maya_sketchy pablo-picasso vincent-van-gogh_road-with-cypresses-1890; do
		mkdir -p $m
		mkdir -p $m/checkpoint_long
		cp ${m}-300/checkpoint_long/*195* $m/checkpoint_long
		echo "model_checkpoint_path: \"${m}_195000.ckpt-195000\"" > $m/checkpoint_long/checkpoint
		echo "all_model_checkpoint_paths: \"${m}_195000.ckpt-195000\"" >> $m/checkpoint_long/checkpoint
	done
	popd

################################################################################
## Rock videos.
################################################################################
elif [ $action == "rock" ]; then
	i=0
	for name in rock/copyofa.tension; do
		for model in "heidelberg akira" "heidelberg maya_all" "heidelberg maya_liney" "heidelberg maya_painty" "heidelberg maya_sketchy" "heidelberg pablo-picasso" "heidelberg vincent-van-gogh_road-with-cypresses-1890" "sanakoyeu-kotovenko cezanne" "sanakoyeu-kotovenko el-greco" "sanakoyeu-kotovenko gauguin" "sanakoyeu-kotovenko kandinsky" "sanakoyeu-kotovenko kirchner" "sanakoyeu-kotovenko monet" "sanakoyeu-kotovenko morisot" "sanakoyeu-kotovenko munch" "sanakoyeu-kotovenko peploe" "sanakoyeu-kotovenko picasso" "sanakoyeu-kotovenko pollock" "sanakoyeu-kotovenko roerich" "sanakoyeu-kotovenko van-gogh"; do
			model_root=`echo $model | cut -d' ' -f1`
			model_name=`echo $model | cut -d' ' -f2`
			if (($i % 2 == 0)); then
				heidelberg.sh evalpublished $model_root $name $model_name 720 0
				i=1
			else
				heidelberg.sh evalpublished $model_root $name $model_name 720 0
				i=0
				#sleep 111
			fi
		done
	done

################################################################################
## Rename files with reformatted number.
################################################################################
elif [ $action == "renumber" ]; then
	model_name=$2
	max_num=$3
	for n in `seq 1 1 $max_num`; do
		sourcenum=`printf '%04d' $n`
		targetnum=`printf '%07d' $n`
		sourcename=${sourcenum}_${model_name}.jpg
		targetname=${targetnum}_${model_name}.jpg
		echo $sourcename $targetname
		mv $sourcename $targetname
	done

################################################################################
## Download danbooru 2018.
################################################################################
elif [ $action == "danbooru2018" ]; then
	pushd /mnt/d1/datasets/anime
	for n in `seq 901 1 999`; do
		d=`printf "%04d" $n`
		echo $d
		rsync --recursive --times --verbose rsync://78.46.86.149:873/danbooru2018/512px/$d ./danbooru2018/512px
	done
	popd

################################################################################
## Make html for wikiart.
################################################################################
elif [ $action == "wahtml" ]; then
	rootfolder=/home/jus/notebook/jus/styletransfer/wikiart
	pushd $rootfolder
	for d in source/*; do
		echo $d
		for f in `ls -1 $d | sort`; do
			artist=`echo $f | cut -d'_' -f1`
			style=`echo $d | cut -d'/' -f2`
			targetfolder=$rootfolder/$style
			htmlfile=$targetfolder/${style}_${artist}.html
			mkdir -p $targetfolder
			echo $f | sed "s/\(.*\)/<img src='..\/source\/${style}\/${f}' width='200' \/>/" >> $htmlfile
		done
	done
	popd

################################################################################
## Render with gatys-johnson-ulyanov.
################################################################################
elif [ $action == "gju" ]; then

	theme=$2
	name=$3
	style=$4
	gpu=$5
	max_size=$6

	gpu_fraction=1.0
	modeldir=/home/jus/github/tensorflow-fast-style-transfer
	contentfolder=/home/jus/notebook/jus/styletransfer/vids/$theme/$name
	stylemodel=/mnt/d1/models/styletransfer/gatys-johnson-ulyanov/${style}/final.ckpt
	inputfolder=$contentfolder/original
	outputfolder=/mnt/d2/renders/$theme/$name/${style}

	mkdir -p $outputfolder
	python ${modeldir}/vids.py --gpu $gpu --gpu_fraction $gpu_fraction --style_model ${stylemodel} --content ${inputfolder} --output ${outputfolder} --max_size ${max_size}
	singles.sh $theme $name $style styled gju

################################################################################
## Render scenes and combine.
################################################################################
elif [ $action == "139" ]; then

	theme=worship
	name=139
	vres=768
	gpu=1
	sentinel=119 # First frame to render from.
	lastframe=8983

	scenefile=/home/jus/notebook/jus/styletransfer/vids/$theme/$name/$name*-Scenes.csv

	# Build a hash table of models.
	declare -A models=([1]="models albert-bloch" [2]="models antoine-blanchard" [3]="models edouard-cortes" [4]="models el-greco" [5]="models hieronymus-bosch" [6]="models john-singer-sargent" [7]="models maurice-de-vlaminck" [8]="models maurice-prendergast" [9]="models pcb" [10]="models synthcube" [11]="models_may akira" [12]="models_may el-greco" [13]="models_may maya_all" [14]="models_may maya_liney" [15]="models_may maya_painty" [16]="models_may maya_sketchy" [17]="models_may monet_water-lilies-1914" [18]="models_may pablo-picasso" [19]="models_may vincent-van-gogh_road-with-cypresses-1890" [20]="models_april akira" [21]="models_april pablo-picasso" [22]="models-april vincent-van-gogh_road-with-cypresses-1890")

	i=1
	for n in `sed '1,5d' $scenefile | cut -d',' -f2`; do

		# Get random index from 1 to 22.
		#index=`echo "scale=7;($RANDOM/32767)*22+1" | bc | cut -d'.' -f1`

		## Get next one in the models list.
		index=`python -c "from math import ceil; print(($i%22)+($i%22==0)*22)"`

		# Get the model from the hash table.
		modelpair="${models[$index]}"
		modelroot=`echo $modelpair | cut -d' ' -f1`
		modelname=`echo $modelpair | cut -d' ' -f2`
		checkpoint=`echo $modelpair | cut -d' ' -f3`
		if [ -z $checkpoint ]; then checkpoint=last; fi

		# Render.
		echo $sentinel $n: $modelroot $modelname
		heidelberg.sh evalframes $theme/$name $sentinel $n $modelroot $modelname $vres $gpu $checkpoint

		let sentinel=n+1
		let i=i+1
	done

	## Get next one in the models list.
	index=`python -c "from math import ceil; print(($i%22)+($i%22==0)*22)"`

	# Get the model from the hash table.
	modelpair="${models[$index]}"
	modelroot=`echo $modelpair | cut -d' ' -f1`
	modelname=`echo $modelpair | cut -d' ' -f2`

	# Last scene.
	echo $sentinel $lastframe: $modelroot $modelname
	heidelberg.sh evalframes $theme/$name $sentinel $lastframe $modelroot $modelname $vres $gpu last

	# Move into subfolder.
	mv /mnt/d2/renders/worship/139/heidelberg/*.jpg /mnt/d2/renders/worship/139/heidelberg/sequence

	# Compile mix.
	singles.sh worship 139 heidelberg styled sequence

################################################################################
## Get essay files.
################################################################################
elif [ $action == "grab_essays" ]; then

	inputfolder=$2
	outputfolder=$3
	panda.py --task grab_essays --inputfolder $inputfolder --outputfolder $outputfolder

################################################################################
## Render akira rock.
################################################################################
elif [ $action == "akira_rock" ]; then

	gpu=0
	
	for v in copyofa.tension; do
		for m in `ls -1 /mnt/d1/models/styletransfer/gatys-johnson-ulyanov/akira`; do
			inputfolder=/mnt/d2/renders/rock/$v/akira/$m
			outputfolder=/home/jus/notebook/jus/styletransfer/vids/rock/$v
			hwalsuklee-vids.sh rock $v akira/$m $gpu 768
			fps=23.9760239760239760239760239760239760239760
			ffmpeg -framerate $fps -i $inputfolder/%07d.jpg -c:v h264_nvenc $outputfolder/x.mp4
			ffmpeg -i $outputfolder/x.mp4 -i $outputfolder/copyofa.tension.m4a -map 0 -map 1 -c copy -shortest $outputfolder/akira.$m.mp4
			rm -f x.mp4
			if (($gpu % 2 == 0)); then gpu=1; else gpu=0; fi
		done
	done

################################################################################
## Make a pdf from jpg.
################################################################################
elif [ $action == "jpg2pdf" ]; then
	quality=$2
	infolder=$3
	outfile=$4
	#convert -size 2550x3300 -density 300 2550-3300.jpg 2550-3300.pdf
	convert $infolder/*.jpg -quality $quality $outfile

################################################################################
## Prune docker volumes.
################################################################################
elif [ $action == "prunedocker" ]; then
	docker system prune --all --volumes --force

################################################################################
## Make mp4 from horoscope.
################################################################################
elif [ $action == "horomp4" ]; then

	hset=$2
	framerate=$3

	pushd /mnt/d2/renders/scrap/horoscope/heidelberg
	for animal in rat ox tigerrabbit dragon snake horse goat monkey rooster dog pig; do
		i=1
		targetdir=/tmp/$hset/$animal
		mkdir -p $targetdir
		rm $targetdir/*
		for res in 120 345 768 1280 768 345 120; do
			for file in `find $res -name "${hset}-${animal}*.jpg"|sort`; do
				newname=`printf "%07d.jpg" $i`
				cp $file $targetdir/$newname
				echo cp $file $targetdir/$newname
				let "i++"
			done
		done
		rm ${hset}-${animal}.mp4
		ffmpeg -framerate $framerate -i $targetdir/%07d.jpg -c:v h264_nvenc ${hset}-${animal}.mp4
	done
	popd

################################################################################
## Render chinese horoscope.
################################################################################
elif [ $action == "horoscope" ]; then

	model=$2
	allorone=$3

	gpu=1
	gpu_fraction=1.0

	inputfolder=/home/jus/notebook/jus/styletransfer/vids/scrap/horoscope/original/$allorone

	if [ $model == "gju" ]; then

		modelroot=/mnt/d1/models/styletransfer/gatys-johnson-ulyanov

		pushd /home/jus/github/tensorflow-fast-style-transfer
		for s in `ls -1 $modelroot`; do
			for m in `ls -1 $modelroot/$s`; do
				echo $m
				stylemodel=/mnt/d1/models/styletransfer/gatys-johnson-ulyanov/$s/$m/final.ckpt
				outputfolder=/mnt/d2/renders/scrap/horoscope/gju/$allorone/$s/$m
				echo $outputfolder
				mkdir -p $outputfolder

				if (($gpu % 2 == 0)); then gpu=1; else gpu=0; fi

				for n in `seq 1 1 12`; do
					num=`printf "%02d" $n`
					resizedfolder=/home/jus/notebook/jus/styletransfer/vids/scrap/horoscope/resized
					rm -f $resizedfolder/*
					find $inputfolder -regex ".*${num}[-]*[a-z]*\.jpg" -exec cp '{}' $resizedfolder \;
					python vids.py --gpu $gpu --gpu_fraction $gpu_fraction --style_model ${stylemodel} --content ${resizedfolder} --output ${outputfolder}
				done
			done
		done
		popd

		pushd /mnt/d2/renders/scrap/horoscope/gju/all
			for n in `seq 1 1 12`; do num=`printf "%07d" $n`; find . -name "*${num}*.jpg" | sort | sed 's/\(.*\)/<img src="\1" width="300"\/>/' > ${num}.html; done
		popd
		pushd /mnt/d2/renders/scrap/horoscope/gju/one
			for n in `seq 1 1 12`; do num=`printf "%02d" $n`; find . -name "*${num}*.jpg" | sort | sed 's/\(.*\)/<img src="\1" width="100"\/>/' > ${num}.html; done
		popd

	elif [ $model == "gatys" ]; then

		pushd /home/jus/github/neural-style-tf
		for weights in "1e0-5e11" "5e0-1e4"; do
			content_weight=`echo $weights | cut -d'-' -f1`
			style_weight=`echo $weights | cut -d'-' -f2`

			for s in `ls -1 /home/jus/notebook/jus/styletransfer/style`; do
				style_dir=/home/jus/notebook/jus/styletransfer/style/$s
				img_output_dir=/mnt/d2/renders/scrap/horoscope/gatys/$allorone/$weights/$s

				if (($gpu % 2 == 0)); then gpu=1; else gpu=0; fi

				device="/gpu:$gpu"

				mkdir -p $img_output_dir
				python csmyth.py \
				  --content_img_dir "${inputfolder}" \
				  --style_imgs_dir "${style_dir}" \
				  --img_output_dir "${img_output_dir}" \
				  --content_weight $content_weight \
				  --style_weight $style_weight \
				  --device "${device}" \
				  --verbose;
			done
		done
		popd

		for weights in "1e0-5e11" "5e0-1e4"; do
		pushd /mnt/d2/renders/scrap/horoscope/gatys/one/$weights
			for n in `seq 1 1 12`; do num=`printf "%02d" $n`; find . -wholename "*/${num}-*.jpg.png" | sort | sed 's/\(.*\)/<img src="\1" width="100"\/>/' > ${num}.html; done
		popd
		done

	elif [ $model == "heidelberg" ]; then

		vres=120

		pushd /home/jus/github/adaptive-style-transfer
		for r in models_avgpool sanakoyeu-kotovenko heidelberg/april heidelberg/may heidelberg/june; do

			modelroot=/mnt/d1/models/styletransfer/$r

			for model_name in `ls -1 $modelroot`; do
				outputfolder=/mnt/d2/renders/scrap/horoscope/heidelberg/$vres/$allorone/$r/$model_name

				lastckpt=`find $modelroot/${model_name} -type f -name '*.meta' -printf '%T+%p\n' | sort -r | head -1`
				ckpt_nmbr=`echo $lastckpt | sed 's/.*-\([0-9]\+\).meta/\1/'`

				if (($gpu % 2 == 0)); then gpu=1; else gpu=0; fi

				mkdir -p $outputfolder
				CUDA_VISIBLE_DEVICES=$gpu python main.py \
					--model_root_dir=$modelroot \
					--model_name=$model_name \
					--phase=inference \
					--image_size=$vres \
					--ii_dir $inputfolder \
					--save_dir=$outputfolder \
					--ckpt_nmbr=$ckpt_nmbr
			done
		done
		popd

		pushd /mnt/d2/renders/scrap/horoscope/heidelberg/$vres/all
			for n in `seq 1 1 12`; do num=`printf "%07d" $n`; find . -name "*${num}*.jpg" | sort | sed 's/\(.*\)/<img src="\1" width="300"\/>/' > ${num}.html; done
		popd
		pushd /mnt/d2/renders/scrap/horoscope/heidelberg/$vres/one
			for n in `seq 1 1 12`; do num=`printf "%02d" $n`; find . -name "*${num}*.jpg" | sort | sed 's/\(.*\)/<img src="\1" width="100"\/>/' > ${num}.html; done
		popd
	fi

################################################################################
## Gather copyofa frames.
################################################################################
elif [ $action == "copyofaframes" ]; then
	# Copy the car.
	sourcedir=/home/jus/notebook/jus/styletransfer/vids/rock/copyofa.tension/original
	targetdir=/home/jus/notebook/jus/styletransfer/vids/rock/copyofa.x/car
	rm -f $targetdir/*.jpg
	for i in `seq 1 1 8651`; do
		f=`printf "%07d.jpg" $i`
		cp $sourcedir/$f $targetdir
		echo cp $sourcedir/$f $targetdir
	done

	# Copy the cdr.
	sourcedir=/home/jus/notebook/jus/styletransfer/vids/rock/copyofa.vevo/original
	targetdir=/home/jus/notebook/jus/styletransfer/vids/rock/copyofa.x/cdr
	rm -f $targetdir/*.jpg
	for i in `seq 1 1 8623`; do
		f=`printf "%07d.jpg" $i`
		cp $sourcedir/$f $targetdir
		echo cp $sourcedir/$f $targetdir
	done

################################################################################
## Build copyofa looping video.
################################################################################
elif [ $action == "copyofaloop" ]; then
	# Get fps from source.
	framerate=`ffprobe -v 0 -of csv=p=0 -select_streams v:0 -show_entries stream=r_frame_rate /home/jus/notebook/jus/styletransfer/vids/rock/copyofa.vevo/copyofa.vevo*.mp4`
	fps=`echo "scale=40;$framerate" | bc`

	rootfolder=/home/jus/notebook/jus/styletransfer/vids/rock/copyofa.x

	# Make parts.
	for part in cdr_resized; do # car cdr; do
		inputfolder=${rootfolder}/$part
		targetfile=${rootfolder}/${part}.mp4
		rm -f $targetfile
		ffmpeg -framerate $fps -i ${inputfolder}/%07d.jpg -c:v h264_nvenc $targetfile
	done

	# Loop the cdr.
	targetfile=${rootfolder}/cdrloop.mp4
	rm -f $targetfile
	ffmpeg -f concat -safe 0 -i ${rootfolder}/cdrloop.txt -c copy $targetfile

	# Concat car+cdr.
	targetfile=${rootfolder}/carcdr.mp4
	rm -f $targetfile
	ffmpeg -f concat -safe 0 -i ${rootfolder}/carcdr.txt -c copy $targetfile

	# Include audio.
	rm -f combined.m4a combined.mp4
	ffmpeg -i combined.wav combined.m4a
	ffmpeg -i carcdr.mp4 -i combined.m4a -map 0 -map 1 -c copy -shortest combined.mp4

################################################################################
## Open unmix.
################################################################################
elif [ $action == "umix" ]; then
	inputfile=$2

	pushd /home/jus
	source anaconda3/bin/activate
	popd
	conda activate open-unmix-pytorch-gpu
	pushd /home/jus/github/open-unmix-pytorch
	python test.py $inputfile
	popd
	conda deactivate
	conda deactivate

################################################################################
## Style Chris Nash using csmyth.
################################################################################
elif [ $action == "csmythsetl" ]; then

	gpu=1
	inputfolder=/home/jus/notebook/jus/styletransfer/vids/people/chrisnash.setl/drink

	pushd /home/jus/github/neural-style-tf
	for weights in "1e0-5e11"; do # "5e0-1e4"; do
		content_weight=`echo $weights | cut -d'-' -f1`
		style_weight=`echo $weights | cut -d'-' -f2`

		style_dir=/home/jus/notebook/jus/styletransfer/vids/people/chrisnash.setl/style
		img_output_dir=/mnt/d2/renders/people/chrisnash.setl/gatys/$weights/$s

		if (($gpu % 2 == 0)); then gpu=1; else gpu=0; fi

		device="/gpu:$gpu"

		mkdir -p $img_output_dir
		python csmyth.py \
		  --content_img_dir "${inputfolder}" \
		  --style_imgs_dir "${style_dir}" \
		  --img_output_dir "${img_output_dir}" \
		  --content_weight $content_weight \
		  --style_weight $style_weight \
		  --device "${device}" \
		  --verbose;
	done
	popd

################################################################################
## SETL styling.
################################################################################
elif [ $action == "setl" ]; then
	step=$2

	sourceroot=/home/jus/notebook/jus/styletransfer/vids/people/chrisnash.setl

	## Copy relevant frames.
	if [ $step == "copysource" ]; then
		sourcefolder=$sourceroot/original
		targetfolder=$sourceroot/crosspond
		mkdir -p $targetfolder
		for n in `seq 2107 1 2464`; do
			filename=`printf "%07d.jpg" $n`
			echo $filename
			cp $sourcefolder/$filename $targetfolder
		done

	## Resize relevant frames.
	elif [ $step == "resize" ]; then
		sourcefolder=$sourceroot/goodexp
		targetfolder=$sourceroot/goodexp-sizedown
		mkdir -p $targetfolder
		resize.py --inputfolder $sourcefolder --outputfolder $targetfolder --newwidth 500 --newheight 281

	## Segment relevant frames.
	elif [ $step == "segment" ]; then
		pushd ~/github/crfasrnn_keras
		rm inputfolder outputfolder
		ln -s $sourceroot/goodexp-sizedown inputfolder
		ln -s $sourceroot/mask outputfolder
		python jus.py
		popd

	## Resize masks.
	elif [ $step == "resizemask" ]; then
		sourcefolder=$sourceroot/mask
		targetfolder=$sourceroot/mask-sizeup
		mkdir -p $targetfolder
		resize.py --inputfolder $sourcefolder --outputfolder $targetfolder --newwidth 1920 --newheight 1080 --filetype png

	## Style with heidelberg.
	elif [ $step == "heidelberg" ]; then
		modelroot=published
		modelname=monet
		job.sh heval people chrisnash.setl $modelroot $modelname 1080 1 last

	## Style images with csmyth.
	elif [ $step == "csmythimages" ]; then
		gpu=1
		inputpart=crosspond-part2
		inputfolder=$sourceroot/$inputpart
		pushd ~/github/neural-style-tf.jus
		for weights in "1e0-5e11"; do
			content_weight=`echo $weights | cut -d'-' -f1`
			style_weight=`echo $weights | cut -d'-' -f2`
			style_dir=$sourceroot/style
			img_output_dir=/mnt/d2/renders/people/chrisnash.setl/gatys/csmyth/$inputpart/$weights

			device="/gpu:$gpu"

			mkdir -p $img_output_dir
			python csmyth.py \
			  --content_img_dir "${inputfolder}" \
			  --style_imgs_dir "${style_dir}" \
			  --img_output_dir "${img_output_dir}" \
			  --content_weight $content_weight \
			  --style_weight $style_weight \
			  --device "${device}" \
			  --verbose;


		done
		popd

	## Style video with csmyth.
	elif [ $step == "csmythvideo" ]; then
		#pushd /home/jus/github/neural-style-tf.jus
		#python csmyth.py --video_input_dir $sourceroot/crosspond --style_imgs_dir $sourceroot/style --style_imgs claude-monet_water-lilies-the-clouds.jpg --start_frame 2107 --end_frame 2464 --max_size 1080 --verbose --video --video_output_dir $sourceroot/crosspond-styled
		#popd

		pushd /home/jus/github/neural-style-tf
		#bash stylize_video.sh $sourceroot/crosspond.mp4 $sourceroot/crosspond-styled

		input_dir=/home/jus/github/neural-style-tf/video_input/crosspond
		style_dir=$sourceroot/style
		style_filename=claude-monet_water-lilies-the-clouds.jpg
		num_frames=358
		max_size=1080

		python neural_style.py --video \
			--video_input_dir "${input_dir}" \
			--style_imgs_dir "${style_dir}" \
			--style_imgs "${style_filename}" \
			--end_frame "${num_frames}" \
			--max_size "${max_size}" \
			--verbose;
		popd

	else
		echo "Unknown step $step!"
	fi

################################################################################
## Assemble random.
################################################################################
elif [ $action == "assemble" ]; then
	rootfolder=/home/jus/notebook/jus/styletransfer/vids/rock/copyofa.tension
	contentfolder=$rootfolder/resized
	rendersroot=/mnt/d2/renders/rock/copyofa.tension
	renders=$rootfolder/config.renders
	instructions=$rootfolder/config.instr
	beats=$rootfolder/config.beats
	lastframe=8661
	outfolder=$rootfolder/assembled
	pushd $rootfolder
	assemble.py --contentfolder $contentfolder --rendersroot $rendersroot --renders $renders --instructions $instructions --lastframe $lastframe --beats $beats --outfolder $outfolder
	rm -f assembled.mp4
	singles.sh rock copyofa.tension copyofa.tension audiovideo $rootfolder/assembled assembled.mp4 x
	popd

################################################################################
## Try Anish's ST.
################################################################################
elif [ $action == "anish" ]; then
	sourceroot=/home/jus/notebook/jus/styletransfer/vids/people/chrisnash.setl
	contentweight=5e0 # 5e0
	styleweight=1e3 # 5e2
	iterations=1000
	contentfolder=$sourceroot/drink-sizedown
	stylefolder=$sourceroot/style
	pushd ~/github/neural-style
	for style in `ls -1 $stylefolder`; do
		for content in `ls -1 $contentfolder`; do
			targetfolder=$sourceroot/gatys/anish/$style
			targetfile=$content
			mkdir -p $targetfolder
			python neural_style.py \
				--content $contentfolder/$content \
				--styles $stylefolder/$style \
				--output $targetfolder/$targetfile \
				--content-weight $contentweight \
				--style-weight $styleweight \
				--iterations $iterations \
				--overwrite
		done
	done
	popd

################################################################################
## Assemble Maya's Tania Branding.
################################################################################
elif [ $action == "mayatania" ]; then
	step=$2

	sourceroot=/home/jus/notebook/jus/styletransfer/vids/maya/tania

	pushd $sourceroot

	## Convert to jpg.
	if [ $step == "convert" ]; then
		for i in `seq 1 2 53`; do
			let "j=(i/2)+1"
			sourcefile=`printf "bmp/tania branding_%04d.bmp" $i`
			targetfile=`printf "original/%07d.jpg" $j`
			convert "$sourcefile" -quality 100 $targetfile
			echo "$sourcefile" $targetfile
		done

	## Make mp4.
	elif [ $step == "mp4" ]; then
		ffmpeg -framerate 30 -i 10percent/%07d.jpg -c:v h264_nvenc 10percent.30fps.mp4

	## Convert to gif.
	elif [ $step == "gif" ]; then
		ffmpeg -i 10percent.30fps.mp4 -vf "fps=30" -loop 0 30fps.gif

	fi

	popd

################################################################################
## Assemble Maya's Left-Right gifs.
################################################################################
elif [ $action == "mayagif" ]; then
	step=$2
	num=$3

	sourceroot=/home/jus/notebook/jus/styletransfer/vids/maya
	pushd $sourceroot/gif${num}

	## Convert to jpg.
	if [ $step == "convert" ]; then
		if [ $num == "1" ]; then
			mkdir -p left right
			convert insta\ experiment\ 5.gif -coalesce -scene 1 left/%07d.jpg
			convert insta\ experiment\ 9.gif -coalesce -scene 1 right/%07d.jpg
		elif [ $num == "2" ]; then
			mkdir -p left right
			convert project\ 1.gif -coalesce -scene 1 left/%07d.jpg
			convert project\ 2.gif -coalesce -scene 1 right/%07d.jpg
		elif [ $num == "3" ]; then
			mkdir -p left right
			convert project\ 3-1.gif -coalesce -scene 1 left/%07d.jpg
			convert ariel\ branding\ gif\ 3.gif -coalesce -scene 1 right/%07d.jpg
		fi

	## Synchronize.
	elif [ $step == "sync" ]; then
		if [ $num == "1" ]; then
			for i in `seq 3 1 48`; do
				let "j=i-2"
				f=`printf "%07d.jpg" $i`
				g=`printf "%07d.jpg" $j`
				mv left/$f left/$g
				echo $f $g
			done
		elif [ $num == "2" ]; then
			side=left
			dec=1
			for sets in "3 7" "9 13" "15 19" "21 24"; do
				x=($sets)
				from=${x[0]}
				to=${x[1]}
				for i in `seq $from 1 $to`; do
					let "j=i-$dec"
					f=`printf "%07d.jpg" $i`
					g=`printf "%07d.jpg" $j`
					mv $side/$f $side/$g
					echo $f $g
				done
				let "dec=dec+1"
			done
			for i in `seq 1 1 20`; do
				let "j=i+20"
				f=`printf "%07d.jpg" $i`
				g=`printf "%07d.jpg" $j`
				cp $side/$f $side/$g
				echo $f $g
			done
			side=right
			dec=1
			for sets in "3 7" "9 13" "15 25" "27 31" "33 37" "39 46"; do
				x=($sets)
				from=${x[0]}
				to=${x[1]}
				for i in `seq $from 1 $to`; do
					let "j=i-$dec"
					f=`printf "%07d.jpg" $i`
					g=`printf "%07d.jpg" $j`
					mv $side/$f $side/$g
					echo $f $g
				done
				let "dec=dec+1"
			done
		elif [ $num == "3" ]; then
			side=left
			max=22
			mult=3
			for n in `seq 1 1 $mult`; do
				for i in `seq 1 1 $max`; do
					let "j=i+($max*$n)"
					f=`printf "%07d.jpg" $i`
					g=`printf "%07d.jpg" $j`
					cp $side/$f $side/$g
					echo $f $g
				done
			done
			rm $side/0000088.jpg
			side=right
			max=29
			mult=2
			for n in `seq 1 1 $mult`; do
				for i in `seq 1 1 $max`; do
					let "j=i+($max*$n)"
					f=`printf "%07d.jpg" $i`
					g=`printf "%07d.jpg" $j`
					cp $side/$f $side/$g
					echo $f $g
				done
			done
		fi

	## Make gif.
	elif [ $step == "gif" ]; then
		fps=7
		height=560
		mp4=gif${num}.${fps}fps.mp4
		ffmpeg -y -framerate $fps -i combined/%07d.jpg -c:v h264_nvenc $mp4
		ffmpeg -y -i $mp4 -vf "fps=$fps,scale=-1:$height:flags=lanczos,palettegen" palette.png
		ffmpeg -y -i $mp4 -i palette.png -filter_complex "fps=$fps,scale=-1:$height:flags=lanczos[x];[x][1:v]paletteuse" -loop 0 set${num}.gif

	## Make mp4.
	elif [ $step == "mp4" ]; then
		fps=7
		mp4=set${num}.5min.mp4
		ffmpeg -y -framerate $fps -loop 1 -i combined-cut/%07d.png -c:v h264_nvenc -t 300 $mp4

	fi

	popd

################################################################################
## Try Tensorflow 2.
################################################################################
elif [ $action == "tf2" ]; then
	docker run -u $(id -u):$(id -g) --runtime=nvidia -it tensorflow/tensorflow:latest-gpu-py3 /job.sh setl csmythimages

################################################################################
## Build instagram loops.
################################################################################
elif [ $action == "instagram" ]; then

	step=$2

	pushd /home/jus/notebook/jus/styletransfer/vids/maya/instagram

	# Generate padded vids.
	if [ $step == "map" ]; then

		for f in 12 14 17 19 20 21 22 23 26; do

			n=`printf "%07d" $f`

			target=${n}_resized

			# Remove output frames.
			rm ${n}/*.jpg
			rm ${target}/*.jpg

			# Generate original output frames.
			ffmpeg -i ${n}.mp4 ${n}/%07d.jpg

			# Generate resized frames.
			resize.py --inputfolder ${n} --outputfolder ${target} --newwidth 1440 --newheight 1080 --padonly

			# Make video from resized frames.
			rm ${target}.mp4
			ffmpeg -framerate 24.0 -i ${target}/%07d.jpg -c:v h264_nvenc ${target}.mp4

		done

	# Assemble into loop.
	elif [ $step == "assemble" ]; then

		for v in vid1 vid2; do
			rm ${v}_*.mp4
			ffmpeg -f concat -safe 0 -i ${v}loop.txt -c:v h264_nvenc ${v}_1080.mp4
			ffmpeg -i ${v}_1080.mp4 -vf "scale=2*iw/3:2*ih/3" ${v}_0720.mp4
			ffmpeg -i ${v}_1080.mp4 -vf "scale=iw/2:ih/2" ${v}_0540.mp4
			ffmpeg -i ${v}_1080.mp4 -vf "scale=iw/3:ih/3" ${v}_0360.mp4
		done

	fi

	popd

################################################################################
## Reduce video size with same quality.
################################################################################
elif [ $action == "reducesize" ]; then

 	sourcename=$2
 	target=${sourcename}_resized.mp4

 	# Figure out fps.
	framerate=`ffprobe -v 0 -of csv=p=0 -select_streams v:0 -show_entries stream=r_frame_rate ${sourcename}.mp4`
 
	mkdir $sourcename

 	# Generate original frames.
 	ffmpeg -i ${sourcename}.mp4 -c:v h264_nvdec ${sourcename}/%07d.jpg
 
 	# Generate new video using NVIDIA H264.
 	ffmpeg -framerate $framerate -i ${sourcename}/%07d.jpg -c:v h264_nvenc ${target}

################################################################################
## Create folder and run dwprofiler.
################################################################################
elif [ $action == "dwprof" ]; then

	targetfolder=$2
	tablename=$3

	# Set target folder.
	if [ -z $targetfolder ]; then
		rootfolder=/home/jus/notebook/jus/dw/profiling
		datetime=`date +%Y-%m-%d`
		targetfolder=$rootfolder/$datetime
	fi

	# Create target folder.
	mkdir -p $targetfolder

 	# Run dwprofiler.
	if [ -z $tablename ]; then
		python /home/jus/bin/dwprofiler.py --targetfolder $targetfolder
	else
		python /home/jus/bin/dwprofiler.py --targetfolder $targetfolder --tablename $tablename
	fi

################################################################################
## Run BIC job.
################################################################################
elif [ $action == "bic" ]; then

	rootdir=~/tmp

	pushd $rootdir

	keyfile=bic_vancouver_receipt_ordering.csv
	infile=bic_vancouver_taxyear2020.pdf
	outfolder=receipts-a9d6dcbe-120c-46c1-af74-807cf4ec84c4

	#keyfile=bic_toronto_receipt_ordering.csv
	#infile=bic_toronto_taxyear2020.pdf
	#outfolder=receipts-89fb94fa-657e-40b0-b952-cea14bab20b5

	convert -verbose -density 300 $infile -quality 100 staging/%07d.jpg

	OLDIFS=$IFS
	IFS=$'\n'
	i=0
	for x in $(cat $keyfile); do
		numpages=`echo $x | cut -f1 -d','`
		outpdf=`echo $x | cut -f2 -d','`.pdf
		first=$i
		i=$((i+numpages))
		second=$((i-1))
		for n in `seq $first $second`; do
			injpg=`printf "%07d.jpg" $n`
			cp ./staging/$injpg ./individual
		done

		convert ./individual/*.jpg -quality 100 $outfolder/$outpdf

		rm -f ./individual/*.jpg
		echo $first $second $outpdf

	done
	IFS=$OLDIFS
	popd

################################################################################
## Run Tyndale jobs.
################################################################################
elif [ $action == "tyndale" ]; then

	#for book in 01.john 02.mark 03.matthew 04.luke 05.acts 06.revelation 07.12peter 08.123john 09.james_jude 10.hebrews 11.romans 12.1corinthians 13.2corinthians 14.galatians 15.ephesians_philippians 16.colossians 17.12thessalonians 18.12timothy 19.titus_philemon 20.ToTheReder; do
	for book in 20.ToTheReder; do
		echo Cleaning up...
		tyndale.sh cleanup
		echo Prepping...
		tyndale.sh prep $book
		echo Processing...
		tyndale.sh process $book
		echo Generating low-res pdf...
		tyndale.sh topdf 3.final ${book}.lowres.pdf 10
		echo Generating hi-res pdf...
		tyndale.sh topdf 3.final ${book}.hires.pdf 100
		echo Done!
	done

################################################################################
## Cleanup youtube vtt.
################################################################################
elif [ $action == "vtt" ]; then
	infile=$2
	#awk 'BEGIN {RS = "\n\n"} ; {print $0}' $infile | awk 'BEGIN {RS = "\n"; FS = "0%"}; {print $1}'
	#awk 'BEGIN {RS = "\n\n"} ; {print $0}' $infile | awk '{s=(NR==1?s:s " ")$0}END{print s}'
	awk 'BEGIN {RS = "\n\n"}; NR%2{print $0}' $infile

################################################################################
## Run Stylized Neural Painting.
################################################################################
elif [ $action == "snp" ]; then

	pushd ~/github/stylized-neural-painting

python demo_prog.py --img_path ./test_images/apple.jpg --canvas_color 'white' --max_m_strokes 500 --max_divide 5 --renderer oilpaintbrush --renderer_checkpoint_dir checkpoints_G_oilpaintbrush --net_G zou-fusion-net --disable_preview

################################################################################
## Resize gif for Teams Wiki.
################################################################################
elif [ $action == "teamsgif" ]; then

	infile=$2
	outfile=$3
	resize=$4
	convert $infile -coalesce -resize ${resize}% -deconstruct $outfile

################################################################################
## Resize gifs for Teams Wiki on OpenRefine.
################################################################################
elif [ $action == "teamsORgif" ]; then
	pushd ~/okr

	ext=png
	newsize=70
	echo "Ensuring folders..."
	for n in 01 02 03; do
		mkdir -p $n/source
		for m in `seq 1 5`; do mkdir -p $n/$m; done
	done

	gifnum=01
	echo "Processing ${gifnum}..."
	#convert OpenRefine.$gifnum.gif -coalesce -resize ${newsize}% -deconstruct $gifnum/source/%07d.$ext
	convert OpenRefine.$gifnum.gif -coalesce -deconstruct PNG8:$gifnum/source/%07d.$ext
	for n in `seq 0 130`; do f=`printf "%07d.$ext" $n`; cp $gifnum/source/$f $gifnum/1; done
	convert -delay 23 $gifnum/1/*.$ext -colors 8 OR${gifnum}.1.gif

	popd

################################################################################
## Run DW jobs.
################################################################################
elif [ $action == "dw" ]; then
	# usage: dwparser.py [-h] [--connection CONNECTION] [--sqlfile SQLFILE]
	# 	--token_format TOKEN_FORMAT [--pattern PATTERN]
	# 	[--leaves_only] [--summary] [--flatten]

	python ~/bin/dwparser.py --connection jz_DEV --token_format cli --sqlfile O.sql

################################################################################
## Run SQLParser 2.
################################################################################
elif [ $action == "sqlparser2" ]; then

	rootfolder=/home/jus/sqlparser
	parsername=SQLParser2
	targetfolder=$rootfolder/$parsername
	python $rootfolder/parser.py --connection jz_DEV --sourcename TmsEPrd --targetfolder $targetfolder/TmsEPrd
	for params in "aq_PROD Aqueduct" "fr_PROD FinancialReporting" "ics_PROD ICS_NET"; do
		connection=`echo $params | cut -d' ' -f1`
		sourcename=`echo $params | cut -d' ' -f2`
		python $rootfolder/parser.py --connection $connection --sourcename $sourcename --targetfolder $targetfolder/$sourcename --pattern %
	done
	pushd $rootfolder
	rm $parsername.tar.gz
	tar cvf $parsername.tar $parsername
	gzip -9 $parsername.tar
	popd

################################################################################
fi

