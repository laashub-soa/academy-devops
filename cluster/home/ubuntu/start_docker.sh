#!/bin/bash

# Pull the customer id from the tags and default to either user parameter or "generic" if the tag isn't set
EC2_AVAIL_ZONE="`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`"

EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed 's/[a-z]$//'`"

EC2_INSTANCE_ID="`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`"

TAG="`aws ec2 describe-tags --output text --region \"$EC2_REGION\" --filters \"Name=key,Values=customername\" \"Name=resource-id,Values=$EC2_INSTANCE_ID\"`"

CUSTOMER="`echo $TAG | cut -d' ' -f 5`"

if [ -z $CUSTOMER ]; then
  CUSTOMER=$#
fi
if [ -z $CUSTOMER ]; then
  CUSTOMER='generic'
fi

# fire up all Docker containers
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
docker start sch315
sleep 10
docker exec gifted_goldberg service kadmin start
docker exec gifted_goldberg service krb5kdc start
#docker start st313
sleep 10
docker exec festive_jones service transformer start
docker exec nifty_hamilton service transformer start
docker exec heuristic_sinoussi service transformer start

# delete existing temp user accounts
for i in `sudo cat /etc/passwd`
do
  TEMPUSER=$(echo $i | cut -d':' -f 1)
  SUBSTR='-user'
  if [ -z "${TEMPUSER##*$SUBSTR*}" ]; then
    sudo userdel $TEMPUSER
    rm -f /home/ubuntu/temp_user_creds.txt
  fi
done

# create new temp user account
RANDOM=$$
USERID=$CUSTOMER'-user'$((1 + $RANDOM % 100))
PASSWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
sudo useradd -G docker -m -s /bin/bash $USERID
echo $USERID:$PASSWD | sudo chpasswd
echo "Created user $USERID with password: $PASSWD"

exit 0
