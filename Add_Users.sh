#!/bin/bash
ret="test"
error () 
{
    #ret="test2"
    echo -e ${Red}"ERROR - Script is ending!"
    
    exit 1
}

error2 () 
{
    #ret="test2"
    echo -e ${Cyan}"Script is ending!"
    
    exit 1
}
timestamp() {
  date +"%Y%m%d%H%M%S" # current time
}
Cyan="\033[0;34m"
Orange="\033[0;33m"
Red="\033[0;31m"
Cyan="\033[0;36m"
NC="\033[0m" # No Color

echo -e ${Cyan}"Script starting: Version 5.0.0"${NC}

min=1
max=700
trap 'error "$ret"' ERR 
trap 'error2 "$ret"' EXIT

# input starting number for user
read -p "Enter the starting number for users to add: " numusersstart

re="^[0-9]+$"
if [ -z "$numusersstart" ] ; then
    numusersstart=1
fi

# validate numeric
if ! [[ $numusersstart =~ $re ]] ; then
   echo -e ${Red}"ERROR: Not a number between 0 and 9"${NC} >&2; exit 1
fi

# input number of users to add
read -p "Enter number of users to add between 1 and 7,000: " numusers

#re="^[0-9]+$"
if [ -z "$numusers" ] ; then
    numusers=2
fi

# validate numeric
if ! [[ $numusers =~ $re ]] ; then
   echo -e ${Red}"ERROR: Not a number between 1 and 9"${NC} >&2; exit 1
fi

# validate that it isn't too big of a number
if ! [[ $numusers -gt 0 && $numusers -lt 7001 ]] ; then
   echo -e ${Red}"ERROR: Not a number between 1 and 7,000"${NC} >&2; exit 1
fi

# input the orgname without the https://dev.azure.com/ which will be appended later
read -p "Enter the name of the ADO org to add users to: " orgname

# append ADO URL to get fully qualified organization name
org="https://dev.azure.com/$orgname"

# print initial message to indicate process is starting
echo $numusers " will be created in " $org

echo -e ${Cyan}"\n************"${NC}
echo -e ${Cyan}"Beginning: $numusers users will be created in org $org at $(date)" ${NC}

progbar='#'

fname="./$orgname-$(timestamp).output.json"

# Add the users to the ADO organization looping based on number of users entered
i=1
while [ $i -le $numusers ]
do
    usernumber=$(($numusersstart + $i - 1))

    username="User$usernumber@someurl.com"

    # Add the user and write output to file
    ret=$(az devops user add --email-id $username --license-type express --org $org --send-email-invite false) #>>$fname --output none

    if [ -z "$ret" ] ; then
        echo -e ${Red}"ERROR - no return value from command while adding user ${NC}$username${Red}, please validate if the user was added."
        exit 1
    fi

    echo $ret >>$fname

    # calculate the percentage that has been done     
    pct=$((100 * $i/$numusers))
    filler=$((100-pct))

    # progbarc = the percentage that is completed
    # progbarr = the percentage that is remaining
    # progbar = the complete progress bar to be printed

    progbarc=$(printf '#%.0s' $(seq 1 $pct))
    progbarr=$(printf ' %.0s' $(seq 1 $filler))
    progbar=$progbarc$progbarr
    
#    progbar=$(printf -v f "%100s" ; printf "%s\n" "${f// /#}")

#   print number of users completed out of total, a progress progbar followed by the percentage competed so far
    echo -ne ${Cyan}"$progbar $((100 * $i/$numusers))% - $i of $numusers\r"
    ((i=i+1))
done

# print completed counts
echo -ne "\n"
echo -e "Completed: $numusers users have been added in org $org at $(date)" ${NC}
echo -e ${Cyan}"************\n"${NC}