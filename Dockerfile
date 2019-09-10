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

# install imports of reporting-grofwild app that are not on cloud
RUN R -e "install.packages(c('shiny', 'sp', 'plotly', 'plyr', 'devtools', 'methods', 'reshape2', 'mgcv', 'rgdal', 'rgeos', 'shinycssloaders'), repos = 'https://cloud.r-project.org/')"
RUN R -e "devtools::install_github('inbo/INBOtheme')"

# basic shiny functionality
RUN R -e "install.packages(c('shiny', 'rmarkdown'), repos='https://cloud.r-project.org/')"

# install dependencies of the woonuitbreidingsgebieden app
RUN R -e "install.packages('dplyr', repos='https://cloud.r-project.org/')"
RUN R -e "install.packages('tidyr', repos='https://cloud.r-project.org/')"
RUN R -e "install.packages('ggplot2', repos='https://cloud.r-project.org/')"
RUN R -e "install.packages('radarchart', repos='https://cloud.r-project.org/')"
RUN R -e "install.packages('readxl', repos='https://cloud.r-project.org/')"

# copy the app to the image by installing package
COPY woonuitbreidingsgebieden.tar.gz /root/
RUN R CMD INSTALL /root/woonuitbreidingsgebieden.tar.gz
RUN rm /root/woonuitbreidingsgebieden.tar.gz

# set host
COPY Rprofile.site /usr/lib/R/etc/

EXPOSE 3838

CMD ["R", "-e woonuitbreidingsgebieden::run_wug()"]
