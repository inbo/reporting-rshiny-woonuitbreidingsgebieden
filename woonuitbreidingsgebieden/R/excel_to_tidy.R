#
# Woonuitbreidingsgebieden
#
# S. Van Hoey
# INBO
#

#' Title
#'
#' @param xls_file char path name of the excel file interested in
#' @param path path to put the files in
#'
#' @export
excel_to_tidy_csv <- function(xls_file, path) {
    extract_lu_data(lu_sheets, xls_file, lu_columns) %>%
        write.csv(., file = file.path(path, "lu_data.csv"))
    esd_data <- extract_esd_data(esd_sheets, xls_file, esd_columns) %>%
        write.csv(., file = file.path(path, "esd_data.csv"))
    wug_link_data <- extract_link_table(xls_file, "Info_Wug") %>%
        write.csv(., file = file.path(path, "wug_link_data.csv"))
}
