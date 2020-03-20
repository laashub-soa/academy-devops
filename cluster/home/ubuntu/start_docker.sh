#!/bin/sh

# Don't run unless a cluster name has been provided as a parameter.
if [ $# -eq 0 ]
  then
    echo "You must supply a cluster name or ID in order to generate a non-privileged login credential\nfor trainees to access the environment. Please try again."
    exit 1
fi

docker start laughing_stonebraker
docker start festive_jones
docker start nifty_hamilton
docker start heuristic_sinoussi
docker start gifted_goldberg
docker start openldap
docker start oracle
docker start mysql
docker start influx
docker start postgres-96-wal2json_db_1
docker start sch313
sleep 10
docker exec -it gifted_goldberg service kadmin start
docker exec -it gifted_goldberg service krb5kdc start
#docker start st312
sleep 10
docker exec -it festive_jones service transformer start
docker exec -it nifty_hamilton service transformer start
docker exec -it heuristic_sinoussi service transformer start

RANDOM=$$
USERID=$1'-user'$((1 + $RANDOM % 100))
PASSWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
sudo useradd -G docker -m -s /bin/bash $USERID
echo $USERID:$PASSWD | sudo chpasswd
echo "Created user $USERID with password: $PASSWD"
