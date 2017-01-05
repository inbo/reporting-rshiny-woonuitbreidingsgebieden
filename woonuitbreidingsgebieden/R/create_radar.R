#
# Woonuitbreidingsgebieden
#
# S. Van Hoey
# INBO
#

#' Plot an nont-interactive ggplot style radar/spider-chart of the ESD data
#' towards a given reference, using the custom ggradar function, derived from
#' the ggradar package
#'
#' @param ESD_data tidy version of the ESD data representation
#' @param reference char choose an option from: wug, gemeente, vlaanderen,
#'     wug_gemeente, wug_provincie, wug_vlaanderen
#' @param thresh provide the value on which a red threshold line should be
#'     provided
#' @param base.text.size int size of the textual graph elements
#'
#' @export
#' @importFrom dplyr %>% filter_ mutate_ select_ mutate
#' @importFrom tidyr spread_ gather_
create_radar <- function(ESD_data, reference,
                         thresh = 0.5,
                         base.text.size = 16){

    current_sel <- ESD_data %>%
        spread_(key = "type", value = "value") %>%
        mutate_("threshold" = thresh) %>%
        select_("ESD", "wug", reference, "threshold") %>%
        gather(key, value, -ESD) %>%
        mutate(value = round(value, 2)) %>%
        spread_(key = "ESD", value = "value") %>%
        mutate(key = factor(key, levels = c(reference,
                                            "wug",
                                            "threshold"),
                            ordered = TRUE))

    colors <- c("#31a354", "#d95f0e", "#800000")

    ggradar(plot.data = current_sel,
            base.text.size = base.text.size,
            grid.label.values = c(0, 0.5, 1),
            plot.extent.x.sf = 1.2,
            plot.extent.y.sf = 1.3,
            axis.label.size = 5,
            axis.label.offset = 1.1,
            group.point.size = 2,
            group.line.width = 0.5,
            group.linecolors = colors,
            axis.label.colour = inbo.steun.donkerroos,
            grid.line.colour = 'grey',
            grid.line.alpha = 0.5,
            grid.label.size = 6,
            grid.label.colour = inbo.grijs,
            background.circle.colour = 'grey',
            background.circle.transparency = 0.1,
            plot.legend = TRUE,
            legend.text.size = 12,
            legend.text.colour = inbo.steun.donkerroos)
}


#' Plot an interactive radar/spider-chart of the ESD data towards a given
#' reference, using the radarchart package
#'
#' @param ESD_data tidy version of the ESD data representation
#' @param reference char choose an option from: wug, gemeente, vlaanderen,
#'     wug_gemeente, wug_provincie, wug_vlaanderen
#' @param threshold provide the value on which a red threshold line should be
#'     provided
#'
#' @export
#' @importFrom dplyr %>% filter_
#' @importFrom tidyr spread
#' @importFrom radarchart chartJSRadar
create_interactive_radar <- function(ESD_data, reference, thresh = 0.5){

    current_sel <- ESD_data %>%
        filter_(~type %in% c("wug", reference)) %>%
        spread(key = type, value = value)

    # add the threshold
    current_sel$threshold <- thresh
    # sort the columns
    current_sel <- current_sel[, c("ESD", "threshold", reference, "wug")]

    # round the numbers for improved visualisation
    current_sel[,-1] <- round(current_sel[,-1], 2)

    colors <- matrix(c(128, 0, 0, ## versus200, 200, 200,
                       49, 163, 84,
                       217, 95, 14), nrow = 3, ncol = 3)

    radar <- chartJSRadar(current_sel,
                          responsive = TRUE,
                          showToolTipLabel = TRUE,
                          polyAlpha = 0.0,  # 0.3
                          colMatrix = colors,
                          addDots = FALSE,
                          maxScale = 1.,
                          scaleStartValue = 0.0,
                          scaleStepWidth = 0.25
                          )
    return(radar)
}
