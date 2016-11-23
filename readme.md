
# Woonuitbreidingsgebieden 

This repo contains all the required scripts (on top of the EC2 ubuntu machine with java installed) to run the affiliated Rshiny app of the R package *woonuitbreidingsgebieden*.

## R package
As the R code to create the visualisations is implemented as an R package, users for the R code itself should check the information in the [woonuitbreidingsgebieden subdirectory](https://github.com/inbo/woonuitbreidingsgebieden/tree/master/woonuitbreidingsgebieden), for which the package functionalities are explained. Important to know is that the function `run_wug()` of the package is the central piece to start the Rshiny app, as this is also used by the [shinyproxy application](http://www.shinyproxy.io/). 

## Deployment of the application
For a detailed description of the [shinyproxy application](http://www.shinyproxy.io/) and in-depth knowledge of the setup, [Docker](https://github.com/inbo/woonuitbreidingsgebieden/blob/master/Dockerfile) settings and  [application.yml](https://github.com/inbo/woonuitbreidingsgebieden/blob/master/application.yml) format, the user is referred to the [documentation of shinyproxy]((http://www.shinyproxy.io/)). In this description, the translation towards the EC2 instance is described. As this is a poc, the deployment is basically done by a created bash-script, [deploy_app.sh](https://github.com/inbo/woonuitbreidingsgebieden/blob/master/systemd/deployapp.sh). Put this file, togethet with the [startapp.sh](https://github.com/inbo/woonuitbreidingsgebieden/blob/master/systemd/startapp.sh) file in the home directory of the *ubuntu* user and run the bash script. 

## systemd startup service
As the application is in a `dev` environment, the instance is stopped each night and rebooted in the morning. This is covered by providing a systemd service which starts the application on machine startup. The systemd service is described in the shinyproxy.service file (put this in the folder `etc/systemd/system` and register the service with the command `sudo systemctl enable shinyproxy.service`. If you want to test this service, start the service manually with `sudo systemctl start shinyproxy`, check the status with `sudo systemctl status shinyproxy` (more commands are found [in the manual](https://www.freedesktop.org/software/systemd/man/systemctl.html))

This service calls the [startapp.sh](https://github.com/inbo/woonuitbreidingsgebieden/blob/master/systemd/startapp.sh) file in the ubuntu home directory when the EC2 instance is started.

### Acknowledgements
We would like to thank [openanalytics](https://www.openanalytics.eu/) to open source their shinyproxy application, which enabled us to bring the Rshiny application to the web. 


