#
# Woonuitbreidingsgebieden
#
# S. Van Hoey
# INBO
#

library(tidyr)
library(dplyr)

#' Collect the  LANDUSE data for a given WUG from the excel-sheet:
#' TABLE:
#'  - LG_WUG_% -> row id_wug, col B:S
#'  - LG_Gemeenten_% -> row GEMEENTE, col B:S
#'  - LG_Provincies_% -> row Provincie, col B:S
#'
#'@param xls_file excel file
#'@param id_wug char wug identifier
#'
#'@return data.frame
get_landuse_data <- function(xls_file, id_wug){

    # read in first sheet and get province and municipality info
    info_wug <- readxl::read_excel(path = xls_file,
                                   sheet = "Info_Wug")
    location_info <- get_locations(info_wug, id_wug)

    # get landuse WUG
    lu_wug <- readxl::read_excel(path = xls_file,
                                 sheet = "LG_WUG_%")
    wuglu <- lu_wug %>%
        filter(lu_wug$`WUG-NR` %in% id_wug) %>%
        select(2:19)
    wuglu$type <- paste("WUG\n", id_wug)

    # get landuse municipality
    lu_gemeente <- readxl::read_excel(path = xls_file,
                                      sheet = "LG_Gemeenten_%")
    gemeente <- lu_gemeente %>%
        filter(lu_gemeente$Gemeente == location_info$GEMEENTE) %>%
        select(2:19)
    gemeente$type <- location_info$GEMEENTE

    # get landuse province
    lu_provincie <- readxl::read_excel(path = xls_file,
                                       sheet = "LG_Provincies_%")
    provincie <- lu_provincie %>%
        filter(lu_provincie$Provincie == location_info$Provincie) %>%
        select(2:19)

    provincie$type <- paste("Provincie\n", location_info$Provincie)

    # combine to a single data table
    lu_data <- bind_rows(wuglu, gemeente, provincie)
    lu_data <- gather(lu_data, landuse, area, -type)

    lu_data$landuse <- factor(lu_data$landuse,
                              levels = c("Bos", "Grasland", "Halfnatuurlijk grasland",
                                         "Ander groen", "Heide", "Duinen", "Landbouw (akker)",
                                         "Landbouw (boomgaard)", "Landbouw (grasland)",
                                         "Landbouw (groenten & fruit)", "Urbaan bebouwd",
                                         "Urbaan onbebouwd", "Infrastructuur", "Industrie",
                                         "Militaire voorziening", "Haven", "Water", "Moeras"),
                              ordered = TRUE)
    lu_data$type <- factor(lu_data$type,
                           levels = c(paste("WUG\n", id_wug),
                                      location_info$GEMEENTE,
                                      paste("Provincie\n", location_info$Provincie)),
                           ordered = TRUE)
    return(lu_data)
}