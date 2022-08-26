#!/bin/bash

###########################################
# Variables
###########################################

file='./data/saheeh_english_fn.csv'
metadata='./data/metadata.csv'
RED='\033[0;31m'
NC='\033[0m'
BOLD=$(tput bold)

remove_verse_number='sed "s/([0-9]\+) //g"'
footnote_new_line='sed "s/;;/\n\n/g"'
footnote_del_blank_line='sed "/::blank::/{N;d;}"'

# Arguments
surah=$1
ayah=$2
ayahLast=$3

# flags
all=0
no_footnote=0
range_given=0
output_verse=0

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
if [[ $surah -gt 115 ]]; then
  echo -e "${RED}Error:${NC} There are only 114 surahs in the Noble Quran."
  exit 1
fi

###########################################
# Functions
###########################################

check_ayah_exists() {
  num_of_ayahs=$(awk -F, -v surah="$1" '$1 == surah {print $2}' $metadata)
  if [[ $2 -gt $num_of_ayahs || $2 -lt 1 ]]; then
    echo -e "${RED}Error:${NC} Surah $(get_surah_name_transliterated "$1") only has $num_of_ayahs ayahs."
    exit 1
  fi
}

check_surah_exists() {
  if [[ $1 -gt 114 || $1 -lt 1 ]]; then
    echo -e "${RED}Error:${NC} There are only 114 surahs in the Noble Quran."
    exit 1
  fi
}

check_verse_exists() {
  if [[ $1 -gt 6236 || $1 -lt 1 ]]; then
    echo -e "${RED}Error:${NC} There are only 6236 verses in the Noble Quran."
    exit 1
  fi
}

# Get the transliterated name of the surah
get_surah_name_transliterated() {
  local res
  res=$(awk -F, -v surah="$1" '$1 == surah {print $5}' "$metadata")
  echo "$res"
}

get_surah_title_by_verse() {
  local res
  res=$(awk -F, -v verse="$1" '$3+1 > verse {print f;exit;} {f=$4 " | " $5 " ("$6")"}' "$metadata") # Prints the line before the match is found
  echo "$res"
}

# Get the title of the surah
get_sruah_title() {
  # _index,_ayas,_start,_name,_tname,_ename,_type,_order,_rukus

  local res
  res=$(awk -F, -v surah="$surah" '$1 == surah {print $4 " | " $5 " ("$6")"}' "$metadata")
  echo "$res"
}

# Prints full information about the surah
get_surah_info() {
  local res
  res=$(awk -F, -v surah="$1" '$1 == surah {print "Index: " $1 "\nNumber of Ayahs: " $2 "\nStarting Verse Number: " $3+1 "\nName: " $4 "\nName (Transliterated): " $5 "\nName (Translation): " $6 "\nType: " $7 "\nOrder: " $8 "\nNumber of Rukūʿ: " $9}' "$metadata")
  echo "$res"
}

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

# TODO: Format output nicely
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
  res=$(awk -F "|" -v s="$1" -v a="$2" '$2 == s && $3 == a {print $4}' $file | eval "$remove_verse_number" | sed "s/\[[0-9]\+\]//g")
  echo "$res"
}

get_ayah_of_a_surah() {
  local res
  res=$(awk -F "|" -v s="$1" -v a="$2" '$2 == s && $3 == a {print $4 "\n"}' $file)
  echo "$res"
}

get_verse() {
  local res
  res=$(awk -F "|" -v a="$1" '$1 == a {print $4 "\n"}' $file | eval "$remove_verse_number")
  echo "$res"
}

get_verse_note() {
  local res
  res=$(awk -F "|" -v a="$ayah" '$1 == a {print $5 "\n"}' $file | eval "$footnote_new_line" | eval "$footnote_del_blank_line")
  echo "$res"
}

get_note() {
  local res
  res=$(awk -F '|' -v s="$surah" -v a="$ayah" '$2 == s && $3 == a {print $5 "\n"}' $file | eval "$footnote_new_line" | eval "$footnote_del_blank_line")
  echo "$res"
}

print_footnotes() {
  footnotes=$(get_verse_note "$1")
  if [[ -n $footnotes ]]; then
    echo
    echo "Footnotes:"
    echo ----------
    echo "$footnotes"
  fi
  exit 0
}

# TODO: Print a help message
print_help() {
  printf "Usage: Under construction\nFor now, please refer to the README.md file on GitHub.\n"
}

###########################################
# Parsing arguments
###########################################

while getopts 'ahsv:i:' opt; do
  case "$opt" in
  a) # TODO: Needs more work
    all=1
    ;;

  s)
    check_surah_exists "$2"
    check_ayah_exists "$2" "$3"
    get_ayah_simple "$2" "$3"
    exit 0
    ;;

  v)
    check_verse_exists "$OPTARG"
    get_surah_title_by_verse "$OPTARG"
    echo
    get_verse "$OPTARG"
    print_footnotes "$OPTARG"
    exit 0
    ;;

  i)
    check_surah_exists "$OPTARG"
    get_surah_info "$OPTARG"
    exit 0
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

# Get the whole surah and footnotes
if [[ -z $ayah ]]; then
  ayahs=$(get_full_surah)
  footnotes=$(get_full_notes)
fi

# The default output when no options are passed
check_ayah_exists "$1" "$2"
get_sruah_title "$1"
echo
get_ayah_of_a_surah "$1" "$2"
print_footnotes "$1" "$2"
