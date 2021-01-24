#! /bin/bash
#sentinel mode (redis) instance switch startup script
ID=${HOSTNAME##*-}

HOSTNAME_IP=`cat /etc/hosts | grep ${HOSTNAME} | awk '{print $1}'`

#set redis domain name variable
HOSTNAME_DOMAIN=`cat /etc/hosts | grep ${HOSTNAME} | awk '{print $2}'`
REDIS_DOMAIN_0=$REDIS_NAME-0.${HOSTNAME_DOMAIN#*.}
REDIS_DOMAIN_1=$REDIS_NAME-1.${HOSTNAME_DOMAIN#*.}
REDIS_DOMAIN_2=$REDIS_NAME-2.${HOSTNAME_DOMAIN#*.}

#judge the domain name of sentinel cluster is SENTINEL_CLUSTER_DOMAIN or SENTINEL_DRILL_CLUSTER_DOMAIN
if [ $SENTINEL_DRILL_CLUSTER_DOMAIN ]
then
    CLUSTER_DOMAIN=$SENTINEL_DRILL_CLUSTER_DOMAIN
else
    CLUSTER_DOMAIN=$SENTINEL_CLUSTER_DOMAIN
fi
#set sentinl domain name variable
SENTINEL_DOMAIN_0=$SENTINEL_NAME-0.$SENTINEL_SERVICE.$SENTINEL_NAMESPACE.svc.$CLUSTER_DOMAIN
SENTINEL_DOMAIN_1=$SENTINEL_NAME-1.$SENTINEL_SERVICE.$SENTINEL_NAMESPACE.svc.$CLUSTER_DOMAIN
SENTINEL_DOMAIN_2=$SENTINEL_NAME-2.$SENTINEL_SERVICE.$SENTINEL_NAMESPACE.svc.$CLUSTER_DOMAIN
SENTINEL_DOMAIN_3=$SENTINEL_NAME-3.$SENTINEL_SERVICE.$SENTINEL_NAMESPACE.svc.$CLUSTER_DOMAIN
SENTINEL_DOMAIN_4=$SENTINEL_NAME-4.$SENTINEL_SERVICE.$SENTINEL_NAMESPACE.svc.$CLUSTER_DOMAIN


#remove  master in sentinel
for m in {0..4}
do 
  n=`eval echo '$'SENTINEL_DOMAIN_$m`
  redis-cli -h $n -p 26379 sentinel remove $MYMASTER 
done

##
if [ $ID == 0 ]
then
    echo "my ID is  0"
    redis-cli -p 6379 -a $PASSWORD slaveof no one
    redis-cli -h $REDIS_DOMAIN_1 -p 6379 -a $PASSWORD slaveof $HOSTNAME_IP 6379
    redis-cli -h $REDIS_DOMAIN_2 -p 6379 -a $PASSWORD slaveof $HOSTNAME_IP 6379
elif [ $ID == 1 ]
then
    echo "my ID is 1"
    redis-cli -p 6379 -a $PASSWORD slaveof no one
    redis-cli -h $REDIS_DOMAIN_0 -p 6379 -a $PASSWORD slaveof $HOSTNAME_IP 6379
    redis-cli -h $REDIS_DOMAIN_2 -p 6379 -a $PASSWORD slaveof $HOSTNAME_IP 6379
else
    echo "my ID is 2"
    redis-cli -p 6379 -a $PASSWORD slaveof no one
    redis-cli -h $REDIS_DOMAIN_0 -p 6379 -a $PASSWORD slaveof $HOSTNAME_IP 6379
    redis-cli -h $REDIS_DOMAIN_1 -p 6379 -a $PASSWORD slaveof $HOSTNAME_IP 6379
fi


#let the sentinel cluster monitor the redis master
for i in {0..4}
do 
    j=`eval echo '$'SENTINEL_DOMAIN_$i`
    redis-cli -h $j -p 26379 sentinel monitor $MYMASTER $HOSTNAME_IP 6379 3
    redis-cli -h $j -p 26379 sentinel set $MYMASTER auth-pass $PASSWORD
    redis-cli -h $j -p 26379 sentinel reset $MYMASTER
    redis-cli -h $j -p 26379 sentinel set $MYMASTER down-after-milliseconds 30000
    redis-cli -h $j -p 26379 sentinel set $MYMASTER failover-timeout 180000 
    redis-cli -h $j -p 26379 sentinel set $MYMASTER parallel-syncs 1
done