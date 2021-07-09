#!/bin/bash

action=$1

################################################################################
## Grab youtube video.
################################################################################
if [ $action == "youtube" ]; then
	youtube-dl -f22 xPIanlF6IwM

################################################################################
## Convert multiple pdfs to jpg, and back to single pdf.
################################################################################
elif [ $action == "journal" ]; then
	pushd /mnt/d/0/faith/journal

	convert -density 300 2016.01.JanMar.pdf -quality 100 merge/2016.01.JanMar.pdf-%03d.jpg
	convert -density 300 2016.02.AprMay.pdf -quality 100 merge/2016.02.AprMay.pdf-%03d.jpg
	convert -density 300 2016.03.Jun.pdf -quality 100 merge/2016.03.Jun.pdf-%03d.jpg
	convert -density 300 2016.04.JulSep.pdf -quality 100 merge/2016.04.JulSep.pdf-%03d.jpg
	convert -density 300 2016.05.OctDec.pdf -quality 100 merge/2016.05.OctDec.pdf-%03d.jpg
	cp 2016.Spring.SonOfDestruction.jpg merge

	convert -density 300 2017.01.JanMar.pdf -quality 100 merge/2017.01.JanMar.pdf-%03d.jpg
	convert -density 300 2017.02.AprMay.pdf -quality 100 merge/2017.02.AprMay.pdf-%03d.jpg
	convert -density 300 2017.03.JunAug.pdf -quality 100 merge/2017.03.JunAug.pdf-%03d.jpg
	convert -density 300 2017.04.SepDec.pdf -quality 100 merge/2017.04.SepDec.pdf-%03d.jpg
	cp 2017.05.Fivethousand.jpg merge

	convert -density 300 2018.01.JanMay.pdf -quality 100 merge/2018.01.JanMay.pdf-%03d.jpg
	convert -density 300 2018.02.MayOct.pdf -quality 100 merge/2018.02.MayOct.pdf-%03d.jpg
	convert -density 300 2018.03.NovDec.pdf -quality 100 merge/2018.03.NovDec.pdf-%03d.jpg

	convert -density 300 2019.01.JanSep.pdf -quality 100 merge/2019.01.JanSep.pdf-%03d.jpg
	convert -density 300 2019.02.OctDec.pdf -quality 100 merge/2019.02.OctDec.pdf-%03d.jpg
	cp 2019.chokhma.jpg 2019.judas.jpg merge

	pushd merge
	convert 2016.*.jpg 2016.pdf
	convert 2017.*.jpg 2017.pdf
	convert 2018.*.jpg 2018.pdf
	convert 2019.*.jpg 2019.pdf
	popd

	popd

################################################################################
## Run job schedule collection, tar viz data folder and send to clover.
################################################################################
elif [ $action == "sched" ]; then
	pushd /mnt/c/github/ReleaseManagement/Schedules

	# Hourly on the hour.
	/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe ./Generate-JobSchedule.ps1 -Environment Prod -Window ThisHour
	/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe ./Generate-JobSchedule.ps1 -Environment Prod -Window FourHours

	# Daily at midnight.
	current_hour=`date +%H`
	if [ $current_hour -eq 0 ]; then
		/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe ./Generate-JobSchedule.ps1 -Environment Prod -Window Today

		# Weekly on Sunday.
		current_weekday=`date +%u`
		if [ $current_weekday -eq 7 ]; then
			/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe ./Generate-JobSchedule.ps1 -Environment Prod -Window ThisWeek

			# Convert source csv to target html for this week.
			source_csv=data/ThisWeek.csv
			target_html=data/ThisWeek.html

			# Make preamble.
			echo '<html>' > $target_html
			echo '<head>' >> $target_html
			echo '<link rel="stylesheet" href="../w3.css">' >> $target_html
			echo '<title>This Week</title>' >> $target_html
			echo '</head>' >> $target_html
			echo '<body>' >> $target_html
			echo '<table class="w3-table w3-bordered w3-tiny">' >> $target_html
			echo '<tr><th>start_time</th><th>server</th><th>job</th><th>cost</th></tr>' >> $target_html

			# Main content.
			tail -n +2 $source_csv | sed 's/^"/<tr><td>/;s/","/<\/td><td>/g;s/".*$/<\/td><\/tr>/' >> $target_html

			# Make footer.
			echo '</table>' >> $target_html
			echo '</body>' >> $target_html
			echo '</html>' >> $target_html

		fi
	fi

	# Make tarball, send, unpack, and deliver.
	rm -f data.tar.gz
	tar cvf data.tar data
	gzip -9 data.tar
	echo "put data.tar.gz" | sftp -b - jus@cloveretl
	ssh jus@cloveretl "tar zxvf data.tar.gz; sudo cp -rp data /opt/tomcat_clover/webapps/apps/IT/ScheduledJobs; rm -rf data*"

	popd

################################################################################
## Restart the cron service.
################################################################################
elif [ $action == "cron" ]; then
	sudo servie cron restart

################################################################################
## Ensure VAERS metadata consistency.
################################################################################
elif [ $action == "vaers" ]; then
	sourcefolder=/mnt/c/Users/Juswaldy.Jusman/Downloads/AllVAERSDataCSVS

	pushd $sourcefolder
	y1=1990
	for n in `seq 1 31`; do
		y2=$((y1+1))
		echo --------------------------------------------------------------------------------
		echo $y1 $y2
		for x in DATA SYMPTOMS VAX; do
			echo $x
			head -1 ${y1}VAERS${x}.csv > /tmp/d1.txt
			head -1 ${y2}VAERS${x}.csv > /tmp/d2.txt
			diff /tmp/d1.txt /tmp/d2.txt
		done
		y1=$y2
	done
	popd

################################################################################
fi
