#!/bin/bash

name=$1
from=/home/$name/
to=/backups_lab/home/$name/


# Check if directory for user-parameter exists
if [ ! -d "$to" ]; then
	echo "'$1' nicht gefunden, ist der Name richtig geschrieben? (Y/N)"
	read -n 1 choice && echo ""

	if [ $choice = "y" -o $choice = "Y" ]; then
		echo "Soll ein neuer Backup-Ordner angelegt werden? (Y/N)"
		read -n 1 choice

		if [ $choice = "y" -o $choice = "Y" ];then
			echo "" && mkdir $to
		else
			echo "" && exit
		fi
	else
		echo "" && exit
	fi
fi


today=$(date +"%Y-%m-%d")
file_name="backup_home_${name}_${today}.tar.bz2"

echo "Geniere backup '$file_name'..."
sudo tar -cjf "$to$file_name" -C "$from" . && echo "Fertig!"


# Check if old backups exist (not current month)
old_backups=$(ls $to | grep "backup_home_$name" | grep -v $(date +"%Y-%m"))
old_months=$(echo "$old_backups" | cut -d '_' -f 4 | cut -d '-' -f 1,2 | sort | uniq)

if [ -n "$old_months" ]; then
	echo "" && echo "Alte Backups gefunden für: " && echo "$old_months" && echo ""
	echo "Sollen die alten Backups gelöscht werden? (Y/N)"
	read -n 1 choice && echo ""

	if [ $choice = "y" -o $choice = "Y" ]; then
		for old_month in $old_months; do
			echo "" && echo "Lösche Monat: $old_month? (Y/N)"
			read -n 1 choice && echo ""

			if [ $choice = "y" -o $choice = "Y" ]; then
				month_files=$(ls ${to}backup_home_${name}_${old_month}-*.tar.bz2)
				rm $month_files && echo "$old_month gelöscht!"
			else
				echo "$old_month beibehalten!"
			echo ""
			fi
		done
		echo "" &&echo "Fertig!" && echo ""
	fi
else
	echo "" && echo "Keine alten Backups gefunden!"
fi
