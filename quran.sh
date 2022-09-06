#!/usr/bin/env bash
########################################################################################################
#                                                                                            ..    .   #
#                                                                                      x .d88"    @88> #
#                x.    .        .u    .                  u.    u.                       5888R     %8P  #
#     .u@u     .@88k  z88u    .d88B :@8c        u      x@88k u@88c.                .    '888R      .   #
#  .zWF8888bx ~"8888 ^8888   ="8888f8888r    us888u.  ^"8888""8888"           .udR88N    888R    .@88u #
# .888  9888    8888  888R     4888>'88"  .@88 "8888"   8888  888R           <888'888k   888R   ''888E`#
# I888  9888    8888  888R     4888> '    9888  9888    8888  888R           9888 'Y"    888R     888E #
# I888  9888    8888  888R     4888>      9888  9888    8888  888R           9888        888R     888E #
# I888  9888    8888 ,888B .  .d888L .+   9888  9888    8888  888R  88888888 9888        888R     888E #
# `888Nx?888   "8888Y 8888"   ^"8888*"    9888  9888   "*88*" 8888" 88888888 ?8888u../  .888B .   888& #
#  "88" '888    `Y"   'YP        "Y"      "888*""888"    ""   'Y"             "8888P'   ^*888%    R888"#
#        88E                               ^Y"   ^Y'                            "P'       "%       ""  #
#        98>                                                                                           #
#        '8                                                                                            #
#         `                                                                                            #
#                                                                                                      #
#      Get the English translation of the verbatim word of Allah, the only God worthy of worship,      #
#                                  Right in your terminal.                                             #
########################################################################################################

# Github: https://github.com/SaminYaser-work/quran-cli
#
#
# Licensed under GNU GENERAL PUBLIC LICENSE Version 3 (GPLv3)
#
# Copyright (C) 2022 Samin Yaser
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

###########################################
# Variables
###########################################

file='./data/saheeh_english_fn.csv'
metadata='./data/metadata.csv'
bookmark_file='./data/bookmark.csv'

RED='\033[0;31m'
NC='\033[0m'
BOLD=$(tput bold)

remove_verse_number='sed "s/([0-9]\+) //g"'
remove_footnote_number='sed "s/\[[0-9]\+\]//g"'
insert_new_line='sed "s/;;/\n\n/g"'
replace_blank_notes='sed "s/::blank::/No notes available/g"'
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

# Error checking functions
# --------------------------

check_ayah_exists_in_a_surah() {
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

check_bookmark_file() {
  if [[ ! -f $bookmark_file ]]; then
    echo -e "${RED}Bookmark file doesn't exist!${NC}"
    exit 1
  fi

  total_bookmarks=$(($(wc -l <$bookmark_file) - 1))

  if [[ $total_bookmarks -lt 1 ]]; then
    echo "No bookmarks found."
    exit 1
  fi
}

check_valid_bookmark() {
  if [[ $1 -gt $(($(wc -l <$bookmark_file) - 1)) || $1 -lt 1 ]]; then
    echo -e "${RED}Error:${NC} Invalid bookmark number."
    exit 1
  fi
}

# Get functions
# ----------------

# Metadata:  _index,_ayas,_start,_name,_tname,_ename,_type,_order,_rukus
# Column No:    1      2     3     4      5      6      7     8      9

# Get the title of the surah
get_surah_title() {
  local res
  res=$(awk -F, -v surah="$1" '$1 == surah {print $4 " | " $5 " ("$6")"}' "$metadata")
  echo "$res"
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

save_bookmark() {
  if [[ ! -f $bookmark_file ]]; then
    echo "No bookmark file found. Creating a new one in $bookmark_file..."
    if touch $bookmark_file; then
      echo "Created new bookmark file at $bookmark_file"
      echo "Surah|Ayah|Date" >$bookmark_file
    else
      echo "Failed to create bookmark file at $bookmark_file."
      exit 1
    fi
  fi

  echo "$1|$2|$(date)" >>$bookmark_file &&
    echo "Bookmark saved." && exit 0

  echo "Failed to write to bookmark file at $bookmark_file."
  exit 1
}

show_bookmarks() {
  check_bookmark_file
  column -t -s '|' $bookmark_file
}

select_bookmark() {
  check_bookmark_file
  check_valid_bookmark "$1"

  s=$(awk -F '|' -v b="$1" 'NR==(b+1) {print $1}' $bookmark_file)
  a=$(awk -F '|' -v b="$1" 'NR==(b+1) {print $2}' $bookmark_file)
  get_surah_title "$s"
  echo
  get_ayah_of_a_surah "$s" "$a"
  print_footnotes "$s" "$a"
}

delete_bookmark() {
  check_bookmark_file
  check_valid_bookmark "$1"

  x=$(($1 + 1))

  sed -i "${x}d" $bookmark_file
  echo "Bookmark deleted."
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
  res=$(awk -F '|' '{print $5"\n"}' "$file" | eval "$insert_new_line" | eval "$replace_blank_notes")
  echo "$res"
}

# TODO: Format output nicely
get_full_quran() {
  local res
  res=$(awk -F '|' '{print $4"|"$5}' "$file" | sed "s/;;/ /g" | eval "$replace_blank_notes")
  echo "$res"
}

get_full_surah() {
  local res
  res=$(awk -F "|" -v s="$1" '$2 == s {print $4"\n"}' $file)
  echo "$res"
}

get_full_notes() {
  local res
  res=$(awk -F '|' -v s="$1" '$2 == s {print $5"\n"}' "$file" | eval "$insert_new_line" | eval "$footnote_del_blank_line")
  echo "$res"
}

# Get single ayah without verse number and references
get_ayah_simple() {
  local res
  res=$(awk -F "|" -v s="$1" -v a="$2" '$2 == s && $3 == a {print $4}' $file | eval "$remove_verse_number" | eval "$remove_footnote_number")
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
  res=$(awk -F "|" -v a="$1" '$1 == a {print $5 "\n"}' $file | eval "$insert_new_line" | eval "$footnote_del_blank_line")
  echo "$res"
}

get_footnotes_of_ayah_in_a_surah() {
  local res
  res=$(awk -F '|' -v s="$1" -v a="$2" '$2 == s && $3 == a {print $5 "\n"}' $file | eval "$insert_new_line" | eval "$footnote_del_blank_line")
  echo "$res"
}

get_footnote_header() {
  echo
  echo "Footnotes:"
  echo ----------
}

print_footnotes() {
  if [[ "$#" -eq 1 ]]; then
    footnotes=$(get_verse_note "$1")
  else
    footnotes=$(get_footnotes_of_ayah_in_a_surah "$1" "$2")
  fi
  if [[ -n $footnotes ]]; then
    get_footnote_header
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

while getopts 'ahslv:i:B:b:d:' opt; do
  case "$opt" in
  h)
    print_help
    exit 0
    ;;

  a) # TODO: Needs more work
    all=1
    echo "This feature is not yet implemented."
    exit 1
    ;;

  s)
    check_surah_exists "$2"
    check_ayah_exists_in_a_surah "$2" "$3"
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

  B)
    save_bookmark "$OPTARG" "$3"
    exit 0
    ;;

  b)
    select_bookmark "$OPTARG"
    exit 0
    ;;

  d)
    delete_bookmark "$OPTARG"
    exit 0
    ;;

  l)
    show_bookmarks
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
# if [[ $all -eq 1 ]]; then
# fi

# The default output when no options are passed

if [[ -z $2 ]]; then
  # Prints a full surah
  check_surah_exists "$1"
  get_surah_title "$1"
  echo
  get_full_surah "$1"
  get_footnote_header
  get_full_notes "$1"

else
  # Print a specific ayah of a surah
  check_ayah_exists_in_a_surah "$1" "$2"
  get_surah_title "$1"
  echo
  get_ayah_of_a_surah "$1" "$2"
  print_footnotes "$1" "$2"
fi
