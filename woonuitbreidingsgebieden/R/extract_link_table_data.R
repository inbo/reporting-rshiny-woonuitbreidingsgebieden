#
# Woonuitbreidingsgebieden
#
# S. Van Hoey
# INBO
#

#' Extract the data table linking the identifiers of the WUG to their
#' corresponding municipality and province
#'
#' @param xls_file char path name of the excel file interested in
#' @param sheetname char sheet name
#'
#' @return tibble with the link information of WUG to municiaplity and province
#'
#' @export
#' @importFrom readxl read_excel
#' @importFrom dplyr %>% select rename_
extract_link_table <- function(xls_file, sheetname){
    read_excel(xls_file, sheet = sheetname) %>%
        select(one_of(c("WUG-NR", "Provincie", "GEMEENTE"))) %>%
        rename_(WUG_ID = "`WUG-NR`",
                Provincie = "Provincie",
                Gemeente = "GEMEENTE")
}
