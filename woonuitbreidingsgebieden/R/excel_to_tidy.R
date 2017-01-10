#
# Woonuitbreidingsgebieden
#
# S. Van Hoey
# INBO
#

# data columns to take into account
columns <- c("Voedsel", "Houtprod", "EnergieMaaisel",
             "NabijGroen", "Bestuiving", "Erosie",
             "Bodemvrucht", "Copslag_bodem", "Copslag_hout",
             "Geluidsregulatie", "Luchtzuivering", "UHI",
             "Denitrificatie", "DiepGrondwater", "Komberging NOG",
             "Retentie")

esd_sheets <- c("ESD_Wug","ESD_Wug_Vlaanderen", "ESD_Wug_Provincie",
                "ESD_Wug_Gemeente", "ESD_Vlaanderen", "ESD_provincie",
                "ESD_Gemeente")

#' Extract the data from a single ESD-data containing sheet of excel
#'
#' @param sheet_name char with the name of the ESD data containing sheet
#' @param xls_file  char path name of the excel file interested in
#'
#' @return tibble with the tidy version of the esd-data sheet
#'
#' @importFrom readxl read_excel
#' @importFrom dplyr %>% select mutate
#' @importFrom tidyr gather
extract_esd_sheet <- function(sheet_name, xls_file, columns) {

    esd_section <- read_excel(path = xls_file,
                              sheet = sheet_name)
    colnames(esd_section)[1] <- "ID"
    esd_section %>%
        select(one_of(c("ID", columns))) %>%  # select the necessary columns
        gather(ESD, value, -ID) %>%
        mutate("spatial_entity" = sheet_name)
}


#' Extract all ESD data and combine into single tidy data set
#'
#' @param esd_sheets list of char with the sheet names
#' @param xls_file char path name of the excel file interested in
#'
#' @return tibble with the tidy version of the esd-data
#'
#' @importFrom plyr mapvalues
#' @importFrom dplyr %>% mutate_ bind_rows
extract_esd_data <- function(esd_sheets, xls_file, columns) {
    bind_rows(lapply(esd_sheets, extract_esd_sheet,
                                 xls_file = xls_file,
                                 columns = columns)) %>%
    mutate("type" = plyr::mapvalues(spatial_entity,
                               c("ESD_Wug",
                                 "ESD_Gemeente",
                                 "ESD_provincie",
                                 "ESD_Vlaanderen",
                                 "ESD_Wug_Gemeente",
                                 "ESD_Wug_Provincie",
                                 "ESD_Wug_Vlaanderen"),
                               c("wug",
                                 "gemeente",
                                 "provincie",
                                 "vlaanderen",
                                 "wug_gemeente",
                                 "wug_provincie",
                                 "wug_vlaanderen")))
}
