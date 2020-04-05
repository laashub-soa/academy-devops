rm -rf ~ubuntu/academy-devops
git clone https://github.com/streamsets/academy-devops.git ~ubuntu/academy-devops
rsync -a --no-o --no-g ~ubuntu/academy-devops/cluster/ /

~ubuntu/start_docker.sh
exit 0
