#!/bin/bash

##### Var definition ###################################################
########################################################################
srv_lst=ConnectionToHtml.app/Contents/Resources/services.txt
NOW=$(date +"%a-%m|%d|%Y"-"%R:%S"-"%Z")
opt=$HOSTNAME-$NOW.html
lp=0
##### checks if the user directory exists; if not it creates one ########
#########################################################################
if [ ! -d results/$HOSTNAME ] ; then
mkdir results/$HOSTNAME
fi

#### main function definition ###########################################
#########################################################################

function main()
{
echo "<html>" > $opt;
echo "<head>" >> $opt;
echo "<TITLE>Adobe Remote Support service</TITLE>" >> $opt;
echo "<META name="Author" content="MINU">"  >> $opt;
echo "<META http-equiv="Content-Type" content="text/html\; charset=ISO-8859-5">" >> $opt;
echo "<link rel="stylesheet" href="ConnectionToHtml.app/Contents/Resources/styles.css">" >> $opt;

echo "</head>" >> $opt;
echo "<body>" >> $opt;
echo  "<H1>Test started on" >> $opt;
date >> $opt;
echo "</H1>" >> $opt;
echo "<br>" >> $opt;
echo "<H2>A.    PING SERVER TESTS</H2>" >> $opt;
echo "<br>" >> $opt;
echo "<table class="tg">" >> $opt;
echo "<tr>" >> $opt;
echo "<th class=\"tg-031e\">""#</th>" >> $opt;
echo "<th class=\"tg-031e\">Test</th>" >> $opt;
echo "<th class=\"tg-031e\">Target</th>" >> $opt;
echo "<th class=\"tg-031e\">Result</th>" >> $opt;
echo "<th class=\"tg-031e\">More Details</th>" >> $opt;
echo "</tr>" >> $opt;
echo "<tr>" >> $opt;

######################################################################################
########   Calling the function PING with hostname detailes as $1 parameter ##########
#####################################################################################


IN=$(cat  services.txt   | grep PING)
   for i in $IN; do
PING $(echo $i | awk -F';' '{print $2}'| sed $'s/\r$//' )
   done
echo "<tr>" >> $opt;


######################################################################################
########   Calling the function NSLOOKUP  with hostname detailes as $1 parameter ##########
#####################################################################################
lp=0
echo "</table>" >> $opt;
echo "<br>" >> $opt;
echo "<H2>B.    DNS SERVER TESTS</H2>" >> $opt;
echo "<br>" >> $opt;
echo "<table class="tg">" >> $opt;
echo "<tr>" >> $opt;
echo "<th class=\"tg-031e\">""#</th>" >> $opt;
echo "<th class=\"tg-031e\">Test</th>" >> $opt;
echo "<th class=\"tg-031e\">Target</th>" >> $opt;
echo "<th class=\"tg-031e\">Nslookup Result</th>" >> $opt;
echo "</tr>" >> $opt;
echo "<tr>" >> $opt;

IN=$(cat  services.txt   | grep NSLOOKUP)
   for i in $IN; do
NSLOOKUP $(echo $i | awk -F';' '{print $2}'| sed $'s/\r$//' )
   done
echo "<tr>" >> $opt;
echo "</table>" >> $opt;

######################################################################################
########   Calling the function TELNET  with hostname detailes ######################
#####################################################################################
lp=0
echo "<br>" >> $opt;
echo "<H2> C.PORT AVAILABILITY TESTS</H2>" >> $opt;
echo "<br>" >> $opt;
echo "<table class="tg">" >> $opt;
echo "<tr>" >> $opt;
echo "<th class=\"tg-031e\">""#</th>" >> $opt;
echo "<th class=\"tg-031e\">Product name on $HOSTNAME</th>" >> $opt;
echo "<th class=\"tg-031e\">Test</th>" >> $opt;
echo "<th class=\"tg-031e\">Result</th>" >> $opt;
echo "</tr>" >> $opt;
echo "<tr>" >> $opt;
IN=$(cat services.txt | awk -F, '/;/{gsub(/ /, "", $0); print } ' | grep TELNET)   
for i in $IN; do
TELNET $(echo $i | awk -F';' '{print $2}' | sed $'s/\r$//' ) $(echo $i | awk -F';' '{print $3}' | sed $'s/\r$//' ) $(echo $i | awk -F';' '{print $4}' | sed $'s/\r$//' )
   done
echo "<tr>" >> $opt;
echo "</table>" >> $opt;
}


###########################################
####### PING FUNCTION ####################
##########################################

function PING ()
{

echo "Testing PING on" $1
lp=$((lp+1));
echo "<tr>" >> $opt;
echo "<td class=\"tg-031e\">$lp</td>" >> $opt;
echo "<td class=\"tg-031e\">Ping Test</td>" >> $opt;
echo "<td class=\"tg-031e\">$1</td>" >> $opt; 

ping -t 5 -c 1 $1 
if [ $? -eq 0 ]
then
   echo "<td class=\"tg-031s\">OK</td>" >> $opt
		echo error level 1
else
   echo "<td class=\"tg-031f\">DOWN</td>" >> $opt
		echo error level 0
fi

echo "<td class=\"tg-031e\">" >>$opt;
ping -t 5 -c 1 $1 | grep ttl >> $opt 
#ping -t 1 -c 1 $1 | grep ttl >> results/$HOSTNAME/DATE.txt
echo "</td>" >> $opt; 

}
###########################################
####### NSLOOKUP FUNCTION ####################
##########################################

function NSLOOKUP ()
{

echo "Testing DNS resolution on" $1
lp=$((lp+1));
echo "<tr>" >> $opt;
echo "<td class=\"tg-031e\">$lp</th>" >> $opt;
echo "<td class=\"tg-031e\">Nslookup Test</th>" >> $opt;
echo "<td class=\"tg-031e\">$1</th>" >> $opt; 

nslookup $1 | grep NXDOMAIN 
if [ $? -eq 1 ]
then
   echo "<td class=\"tg-031s\">$(nslookup $1)</td>" >> $opt
		echo error level 1
else
   echo "<td class=\"tg-031f\">$(nslookup $1)</td>" >> $opt
		echo error level 0
fi

echo "</tr>" >> $opt
}

function TELNET ()
{

echo "Testing port availability on" $1
lp=$((lp+1));
echo "<tr>" >> $opt;
echo "<td class=\"tg-031e\">$lp</td>" >> $opt;
echo "<td class=\"tg-031e\">$1</td>" >> $opt;
echo "<td class=\"tg-031e\">$2 on port $3</td>" >> $opt;


nc -G3 -z $2 $3 
if [ $? -eq 0 ]
then
echo "<td class=\"tg-031s\"> OK </td>" >> $opt 
echo error level 1
else
   echo "<td class=\"tg-031f\">Operation timed out! </td>" >> $opt
                echo error level 0
fi


echo "</tr>" >> $opt
}

main
x=$(ls -Art | tail -n 1)
cp $x ~/Desktop/
open ~/Desktop/$x
echo "Data transfer"
ftp -inv 10.42.136.116 << EOF
user bomgar DonnaBionica906090
cd /home/bomgar/
put *.html


exit $?




