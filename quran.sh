#!/bin/bash

file='./data/saheeh_english_fn.csv'
RED='\033[0;31m'
NC='\033[0m'
BOLD=$(tput bold)

surah=$1
ayah=$2

if [[ $surah -gt 144 ]]; then
  echo -e "${RED}Error:${NC} There are only 114 surahs in the Noble Quran."
  exit 1
fi

# Get the whole surah and footnotes
if [[ -z $ayah ]]; then
  ayahs=$(awk -F "|" -v s="$surah" '$2 == s {print $4"\n"}' $file)
  footnotes=$(awk -F '|' -v s="$surah" '$2 == s {print $5"\n"}' "$file" | sed "s/;;/\n\n/g" | sed "/::blank::/{N;d;}")

# Get only specific ayah and footnotes
else
  ayahs=$(awk -F "|" -v s="$surah" -v a="$ayah" '$2 == s && $3 == a {print $4 "\n"}' $file)
  footnotes=$(awk -F '|' -v s="$surah" -v a="$ayah" '$2 == s && $3 == a {print $5 "\n"}' $file | sed "s/;;/\n\n/g" | sed "/::blank::/{N;d;}")
fi


if [[ -n $ayahs ]]; then
  echo "$ayahs"
  echo
  echo "Footnotes:"
  echo ----------

  if [[ -z $footnotes ]]; then
    echo "No footnotes available"
  else
    echo "$footnotes"
  fi
  exit 0

else
  echo -e "${RED}Error:${NC} Ayah doens't exist for that surah "
  exit 1
fi
