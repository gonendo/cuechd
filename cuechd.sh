#!/bin/bash
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
path=$1

if [ ! $(command -v chdman) ]; then
	log ${red}"[cuechd] Cannot find chdman command"
	exit
fi

log() {
	echo "$1 $2"
	tput init
}
getchdname() {
	chdname=$(echo "$1" | sed 's/.cue/.chd/g')
}

#initialize patterns list
while IFS= read -r line
do
    patterns+=("$line")
done < "patterns.txt"

#find the cue files and compress them to chd
if [ ${#@} -gt 0 ] && [ -d "$path" ]; then
	cues=$(find "$path" -type f -name '*.cue')
	if [ ! ${#cues} -gt 0 ]; then
		log ${red}"[cuechd] No cue files were found"
		exit
	fi
	echo "$cues" | sort -fd | while read -r file
	do
		log ${yellow}"[cuechd] Starting the compression of $file..."
		getchdname "$file"
		chdman createcd -i "$file" -o "$chdname" --force
		if [ -f "$chdname" ]; then
			#delete .cue and its .bin files
			grep "FILE" "$file" | while read -r result
			do
				delfile=$(echo "$result" | sed 's/.*"\(.*\)".*/\1/g')
				rm -rf "$(dirname "$file")/$delfile"
			done
			rm -rf "$file"
			log ${green}"[cuechd] Compression success !"
		else
			log ${red}"[cuechd] Compression failed"
			continue
		fi
		#create m3u file if using multiple discs if a pattern is found
		foundpattern=""
		for pattern in "${patterns[@]}"
		do
			if [[ $file =~ $pattern ]]; then
				foundpattern=$pattern
				break
			fi
		done
		if [ ${#foundpattern} -gt 0 ]; then
			regex=$(echo "s/$foundpattern//" | sed 's/\\//g')
			game=$(echo "$file" | sed "$regex")
			game=$(echo "$game" | sed 's/.cue//')
			if [[ $tmpgame == $game ]]; then
				if [[ $m3u == "$game.m3u" ]] && [ -f "$game.m3u" ]; then
					getchdname "$(basename "$file")"
					echo "$chdname" >> "$game.m3u"
				else
					log ${yellow}"[cuechd] Creating m3u file for $(basename "$game")..."
					rm -rf "$game.m3u"
					getchdname "$(basename "$tmpfile")"
					echo "$chdname" >> "$game.m3u"
					getchdname "$(basename "$file")"
					echo "$chdname" >> "$game.m3u"
					m3u="$game.m3u"
				fi
			fi
			tmpgame=$game
			tmpfile=$file
		fi
	done
else
	log ${red}"[cuechd] Invalid path or missing argument"
fi