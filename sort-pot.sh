#!/bin/bash
VERSION="v1.2"
SCRIPTPATH="$( cd "$(dirname "$0")" || { echo -e "\e[91mERROR\e[0m: Script path cannot be found" ; exit; } >/dev/null 2>&1 ; pwd -P )"

source "$SCRIPTPATH"/creds.txt || { echo -e "\e[91mERROR\e[0m: creds.txt doesn't exist in scritp path" ; exit; }

echo "wpa-sec-api $VERSION by Czechball"

if ping "wpa-sec.stanev.org" -c 1 -w 5 > /dev/null; then
	:
else
	echo -e "\e[91mERROR\e[0m: wpa-sec.stanev.org couldn't be reached, check your internet connection"
	exit
fi

if [[ $1 == "" ]]; then
	if [[ $WPASECKEY == "" ]]; then
		echo -e "\e[91mERROR\e[0m: No wpa-sec key supplied. Enter your key into creds.txt"
		exit
	else
		if test -f "current.potfile"; then
			echo -e "\e[1mcurrent.pot\e[0m exists, downloading remote potfile..."
			./get-pot.sh "$KEY" | sort | uniq -w 12 | cut -d ":" -f 1,3,4 > temp-pot.txt
			if cmp -s temp-pot.txt current.potfile; then
				echo "No new sites cracked."
				rm temp-pot.txt
				exit
			fi
			if test -f "old.potfile"; then
				mkdir -p archive
				TEMPDATE=$(date -r old.potfile "+%Y-%m-%d_%H-%M-%S")
				mv old.potfile "archive/$TEMPDATE-old.potfile"
			fi
			mv current.potfile old.potfile
			mv temp-pot.txt current.potfile
			test -f "old.potfile"
			diff -ua old.potfile current.potfile | grep -Ea "^\+" | tail -n +2 | tr -d "+" > newsites.txt
			WC_LINES=$(wc -l newsites.txt | cut -d " " -f 1)
			echo -e "\e[92m$WC_LINES new sites cracked.\e[0m"
		else
			echo -e "\e[33mNo previous potfiles detected, downloading remote potfile...\e[0m"
			./get-pot.sh "$KEY" | sort | uniq -w 12 | cut -d ":" -f 1,3,4 > current.potfile
		fi
	fi
else
	if test -f "$1"; then
		echo "Parsing custom potfile: $1"
		sort "$1" | uniq -w 12 | cut -d ":" -f 1,3,4 > "parsed-$1"
	else
		echo  "$1 is not a valid file"
		exit
	fi
fi