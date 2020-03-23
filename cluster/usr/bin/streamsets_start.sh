git pull https://github.com/streamsets/academy-devops.git
cp /root/academy-devops/cluster/home/ubuntu/*-docker.sh /home/ubuntu
chown ubuntu: /home/ubuntu/*-docker.sh
./home/ubuntu/start_docker.sh
