#!/bin/bash
#####################################################
# v0.2                                              #
# copyleft Sanjay Willie sanjayws@gmail.com         #
# SCRIPT PURPOSE: GENERATE SMS OFFLINE QUEUE        #
# GEN INFO: Change variables sections               #
#####################################################
# This script was edit by Michael A. Gates          #
# becuase it didn't work in Freepbx 5.211.65-12     #
# Asterisk v11.9  OS SHMZ release 6.5 (Final)       #
# I am by no means a Linux guy or a Asterisk        #
# guy (Still learning). Without Sanjay Willie's     #
# work I could not have done this.                  #
#                                                   #
#                                                   #
#Contact: Michael.allen.gates@gmail.com             #
#####################################################

#VARIABLES
maxretry=100            #Number of Atempts for sending the sms
retryint=30             #Number of Seconds between Retries
#CONSTANTS
        ERRORCODE=0
        d_unique=`date +%s`
        d_friendly=`date +%T_%D`
        astbin=`which asterisk`
        myrandom=$[ ( $RANDOM % 1000 )  + 1 ]
#

function bail()
        {
                echo "SMS:[$ERRORCODE] $MSGOUT. Runtime:$d_friendly. UniqueCode:$d_unique"
                exit $ERRORCODE
        }
function gencallfile(){

filename=$1
destexten=$2
source=$3
dest=$4
message=$5
mydate=`date +%d%m%y`
logdate=`date`
#dest=echo $dest | grep -d
#
echo -e "Channel: Local/$destexten@app-fakeanswer
CallerID: $source
Maxretries: $maxretry
RetryTime: $retryint
Context: messages
Extension: $destexten
Priority: 1
Set: MESSAGE(body)=$message
Set: MESSAGE(to)=$dest
Set: MESSAGE(from)=$source
Set: INQUEUE=1 "> /var/spool/asterisk/temp/$filename

# move files
chown asterisk:asterisk /var/spool/asterisk/temp/$filename
chmod 777 /var/spool/asterisk/temp/$filename
sleep 3
mv /var/spool/asterisk/temp/$filename /var/spool/asterisk/outgoing/

#
#exit $ERRORCODE
bail
}

while test -n "$1"; do
    case "$1" in
        -SRC)
            source="$2"
            echo $source
            shift
           ;;
        -DST)
            dest="$2"
            echo $dest
            shift
           ;;
        -MSG)
            message="$2"
            echo $message
            shift
           ;;
        -TIME)
            originaltime="$2"
            echo $originaltime
            shift
           ;;
esac
shift
done

#[checking for appropriate arguments]
        if [[ "$source" == "" ]]; then
                echo "ERROR: No source. Quitting."
                ERRORCODE=1
                bail
        fi

        if [[ "$dest" == "" ]]; then
                echo "ERROR: No usable destination. Quitting."
                ERRORCODE=1
                bail
        fi

        if [[ "$message" == "" ]]; then
                echo "ERROR: No message specified.Quitting."
                ERRORCODE=1
                bail
        fi
#[End Argument checking]

# Check to see if extension exist

destexten=`echo $dest | cut -d\@ -f1 | cut -d\: -f2`
ifexist=`$astbin -rx "sip show peers" | grep -c $destexten`

if [[ "$ifexist" == "0" ]]; then
        echo "Destination extension don't exist, exiting.."
        ERRORCODE=1
                baduser=$destexten
                destexten=`echo $source | cut -d\@ -f1 | cut -d\: -f2`
                temp=$source
                source=$dest
                dest=$temp
                message="The user $baduser does not exist, please try your message again using a different recipient.:("
                filename="$destexten-$d_unique.$myrandom.NoSuchUser.call"
                gencallfile "$filename" "$destexten" "$source" "$dest" "$message"
                bail
fi
#End of Check


# If that conditions pass, then we will queue,
# you can write other conditions too to keep the sanity of the looping
        destexten=`echo $dest | cut -d\@ -f1 | cut -d\: -f2`
        filename="$destexten-$d_unique.$myrandom.call"
        gencallfile "$filename" "$destexten" "$source" "$dest" "$message"
        bail

