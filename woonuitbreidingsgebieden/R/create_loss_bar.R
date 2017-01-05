#
# Woonuitbreidingsgebieden
#
# S. Van Hoey
# INBO
#

#' Plot an stacked graph of the relative percentages of landuse in each of the
#' spatial entities: WUG, municipality and province
#'
#' @param lu_data_ha tidy version of the landuse data representation
#' @param base.text.size int size of the textual graph elements
#'
#' @return ggplot barplot
#'
#' @export
#' @importFrom dplyr %>% arrange_ desc
#' @importFrom ggplot2 ggplot geom_bar scale_fill_manual scale_x_discrete
#'     coord_flip ylab xlab theme aes element_text
create_loss_bar <- function(lu_data_ha, base.text.size = 16){
    lu_data_ha <- lu_data_ha %>%
        arrange_(~desc(landuse)) %>%
        filter_(~pt_loss > 0.0)

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
        xlab("")  +
        theme(text = element_text(size = base.text.size),
              axis.text = element_text(colour = inbo.steun.donkerroos),
              axis.title.x = element_text(colour = vl.grey6),
              axis.title.y = element_text(colour = vl.grey6),
              legend.text = element_text(colour = inbo.steun.donkerroos),
              legend.title = element_text(colour = vl.grey6))
}


