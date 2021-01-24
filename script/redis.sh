#! /bin/bash
#sentinel mode (redis) instance startup script
ID=${HOSTNAME##*-}

#set domain name variable
REDIS_DOMAIN_0=$REDIS_NAME-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_CLUSTER_DOMAIN
SENTINEL_DOMAIN_0=$SENTINEL_NAME-0.$SENTINEL_SERVICE.$SENTINEL_NAMESPACE.svc.$SENTINEL_CLUSTER_DOMAIN
SENTINEL_DOMAIN_1=$SENTINEL_NAME-1.$SENTINEL_SERVICE.$SENTINEL_NAMESPACE.svc.$SENTINEL_CLUSTER_DOMAIN
SENTINEL_DOMAIN_2=$SENTINEL_NAME-2.$SENTINEL_SERVICE.$SENTINEL_NAMESPACE.svc.$SENTINEL_CLUSTER_DOMAIN
SENTINEL_DOMAIN_3=$SENTINEL_NAME-3.$SENTINEL_SERVICE.$SENTINEL_NAMESPACE.svc.$SENTINEL_CLUSTER_DOMAIN
SENTINEL_DOMAIN_4=$SENTINEL_NAME-4.$SENTINEL_SERVICE.$SENTINEL_NAMESPACE.svc.$SENTINEL_CLUSTER_DOMAIN


#judge whether to start for the first time by standalone.conf
if [ -e ../conf/standalone.conf ]
then
    
      echo "no copy file ....... "
      sleep 3m
      #get current master
      MASTER_DOMAIN=`redis-cli -h $SENTINEL_DOMAIN_0 -p 26379 sentinel get-master-addr-by-name $MYMASTER | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' || redis-cli -h $SENTINEL_DOMAIN_1 -p 26379 sentinel get-master-addr-by-name $MYMASTER | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' || redis-cli -h $SENTINEL_DOMAIN_2 -p 26379 sentinel get-master-addr-by-name $MYMASTER | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' || redis-cli -h $SENTINEL_DOMAIN_3 -p 26379 sentinel get-master-addr-by-name $MYMASTER | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' || redis-cli -h $SENTINEL_DOMAIN_4 -p 26379 sentinel get-master-addr-by-name $MYMASTER | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'`
	  
      #reset the master in sentinel 
      for m in {0..4}
      do 
                n=`eval echo '$'SENTINEL_DOMAIN_$m`
                redis-cli -h $n -p 26379 sentinel reset $MYMASTER 
      done
      redis-server  ../conf/standalone.conf  --slaveof  $MASTER_DOMAIN 6379 
      
else
      
      echo "This is the first time，and coping file ......"
      cp -fp ../standalone.conf ../conf
      chmod -R 0755 ../conf/standalone.conf

      #set password into file
      sed -i '$a\requirepass '$PASSWORD'' ../conf/standalone.conf
      sed -i '$a\masterauth '$PASSWORD'' ../conf/standalone.conf

      #judge whether it is the last container
       if [ $ID == 0 ]
       then
             echo "my ID is  0"
             redis-server ../conf/standalone.conf
       elif [ $ID == 1 ]
       then
             echo "my ID is 1"
             redis-server ../conf/standalone.conf --slaveof $REDIS_DOMAIN_0 6379
       else
             echo "my ID is 2"
			 
             until [ -n "$(dig +short $REDIS_DOMAIN_0)" ]
             do
                 echo $(date)
             done
             r=`dig +short $REDIS_DOMAIN_0`
			 
             #let the sentinel cluster monitor the redis master
             for i in {0..4}
             do 
                j=`eval echo '$'SENTINEL_DOMAIN_$i`
                redis-cli -h $j -p 26379 sentinel monitor $MYMASTER $r 6379 3
                redis-cli -h $j -p 26379 sentinel set $MYMASTER auth-pass $PASSWORD
                redis-cli -h $j -p 26379 sentinel reset $MYMASTER
                redis-cli -h $j -p 26379 sentinel set $MYMASTER down-after-milliseconds 30000
                redis-cli -h $j -p 26379 sentinel set $MYMASTER failover-timeout 180000 
                redis-cli -h $j -p 26379 sentinel set $MYMASTER parallel-syncs 1
             done
             redis-server ../conf/standalone.conf --slaveof $REDIS_DOMAIN_0 6379
       fi
fi