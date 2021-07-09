#!/bin/bash

# Figure out length and framerate.
#ffmpeg -i original.mp4 2>&1 | grep Duration
# Duration: 00:04:30.77, start: 0.000000, bitrate: 773 kb/s
# 270.77 seconds
# 6491 frames
# 23.972375 fps

vid=isheworthy
rootfolder=/home/jus/notebook/jus/styletransfer/vids/${vid}
originalfolder=${rootfolder}/original
stylefolder=${rootfolder}/style
mixfolder=${rootfolder}/mix
stagingfolder=${rootfolder}/staging
framefolder=${rootfolder}/frame
finalfolder=${rootfolder}/final
withstyle=${rootfolder}/withstyle
styletransfer=/home/jus/notebook/jus/styletransfer

passionfolder=/home/jus/notebook/jus/styletransfer/vids/passion
passionoriginal=${passionfolder}/original
passionstyle=${passionfolder}/style
passionstaging=${passionfolder}/staging

################################################################################

copy() {
	folderfrom=$1
	folderto=$2
	framefrom=$3
	frameto=$4
	offset=$5
	if [ -z $offset ]; then offset=0; fi
	for i in `seq $framefrom $frameto`; do
		f=`printf "%05d.jpg" $i`
		g=`printf "%05d.jpg" $((i+$offset))`
		echo $f - $g
		cp $folderfrom/$f $folderto/$g
	done
}

backandforth() {
	folderfrom=$1
	folderto=$2
	framefrom=$3
	frameto=$4
	targetframe=$5
	repeat=$6
	first=$framefrom
	last=$frameto
	inc=1
	for i in `seq 1 $repeat`; do
		for j in `seq $first $inc $last`; do
			f=`printf "%05d.jpg" $j`
			g=$targetframe.jpg
			echo $f - $g
			cp $folderfrom/$f $folderto/$g
			let targetframe-=1
			if (($i % 2 == 0)); then first=$framefrom; last=$frameto; inc=1; else first=$frameto; last=$framefrom; inc=-1; fi
		done
	done
}

style() {
	framefrom=$1
	frameto=$2
	stylefrom=$3
	styleto=$4
	if [ -z $styleto ]; then
		copy $rootfolder/$stylefrom $stagingfolder $framefrom $frameto
	else
		transition.sh isheworthy $stylefrom $styleto $framefrom $frameto
	fi
}

withstyle() {
	framefrom=$1
	frameto=$2
	stylefrom=$styletransfer/$3
	if [ -z $4 ]; then
		withstyle.py --framefirst $framefrom --framelast $frameto --contentfolder $finalfolder --stylefrom $stylefrom --outputfolder $stagingfolder
	else
		styleto=$styletransfer/$4
		withstyle.py --framefirst $framefrom --framelast $frameto --contentfolder $finalfolder --stylefrom $stylefrom --styleto $styleto --outputfolder $stagingfolder
	fi
}


################################################################################

pushd ${rootfolder}

################################################################################
# Get original video from youtube and process.
################################################################################
# Get youtube video.
#youtube-dl -f22 https://www.youtube.com/watch?v=OIahc83Kvp4
#
## Get cropped frames.
#ffmpeg -i ${rootfolder}/Andrew\ Peterson\ -\ Is\ He\ Worthy-OIahc83Kvp4.mp4 -filter:v "crop=1280:532:0:95" -q:v 1 ${originalfolder}/%05d.jpg
#
## Get cropped frames lower quality.
#ffmpeg -i ${rootfolder}/Andrew\ Peterson\ -\ Is\ He\ Worthy-OIahc83Kvp4.mp4 -filter:v "crop=1280:532:0:95" ${rootfolder}/lower/%05d.jpg
#
## Get m4a audio.
#ffmpeg -i ${rootfolder}/Andrew\ Peterson\ -\ Is\ He\ Worthy-OIahc83Kvp4.mp4 -vn -acodec copy ${rootfolder}/${vid}.m4a
#
## Reconstruct original mp4 video only.
#ffmpeg -framerate 23.972375 -i ${originalfolder}/%05d.jpg -c:v h264_nvenc ${rootfolder}/original.mp4
#
## Figure out length and framerate.
#ffmpeg -i original.mp4 2>&1 | grep Duration
# Duration: 00:04:30.77, start: 0.000000, bitrate: 773 kb/s
# 270.77 seconds
# 6491 frames
# 23.972375 fps

################################################################################
# Combine original with the passion.
################################################################################
#copy $originalfolder $stagingfolder 1 2600
#copy $passionoriginal $stylefolder/passion/original 2674 3581 -674 # 2000-2907
#transition.sh $vid original style/passion/original 2501 2550
#copy $stylefolder/passion/original $stagingfolder 2551 2907
#transition.sh $vid style/passion/original original 2895 2907
#copy $originalfolder $stagingfolder 2908 3150
#copy $passionoriginal $stylefolder/passion/original 1144 1153 1997 # 3141-3150
#transition.sh $vid original style/passion/original 3141 3150
#copy $passionoriginal $stagingfolder 1154 1360 1997 # 3151-3357
#copy $passionoriginal $stagingfolder 1366 1555 1992 # 3358-3547
#copy $passionoriginal $stagingfolder 1586 2046 1962 # 3548-4008
#copy $passionoriginal $stagingfolder 3662 4410 347 # 4009-4757
#copy $passionoriginal $stagingfolder 678 778 4080 # 4758-4858
#copy $passionoriginal $stagingfolder 4411 4796 448 # 4859-5244
#copy $passionoriginal $stagingfolder 4797 4896 448 # 5245-5344
#backandforth $passionoriginal $stylefolder/passion/original 360 364 5345 20
#transition.sh $vid staging style/passion/original 5335 5344
#copy $passionoriginal $stagingfolder 360 460 4985 # 5345-5445
#copy $passionoriginal $stylefolder/passion/original 461 490 4985 # 5446-5475
#transition.sh $vid style/passion/original original 5446 5475
#copy $originalfolder $stagingfolder 5476 6491
#mv $stagingfolder/* $mixfolder
#stampimage.py --stampinfo filename --inputfolder $mixfolder --outputfolder $framefolder
#rm x.mp4 frame.mp4
#ffmpeg -framerate 23.972375 -i $framefolder/%05d.jpg -c:v h264_nvenc $rootfolder/x.mp4
#ffmpeg -i $rootfolder/x.mp4 -i $rootfolder/isheworthy.m4a -map 0 -map 1 -c copy -shortest $rootfolder/frame.mp4

################################################################################
# Add style to the mix.
################################################################################
#rm $stagingfolder/*
#style 1 300 mix
#style 301 450 mix style/common/starry.jpg
#style 451 1100 style/common/starry.jpg
#style 1101 1170 style/common/starry.jpg style/maya/wiggles_final.jpg
#style 1171 1450 style/maya/wiggles_final.jpg
#style 1271 1340 style/maya/wiggles_final.jpg style/maya/wiggles-udnie.jpg
#style 1341 1400 style/maya/wiggles-udnie.jpg
#style 1401 1500 style/maya/wiggles-udnie.jpg style/other/studentlife-reading.jpg
#style 1501 1600 style/other/studentlife-reading.jpg
## 1600 is it GOOD that we remind ourselves of this?
#style 1601 1700 style/other/studentlife-reading.jpg style/common/starry.jpg
#style 1701 1800 style/common/starry.jpg
#style 1801 1940 style/common/starry.jpg style/mira/MiraWolf1.jpg
#style 1940 2050 style/mira/MiraWolf1.jpg
#style 2051 2100 style/mira/MiraWolf1.jpg style/mira/phoenix1.jpg
#style 2101 2200 style/mira/phoenix1.jpg
#style 2201 2300 style/mira/phoenix1.jpg style/common/the_scream.jpg
#style 2301 2450 style/common/the_scream.jpg
#style 2451 2500 style/common/the_scream.jpg style/maya/wiggles-udnie.jpg
#style 2501 2900 style/maya/wiggles-udnie.jpg
#style 2901 3050 style/maya/wiggles-udnie.jpg mix
#style 3051 3100 mix
#style 3101 3150 mix style/common/starry.jpg
#style 3151 3217 style/common/starry.jpg
#style 3218 3257 style/common/starry.jpg style/maya/forgodsoloved.jpg
#style 3258 3356 style/maya/forgodsoloved.jpg
#cp $stylefolder/maya/forgodsoloved.jpg/3360.jpg $stagingfolder/3357.jpg
#cp $stylefolder/maya/forgodsoloved.jpg/3360.jpg $stagingfolder/3358.jpg
#cp $stylefolder/maya/forgodsoloved.jpg/3360.jpg $stagingfolder/3359.jpg
#style 3360 3602 style/common/starry.jpg
#style 3603 3663 style/common/starry.jpg style/maya/wiggles_final.jpg
#style 3664 3680 style/maya/wiggles_final.jpg
#style 3681 3750 style/maya/wiggles_final.jpg style/maya/wiggles-udnie.jpg
#style 3751 3895 style/maya/wiggles-udnie.jpg style/maya/wiggles_final.jpg
#style 3896 4000 style/maya/wiggles-udnie.jpg
#style 4001 4150 style/maya/wiggles-udnie.jpg style/maya/wiggles_final.jpg
#style 4151 4500 style/maya/wiggles_final.jpg
#style 4501 4682 style/maya/wiggles_final.jpg style/maya/wiggles-udnie.jpg
#style 4683 5470 style/maya/wiggles-udnie.jpg
#style 5471 5510 style/maya/wiggles-udnie.jpg mix
#style 5511 5580 mix
#style 5581 5620 mix style/common/rain_princess.jpg
#style 5621 5660 style/common/rain_princess.jpg style/maya/forgodsoloved.jpg
#style 5661 5700 style/maya/forgodsoloved.jpg style/mira/phoenix1.jpg
#style 5701 5740 style/mira/phoenix1.jpg style/maya/udnie-wiggles.jpg
#style 5741 5780 style/maya/udnie-wiggles.jpg style/maya/mayadoodle.jpg
#style 5781 5820 style/maya/mayadoodle.jpg style/jus/sheepface.jpg
#style 5821 5860 style/jus/sheepface.jpg style/mira/MiraWolf1.jpg
#style 5861 5900 style/mira/MiraWolf1.jpg style/other/studentlife-reading.jpg
#style 5901 5940 style/other/studentlife-reading.jpg style/maya/wiggles-udnie.jpg
#style 5941 5980 style/maya/wiggles-udnie.jpg style/common/la_muse.jpg
#style 5981 6020 style/common/la_muse.jpg style/common/the_scream.jpg
#style 6021 6060 style/common/the_scream.jpg style/common/starry.jpg
#style 6061 6150 style/common/starry.jpg
#style 6151 6200 style/common/starry.jpg mix
#style 6201 6491 mix

#mv $stagingfolder/* $finalfolder
#rm x.mp4 final.mp4
#ffmpeg -framerate 23.972375 -i $finalfolder/%05d.jpg -c:v h264_nvenc $rootfolder/x.mp4
#ffmpeg -i $rootfolder/x.mp4 -i $rootfolder/isheworthy.m4a -map 0 -map 1 -c copy -shortest $rootfolder/final.mp4

################################################################################
# Paste the style on to the content.
################################################################################
rm $stagingfolder/*
withstyle 1 300 style/vid/isheworthy.jpg
withstyle 301 450 style/vid/isheworthy.jpg style/common/starry.jpg
withstyle 451 1100 style/common/starry.jpg
withstyle 1101 1170 style/common/starry.jpg style/maya/wiggles_final.jpg
withstyle 1171 1450 style/maya/wiggles_final.jpg
withstyle 1271 1340 style/maya/wiggles_final.jpg style/maya/wiggles-udnie.jpg
withstyle 1341 1400 style/maya/wiggles-udnie.jpg
withstyle 1401 1500 style/maya/wiggles-udnie.jpg style/other/studentlife-reading.jpg
withstyle 1501 1600 style/other/studentlife-reading.jpg
withstyle 1601 1700 style/other/studentlife-reading.jpg style/common/starry.jpg
withstyle 1701 1800 style/common/starry.jpg
withstyle 1801 1940 style/common/starry.jpg style/mira/MiraWolf1.jpg
withstyle 1940 2050 style/mira/MiraWolf1.jpg
withstyle 2051 2100 style/mira/MiraWolf1.jpg style/mira/phoenix1.jpg
withstyle 2101 2200 style/mira/phoenix1.jpg
withstyle 2201 2300 style/mira/phoenix1.jpg style/common/the_scream.jpg
withstyle 2301 2450 style/common/the_scream.jpg
withstyle 2451 2500 style/common/the_scream.jpg style/maya/wiggles-udnie.jpg
withstyle 2501 2900 style/maya/wiggles-udnie.jpg
withstyle 2901 3050 style/maya/wiggles-udnie.jpg style/vid/isheworthy.jpg
withstyle 3051 3100 style/vid/isheworthy.jpg
withstyle 3101 3150 style/vid/isheworthy.jpg style/common/starry.jpg
withstyle 3151 3217 style/common/starry.jpg
withstyle 3218 3257 style/common/starry.jpg style/maya/forgodsoloved.jpg
withstyle 3258 3359 style/maya/forgodsoloved.jpg
withstyle 3360 3602 style/common/starry.jpg
withstyle 3603 3663 style/common/starry.jpg style/maya/wiggles_final.jpg
withstyle 3664 3680 style/maya/wiggles_final.jpg
withstyle 3681 3750 style/maya/wiggles_final.jpg style/maya/wiggles-udnie.jpg
withstyle 3751 3895 style/maya/wiggles-udnie.jpg style/maya/wiggles_final.jpg
withstyle 3896 4000 style/maya/wiggles-udnie.jpg
withstyle 4001 4150 style/maya/wiggles-udnie.jpg style/maya/wiggles_final.jpg
withstyle 4151 4500 style/maya/wiggles_final.jpg
withstyle 4501 4682 style/maya/wiggles_final.jpg style/maya/wiggles-udnie.jpg
withstyle 4683 5470 style/maya/wiggles-udnie.jpg
withstyle 5471 5510 style/maya/wiggles-udnie.jpg style/vid/isheworthy.jpg
withstyle 5511 5580 style/vid/isheworthy.jpg
withstyle 5581 5620 style/vid/isheworthy.jpg style/common/rain_princess.jpg
withstyle 5621 5660 style/common/rain_princess.jpg style/maya/forgodsoloved.jpg
withstyle 5661 5700 style/maya/forgodsoloved.jpg style/mira/phoenix1.jpg
withstyle 5701 5740 style/mira/phoenix1.jpg style/maya/udnie-wiggles.jpg
withstyle 5741 5780 style/maya/udnie-wiggles.jpg style/maya/mayadoodle.jpg
withstyle 5781 5820 style/maya/mayadoodle.jpg style/jus/sheepface.jpg
withstyle 5821 5860 style/jus/sheepface.jpg style/mira/MiraWolf1.jpg
withstyle 5861 5900 style/mira/MiraWolf1.jpg style/other/studentlife-reading.jpg
withstyle 5901 5940 style/other/studentlife-reading.jpg style/maya/wiggles-udnie.jpg
withstyle 5941 5980 style/maya/wiggles-udnie.jpg style/common/la_muse.jpg
withstyle 5981 6020 style/common/la_muse.jpg style/common/the_scream.jpg
withstyle 6021 6060 style/common/the_scream.jpg style/common/starry.jpg
withstyle 6061 6150 style/common/starry.jpg
withstyle 6151 6200 style/common/starry.jpg style/vid/isheworthy.jpg
withstyle 6201 6491 style/vid/isheworthy.jpg

rm $withstyle/*
mv $stagingfolder/* $withstyle
rm x.mp4 withstyle.mp4
ffmpeg -framerate 23.972375 -i $withstyle/%05d.jpg -c:v h264_nvenc $rootfolder/x.mp4
ffmpeg -i $rootfolder/x.mp4 -i $rootfolder/isheworthy.m4a -map 0 -map 1 -c copy -shortest $rootfolder/withstyle.mp4

################################################################################

popd

################################################################################
# Old
################################################################################
## Up to ceiling.
#copy $mixfolder $stagingfolder 1 300
#
## Coming down from ceiling.
#transition.sh $vid original style/common/starry.jpg 300 450
#
## Going around pianist.
#copy $stylefolder/common/starry.jpg $stagingfolder 451 1100
#
## Staying on pianist.
#transition.sh $vid style/common/starry.jpg style/maya/wiggles_final.jpg 1100 1170
#
## Going around.
#copy $stylefolder/maya/wiggles_final.jpg $stagingfolder 1171 1450
#
## Until reminding ourselves.
#transition.sh $vid style/maya/wiggles_final.jpg style/common/starry.jpg 1451 1800
#
## Until howling.
#transition.sh $vid style/common/starry.jpg style/mira/MiraWolf1.jpg 1801 1940
#
## Howling until going around.
#copy $stylefolder/mira/MiraWolf1.jpg $stagingfolder 1941 2100
#
# Going around until piano.
#transition.sh $vid style/mira/MiraWolf1.jpg style/murakami/arhatsdetail.jpg 2100 2500
#
## Piano until he is.
#transition.sh passion style/murakami/arhatsdetail.jpg style/maya/wiggles_final.jpg 3175 3300
#copy $passionfolder/style/maya/wiggles_final.jpg $passionfolder/staging 3301 3581
#move $passionfolder/staging $stylefolder/passion/isheworthy1 3175 3581 -674
#transition.sh $vid style/murakami/arhatsdetail.jpg style/passion/isheworthy1 2501 2540
#copy $stylefolder/passion/isheworthy1 $stagingfolder 2541 2907
#
## Piano pan out.
#copy $stylefolder/maya/wiggles_final.jpg $stagingfolder 2908 3000
#transition.sh $vid style/maya/wiggles_final.jpg original 3001 3100
#
## Father loves us.
#transition.sh $vid original style/common/starry-medium.jpg 3101 3150
#
# Move into passion.
#copy $passionfolder/style/common/starry.jpg $passionfolder/staging 1144 1220
#transition.sh passion style/common/starry.jpg style/maya/wiggles_final.jpg 1221 1260
#copy $passionfolder/style/maya/wiggles_final.jpg $passionfolder/staging 1261 1400
#transition.sh passion staging style/common/starry.jpg 1361 1400
#copy $passionfolder/style/common/starry.jpg $passionfolder/staging 1401 1555
#move $passionfolder/staging $stagingfolder 1144 1555 1997

# Until Jesus our Messiah.
#transition.sh $vid style/common/starry-medium.jpg staging 3141 3150
#move $stagingfolder /tmp 3358 3362 0
#move $stagingfolder $stagingfolder 3363 3552 -5

# Until is anyone worthy.
#copy $passionfolder/style/common/starry.jpg $passionfolder/staging 1586 1640
#transition.sh passion style/common/starry.jpg style/maya/wiggles_final.jpg 1641 1700
#copy $passionfolder/style/maya/wiggles_final.jpg $passionfolder/staging 1701 2046
#move $passionfolder/staging $stagingfolder 1586 2046 1962

#copy $passionfolder/style/maya/wiggles_final.jpg $passionfolder/staging 3662 4410
#move $passionfolder/staging $stagingfolder 3662 4410 347
#move $stagingfolder /tmp 4758 5247 0

#copy $passionfolder/style/maya/wiggles_final.jpg $passionfolder/staging 678 778
#move $passionfolder/staging $stagingfolder 678 778 4080

#move /tmp $stagingfolder 4758 5247 101

#transition.sh $vid style/maya/wiggles_final.jpg style/common/starry.jpg 5349 5678
#transition.sh $vid style/common/starry.jpg original 5679 6491


#mv $stagingfolder/* $finalfolder

