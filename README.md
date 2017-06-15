
# Woonuitbreidingsgebieden 

This repo contains all the required scripts to run the affiliated Rshiny app of the R package *woonuitbreidingsgebieden*. For most users, this will be appropriate. Besides the R package, some deploy elements are included in this repo to support the incorporation of the Rshiny app within the shinyproxy environment.

## R package

As the R code to create the visualisations is implemented as an R package, users for the R code itself should check the information in the [woonuitbreidingsgebieden subdirectory](https://github.com/inbo/woonuitbreidingsgebieden/tree/master/woonuitbreidingsgebieden), for which the package functionalities are explained. Important to know is that the function `run_wug()` of the package is the central piece to start the Rshiny app, as this is also used by the [shinyproxy application](http://www.shinyproxy.io/). 

## Deployment of the application

For a detailed description of the [shinyproxy application](http://www.shinyproxy.io/) and in-depth knowledge of the setup, [Docker](https://github.com/inbo/woonuitbreidingsgebieden/blob/master/Dockerfile) settings and  [application.yml](https://github.com/inbo/woonuitbreidingsgebieden/blob/master/application.yml) format, the user is referred to the [documentation of shinyproxy]((http://www.shinyproxy.io/)). The  full [deployment on the AWS infrastructure](https://www.milieuinfo.be/confluence/pages/viewpage.action?spaceKey=INBOAWS&title=Shiny-Proxy) is out of scope for this manual and the configuration and setup is provided in a [private repo](https://github.com/inbo/shinyproxy). However, the following elements are present here to support the deployment and should be taken into account when creating new Rshiny packages/application to be handled by the INBO instance of shinyproxy:

* [Dockerfile](https://github.com/inbo/woonuitbreidingsgebieden/blob/master/Dockerfile) to put the R package in a container as required by shinyproxy. This Docker could be used as start for new developments
* [Rprofile.site](https://github.com/inbo/woonuitbreidingsgebieden/blob/master/Rprofile.site), an additional port forwarding feature for the Docker handling
* [appspec.yml](https://github.com/inbo/woonuitbreidingsgebieden/blob/master/appspec.yml) providing the required settings for the AWS codedeploy
* scripts/woonuitbreidingsgebieden.sh providing the minimal actions to enable the usage of this R package and R shiny application wihtin the shinyproxy environment, i.e. build a Docker with the package inside

**Note**: Keep the `filereconfig` branch as a quick an easy reference to the initial poc setup in dev environment (or checkout to commit hash `733b5735ad6e33847c5f41f33ab94fdc70146f68`)

## Troubleshooting

If you want to check on the EC2 how the Rshiny App inside the Docker is running (without the shinyproxy) wrap:

```
sudo docker run -p 3838:3838 wug1 R -e 'woonuitbreidingsgebieden::run_wug()'
```

In a similar way, specific R functions can be tested as well. Remember that the data is ported as part of the R-package and stored as such on the Docker:

```
sudo docker run -p 3838:3838 wug1 R -e 'appDir <- system.file("shiny-examples", "wug", package = "woonuitbreidingsgebieden");setwd(appDir);library(woonuitbreidingsgebieden);xls_file <- "../../extdata/Afwegingskader_Wug.xlsx";wug_link_data <- extract_link_table(xls_file, "Info_Wug");id_wug <- "11002_08";lu_data <- get_landuse_data_pt_excel(xls_file, id_wug);create_stacked_bar(lu_data)'
```

### Acknowledgements
We would like to thank [openanalytics](https://www.openanalytics.eu/) to open source their shinyproxy application, which enabled us to bring the Rshiny application to the web. 


