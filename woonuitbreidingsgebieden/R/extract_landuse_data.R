#
# Woonuitbreidingsgebieden
#
# S. Van Hoey
# INBO
#

#' Extract all landuse data and combine into a single tidy data set
#'
#' @param lu_sheets list of char with the sheet names
#' @param xls_file char path name of the excel file interested in
#' @param columns list of char with the column names to use
#'
#' @return tibble with the tidy version of the lu-data
#'
#' @export
#' @importFrom dplyr bind_rows
extract_lu_data <- function(lu_sheets, xls_file, columns) {
    lu_data <- bind_rows(lapply(lu_sheets, extract_sheet,
                                xls_file = xls_file,
                                columns = columns))
    lu_data$category <- factor(lu_data$category,
                               levels = c("Bos", "Grasland",
                                          "Halfnatuurlijk grasland",
                                          "Ander groen", "Heide",
                                          "Duinen", "Landbouw (akker)",
                                          "Landbouw (boomgaard)",
                                          "Landbouw (grasland)",
                                          "Landbouw (groenten & fruit)",
                                          "Urbaan bebouwd",
                                          "Urbaan onbebouwd",
                                          "Infrastructuur", "Industrie",
                                          "Militaire voorziening", "Haven",
                                          "Water", "Moeras"),
                               ordered = TRUE)
    return(lu_data)
}
