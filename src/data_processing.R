#
# Data processing for WUG tool
#
# Van Hoey S.
# INBO - Lifewatch


library(dplyr)
library(tidyr)

# WUG AREA

id_wug <- "11002_02"
xls_file <- "data/Afwegingskader_Wug_versie2.xlsx"
# ALTERATIONS
# => gemeente in header
# => KomberginNOg ipv Komberging NOG

# ------------------------------------------------------------
lu_data <- get_landuse_data(xls_file, id_wug)
ESD_data <- get_esd_data(xls_file, id_wug)
# ------------------------------------------------------------

info_wug <- readxl::read_excel(path = xls_file,
                               sheet = "Info_Wug")



library(ggplot2)


create_radar(ESD_data, "wug_gemeente")



# ---------------------------------------------------------------------------


