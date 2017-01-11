#
# Woonuitbreidingsgebieden
#
# S. Van Hoey
# INBO
#

#' Extract the data from a single ESD-data containing sheet of excel
#'
#' @param sheet_name char with the name of the ESD data containing sheet
#' @param xls_file  char path name of the excel file interested in
#'
#' @return tibble with the tidy version of the esd-data sheet
#'
#' @export
#' @importFrom readxl read_excel
#' @importFrom dplyr %>% select mutate
#' @importFrom tidyr gather
extract_sheet <- function(sheet_name, xls_file, columns) {

    section <- read_excel(path = xls_file,
                          sheet = sheet_name)
    colnames(section)[1] <- "ID"
    section %>%
        select(one_of(c("ID", columns))) %>%  # select the necessary columns
        gather(category, value, -ID) %>%
        mutate("spatial_entity" = sheet_name)
}
