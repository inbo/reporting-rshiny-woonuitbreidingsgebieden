#
# Woonuitbreidingsgebieden
#
# S. Van Hoey
# INBO
#


#' Collect the ESD data for a given WUG from the tidy data representation
#'
#' @param esd_data tidy representation of all ecosystem services data
#' @param wug_link_data tidy version of link table wug/municipality/province
#' @param id_wug wug identifier to get data from
#'
#' @export
#' @importFrom dplyr %>% mutate left_join select_ rename_
#' @importFrom tidyr gather
get_esd_data <- function(esd_data, wug_link_data, id_wug){

    location_info <- get_locations(wug_link_data, id_wug) %>%
        mutate(Gewest = "Vlaanderen") %>%
        mutate(Gewestwug = "VlaamseWug") %>%
        gather(property, ID)
    location_info <- bind_rows(location_info[1:4,],
                               location_info[2:3,],
                               location_info[5,])
    location_info$type <- c("wug", "provincie", "gemeente", "vlaanderen",
                            "wug_provincie", "wug_gemeente", "wug_vlaanderen")
    esd_data <- location_info %>%
        left_join(y = esd_data, by = c("ID", "type")) %>%
        select_("category", "type", "value") %>%
        rename_(ESD = "category") %>%
        mutate("ESD" = mapvalues(ESD,
                                 esd_names_orig,
                                 esd_names_plot))

    esd_data$ESD <- factor(esd_data$ESD,
                           levels = esd_names_plot ,
                           ordered = TRUE)
    return(esd_data)
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
#' @param xls_file excel file
#' @param id_wug char wug identifier
#'
#' @return data.frame
#'
#' @export
#' @importFrom readxl read_excel
#' @importFrom dplyr %>% filter_ select bind_rows
#' @importFrom tidyr gather
get_esd_data_excel <- function(xls_file, id_wug){

    # read in first sheet and get province and municipality info
    info_wug <- extract_link_table(xls_file, "Info_Wug")
    location_info <- get_locations(info_wug, id_wug)

    # get ESD WUG (ESD_Wug)
    esd_wug <- read_excel(path = xls_file,
                          sheet = "ESD_Wug")
    wug <- esd_wug %>%
        filter_(~NR_WUG == id_wug) %>%
        select(6:21)
    wug$type <- "wug"

    # get ESD municipality (ESD_Gemeente)
    esd_gemeente <- read_excel(path = xls_file,
                               sheet = "ESD_Gemeente")
    gemeente <- esd_gemeente %>%
        filter_(~Gemeente == location_info$Gemeente) %>%
        select(3:18)
    gemeente$type <- "gemeente"

    # get ESD Flanders (ESD_Vlaanderen)
    esd_vlaanderen <- read_excel(path = xls_file,
                                 sheet = "ESD_Vlaanderen")
    vlaanderen <- esd_vlaanderen %>%
        select(3:18)
    vlaanderen$type <- "vlaanderen"

    # get ESD for WUG in municipality (ESD_Wug_Gemeente)
    esd_wug_gemeente <- read_excel(path = xls_file,
                                   sheet = "ESD_Wug_Gemeente")
    wug_gemeente <- esd_wug_gemeente %>%
        filter_(~Gemeente == location_info$Gemeente) %>%
        select(2:17)
    wug_gemeente$type <- "wug_gemeente"

    # get ESD for WUG in province (ESD_Wug_Provincie)
    esd_wug_provincie <- read_excel(path = xls_file,
                                    sheet = "ESD_Wug_Provincie")
    wug_provincie <- esd_wug_provincie %>%
        filter_(~Provincie == location_info$Provincie) %>%
        select(3:18)
    wug_provincie$type <- "wug_provincie"

    # get ESD for WUG in Flanders (ESD_Wug_Vlaanderen)
    esd_wug_vlaanderen <- read_excel(path = xls_file,
                                     sheet = "ESD_Wug_Vlaanderen")
    wug_vlaanderen <- esd_wug_vlaanderen %>%
        select(3:18)
    wug_vlaanderen$type <- "wug_vlaanderen"

    # combine to a single data table
    esd_data <- bind_rows(wug, gemeente, vlaanderen, wug_gemeente,
                          wug_provincie, wug_vlaanderen)
    esd_data <- gather(esd_data, ESD, value, -type) %>%
        mutate("ESD" = mapvalues(ESD,
                                 esd_names_orig,
                                 esd_names_plot))

    esd_data$ESD <- factor(esd_data$ESD,
                           levels = esd_names_plot,
                           ordered = TRUE)

    return(esd_data)
}
