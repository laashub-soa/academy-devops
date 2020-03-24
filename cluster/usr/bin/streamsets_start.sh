git pull https://github.com/streamsets/academy-devops.git
cp /root/academy-devops/cluster/home/ubuntu/*_docker.sh /home/ubuntu
chown ubuntu: /home/ubuntu/*_docker.sh
su - ubuntu -c "/home/ubuntu/start_docker.sh"
