
library(radarchart)
library(ggplot2)
library(dplyr)
library(tidyr)

# DATA PROCESSING FUNCTIONS


#' get from link-table containing an overview of the WUG-NR - Provincie -
#' GEMEENTE relation the corresponding province and municipality based on the
#' WUG identifier
#'
#'@param link_table data.frame
#'@param id_wug char identifier for the WUG
get_locations <- function(link_table, id_wug){
    return(link_table[link_table$`WUG-NR` == id_wug, c(1, 3:5)])
}

#' get from link-table containing an overview of the WUG-NR - Provincie -
#' GEMEENTE relation the corresponding province and municipality based on the
#' WUG identifier
#'
#'@param link_table data.frame
#'@param id_wug char identifier for the WUG
get_wug_ids <- function(link_table){
    return(unique(link_table$`WUG-NR`))
}


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

#' Collect the ESD data for a given WUG from the excel-sheet:
#'
#' TABLE:
#'  - ESD_Wug >- row id_wug, col F:U
#'  - ESD_Gemeente -> row GEMEENTE, col C:R
#'  - ESD_Vlaanderen -> row 'Vlaanderen', col C:R
#'  - ESD_Wug_Gemeente -> row GEMEENTE, col B:Q
#'  - ESD_Wug_Provincie -> row Provincie, col C:R
#'  - ESD_Wug_Vlaanderen -> row 'VlaamseWug' (all), col C:R
#'
#'@param xls_file excel file
#'@param id_wug char wug identifier
#'
#'@return data.frame
#'
get_esd_data <- function(xls_file, id_wug){

    # read in first sheet and get province and municipality info
    info_wug <- readxl::read_excel(path = xls_file,
                                   sheet = "Info_Wug")
    location_info <- get_locations(info_wug, id_wug)

    # get ESD WUG (ESD_Wug)
    esd_wug <- readxl::read_excel(path = xls_file,
                                  sheet = "ESD_Wug")
    wug <- esd_wug %>%
        filter(esd_wug$NR_WUG == id_wug) %>%
        select(6:21)
    wug$type <- "wug"

    # get ESD municipality (ESD_Gemeente)
    esd_gemeente <- readxl::read_excel(path = xls_file,
                                      sheet = "ESD_Gemeente")
    gemeente <- esd_gemeente %>%
        filter(esd_gemeente$Gemeente == location_info$GEMEENTE) %>%
        select(3:18)
    gemeente$type <- "gemeente"

    # get ESD Flanders (ESD_Vlaanderen)
    esd_vlaanderen <- readxl::read_excel(path = xls_file,
                                       sheet = "ESD_Vlaanderen")
    vlaanderen <- esd_vlaanderen %>%
        select(3:18)
    vlaanderen$type <- "vlaanderen"

    # get ESD for WUG in municipality (ESD_Wug_Gemeente)
    esd_wug_gemeente <- readxl::read_excel(path = xls_file,
                                       sheet = "ESD_Wug_Gemeente")
    wug_gemeente <- esd_wug_gemeente %>%
        filter(esd_wug_gemeente$Gemeente == location_info$GEMEENTE) %>%
        select(2:17)
    wug_gemeente$type <- "wug_gemeente"

    # get ESD for WUG in province (ESD_Wug_Provincie)
    esd_wug_provincie <- readxl::read_excel(path = xls_file,
                                           sheet = "ESD_Wug_Provincie")
    wug_provincie <- esd_wug_provincie %>%
        filter(esd_wug_provincie$Provincie == location_info$Provincie) %>%
        select(3:18)
    wug_provincie$type <- "wug_provincie"

    # get ESD for WUG in Flanders (ESD_Wug_Vlaanderen)
    esd_wug_vlaanderen <- readxl::read_excel(path = xls_file,
                                             sheet = "ESD_Wug_Vlaanderen")
    wug_vlaanderen <- esd_wug_vlaanderen %>%
        select(3:18)
    wug_vlaanderen$type <- "wug_vlaanderen"

    # combine to a single data table
    esd_data <- bind_rows(wug, gemeente, vlaanderen, wug_gemeente,
                          wug_provincie, wug_vlaanderen)
    esd_data <- gather(esd_data, ESD, value, -type)

    esd_data$ESD <- factor(esd_data$ESD,
                           levels = c("Voedsel", "Houtprod", "EnergieMaaisel",
                                      "NabijGroen", "Bestuiving", "Erosie",
                                      "Bodemvrucht", "Copslag_bodem", "Copslag_hout",
                                      "Geluidsregulatie", "Luchtzuivering", "UHI",
                                      "Denitrificatie", "DiepGrondwater", "Komberging NOG",
                                      "Retentie"),
                           ordered = TRUE)

    return(esd_data)
}


# PLOT FUNCTIONS

# OPTIES VOOR DE VISUALISATIE VAN DE PERCENTAGES
create_stacked_bar <- function(lu_data){
    # arrange the data order to fit the legend order
    lu_data <- lu_data %>%
                    arrange(desc(landuse))
    cbPalette <- c("Bos" = "#006d2c",
                   "Grasland" = "#31a354",
                   "Halfnatuurlijk grasland" = "#74c476",
                   "Ander groen" = "#bae4b3",
                   "Heide" = "#c994c7",
                   "Duinen" = "#dd1c77",
                   "Landbouw (akker)" = "#fed98e",
                   "Landbouw (boomgaard)" = "#fe9929",
                   "Landbouw (grasland)" = "#d95f0e",
                   "Landbouw (groenten & fruit)" = "#993404",
                   "Urbaan bebouwd" = "#fee5d9",
                   "Urbaan onbebouwd" = "#fcae91",
                   "Infrastructuur" = "#fb6a4a",
                   "Industrie" = "#de2d26",
                   "Militaire voorziening" =  "#a50f15",
                   "Haven" = "#3182bd",
                   "Water" = "#9ecae1",
                   "Moeras" = "#deebf7")

    barp <- ggplot(lu_data, aes(y = area, fill = landuse)) +
                geom_bar(stat = 'identity', aes(x = type)) +
                scale_fill_manual(name = "Landgebruik",
                                  values = cbPalette) +

                xlab("") +
                ylab("Oppervlakte %") +
                theme_inbo2015(base_size = 14) +
                theme(axis.text = element_text((size = 15)))
    return(barp)
}

#' Plot an interactive radar/spider-chart of the ESD data towards a given
#' reference
#'
#'@param ESD_tidy tidy version of the ESD data representation
#'@param char choose an option from: wug, gemeente, vlaanderen,
#' wug_gemeente, wug_provincie, wug_vlaanderen
#'
create_radar <- function(ESD_data, reference, threshold = 0.5){

    current_sel <- ESD_data %>%
        filter(type == "wug" | type == reference) %>%
        spread(key = type, value = value)

    # add the threshold
    current_sel$threshold <- threshold
    # sort the columns
    current_sel <- current_sel[, c("ESD", "threshold", reference, "wug")]

    # round the numbers for improved visualisation
    current_sel[,-1] <- round(current_sel[,-1], 2)

    colors <- matrix(c(128, 0, 0, ## versus200, 200, 200,
                       49, 163, 84,
                       217, 95, 14), nrow = 3, ncol = 3)

    radar <- chartJSRadar(current_sel,
                 responsive = TRUE,
                 showToolTipLabel = TRUE,
                 polyAlpha = 0.0,  # 0.3
                 colMatrix = colors,
                 addDots = FALSE)
    return(radar)
}

# Documentation:
# https://cran.r-project.org/web/packages/fmsb/fmsb.pdf -> http://www.r-graph-gallery.com/142-basic-radar-chart/
# http://personality-project.org/r/html/spider.html
# https://github.com/mangothecat/radarchart
# http://www.r-graph-gallery.com/143-spider-chart-with-saveral-individuals/
# (met band errond die de kleur van de thematiek aangeeft)

