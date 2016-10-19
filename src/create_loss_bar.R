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

    ggplot(lu_data_ha, aes(x = landuse, y = pt_loss, fill = landuse)) +
        geom_bar(stat = "identity") +
        scale_fill_manual(name = "Landgebruik",
                          breaks = levels(lu_data_ha$landuse),
                          values = cbPalette_lu) +
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