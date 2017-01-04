#
# Script used from https://github.com/jerryzhujian9/ezmisc/blob/master/R/plot.R
# The MIT License (MIT)
#
# Copyright (c) 2016 jerryzhujian9
#
# http://stackoverflow.com/questions/28898143/closing-the-lines-in-a-ggplot2-radar-spider-chart
#

#' define a new coordinate system
#' @return
#' @examples
#' @export
coord_radar <- function(theta = "x", start = 0, direction = 1)
{
    theta <- match.arg(theta, c("x", "y"))
    r <- if (theta == "x")
        "y"
    else "x"
    ggproto("CordRadar", CoordPolar, theta = theta,
            r = r, start = start,
            direction = sign(direction),
            is_linear = function(coord) TRUE)
}


#' draw a radar plot
#' @description variables/axes arranged in the shape of a radar map, scales are rescaled to 0-1
#' \cr best works with multivariates
#' @param df a data frame with a single variable as factor and all othere variables being numeric
#' @param id column name as id in quotes ""
#' @param stats perform stats (with NA removed) grouped by id, "mean", "median", "sd", "var", "none"; if "none", assume df already has summary stats
#' @param lwd line width
#' @param angle angle to show the variable names
#' @param fontsize fontsize of variable names, if 0, no variable names shown
#' @param facet if F show each id level separately; if T show all levels in one plot
#' @param facetfontsize fontsize of id level names (only valid when facet=T)
#' @param color color for different id levels, if NULL, remain the same for different id levels
#' @param linetype linetype for different id levels, if NULL, remain the same for different id levels
#' @return a ggplot object (+theme_apa() to get apa format plot)
#' @examples
#' @note As a reminder, the returned ggplot object can be modified post-hoc
#' @export
#' @references \href{http://www.cmap.polytechnique.fr/~lepennec/R/Radar/RadarAndParallelPlots.html}{Erwan Le Pennec - CMAP}
ez.radarmap <- function(df, id, stats="mean", lwd=1, angle=0, fontsize=0.8,
                       facet=FALSE, facetfontsize=1, color=id, linetype=NULL)
{
    df.ori = df

    # 1) summarise
    if (stats != "none") {
        cmd = sprintf('df.stats = dplyr::summarise_each(dplyr::group_by(df.ori,%s),
                      dplyr::funs(%s(.,na.rm=T)))
                      ', id, stats)
        eval(parse(text = cmd))
    } else {
        df.stats = df.ori
    }

    # 2) to long format
    cmd = sprintf('tidyr::gather(df.stats, variable, value, -%s, factor_key = T) -> df
                  ',id)
    eval(parse(text = cmd))

    # 4) plot
    # geom_polygon connects together, no fill
    # geom_line draw legend (the legend by polygon is hallow)
    if (!facet) {
        cmd = sprintf('
                      p=ggplot(df, aes(x = variable, y = value, group = %s, color=%s, linetype=%s)) +
                      geom_polygon(aes(), fill = NA, size = %f, show.legend = FALSE) +
                      geom_line(aes(), size = %f) +
                      theme(axis.text.x = element_text(size = rel(%f), angle = %d),
                      axis.ticks.y = element_blank(),
                      axis.text.y = element_blank()) +
                      xlab("") + ylab("") +
                      guides(color = guide_legend(ncol=2)) +
                      coord_radar()
                      ', id, id, id, lwd, lwd, fontsize, angle)

    } else {
        cmd = sprintf('
                      p=ggplot(df, aes(x = variable, y = value, group = %s, color = %s, linetype = %s)) +
                      geom_polygon(aes(), fill = NA, size = %f, show.legend = FALSE) +
                      facet_wrap(~ %s) +
                      theme(strip.text.x = element_text(size = rel(%f)),
                      axis.ticks.x = element_blank(),
                      axis.text.x = element_text(size = rel(%f), angle = %d),
                      axis.ticks.y = element_blank(),
                      axis.text.y = element_blank()) +
                      xlab("") + ylab("") +
                      guides(color = "none") +
                      coord_radar()
                      ', id, id, id, lwd, id, facetfontsize, fontsize, angle)

    }
    eval(parse(text = cmd))

    # 5) hack: couldn't pass NULL to color, linetype
    if (is.null(color)) {
        cmd = sprintf('p = p + scale_color_manual(values=rep("black",nlevels(factor(df$%s))))
                      ',id)
        eval(parse(text = cmd))
    }
    if (is.null(linetype)) {
        cmd = sprintf('p = p + scale_linetype_manual(values=rep("solid",nlevels(factor(df$%s))))
                      ',id)
        eval(parse(text = cmd))
    }

    return(p)
    }
