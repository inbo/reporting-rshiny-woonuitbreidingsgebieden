FROM openanalytics/r-base

MAINTAINER Stijn Van Hoey stijn.vanhoey@inbo.be 

# system libraries of general use
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libssl1.0.0 


# Dependencies for rgdal and rgeos
RUN  apt-get update && apt-get install -y software-properties-common && \
     add-apt-repository ppa:ubuntugis/ppa

RUN  apt-get update && \
     apt-get install -y gdal-bin libgdal-dev libproj-dev libgeos-dev

# install dependencies of the woonuitbreidingsgebieden app
RUN R -e "install.packages(c('shiny', 'sp', 'plotly', 'plyr', 'rmarkdown', 'devtools', 'methods', 'reshape2', 'mgcv', 'rgdal', 'dplyr', 'tidyr', 'ggplot2', 'radarchart', 'readxl', 'rgeos', 'shinycssloaders'), repos = 'https://cloud.r-project.org/')"
RUN R -e "devtools::install_github('inbo/INBOtheme')"


# copy the app to the image by installing package
COPY woonuitbreidingsgebieden.tar.gz /root/
RUN R CMD INSTALL /root/woonuitbreidingsgebieden.tar.gz
RUN rm /root/woonuitbreidingsgebieden.tar.gz

# set host
COPY Rprofile.site /usr/lib/R/etc/

EXPOSE 3838

CMD ["R", "-e woonuitbreidingsgebieden::run_wug()"]
