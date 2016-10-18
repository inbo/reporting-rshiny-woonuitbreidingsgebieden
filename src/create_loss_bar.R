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
create_loss_bar <- function(lu_data_ha){
    lu_data_ha <- lu_data_ha %>%
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

    ggplot(lu_data_ha, aes(x = landuse, y = pt_loss, fill = landuse)) +
        geom_bar(stat = "identity") +
        scale_fill_manual(name = "Landgebruik",
                          breaks = levels(lu_data_ha$landuse),
                          values = cbPalette) +
        #geom_text(aes(y = -0.1, label = sprintf("%2.2f", pt_loss),
        #              hjust = -0.1),
        #          size = 5) +
        scale_x_discrete(limits = unique(lu_data_ha$landuse)) +
        coord_flip() +
        ylab("Verlies aan oppervlakte (%)") +
        xlab("") +
        theme_inbo2015(base_size = 16) +
        theme(axis.text = element_text((size = 16)))

    # http://stackoverflow.com/questions/26853926/positioning-labels-on-geom-bar
}