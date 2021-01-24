#! /bin/bash
#redis cluster mode trib startup script

#set redis domain name variable
REDIS_DOMAIN_0=$REDIS_NAME-0-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_CLUSTER_DOMAIN
REDIS_DOMAIN_1=$REDIS_NAME-1-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_CLUSTER_DOMAIN
REDIS_DOMAIN_2=$REDIS_NAME-2-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_CLUSTER_DOMAIN
REDIS_DOMAIN_3=$REDIS_NAME-3-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_CLUSTER_DOMAIN
REDIS_DOMAIN_4=$REDIS_NAME-4-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_CLUSTER_DOMAIN
REDIS_DOMAIN_5=$REDIS_NAME-5-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_CLUSTER_DOMAIN
REDIS_DOMAIN_6=$REDIS_NAME-6-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_CLUSTER_DOMAIN
REDIS_DOMAIN_7=$REDIS_NAME-7-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_CLUSTER_DOMAIN
REDIS_DOMAIN_8=$REDIS_NAME-8-0.$REDIS_SERVICE.$REDIS_NAMESPACE.svc.$REDIS_CLUSTER_DOMAIN

#the loop outputs the current time until all instances can ping
until  redis-cli -h $REDIS_DOMAIN_0 -p 6379 -a $PASSWORD ping  &&  redis-cli -h $REDIS_DOMAIN_1 -p 6379 -a $PASSWORD ping  &&  redis-cli -h $REDIS_DOMAIN_2 -p 6379 -a $PASSWORD ping  &&  redis-cli -h $REDIS_DOMAIN_3 -p 6379 -a $PASSWORD ping  &&  redis-cli -h $REDIS_DOMAIN_4 -p 6379 -a $PASSWORD ping  &&  redis-cli -h $REDIS_DOMAIN_5 -p 6379 -a $PASSWORD ping  &&  redis-cli -h $REDIS_DOMAIN_6 -p 6379 -a $PASSWORD ping  &&  redis-cli -h $REDIS_DOMAIN_7 -p 6379 -a $PASSWORD ping  &&  redis-cli -h $REDIS_DOMAIN_8 -p 6379 -a $PASSWORD ping
do
    echo $(date)
done

sleep 5s

#create a cluster with only 0, 1 and 2 container instances and all of them are master
redis-trib.rb create --replicas 0 `dig +short $REDIS_DOMAIN_0`:6379 `dig +short $REDIS_DOMAIN_1`:6379 `dig +short $REDIS_DOMAIN_2`:6379

sleep 5s

##
redis-cli -c -h $REDIS_DOMAIN_3 -p 6379 -a $PASSWORD cluster meet `dig +short $REDIS_DOMAIN_0` 6379
redis-cli -c -h $REDIS_DOMAIN_4 -p 6379 -a $PASSWORD cluster meet `dig +short $REDIS_DOMAIN_1` 6379
redis-cli -c -h $REDIS_DOMAIN_5 -p 6379 -a $PASSWORD cluster meet `dig +short $REDIS_DOMAIN_2` 6379
redis-cli -c -h $REDIS_DOMAIN_6 -p 6379 -a $PASSWORD cluster meet `dig +short $REDIS_DOMAIN_0` 6379
redis-cli -c -h $REDIS_DOMAIN_7 -p 6379 -a $PASSWORD cluster meet `dig +short $REDIS_DOMAIN_1` 6379
redis-cli -c -h $REDIS_DOMAIN_8 -p 6379 -a $PASSWORD cluster meet `dig +short $REDIS_DOMAIN_2` 6379

sleep 5s

##
redis-cli -c -h $REDIS_DOMAIN_3 -p 6379 -a $PASSWORD cluster replicate `redis-cli -c -h $REDIS_DOMAIN_0 -p 6379 -a $PASSWORD cluster myid`
redis-cli -c -h $REDIS_DOMAIN_4 -p 6379 -a $PASSWORD cluster replicate `redis-cli -c -h $REDIS_DOMAIN_1 -p 6379 -a $PASSWORD cluster myid`
redis-cli -c -h $REDIS_DOMAIN_5 -p 6379 -a $PASSWORD cluster replicate `redis-cli -c -h $REDIS_DOMAIN_2 -p 6379 -a $PASSWORD cluster myid`
redis-cli -c -h $REDIS_DOMAIN_6 -p 6379 -a $PASSWORD cluster replicate `redis-cli -c -h $REDIS_DOMAIN_0 -p 6379 -a $PASSWORD cluster myid`
redis-cli -c -h $REDIS_DOMAIN_7 -p 6379 -a $PASSWORD cluster replicate `redis-cli -c -h $REDIS_DOMAIN_1 -p 6379 -a $PASSWORD cluster myid`
redis-cli -c -h $REDIS_DOMAIN_8 -p 6379 -a $PASSWORD cluster replicate `redis-cli -c -h $REDIS_DOMAIN_2 -p 6379 -a $PASSWORD cluster myid`
