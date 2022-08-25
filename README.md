# quran-cli

Get the English translation of the verbatim word of Allah, the only God worthy of worship, right in your terminal.

## Usage
```bash
./quran.sh <surah number> [verse number]
```

### Examples:
```
$ ./quran.sh 1 1
الفاتحة | Al-Faatiha (The Opening)

(1) In the name of Allāh,[2] the Entirely Merciful, the Especially Merciful.[3]

Footnotes:
----------
[2]- Allāh is a proper name belonging only to the one Almighty God, Creator and Sustainer of the heavens and the earth and all that is within them, the Eternal and Absolute, to whom alone all worship is due.

[3]- Ar-Raḥmān and ar-Raḥeem are two names of Allāh derived from the word "raḥmah" (mercy) . In Arabic grammar both are intensive forms of "merciful" (i.e., extremely merciful) . A complimentary and comprehensive meaning is intended by using both together. Raḥmān is used only to describe Allāh, while raḥeem might be used to describe a person as well. The Prophet (ﷺ) was described in the Qur’ān as raḥeem. Raḥmān is above the human level (i.e., intensely merciful) . Since one usually understands intensity to be something of short duration, Allāh describes Himself also as raḥeem (i.e., continually merciful) . Raḥmān also carries a wider meaning - merciful to all creation. Justice is a part of this mercy. Raḥeem includes the concept of speciality - especially and specifically merciful to the believers. Forgiveness is a part of this mercy. In addition, Raḥmān is adjectival, referring to an attribute of Allāh and is part of His essence. Raḥeem is verbal, indicating what He does: i.e., bestowing and implementing mercy.
```

Omit the ayah to print the full surah with footnotes.
```
$ ./quran.sh 1
الفاتحة | Al-Faatiha (The Opening)

(1) In the name of Allāh,[2] the Entirely Merciful, the Especially Merciful.[3]

(2) [All] praise is [due] to Allāh, Lord[4] of the worlds -

(3) The Entirely Merciful, the Especially Merciful,

(4) Sovereign of the Day of Recompense.[5]

(5) It is You we worship and You we ask for help.

(6) Guide us to the straight path -

(7) The path of those upon whom You have bestowed favor, not of those who have earned [Your] anger or of those who are astray.

Footnotes:
----------
[2]- Allāh is a proper name belonging only to the one Almighty God, Creator and Sustainer of the heavens and the earth and all that is within them, the Eternal and Absolute, to whom alone all worship is due.

[3]- Ar-Raḥmān and ar-Raḥeem are two names of Allāh derived from the word "raḥmah" (mercy) . In Arabic grammar both are intensive forms of "merciful" (i.e., extremely merciful) . A complimentary and comprehensive meaning is intended by using both together. Raḥmān is used only to describe Allāh, while raḥeem might be used to describe a person as well. The Prophet (ﷺ) was described in the Qur’ān as raḥeem. Raḥmān is above the human level (i.e., intensely merciful) . Since one usually understands intensity to be something of short duration, Allāh describes Himself also as raḥeem (i.e., continually merciful) . Raḥmān also carries a wider meaning - merciful to all creation. Justice is a part of this mercy. Raḥeem includes the concept of speciality - especially and specifically merciful to the believers. Forgiveness is a part of this mercy. In addition, Raḥmān is adjectival, referring to an attribute of Allāh and is part of His essence. Raḥeem is verbal, indicating what He does: i.e., bestowing and implementing mercy.

[4]- When referring to Allāh (subḥānahu wa taʿālā) , the Arabic term "rabb" (translated as "Lord") includes all of the following meanings: "owner, master, ruler, controller, sustainer, provider, guardian and caretaker."

[5]- i.e., repayment and compensation for whatever was earned of good or evil during life on this earth.
```

`-s` flag simply outputs an Ayah. No verse number or footnotes. Good for piping to other programs.
```
$ ./quran.sh -s 21 35
Every soul will taste death. And We test you with evil and with good as trial; and to Us you will be returned.

$ ./quran.sh -s 2 1 | figlet
    _    _ _  __    _     _   _                __  __                       
   / \  | (_)/ _|  | |   (_)_(_) _ __ ___     |  \/  | ___  ___ _ __ ___    
  / _ \ | | | |_   | |     /_\  | '_ ` _ \    | |\/| |/ _ \/ _ \ '_ ` _ \   
 / ___ \| | |  _|  | |___ / _ \ | | | | | |_  | |  | |  __/  __/ | | | | |_ 
/_/   \_\_|_|_|( ) |_____/_/ \_\|_| |_| |_( ) |_|  |_|\___|\___|_| |_| |_(_)
               |/                         |/                                

```
Print an Ayah by verse number (independently of surah number) using the `-v` flag.
```
$ ./quran.sh -v 10
Who believe in the unseen, establish prayer,[9] and spend out of what We[10] have provided for them,

Footnotes:
----------
[9]- At its proper times and according to its specified conditions.

[10]- It is to be noted that the reference of Allāh (Subḥānahu wa taʿālā) to Himself as "We" in many Qur’ānic verses is necessarily understood in the Arabic language to denote grandeur and power, as opposed to the more intimate singular form "I" used in specific instances.
```
`-i` flag prints full information about a Surah.
```
$ ./quran.sh -i 18
Index: 18
Number of Ayahs: 110
Starting Verse Number: 2141
Name: الكهف
Name (Transliterated): Al-Kahf
Name (Translation): The Cave
Type: Meccan
Order: 69
Number of Rukūʿ: 12
```