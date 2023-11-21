#!/usr/bin/env bash

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load 'test_helper/bats-files/load'
    DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
}

@test "Can run the script" {
    ./quran
}

@test "Print help" {
    run ./quran -h
    assert_success
    assert_output --partial "Usage: Under construction"
}

@test "Print help when no arguments given" {
    run ./quran
    assert_success
    assert_output --partial "Usage: Under construction"
}

@test "Print information about a surah" {
    run ./quran -i 1
    assert_success
    assert_output --partial "Index: 1
Number of Ayahs: 7
Starting Verse Number: 1
Name: الفاتحة
Name (Transliterated): Al-Faatiha
Name (Translation): The Opening
Type: Meccan
Order: 5
Number of Rukūʿ: 1"
}

@test "Print ayah of a surah with footenotes" {
    run ./quran 2 1
    assert_success
    assert_output --partial "Alif, Lām, Meem."
    assert_output --partial "These are among the fourteen opening letters which occur in various combinations"
}

@test "Print ayah of a surah but no footenotes" {
    run ./quran -f 2 1
    assert_success
    assert_output --partial "Alif, Lām, Meem."
    refute_output --partial "These are among the fourteen opening letters which occur in various combinations"
}

@test "Print ayahs of a surah in a specified range with footnotes" {
    run ./quran -r 2 1 3
    assert_success
    assert_output --partial "Alif, Lām, Meem."
    assert_output --partial "This is the Book about which there is no doubt"
    assert_output --partial "Who believe in the unseen"
    assert_output --partial "Who believe in the unseen"
    assert_output --partial "These are among the fourteen opening letters which occur in various combinations"
    assert_output --partial "It is to be noted that the reference of Allāh"
}

@test "Print an ayah in simple format" {
    run ./quran -s 2 1
    assert_success
    assert_output "Alif, Lām, Meem."
}

@test "Print an ayah in verse format with footnotes" {
    run ./quran -v 8
    assert_success
    assert_output --partial "Alif, Lām, Meem."
    assert_output --partial "These are among the fourteen opening letters which occur in various combinations"
}

@test "Print a full full surah with footnotes" {
    run ./quran 112
    assert_success
    assert_output --partial 'Say, "He is Allāh, [who is] One'
    assert_output --partial 'Nor is there to Him any equivalent.'
    assert_output --partial 'Alone, without another, indivisible with absolute and permanent unity and distinct from all else.'
    assert_output --partial 'He who is absolute, perfect, complete, essential, self-sufficient and sufficient'
}

@test "Print error message when surah number is invalid" {
    run ./quran 1000 1
    assert_failure
    assert_output --partial "There are only 114 surahs in the Noble Quran."
}

@test "Print error message when surah number is valid but ayah number is invalid" {
    run ./quran 1 8
    assert_failure
    assert_output --partial "only has 7 ayahs."
}

@test "Print error message when verse number is invalid" {
    run ./quran -v 7000
    assert_failure
    assert_output --partial "There are only 6236 verses in the Noble Quran."
}
