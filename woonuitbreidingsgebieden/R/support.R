#
# Woonuitbreidingsgebieden
#
# S. Van Hoey
# INBO
#


cbPalette_lu <- c("Bos" = "#006d2c",
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

inbo.steun.donkerroos <- rgb(132, 56, 96, maxColorValue = 255)
inbo.grijs <- rgb(142, 157, 167, maxColorValue = 255)
vl.grey6 <- rgb(73, 73, 73, maxColorValue = 255)

#' get from link-table containing an overview of the WUG-NR - Provincie -
#' GEMEENTE relation the corresponding province and municipality based on the
#' WUG identifier
#'
#' @param link_table data.frame
#' @param id_wug char identifier for the WUG
#'
#' @return data.frame containing the wug municipality and province
#'
#' @export
get_locations <- function(link_table, id_wug){
    return(link_table[link_table$`WUG-NR` == id_wug, c(1, 3:5)])
}


#' get from link-table containing an overview of the WUG-NR - Provincie -
#' GEMEENTE relation the corresponding province and municipality based on the
#' WUG identifier
#'
#' @param link_table data.frame
#'
#' @return list with unique wug identifier codes
#'
#' @export
get_wug_ids <- function(link_table){
    return(unique(link_table$`WUG-NR`))
}







