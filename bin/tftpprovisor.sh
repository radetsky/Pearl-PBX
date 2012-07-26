#!/bin/sh

EXT=
PASS=
NAME=
MODEL=
SUBMODEL=
MAC=

clear_vars(){
    EXT=
    PASS=
    NAME=
    MODEL=
    SUBMODEL=
    MAC=
}

generate_SPA_config() {

[ -d ${TFTPDIR}/SPA${SUBMODEL} ] || mkdir -p ${TFTPDIR}/SPA${SUBMODEL}

cat > ${TFTPDIR}/SPA${SUBMODEL}/${MAC}.xml <<EOF
<flat-profile>
  <User_ID_1_ group="Ext_1/Subscriber_Information">${EXT}</User_ID_1_>
  <Password_1_ group="Ext_1/Subscriber_Information">${PASS}</Password_1_>
  <Use_Auth_ID_1_ group="Ext_1/Subscriber_Information">No</Use_Auth_ID_1_>
  <Auth_ID_1_ group="Ext_1/Subscriber_Information"></Auth_ID_1_>
  <Display_Name_1_ group="Ext_1/Subscriber_Information">${EXT}</Display_Name_1_>
  <Proxy_1_ group="Ext_1/Proxy_and_Registration">${SIPSERVER}</Proxy_1_>
  <Station_Name group="Phone/General">${EXT}</Station_Name>
  <Station_Display_Name group="Phone/General">${EXT}</Station_Display_Name>
  <Voice_Mail_Number ua="rw"></Voice_Mail_Number>
  <Text_Logo group="Phone/General">Taxi Express</Text_Logo>
  <BMP_Picture_Download_URL group="Phone/General"></BMP_Picture_Download_URL>
  <Select_Logo group="Phone/General">Text Logo</Select_Logo>
  <Select_Background_Picture group="Phone/General">None</Select_Background_Picture>
  <Time_Format group="User/Supplementary_Services">24hr</Time_Format>
  <DND_Serv group="Phone/Supplementary_Services">No</DND_Serv>
</flat-profile>
EOF

chmod 777 ${TFTPDIR}/SPA${SUBMODEL}/${MAC}.xml 
clear_vars

}

generate_GXP1200_config(){
[ -d ${TFTPDIR} ] || mkdir -p ${TFTPDIR}

cat > ${TFTPDIR}/cfg${MAC}.txt <<EOF
#--------------------------------------------------------------------------------------
# Primary Account (Account 1) Settings
#--------------------------------------------------------------------------------------
# Do not disable call waiting
P91 = 0
# Account Active (In Use). 0 - no, 1 - yes
P271 = 1
# Account Second is not active 
P401 = 0
# Account Name
# P270 = ${NAME}
# SIP Server
P47 = ${SIPSERVER}
# Outbound Proxy
P48 = ${SIPSERVER}
# SIP User ID
P35 = ${EXT}
# SIP Password
P34 = ${PASS}
# Authenticate ID
P36 = ${EXT}
# Display Name (John Doe)
P3 = ${NAME}
# Config server 
P237 = ${SIPSERVER}
#--------------------------------------------------------------------------------------
# End User Time settings
#--------------------------------------------------------------------------------------
# Time Zone. Offset in minutes to GMT 
# ( Offset from GMT in minutes + 720, IE: MST (GMT - 7 hours) = -420 + 720 = 300 )
P64=${TIMEOFFSET}
# Time Display Format. 0 - 12 Hour, 1 - 24 Hour
P122 = ${TIMEDISPLAYFORMAT}
# NTP Server
P30 = ${NTPSERVER}
# Enable Downloadable Phonebook (P330): NO/YES-HTTP/YES-TFTP
# (default NO). Possible values 0 (NO)/1 (HTTP)/2 (TFTP), other values
# ignored.
P330 = 2
# Phonebook XML Path (P331): This is a string of up to 128 characters that
# should contain a path to the XML file. It MUST be in the host/path format.
# Name must be gs_phonebook.xml
# For example: directory.grandstream.com/engineering
# TFTP dont understand path. So onle host/ format is working
P331 = ${PHONEBOOK}
# Phonebook Download Interval (P332): This is an integer variable in MINUTES.
# Valid value range is 0-720 (default 0), and greater values will default to 720.
P332 = 60
EOF

compile_GXP1200_config ${MAC}

}

compile_GXP1200_config(){
    /usr/bin/grandstream-config.pl ${MAC} ${TFTPDIR}/cfg${MAC}.txt ${TFTPDIR}/cfg${MAC}
    rm -rf ${TFTPDIR}/cfg${MAC}.txt
    chmod 777 ${TFTPDIR}/cfg${MAC}
    clear_vars
}

read_from_db(){
psql -U ${PSQLUSER} -h ${PSQLHOST} -A -t -c 'select a.name,a.secret,a.callerid,b.teletype,b.mac_addr_tel from public.sip_peers a, integration.workplaces b where a.id=b.sip_id' | \
  while read str; do
    echo $str | tr "|" ":" |\
    while IFS=":" read Extn Upass Dname Model Mac; do
        EXT=$Extn
        PASS=$Upass
        NAME=$(echo $Dname | awk '{print $1,$2}')
        MODEL=$Model
        MAC=$Mac
        case 1 in 
            $(echo $MODEL | grep -ic GXP1200 ) )
                generate_GXP1200_config
                ;;
            $(echo $MODEL | grep -ic SPA502G ) )
        	SUBMODEL="502G"
                generate_SPA_config
                ;;
            $(echo $MODEL | grep -ic SPA504G ) )
        	SUBMODEL="504G"
                generate_SPA_config
                ;;
        esac
    done
 done
}

legend() {
    cat <<EOF
    Usage: $(basename $0) [options]
      -h            print this screen
      -m model      Phone model (Example: 502G)
      -s SIP        SIP server IP address (Example: 192.168.1.82)
      -e extension  SIP extension number (Example: 201)
      -p password   SIP user password
      -M Phone MAC  Phone MAC address (Example: e0:b9:a5:6a:ba:a1)
      -I NotInteractive mode. Read from database. Without other args.

Example: 
# $(basename $0) -m SPA502G -s 192.168.1.92 -e 201 -p "SuperSecret" -M "f4:6d:04:0b:ee:0a"
or
# $(basename $0) -I

EOF
}

if [ -f /etc/NetSDS/tftpprovisor.conf ];then
. /etc/NetSDS/tftpprovisor.conf
else
    echo "Configuration not found"
    echo "Copmlete configuration in /etc/NetSDS/tftpprovisor.conf and run $(basename $0) again "
    mkdir -p /etc/NetSDS/
    cat > /etc/NetSDS/tftpprovisor.conf <<EOF
MODE="comandline"
TFTPDIR="/var/lib/tftpboot"
NTPSERVER=""
SIPSERVER=""
PHONEBOOK=""
TIMEDISPLAYFORMAT="1"
TIMEOFFSET="840"
PSQLUSER=""
PSQLHOST=""
EOF
    exit 1
fi

getoptarg="hc:m:s:e:p:M:I"

while getopts $getoptarg opt
do
    case $opt in
        h) legend; exit 0;;
        m) MODEL="$OPTARG";;
        s) SIP="$OPTARG";;
        e) EXT="$OPTARG";;
        p) PASS="$OPTARG";;
        M) MAC=$(echo "$OPTARG" | tr "[A-Z]" "[a-z]" | tr -d ":");;
        I) MODE="auto"
    esac
done


if [ "$MODE" = "auto" ];then
    read_from_db
else
    if [ -z "${MAC}" -o -z "${EXT}" -o -z "${PASS}" -o -z "${SIP}" -o -z "${MODEL}" ]; then
        legend
        echo "Error: Missing one from required parameters."
        exit 1
    else
        case 1 in 
            $(echo $MODEL | grep -ic GXP1200 ) )
                generate_GXP1200_config
                ;;
            $(echo $MODEL | grep -ic SPA502G ) )
        	SUBMODEL="502G"
                generate_SPA_config
                ;;
            $(echo $MODEL | grep -ic SPA504G ) )
        	SUBMODEL="504G"
                generate_SPA_config
                ;;
            * )
            echo "Unknown model. Tell about software autor"
            ;;
        esac
    fi
fi
