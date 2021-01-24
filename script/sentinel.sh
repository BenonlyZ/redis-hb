#! /bin/bash
#sentinel mode (sentinel) instance startup script
#judge whether to start for the first time by sentinel.conf
if [ -e ../conf/sentinel.conf ]
then
      
      echo "no copy file ....... "
      redis-sentinel  ../conf/sentinel.conf           
else
      
      echo "This is the first time，and coping file ......"
      cp -fp ../sentinel.conf  ../conf
      chmod -R 0755 ../conf/sentinel.conf
      redis-sentinel  ../conf/sentinel.conf
fi