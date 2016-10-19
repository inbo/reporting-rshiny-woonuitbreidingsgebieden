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

    barp <- ggplot(lu_data, aes(y = area, fill = landuse)) +
        geom_bar(stat = 'identity', aes(x = type)) +
        scale_fill_manual(name = "Landgebruik",
                          values = cbPalette_lu) +
        xlab("") +
        ylab("Oppervlakte %") +
        theme_inbo2015(base_size = 16) +
        theme(axis.text = element_text((size = 16)))
    return(barp)
}