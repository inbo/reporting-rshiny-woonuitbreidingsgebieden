#
# Woonuitbreidingsgebieden
#
# S. Van Hoey
# INBO
#

#' Extract all ESD data and combine into single tidy data set
#'
#' @param esd_sheets list of char with the sheet names
#' @param xls_file char path name of the excel file interested in
#' @param columns list of char with the column names to use
#'
#' @return tibble with the tidy version of the esd-data
#'
#' @export
#' @importFrom plyr mapvalues
#' @importFrom dplyr %>% mutate_ bind_rows
extract_esd_data <- function(esd_sheets, xls_file, columns) {
    bind_rows(lapply(esd_sheets, extract_sheet,
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
