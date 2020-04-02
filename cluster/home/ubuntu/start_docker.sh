#!/bin/bash
exec 1>/home/ubuntu/streamsets_service_startup.log
exec 2>&1

echo "Starting StreamSets service..."

# Pull the customer id from the tags and default to either user parameter or "generic" if the tag isn't set
EC2_AVAIL_ZONE="`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`"

EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed 's/[a-z]$//'`"

EC2_INSTANCE_ID="`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`"

EC2_PUBLIC_IP="`wget -q -O - http://169.254.169.254/latest/meta-data/public-ipv4`"

EC2_PUBLIC_HOSTNAME="`wget -q -O - http://169.254.169.254/latest/meta-data/public-hostname`"

CUSTOMER_TAG="`aws ec2 describe-tags --output text --region \"$EC2_REGION\" --filters \"Name=key,Values=customername\" \"Name=resource-id,Values=$EC2_INSTANCE_ID\"`"

CUSTOMER="`echo $CUSTOMER_TAG | cut -d' ' -f 5`"

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

# Start Kerberos services
sleep 10
docker exec gifted_goldberg service kadmin start
docker exec gifted_goldberg service krb5kdc start

# Start Transformer instances after fixing hostname setting on node-3
sleep 10
#docker start st313
if grep -q "training-" $EC2_PUBLIC_HOSTNAME
then
  NODE-3_TRANSFORMER_HOST=$EC2_PUBLIC_HOSTNAME
else
  NODE-3_TRANSFORMER_HOST=$EC2_PUBLIC_IP
fi
echo "setting node-3 transformer host property: $NODE-3_TRANSFORMER_HOST"
docker exec nifty_hamilton sed -i 's#replaceme#$NODE-3_TRANSFORMER_HOST#g' /etc/transformer/transformer.properties

docker exec festive_jones service transformer start
docker exec nifty_hamilton service transformer start
docker exec heuristic_sinoussi service transformer start

# delete existing temp user accounts
echo "Deleting old temp accounts..."
for i in `sudo cat /etc/passwd`
do
  TEMPUSER=$(echo $i | cut -d':' -f 1)
  SUBSTR='-user'
  if [ -z "${TEMPUSER##*$SUBSTR*}" ]; then
    echo "Deleting user: $TEMPUSER"
    sudo userdel $TEMPUSER
  fi
done

# create new temp user account
RANDOM=$$
USERID=$CUSTOMER'-user'$((1 + $RANDOM % 100))
echo "Creating new user $USERID..."
PASSWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
echo "passord: $PASSWD"
sudo useradd -aG docker -m -s /bin/bash $USERID
echo $USERID:$PASSWD | sudo chpasswd
echo "Created user $USERID with password: $PASSWD"

exit 0
