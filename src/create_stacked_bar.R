#
# Woonuitbreidingsgebieden
#
# S. Van Hoey
# INBO
#

library(dplyr)
library(ggplot2)
library(INBOtheme)

#' Plot an stacked graph of the relative percentages of landuse in each of the
#' spatial entities: WUG, municipality and province
#'
#'@param lu_data tidy version of the landuse data representation
#'
#'@return ggplot barplot
create_stacked_bar <- function(lu_data){
    # arrange the data order to fit the legend order
    lu_data <- lu_data %>%
        arrange(desc(landuse))
    cbPalette <- c("Bos" = "#006d2c",
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

    barp <- ggplot(lu_data, aes(y = area, fill = landuse)) +
        geom_bar(stat = 'identity', aes(x = type)) +
        scale_fill_manual(name = "Landgebruik",
                          values = cbPalette) +

        xlab("") +
        ylab("Oppervlakte %") +
        theme_inbo2015(base_size = 16) +
        theme(axis.text = element_text((size = 16)))
    return(barp)
}