#! /bin/bash
#redis cluster mode instance startup script

#judge whether to start for the first time by nodes.conf
if [ -e ../nodes.conf ]
then 
       echo "no copy file ......"  
       #refresh IP
       HOSTNAME_IP=`cat /etc/hosts | grep ${HOSTNAME} | awk '{print $1}'`
       B=`cat ../nodes.conf | grep 'myself'`
       C=${B%%:*}
       D=${C#* }
       sed -i "s/$D/$HOSTNAME_IP/g" ../nodes.conf

       sleep 60s
    
       redis-server  ../conf/cluster.conf
else
       echo "This is the first time，and coping file ......"
       cp -fp ../cluster.conf ../conf
       chmod -R 0755 ../conf/cluster.conf
	   
       #set password into file
       sed -i '$a\requirepass '$PASSWORD'' ../conf/cluster.conf
       sed -i '$a\masterauth '$PASSWORD'' ../conf/cluster.conf
       redis-server  ../conf/cluster.conf
fi