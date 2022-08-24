#!/bin/bash

###########################################
# Variables
###########################################

file='./data/saheeh_english_fn.csv'
RED='\033[0;31m'
NC='\033[0m'
BOLD=$(tput bold)

# Arguments
surah=$1
ayah=$2
ayahLast=$3

# flags
all=0
no_footnote=0
range_given=0
simple_output=0

if [[ -n $ayahLast ]]; then
  range_given=1
fi

###########################################
# Error handling
###########################################

# Check if the surah is non-empty
if [ -z "$surah" ]; then
  echo -e "${RED}Surah number is required.${NC}"
  print_help
  exit 1
fi

# Check if surah is valid
if [[ $surah -gt 144 ]]; then
  echo -e "${RED}Error:${NC} There are only 114 surahs in the Noble Quran."
  exit 1
fi

###########################################
# Functions
###########################################

get_all_ayahs() {
  local res
  res=$(awk -F "|" '{print $4""}' $file)
  echo "$res"
}

get_all_notes() {
  local res
  # res=$(awk -F '|' '{print $5"\n"}' "$file" | sed "s/;;/\n\n/g" | sed "s/::blank::/No notes available/g")
  res=$(awk -F '|' '{print $5"\n"}' "$file" | sed "s/;;/ /g" | sed "s/::blank::/No notes available/g")
  echo "$res"
}

get_full_quran() {
  local res
  res=$(awk -F '|' '{print $4"|"$5}' "$file" | sed "s/;;/ /g" | sed "s/::blank::/No notes available/g")
  echo "$res"
}

get_full_surah() {
  local res
  res=$(awk -F "|" -v s="$surah" '$2 == s {print $4"\n"}' $file)
  echo "$res"
}

get_full_notes() {
  local res
  res=$(awk -F '|' -v s="$surah" '$2 == s {print $5"\n"}' "$file" | sed "s/;;/\n\n/g" | sed "/::blank::/{N;d;}")
  echo "$res"
}

# Get single ayah without verse number and references
get_ayah_simple() {
  local res
  res=$(awk -F "|" -v s="$surah" -v a="$ayah" '$2 == s && $3 == a {print $4}' $file | sed "s/([0-9]\+) //g" | sed "s/\[[0-9]\+\]//g")
  echo "$res"
}

get_ayah() {
  local res
  res=$(awk -F "|" -v s="$surah" -v a="$ayah" '$2 == s && $3 == a {print $4 "\n"}' $file)
  echo "$res"
}

get_note() {
  local res
  res=$(awk -F '|' -v s="$surah" -v a="$ayah" '$2 == s && $3 == a {print $5 "\n"}' $file | sed "s/;;/\n\n/g" | sed "/::blank::/{N;d;}")
  echo "$res"
}

print_help() {
  printf "Usage: quran.sh [OPTION]\nUnder construction"
}

###########################################
# Parsing arguments
###########################################

while getopts 'ahs' opt; do
  case "$opt" in
  a)
    all=1
    ;;

  # h)
  #   arg="$OPTARG"
  #   echo "Processing option 'c' with '${OPTARG}' argument"
  #   ;;
  s)
    simple_output=1
    surah=$2
    ayah=$3
    ;;

  h)
    print_help
    exit 0
    ;;

  :)
    echo -e "option requires an argument."
    print_help
    exit 1
    ;;

  ?)
    echo -e "Invalid command option."
    print_help
    exit 1
    ;;
  esac
done
shift "$((OPTIND - 1))"

###########################################
# Printing results
###########################################

# Printing full Qur'an
if [[ $all -eq 1 ]]; then
  ayahs=$(get_all_ayahs)
  footnotes=$(get_all_notes)

  # paste <(echo "$ayahs") <(echo "$footnotes") | column -s $'\t' -t

  #   cat <<-EOF | column --separator '|' \
  #     --table \
  #     --table-columns C1,C2 \
  #     --table-wrap C1
  #       $(get_full_quran)
  # EOF

  ayahs=$(get_all_ayahs | fold -w 50)
  footnotes=$(get_all_notes | fold -w 30 -s)
  # column --separator
  echo "$ayahs"

  # pr "$ayahs" "$footnotes"
  # echo "$ayahs" | pr -m -T | less
  # pr -w 70 -m -t <(echo "$ayahs") <(echo "$footnotes") | less

  # get_full_quran
  exit 0
fi

# simple output
if [[ $simple_output -eq 1 ]]; then
  echo $(get_ayah_simple)
  exit 0
fi

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
