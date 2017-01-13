#
# Woonuitbreidingsgebieden
#
# S. Van Hoey
# INBO
#


#' Collect the percentage landuse data for a given WUG from tidy data
#'
#' @param lu_data tidy representation of all landuse data
#' @param wug_link_data tidy version of link table wug/municipality/province
#' @param id_wug wug identifier to get data from
#'
#' @export
#' @importFrom dplyr %>% mutate select_ left_join filter_ distinct_ rename_
#' @importFrom tidyr gather spread
#' @importFrom plyr mapvalues
get_landuse_data_pt <- function(lu_data, wug_link_data, id_wug) {

    location_info <- get_locations(wug_link_data, id_wug)
    gemeente_name <- location_info$Gemeente
    wug_name <- paste("WUG\n", id_wug)
    provincie_name <- paste("Provincie\n", location_info$Provincie)

    location_info <- location_info %>% gather(property, ID)
    location_info["spatial_entity"] <- c("LG_WUG_%",
                                         "LG_Gemeenten_%",
                                         "LG_Provincies_%")
    location_info %>%
        left_join(y = lu_data, by = c("ID", "spatial_entity")) %>%
        filter_(lazyeval::interp(quote(grepl("%", col)),
                                 col = as.name("spatial_entity"))) %>%
        mutate("spatial_entity" = mapvalues(spatial_entity,
                                            c("LG_WUG_%",
                                              "LG_Gemeenten_%",
                                              "LG_Provincies_%"),
                                            c(wug_name,
                                              gemeente_name,
                                              provincie_name))) %>%
        select_("category", "spatial_entity", "value") %>%
        rename_(landuse = "category",
                area = "value",
                type = "spatial_entity")

}

#' Collect the  LANDUSE data for a given WUG from the excel-sheet:
#' TABLE:
#'  - LG_WUG_\% -> row id_wug, col B:S
#'  - LG_Gemeenten_\% -> row GEMEENTE, col B:S
#'  - LG_Provincies_\% -> row Provincie, col B:S
#'
#' @param xls_file excel file
#' @param id_wug char wug identifier
#'
#' @return data.frame
#'
#' @export
#' @importFrom readxl read_excel
#' @importFrom dplyr %>% filter_ select bind_rows
#' @importFrom tidyr gather
get_landuse_data_pt_excel <- function(xls_file, id_wug){

    # read in first sheet and get province and municipality info
    info_wug <- extract_link_table(xls_file, "Info_Wug")
    location_info <- get_locations(info_wug, id_wug)

    # get landuse WUG
    lu_wug <- read_excel(path = xls_file,
                         sheet = "LG_WUG_%")
    wuglu <- lu_wug %>%
        filter_(~`WUG-NR` %in% id_wug) %>%
        select(2:19)
    wuglu$type <- paste("WUG\n", id_wug)

    # get landuse municipality
    lu_gemeente <- read_excel(path = xls_file,
                              sheet = "LG_Gemeenten_%")
    gemeente <- lu_gemeente %>%
        filter_(~Gemeente == location_info$Gemeente) %>%
        select(2:19)
    gemeente$type <- location_info$Gemeente

    # get landuse province
    lu_provincie <- read_excel(path = xls_file,
                               sheet = "LG_Provincies_%")
    provincie <- lu_provincie %>%
        filter_(~Provincie == location_info$Provincie) %>%
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
                                      location_info$Gemeente,
                                      paste("Provincie\n", location_info$Provincie)),
                           ordered = TRUE)
    return(lu_data)
}

#' Collect the ha landuse data for a given WUG from tidy data
#'
#' @param lu_data tidy representation of all landuse data
#' @param wug_link_data tidy version of link table wug/municipality/province
#' @param id_wug wug identifier to get data from
#'
#' @return wug_ha
#'
#' @export
#' @importFrom dplyr %>% mutate select_ left_join filter_ distinct_
#' @importFrom tidyr gather spread
#' @importFrom plyr mapvalues
get_landuse_data_ha <- function(lu_data, wug_link_data, id_wug){

    location_info <- get_locations(wug_link_data, id_wug)
    gemeente_name <- location_info$Gemeente
    wug_name <- paste("WUG\n", id_wug)

    location_info <- location_info %>% gather(property, ID)
    location_info["spatial_entity"] <- c("LG_Wug_ha",
                                         "LG_Gemeenten_ha",
                                         "LG_Provincies_ha")

    lu_data_ha <- location_info %>%
        left_join(y = lu_data, by = c("ID", "spatial_entity")) %>%
        filter_(~spatial_entity %in% c("LG_Wug_ha", "LG_Gemeenten_ha")) %>%
        mutate("spatial_entity" = mapvalues(spatial_entity,
                                            c("LG_Wug_ha",
                                              "LG_Gemeenten_ha"),
                                            c(wug_name,
                                              gemeente_name))) %>%
        select_("category", "spatial_entity", "value") %>%
        rename_(landuse = "category")

    # drop the columns with no effect on the WUG (WUG ha == 0)
    wug_landuses <- lu_data_ha %>%
        filter_("ID" != gemeente_name & "value" != 0.0) %>%
        filter_("landuse" != "Urbaan bebouwd") %>%
        distinct_(~landuse)

    # select only the relevant landuses
    wug_ha <- lu_data_ha %>%
        filter_(~landuse %in% wug_landuses$landuse)
    wug_ha$spatial_entity <- factor(wug_ha$spatial_entity,
                                    levels = c(wug_name,
                                               gemeente_name),
                                    ordered = TRUE)
    wug_ha <- spread(wug_ha, key = "spatial_entity", value = "value")

    # derive the potential loss of landuse
    wug_ha["pt_loss"] <- 100. - (wug_ha[,3] - wug_ha[,2])*100./wug_ha[,3]
    return(wug_ha)
}



#' Collect the  LANDUSE data for a given WUG from the excel-sheet in ha:
#' TABLE:
#'  - LG_WUG_\% -> row id_wug, col B:S
#'  - LG_Gemeenten_\% -> row GEMEENTE, col B:S
#'  - LG_Provincies_\% -> row Provincie, col B:S
#'
#'@param xls_file excel file
#'@param id_wug char wug identifier
#'
#'@return data.frame
#'
#'@export
#'@importFrom readxl read_excel
#'@importFrom dplyr %>% filter_ select bind_rows distinct_
#'@importFrom tidyr gather spread
get_landuse_data_ha_excel <- function(xls_file, id_wug){

    # read in first sheet and get province and municipality info
    info_wug <- extract_link_table(xls_file, "Info_Wug")
    location_info <- get_locations(info_wug, id_wug)

    # get landuse WUG
    lu_wug <- read_excel(path = xls_file,
                         sheet = "LG_Wug_ha")
    wuglu <- lu_wug %>%
        filter_(~`WUG-NR` %in% id_wug) %>%
        select(2:19)
    wug_name <- paste("WUG\n", id_wug)
    wuglu$type <- wug_name

    # get landuse municipality
    lu_gemeente <- read_excel(path = xls_file,
                              sheet = "LG_Gemeenten_ha")
    gemeente <- lu_gemeente %>%
        filter_(~Gemeente == location_info$Gemeente) %>%
        select(2:19)
    gemeente_name <- location_info$Gemeente
    gemeente$type <- gemeente_name

    # combine to a single data table
    lu_data_ha <- bind_rows(wuglu, gemeente)
    lu_data_ha <- gather(lu_data_ha, landuse, area, -type)

    # drop the columns with no effect on the WUG (WUG ha == 0)
    wug_landuses <- lu_data_ha %>%
        filter_("type" != location_info$Gemeente & "area" != 0.0) %>%
        filter_("landuse" != "Urbaan bebouwd") %>%
        distinct_(~landuse)

    # select only the relevant landuses
    wug_ha <- lu_data_ha %>%
        filter_(~landuse %in% wug_landuses$landuse)
    wug_ha$type <- factor(wug_ha$type,
                          levels = c(wug_name,
                                     gemeente_name),
                          ordered = TRUE)
    wug_ha <- spread(wug_ha, key = "type", value = "area")

    wug_ha$landuse <- factor(wug_ha$landuse,
                             levels = c("Bos", "Grasland", "Halfnatuurlijk grasland",
                                        "Ander groen", "Heide", "Duinen", "Landbouw (akker)",
                                        "Landbouw (boomgaard)", "Landbouw (grasland)",
                                        "Landbouw (groenten & fruit)", "Urbaan bebouwd",
                                        "Urbaan onbebouwd", "Infrastructuur", "Industrie",
                                        "Militaire voorziening", "Haven", "Water", "Moeras"),
                             ordered = TRUE)
    # derive percentage loss
    wug_ha["pt_loss"] <- 100. - (wug_ha[,3] - wug_ha[,2])*100./wug_ha[,3]

    return(wug_ha)
}
