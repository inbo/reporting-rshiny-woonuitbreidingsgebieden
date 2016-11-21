#
# Woonuitbreidingsgebieden
#
# S. Van Hoey
# INBO
#

#' Plot an interactive radar/spider-chart of the ESD data towards a given
#' reference
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
create_radar <- function(ESD_data, reference, threshold = 0.5){

    current_sel <- ESD_data %>%
        filter_(~type %in% c("wug", reference)) %>%
        spread(key = type, value = value)

    # add the threshold
    current_sel$threshold <- threshold
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
