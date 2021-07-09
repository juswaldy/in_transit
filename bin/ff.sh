#!/bin/bash


#ffmpeg -i starry.jpg/%05d.jpg -c:v h264_nvenc starry.mp4

#ffmpeg -i Andrew\ Peterson\ -\ Is\ He\ Worthy-OIahc83Kvp4.mp4 -filter:v "crop=1280:532:0:95" -q:v 1 original/%05d.jpg
#ffmpeg -i Andrew\ Peterson\ -\ Is\ He\ Worthy-OIahc83Kvp4.mp4 -vn -acodec copy isheworthy.m4a
#ffmpeg -framerate 23.972375 -i original/%05d.jpg -c:v h264_nvenc original.mp4

#ffmpeg -i Beautiful\ Passion\ of\ the\ Christ\ montage\ cut\ to\ inspired\ music-GH-bY-U014M.mp4 -r 1/1 passion/%05d.jpg
#ffmpeg -i Beautiful\ Passion\ of\ the\ Christ\ montage\ cut\ to\ inspired\ music-GH-bY-U014M.mp4 -filter:v "crop=1280:532:0:90" passion.mp4
#ffmpeg -i passion.mp4 passion/%05d.jpg

#ffmpeg -start_number 300 -i %05d.jpg -c:v h264_nvenc x.mp4
#ffmpeg -start_number 1100 -i %05d.jpg -c:v h264_nvenc x.mp4

#ffmpeg -start_number 2101 -i staging/%05d.jpg -c:v h264_nvenc staging.mp4
#rm x.mp4 staging.mp4
#ffmpeg -framerate 23.972375 -i staging/%05d.jpg -c:v h264_nvenc x.mp4
#ffmpeg -i x.mp4 -i isheworthy.m4a -map 0 -map 1 -c copy -shortest staging.mp4

#ffmpeg -framerate 23.972375 -i final/%05d.jpg -c:v h264_nvenc final.mp4
#ffmpeg -i final.mp4 -i isheworthy.mp3 -map 0 -map 1 -c copy -shortest worthy.mp4
#ffmpeg -i final.mp4 -i isheworthy.m4a -map 0 -map 1 -c copy -shortest isheworthy.mp4

vid=isheworthy
fps=23.972375
rootfolder=/home/jus/notebook/jus/styletransfer/vids/${vid}
stylefolder=${rootfolder}/style
allfolder=${rootfolder}/all

i=1
step=$1

#for style in skies/samantha-smaller.jpg skies/kyle_1-small.jpg other/ygartua.sunmask-small.jpg other/ygartua-portofino1-small.jpg other/tremblay-Whats-he-building-in-there.jpg other/lecoy.trypophobia.jpg other/dawes.milllakepark.jpg other/ygartua.reflections-small.jpg murakami/giantDOB-small.jpg flower/tulip.jpg food/dennys-nachos.jpg; do
#for style in maya/wiggles_final.jpg maya/udnie-wiggles.jpg maya/wiggles-udnie.jpg other/dawes.milllakepark.jpg mira/phoenix1.jpg maya/forgodsoloved.jpg common/starry.jpg common/starry-large.jpg common/udnie.jpg common/the_scream.jpg common/rain_princess.jpg common/la_muse.jpg common/wave.jpg other/tremblay-Whats-he-building-in-there.jpg skies/samantha-small.jpg skies/samantha-large.jpg skies/samantha-smaller.jpg maya/lingling.thankyou.jpg skies/kyle_1-small.jpg maya/mayadoodle.jpg jus/lamb3nooval.jpg jus/sheepface.jpg other/studentlife-reading.jpg jus/crosshill.jpg other/ygartua.portofino1-small.jpg other/ygartua.sunmask-small.jpg other/ygartua.reflections-small.jpg murakami/arhatsdetail.jpg murakami/giantDOB-small.jpg other/lecoy.trypophobia.jpg flower/leaf.jpg flower/blurryviolet.jpg flower/tulip.jpg food/dennys-grandslam.jpg food/dennys-nachos.jpg food/dognoodle.jpg; do
#for pair in "maya/wiggles_final.jpg maya/udnie-wiggles.jpg" "maya/wiggles-udnie.jpg other/dawes.milllakepark.jpg" "mira/phoenix1.jpg maya/forgodsoloved.jpg" "common/starry.jpg common/starry-large.jpg" "common/udnie.jpg common/the_scream.jpg" "common/rain_princess.jpg common/la_muse.jpg" "common/wave.jpg other/tremblay-Whats-he-building-in-there.jpg" "skies/samantha-small.jpg skies/samantha-large.jpg" "skies/samantha-smaller.jpg maya/lingling.thankyou.jpg" "skies/kyle_1-small.jpg maya/mayadoodle.jpg" "jus/lamb3nooval.jpg jus/sheepface.jpg" "other/studentlife-reading.jpg jus/crosshill.jpg" "other/ygartua.portofino1-small.jpg other/ygartua.sunmask-small.jpg" "other/ygartua.reflections-small.jpg murakami/arhatsdetail.jpg" "murakami/giantDOB-small.jpg other/lecoy.trypophobia.jpg" "flower/leaf.jpg flower/blurryviolet.jpg" "flower/tulip.jpg food/dennys-grandslam.jpg" "food/dennys-nachos.jpg food/dognoodle.jpg"; do
#for pair in "skies/samantha-small.radial.jpg skies/samantha-small.horz.jpg" "skies/samantha-small.vert.jpg maya/lingling.thankyou.radial.jpg"; do
#for pair in "skies/samantha-large.radial.jpg maya/aok.radial.jpg"; do
#for pair in "skies/samantha-smaller.radial.jpg skies/samantha-smaller.horz.jpg" "skies/samantha-smaller.vert.jpg skies/samanthasketch.jpg"; do
#for pair in "maya/moomin_corrected.jpg maya/handpower.jpg" "maya/minoru.jpg maya/uzi_pakkard.jpg" "maya/katamari_day-small.jpg maya/katamari_night-small.jpg"; do
for pair in "maya/katamari_day-smaller.jpg maya/katamari_night-smaller.jpg" "maya/moomin_corrected-small.jpg maya/uzi_pakkard-small.jpg"; do
	for style in $pair; do
		result=`echo $style|sed 's/\//./'`
		echo $result
		if [ $step == 1 ]; then
			rm $allfolder/x$i.mp4
			if (($i % 2 == 1)); then
				ffmpeg -framerate $fps -i $stylefolder/$style/%05d.jpg -c:v h264_nvenc $allfolder/x$i.mp4 &
			else
				ffmpeg -framerate $fps -i $stylefolder/$style/%05d.jpg -c:v h264_nvenc $allfolder/x$i.mp4
				sleep 7
			fi
		else
			ffmpeg -i $allfolder/x$i.mp4 -i $rootfolder/$vid*.m4a -map 0 -map 1 -c copy -shortest $allfolder/$result.mp4
			rm $allfolder/x$i.mp4
		fi
		let "i++"
	done
done
