#!/bin/bash

file='./data/saheeh_english_fn.csv'
RED='\033[0;31m'
NC='\033[0m'
BOLD=$(tput bold)

surah=$1
ayah=$2

# Check if surah is valid
if [[ $surah -gt 144 ]]; then
  echo -e "${RED}Error:${NC} There are only 114 surahs in the Noble Quran."
  exit 1
fi

# Functions
get_full_surah()
{
  local res
  res=$(awk -F "|" -v s="$surah" '$2 == s {print $4"\n"}' $file)
  echo "$res"
}

get_full_notes()
{
  local res
  res=$(awk -F '|' -v s="$surah" '$2 == s {print $5"\n"}' "$file" | sed "s/;;/\n\n/g" | sed "/::blank::/{N;d;}")
  echo "$res"
}

get_ayah()
{
  local res
  res=$(awk -F "|" -v s="$surah" -v a="$ayah" '$2 == s && $3 == a {print $4 "\n"}' $file)
  echo "$res"
}

get_note()
{
  local res
  res=$(awk -F '|' -v s="$surah" -v a="$ayah" '$2 == s && $3 == a {print $5 "\n"}' $file | sed "s/;;/\n\n/g" | sed "/::blank::/{N;d;}")
  echo "$res"
}

# Get the whole surah and footnotes
if [[ -z $ayah ]]; then
  ayahs=$(get_full_surah)
  footnotes=$(get_full_notes)

# Get specific ayah and footnotes
else
  ayahs=$(get_ayah)
  footnotes=$(get_note)
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
