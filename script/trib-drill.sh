#! /bin/bash
#redis cluster mode trib drill startup script

#set main redis domain name variable
REDIS_DOMAIN_0=$REDIS_NAME-0-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_CLUSTER_DOMAIN
REDIS_DOMAIN_1=$REDIS_NAME-1-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_CLUSTER_DOMAIN
REDIS_DOMAIN_2=$REDIS_NAME-2-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_CLUSTER_DOMAIN
REDIS_DOMAIN_3=$REDIS_NAME-3-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_CLUSTER_DOMAIN
REDIS_DOMAIN_4=$REDIS_NAME-4-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_CLUSTER_DOMAIN
REDIS_DOMAIN_5=$REDIS_NAME-5-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_CLUSTER_DOMAIN
REDIS_DOMAIN_6=$REDIS_NAME-6-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_CLUSTER_DOMAIN
REDIS_DOMAIN_7=$REDIS_NAME-7-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_CLUSTER_DOMAIN
REDIS_DOMAIN_8=$REDIS_NAME-8-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_CLUSTER_DOMAIN

#set space redis domain name variable
REDIS_DRILL_DOMAIN_0=$REDIS_NAME-0-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_DRILL_CLUSTER_DOMAIN
REDIS_DRILL_DOMAIN_1=$REDIS_NAME-1-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_DRILL_CLUSTER_DOMAIN
REDIS_DRILL_DOMAIN_2=$REDIS_NAME-2-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_DRILL_CLUSTER_DOMAIN
REDIS_DRILL_DOMAIN_3=$REDIS_NAME-3-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_DRILL_CLUSTER_DOMAIN
REDIS_DRILL_DOMAIN_4=$REDIS_NAME-4-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_DRILL_CLUSTER_DOMAIN
REDIS_DRILL_DOMAIN_5=$REDIS_NAME-5-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_DRILL_CLUSTER_DOMAIN
REDIS_DRILL_DOMAIN_6=$REDIS_NAME-6-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_DRILL_CLUSTER_DOMAIN
REDIS_DRILL_DOMAIN_7=$REDIS_NAME-7-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_DRILL_CLUSTER_DOMAIN
REDIS_DRILL_DOMAIN_8=$REDIS_NAME-8-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_DRILL_CLUSTER_DOMAIN

#set main redis of cluster id variable
REDIS_ID_0=`redis-cli -c -h $REDIS_DOMAIN_0 -p 6379 -a $PASSWORD cluster myid`
REDIS_ID_1=`redis-cli -c -h $REDIS_DOMAIN_1 -p 6379 -a $PASSWORD cluster myid`
REDIS_ID_2=`redis-cli -c -h $REDIS_DOMAIN_2 -p 6379 -a $PASSWORD cluster myid`
REDIS_ID_3=`redis-cli -c -h $REDIS_DOMAIN_3 -p 6379 -a $PASSWORD cluster myid`
REDIS_ID_4=`redis-cli -c -h $REDIS_DOMAIN_4 -p 6379 -a $PASSWORD cluster myid`
REDIS_ID_5=`redis-cli -c -h $REDIS_DOMAIN_5 -p 6379 -a $PASSWORD cluster myid`
REDIS_ID_6=`redis-cli -c -h $REDIS_DOMAIN_6 -p 6379 -a $PASSWORD cluster myid`
REDIS_ID_7=`redis-cli -c -h $REDIS_DOMAIN_7 -p 6379 -a $PASSWORD cluster myid`
REDIS_ID_8=`redis-cli -c -h $REDIS_DOMAIN_8 -p 6379 -a $PASSWORD cluster myid`

#the loop outputs the current time until all instances can ping
until  redis-cli -h $REDIS_DRILL_DOMAIN_0 -p 6379 -a $PASSWORD ping  &&  redis-cli -h $REDIS_DRILL_DOMAIN_1 -p 6379 -a $PASSWORD ping  &&  redis-cli -h $REDIS_DRILL_DOMAIN_2 -p 6379 -a $PASSWORD ping  &&  redis-cli -h $REDIS_DRILL_DOMAIN_3 -p 6379 -a $PASSWORD ping  &&  redis-cli -h $REDIS_DRILL_DOMAIN_4 -p 6379 -a $PASSWORD ping  &&  redis-cli -h $REDIS_DRILL_DOMAIN_5 -p 6379 -a $PASSWORD ping  &&  redis-cli -h $REDIS_DRILL_DOMAIN_6 -p 6379 -a $PASSWORD ping  &&  redis-cli -h $REDIS_DRILL_DOMAIN_7 -p 6379 -a $PASSWORD ping  &&  redis-cli -h $REDIS_DRILL_DOMAIN_8 -p 6379 -a $PASSWORD ping 
do
    echo $(date)
done

sleep 5s

#add all instances of the space redis into the cluster of the main redis
redis-cli -c -h $REDIS_DRILL_DOMAIN_0 -p 6379 -a $PASSWORD cluster meet $MASTER_0_IP 6379
redis-cli -c -h $REDIS_DRILL_DOMAIN_3 -p 6379 -a $PASSWORD cluster meet $MASTER_0_IP 6379
redis-cli -c -h $REDIS_DRILL_DOMAIN_6 -p 6379 -a $PASSWORD cluster meet $MASTER_0_IP 6379
redis-cli -c -h $REDIS_DRILL_DOMAIN_1 -p 6379 -a $PASSWORD cluster meet $MASTER_1_IP 6379
redis-cli -c -h $REDIS_DRILL_DOMAIN_4 -p 6379 -a $PASSWORD cluster meet $MASTER_1_IP 6379
redis-cli -c -h $REDIS_DRILL_DOMAIN_7 -p 6379 -a $PASSWORD cluster meet $MASTER_1_IP 6379
redis-cli -c -h $REDIS_DRILL_DOMAIN_2 -p 6379 -a $PASSWORD cluster meet $MASTER_2_IP 6379
redis-cli -c -h $REDIS_DRILL_DOMAIN_5 -p 6379 -a $PASSWORD cluster meet $MASTER_2_IP 6379
redis-cli -c -h $REDIS_DRILL_DOMAIN_8 -p 6379 -a $PASSWORD cluster meet $MASTER_2_IP 6379

sleep 5s

##
redis-cli -c -h $REDIS_DRILL_DOMAIN_0 -p 6379 -a $PASSWORD cluster replicate `redis-cli -c -h $MASTER_0_IP -p 6379 -a $PASSWORD cluster myid`
redis-cli -c -h $REDIS_DRILL_DOMAIN_3 -p 6379 -a $PASSWORD cluster replicate `redis-cli -c -h $MASTER_0_IP -p 6379 -a $PASSWORD cluster myid`
redis-cli -c -h $REDIS_DRILL_DOMAIN_6 -p 6379 -a $PASSWORD cluster replicate `redis-cli -c -h $MASTER_0_IP -p 6379 -a $PASSWORD cluster myid`
redis-cli -c -h $REDIS_DRILL_DOMAIN_1 -p 6379 -a $PASSWORD cluster replicate `redis-cli -c -h $MASTER_1_IP -p 6379 -a $PASSWORD cluster myid`
redis-cli -c -h $REDIS_DRILL_DOMAIN_4 -p 6379 -a $PASSWORD cluster replicate `redis-cli -c -h $MASTER_1_IP -p 6379 -a $PASSWORD cluster myid`
redis-cli -c -h $REDIS_DRILL_DOMAIN_7 -p 6379 -a $PASSWORD cluster replicate `redis-cli -c -h $MASTER_1_IP -p 6379 -a $PASSWORD cluster myid`
redis-cli -c -h $REDIS_DRILL_DOMAIN_2 -p 6379 -a $PASSWORD cluster replicate `redis-cli -c -h $MASTER_2_IP -p 6379 -a $PASSWORD cluster myid`
redis-cli -c -h $REDIS_DRILL_DOMAIN_5 -p 6379 -a $PASSWORD cluster replicate `redis-cli -c -h $MASTER_2_IP -p 6379 -a $PASSWORD cluster myid`
redis-cli -c -h $REDIS_DRILL_DOMAIN_8 -p 6379 -a $PASSWORD cluster replicate `redis-cli -c -h $MASTER_2_IP -p 6379 -a $PASSWORD cluster myid`

sleep 60m

#clean up invalid IP in the file
redis-trib.rb call `dig +short $REDIS_DRILL_DOMAIN_0`:6379 cluster forget $REDIS_ID_0
redis-trib.rb call `dig +short $REDIS_DRILL_DOMAIN_0`:6379 cluster forget $REDIS_ID_1
redis-trib.rb call `dig +short $REDIS_DRILL_DOMAIN_0`:6379 cluster forget $REDIS_ID_2
redis-trib.rb call `dig +short $REDIS_DRILL_DOMAIN_0`:6379 cluster forget $REDIS_ID_3
redis-trib.rb call `dig +short $REDIS_DRILL_DOMAIN_0`:6379 cluster forget $REDIS_ID_4
redis-trib.rb call `dig +short $REDIS_DRILL_DOMAIN_0`:6379 cluster forget $REDIS_ID_5
redis-trib.rb call `dig +short $REDIS_DRILL_DOMAIN_0`:6379 cluster forget $REDIS_ID_6
redis-trib.rb call `dig +short $REDIS_DRILL_DOMAIN_0`:6379 cluster forget $REDIS_ID_7
redis-trib.rb call `dig +short $REDIS_DRILL_DOMAIN_0`:6379 cluster forget $REDIS_ID_8
