#! /bin/bash
#sentinel mode (redis) instance drill startup script
ID=${HOSTNAME##*-}

#set main redis domain name variable
REDIS_DOMAIN_0=$REDIS_NAME-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_CLUSTER_DOMAIN
REDIS_DOMAIN_1=$REDIS_NAME-1.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_CLUSTER_DOMAIN
REDIS_DOMAIN_2=$REDIS_NAME-2.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_CLUSTER_DOMAIN
#set main sentinl domain name variable
SENTINEL_DOMAIN_0=$SENTINEL_NAME-0.$SENTINEL_SERVICE.$SENTINEL_NAMESPACE.svc.$SENTINEL_CLUSTER_DOMAIN
SENTINEL_DOMAIN_1=$SENTINEL_NAME-1.$SENTINEL_SERVICE.$SENTINEL_NAMESPACE.svc.$SENTINEL_CLUSTER_DOMAIN
SENTINEL_DOMAIN_2=$SENTINEL_NAME-2.$SENTINEL_SERVICE.$SENTINEL_NAMESPACE.svc.$SENTINEL_CLUSTER_DOMAIN
SENTINEL_DOMAIN_3=$SENTINEL_NAME-3.$SENTINEL_SERVICE.$SENTINEL_NAMESPACE.svc.$SENTINEL_CLUSTER_DOMAIN
SENTINEL_DOMAIN_4=$SENTINEL_NAME-4.$SENTINEL_SERVICE.$SENTINEL_NAMESPACE.svc.$SENTINEL_CLUSTER_DOMAIN
#set space sentinl domain name variable
SENTINEL_DRILL_DOMAIN_0=$SENTINEL_NAME-0.$SENTINEL_SERVICE.$SENTINEL_NAMESPACE.svc.$SENTINEL_DRILL_CLUSTER_DOMAIN
SENTINEL_DRILL_DOMAIN_1=$SENTINEL_NAME-1.$SENTINEL_SERVICE.$SENTINEL_NAMESPACE.svc.$SENTINEL_DRILL_CLUSTER_DOMAIN
SENTINEL_DRILL_DOMAIN_2=$SENTINEL_NAME-2.$SENTINEL_SERVICE.$SENTINEL_NAMESPACE.svc.$SENTINEL_DRILL_CLUSTER_DOMAIN
SENTINEL_DRILL_DOMAIN_3=$SENTINEL_NAME-3.$SENTINEL_SERVICE.$SENTINEL_NAMESPACE.svc.$SENTINEL_DRILL_CLUSTER_DOMAIN
SENTINEL_DRILL_DOMAIN_4=$SENTINEL_NAME-4.$SENTINEL_SERVICE.$SENTINEL_NAMESPACE.svc.$SENTINEL_DRILL_CLUSTER_DOMAIN


#judge whether to start for the first time by standalone.conf
if [ -e ../conf/standalone.conf ]
then
      
      echo "no copy file ....... "
      sleep 3m

      #get current master
      MASTER_DOMAIN=`redis-cli -h $SENTINEL_DRILL_DOMAIN_0 -p 26379 sentinel get-master-addr-by-name $MYMASTER | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' || redis-cli -h $SENTINEL_DRILL_DOMAIN_1 -p 26379 sentinel get-master-addr-by-name $MYMASTER | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' || redis-cli -h $SENTINEL_DRILL_DOMAIN_2 -p 26379 sentinel get-master-addr-by-name $MYMASTER | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' || redis-cli -h $SENTINEL_DRILL_DOMAIN_3 -p 26379 sentinel get-master-addr-by-name $MYMASTER | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' || redis-cli -h $SENTINEL_DRILL_DOMAIN_4 -p 26379 sentinel get-master-addr-by-name $MYMASTER | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'`

      #reset the master in sentinel 
      for i in {0..4}
      do 
                j=`eval echo '$'SENTINEL_DRILL_DOMAIN_$i`
                redis-cli -h $j -p 26379 sentinel reset $MYMASTER 
      done

      redis-server  ../conf/standalone.conf  --slaveof  $MASTER_DOMAIN 6379 
      
else
      
      echo "This is the first time，and coping file ......"
      cp -fp ../standalone.conf ../conf
      chmod -R 0755 ../conf/standalone.conf

      #set password into file
      sed -i '$a\requirepass '$PASSWORD'' ../conf/standalone.conf
      sed -i '$a\masterauth '$PASSWORD'' ../conf/standalone.conf

      #get current master
      MASTER_DOMAIN=`redis-cli -h $SENTINEL_DOMAIN_0 -p 26379 sentinel get-master-addr-by-name $MYMASTER | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' || redis-cli -h $SENTINEL_DOMAIN_1 -p 26379 sentinel get-master-addr-by-name $MYMASTER | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' || redis-cli -h $SENTINEL_DOMAIN_2 -p 26379 sentinel get-master-addr-by-name $MYMASTER | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' || redis-cli -h $SENTINEL_DOMAIN_3 -p 26379 sentinel get-master-addr-by-name $MYMASTER | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' || redis-cli -h $SENTINEL_DOMAIN_4 -p 26379 sentinel get-master-addr-by-name $MYMASTER | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'`
      
      #judge whether it is the last container
       if [ $ID != 2 ]
       then
             echo "my ID is  $ID"
             t=`eval echo '$'REDIS_DOMAIN_$ID`
			 #set fail over priority
             redis-cli -h $t -p 6379 -a $PASSWORD config set slave-priority 100
             redis-server ../conf/standalone.conf   --slaveof  $MASTER_DOMAIN 6379  --slave-priority 10
 
       else
             echo "my ID is 2"
             #let the space sentinel cluster monitor the redis master
             for i in {0..4}
             do 
                j=`eval echo '$'SENTINEL_DRILL_DOMAIN_$i`
                redis-cli -h $j -p 26379 sentinel monitor $MYMASTER $MASTER_DOMAIN 6379 3
                redis-cli -h $j -p 26379 sentinel set $MYMASTER auth-pass $PASSWORD
                redis-cli -h $j -p 26379 sentinel reset $MYMASTER
                redis-cli -h $j -p 26379 sentinel set $MYMASTER down-after-milliseconds 30000
                redis-cli -h $j -p 26379 sentinel set $MYMASTER failover-timeout 180000 
                redis-cli -h $j -p 26379 sentinel set $MYMASTER parallel-syncs 1
             done
              
             redis-cli -h $REDIS_DOMAIN_2 -p 6379 -a $PASSWORD config set slave-priority 100
             redis-server ../conf/standalone.conf   --slaveof  $MASTER_DOMAIN 6379  --slave-priority 10
       fi
fi