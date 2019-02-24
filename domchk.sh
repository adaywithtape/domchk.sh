#!/bin/bash
#domchk.sh v0.1a
#By TAPE
#Last edit 28-02-2018 10:00
VERS=$(sed -n 2p $0 | awk '{print $2}')    		#Version information
LED=$(sed -n 4p $0 | awk '{print $3 " " $4}') 	#Date of last edit to script
#
#						TEH COLORZ :D
########################################################################
STD=$(echo -e "\e[0;0;0m")		#Revert fonts to standard colour/format
RED=$(echo -e "\e[1;31m")		#Alter fonts to red bold
REDN=$(echo -e "\e[0;31m")		#Alter fonts to red normal
GRN=$(echo -e "\e[1;32m")		#Alter fonts to green bold
GRNN=$(echo -e "\e[0;32m")		#Alter fonts to green normal
ORN=$(echo -e "\e[1;33m")		#Alter fonts to orange bold
ORNN=$(echo -e "\e[0;33m")		#Alter fonts to orange bold
BLU=$(echo -e "\e[1;36m")		#Alter fonts to blue bold
BLUN=$(echo -e "\e[0;36m")		#Alter fonts to blue normal
#
#						VARIABLES
########################################################################
COLOUR=TRUE		# FALSE = no colours, TRUE = prettified output :D
if [ "$COLOUR" == "FALSE" ] ; then
read RED REDN GRN GRNN ORN ORNN BLU BLUN  <<< $(echo -e "\e[0;0;0m")
fi
#
CCOUNT=25		# To allow the script to start clearing output and avoid error message.
#
#						HEADER
########################################################################
f_header1() {
echo $STD"   _   $BLUN By TAPE$STD    _   _   
 _| |___ _____ ___| |_| |_ 
| . | . |     |  _|   | '_|
|___|___|_|_|_|___|_|_|_,_|$STD"
}

f_header2() {
echo "
       __     $BLUN By TAPE$STD        __    __  
  ____/ /___  ____ ___  _____/ /_  / /__
 / __  / __ \/ __ \`__ \/ ___/ __ \/ //_/
/ /_/ / /_/ / / / / / / /__/ / / / ,<   
\__,_/\____/_/ /_/ /_/\___/_/ /_/_/|_|"
}







#
#						HELP
########################################################################
f_help() {
f_header1
echo $BLUN"> Help information$STD"
echo "
domchk.sh -- (sub)domain checker
Usage: domchk.sh -i <IP address> -d <domain.ext> -w <wordlist> -s <response size>

-d  -- domain.extension
-h  -- This help information
-i  -- IP address
-s  -- Known response size to check against
-w  -- Wordlist
-v  -- Version information

It is recommended to first run without the -s switch to view response sizes of non-existent (sub)domains.
Then to use the -s switch to check for response sizes different from the known ones.

Examples;
./domchk.sh -i 10.10.10.81 -d bart.htb -w /usr/share/seclists/Discovery/DNS/namelist.txt 
./domchk.sh -i 10.10.10.81 -d bart.htb -w /usr/share/seclists/Discovery/DNS/namelist.txt -s 0
"
exit
}
#
#						VERSION INFO
########################################################################
f_vers() {
clear
f_header2
echo $BLUN"> Version information$STD"
echo $STD
echo $STD"domchk.sh $GRNN$VERS$STD Last edit $GRNN$LED$STD

For.. ¯\_(ツ)_/¯ ..the freaks at The HiVE? :D"
exit
}
#
#						OPTION FUNCTIONS
########################################################################
while getopts ":d:hi:s:w:v" opt; do
  case $opt in
	d) DOMEX=$OPTARG ;;
	h) f_help ;;
	i) IP=$OPTARG ;;
	s) SIZE=$OPTARG ;;
	w) WORDLIST=$OPTARG ;;
	v) f_vers ;;
  esac
done
#
#						INPUT CHECKS
########################################################################
#
if [ $# -eq 0 ] ; then clear ; f_help ; exit ; fi							# if no arguments, return help info and quit.
#
if [[ -z $DOMEX ]] ; then 												# check if domain is entered.
	echo "[$RED!$STD] Please enter domain.extension with the$BLUN -d$STD switch"
	echo "[$RED!$STD] Required input: -i <ip address> -d <domain.extension> -w <wordlist>"
	exit
fi
#
if [[ -z $IP ]] ; then 													# check if IP address is entered.
	echo "[$RED!$STD] Please enter IP address with the$BLUN -i$STD switch"
	echo "[$RED!$STD] Required input: -i <ip address> -d <domain.extension> -w <wordlist>"
	exit
fi
#
if [[ -z $WORDLIST ]] ; then 											# check if wordlist is entered. 
	echo "[$RED!$STD] Please enter a /path/to/wordlist with the$BLUN -w$STD switch"
	echo "[$RED!$STD] Required input: -i <ip address> -d <domain.extension> -w <wordlist>"
	exit
fi
#
#
#						START THE WORK!
########################################################################
LENGTH=$(wc $WORDLIST | awk '{print $1}')
echo $BLUN"[+]$STD IP:PORT            : $IP"
echo $BLUN"[+]$STD Domain/Extension   : $DOMEX"
echo $BLUN"[+]$STD Wordlist           : $WORDLIST"
echo $BLUN"[+]$STD Wordlist wordcount : $LENGTH"
echo $BLUN"[+]$STD Known response size: $SIZE"
#
DOMEX=".$DOMEX"
echo $BLUN"PROGRESS  --  RESPONSE SIZE  -- CHECKING (SUB)DOMAIN$STD"
while read WORD; do
	START=$(($START + 1))
	SPACE=$(head -c $CCOUNT < /dev/zero | tr '\0' '\040')
	x=$(curl -s --header "Host: $WORD$DOMEX" $IP | wc -c)
	if [ "$SIZE" != "" ] ; then
			echo -ne "$SPACE \r"
			printf '%-17s %-13s %-1s\r' "$START/$LENGTH" "$x" "$REDN$WORD$DOMEX$STD"
			CCOUNT=$(printf '%-17s %-13s %-1s\r' "$START/$LENGTH" "$x" "$REDN$WORD$DOMEX$STD" | wc -c)
		if [ "$x" != "$SIZE" ] ; then
			printf '%-17s %-13s %-1s\n' "$START/$LENGTH" "$x" "$GRNN$WORD$DOMEX$STD <-- possible domain found"
		fi
	else
		printf '%-17s %-13s %-1s\n' "$START/$LENGTH" "$x" "$WORD$DOMEX"
	fi
done < $WORDLIST
echo $REDN"[!]$STD Completed testing file: $WORDLIST"
exit
