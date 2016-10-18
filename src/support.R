#
# Woonuitbreidingsgebieden
#
# S. Van Hoey
# INBO
#

library(dplyr)
library(tidyr)

#' get from link-table containing an overview of the WUG-NR - Provincie -
#' GEMEENTE relation the corresponding province and municipality based on the
#' WUG identifier
#'
#'@param link_table data.frame
#'@param id_wug char identifier for the WUG
#'
#'@return data.frame containing the wug municipality and province
get_locations <- function(link_table, id_wug){
    return(link_table[link_table$`WUG-NR` == id_wug, c(1, 3:5)])
}


#' get from link-table containing an overview of the WUG-NR - Provincie -
#' GEMEENTE relation the corresponding province and municipality based on the
#' WUG identifier
#'
#'@param link_table data.frame
#'@param id_wug char identifier for the WUG
#'
#'@return list with unique wug identifier codes
get_wug_ids <- function(link_table){
    return(unique(link_table$`WUG-NR`))
}







