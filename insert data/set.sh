#!/bin/bash
for((i=0;i<1000000;i++))
do
   echo "SET A"$i" a"$i"" >> data-redis.txt;
done