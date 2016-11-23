#
# Current basic deployment for the shinyproxy application
# 
# All code is provided in the github repo, so all changes should be done from their
# 
# Remark: there is also a startup service running, as the rundeck environment closes
# dev/uat machines every night. This does not a full deployment, only starts the 
# springboot application. Please adapt this when changing ofspringboot version
# /etc/init/shinyproxy.conf

# Kill a running version of shinyproxy
pkill java

# Git pull the code
cd woonuitbreidingsgebieden
git pull origin master

# remove woonuitbreidingsgebieden info
if [ -f woonuitbreidingsgebieden.tar.gz ]; then
    rm woonuitbreidingsgebieden.tar.gz
fi

# Make a tar.gz from the R-package from the code
tar -zcvf woonuitbreidingsgebieden.tar.gz woonuitbreidingsgebieden

# build the docker image
sudo docker build -t wog1 .

# start the application
nohup java -jar shinyproxy-0.7.5.jar > logit 2>&1 &
