#!/bin/bash
# Make sure shiny starts at boot
sudo mv /home/ubuntu/woonuitbreidingsgebieden/scripts/woonuitbreidingsgebieden /etc/init.d/
sudo chmod 755 /etc/init.d/woonuitbreidingsgebieden
sudo chown root:root /etc/init.d/woonuitbreidingsgebieden
sudo update-rc.d woonuitbreidingsgebieden defaults
# Make a tar.gz from the R-package from the code
cd /home/ubuntu/woonuitbreidingsgebieden
if [ -f woonuitbreidingsgebieden.tar.gz ]; then
    rm woonuitbreidingsgebieden.tar.gz
fi
tar -zcvf woonuitbreidingsgebieden.tar.gz woonuitbreidingsgebieden
# Build the docker image
sudo docker build -t wug1 .