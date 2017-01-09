#
# Woonuitbreidingsgebieden
#
# S. Van Hoey
# INBO
#

#' Plot an stacked graph of the relative percentages of landuse in each of the
#' spatial entities: WUG, municipality and province
#'
#' @param lu_data tidy version of the landuse data representation
#' @param base.text.size int size of the textual graph elements
#'
#' @return ggplot barplot
#' @export
#' @importFrom dplyr %>% arrange_ desc
#' @importFrom ggplot2 ggplot geom_bar scale_fill_manual
#'     ylab xlab theme aes element_text
create_stacked_bar <- function(lu_data, base.text.size = 16){
    # arrange_ the data order to fit the legend order
    lu_data <- lu_data %>%
        arrange_(~desc(landuse))

    barp <- ggplot(lu_data, aes(y = area, fill = landuse)) +
        geom_bar(stat = 'identity', aes(x = type)) +
        scale_fill_manual(name = "Landgebruik",
                          values = cbPalette_lu) +
        xlab("") +
        ylab("Oppervlakte %") +
        theme(text = element_text(size = base.text.size),
              axis.text = element_text(colour = inbo.steun.donkerroos),
              axis.title.x = element_text(colour = vl.grey6),
              axis.title.y = element_text(colour = vl.grey6),
              legend.text = element_text(colour = inbo.steun.donkerroos),
              legend.title = element_text(colour = vl.grey6))
    return(barp)
}
