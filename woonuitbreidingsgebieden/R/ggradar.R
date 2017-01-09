# This code is an adaptation of the ggplot extension package ggradar
# https://github.com/ricardo-bion/ggradar from original author Ricardo Bion
# The ggradar package is largely based on the code from
# http://rstudio-pubs-static.s3.amazonaws.com/5795_e6e6411731bb4f1b9cc7eb49499c2082.html
#
# further adapted and reconfigured by S. Van Hoey

#' ggplot style radar chart plots
#'
#' @param plot.data data.frame with the first column the group names of the
#' individual rows. All the other columns define the individual radial axis
#' @param base.text.size int size of the text elements in the graph
#' @param axis.labels list default the titles of the second to last column names
#' @param plot.extent.x.sf float scaling factor of plot size in x direction
#' @param plot.extent.y.sf float scaling factor of plot size in y direction
#' @param grid.line.width width of the grid lines
#' @param grid.line.linetype linetype of the grid lines
#' @param grid.line.colour colour of the grid lines
#' @param grid.line.alpha transparency of text tabels used for the grid ticks
#' @param grid.label.ticks list of 3 values (min, mid, max), defining the  values
#' (according to data) to put the grid ticks
#' @param grid.label.values text tabels used for the grid ticks
#' @param grid.label.size size of text tabels used for the grid ticks
#' @param grid.label.colour colour of text tabels used for the grid ticks
#' @param grid.label.min bool plot the smallest value of the grid tick labels
#' @param axis.label.offset offset value to shift the labels from the grid cross sections
#' @param axis.label.size size of the axis labels
#' @param axis.label.colour colour of the axis labels
#' @param group.line.width line width of the data lines
#' @param group.point.size point size of the data
#' @param background.circle.colour colour of the background panel
#' @param background.circle.transparency transparency of the background panel
#' @param plot.legend boolean add a legend (TRUE) or not (FALSE)
#' @param legend.text.size size of the legend text
#' @param legend.text.colour colour of the legend text
#' @param group.linecolors colours of the lines, when the list of colors does
#' not match the  number of columns, the provided list of colors will be
#' replicated and colors will be reused
#'
#' @importFrom ggplot2 ggplot geom_point geom_text geom_path geom_polygon
#'     scale_x_continuous scale_y_continuous scale_colour_manual element_rect
#'     ylab xlab theme aes element_text element_blank unit labs theme_bw
#'     coord_equal
#'
#' @export
ggradar <- function(plot.data,
                    base.text.size = 14,
                    axis.labels = colnames(plot.data)[-1],
                    plot.extent.x.sf = 1,
                    plot.extent.y.sf = 1.2,
                    grid.line.width = 0.5,
                    grid.line.linetype = "longdash",
                    grid.line.colour = "grey",
                    grid.line.alpha = 0.5,
                    grid.label.ticks = c(0, 0.5, 1),
                    grid.label.values = c("0%", "50%", "100%"),
                    grid.label.size = 7,
                    grid.label.colour = 'grey',
                    grid.label.min = TRUE,
                    axis.label.offset = 1.15,
                    axis.label.size = 8,
                    axis.label.colour = "grey",
                    group.line.width = 1.5,
                    group.point.size = 6,
                    background.circle.colour = "grey",
                    background.circle.transparency = 0.2,
                    plot.legend = if (nrow(plot.data) > 1) TRUE else FALSE,
                    legend.text.size = grid.label.size,
                    legend.text.colour = "grey",
                    group.linecolors = c("#FF5A5F", "#FFB400", "#007A87",
                                         "#8CE071", "#7B0051", "#00D1C1",
                                         "#FFAA91", "#B4A76C", "#9CA299",
                                         "#565A5C", "#00A04B", "#E54C20")) {

    grid.min <- grid.label.ticks[1]
    grid.mid <- grid.label.ticks[2]
    grid.max <- grid.label.ticks[3]

    centre.y = grid.min - ((1/9)*(grid.max - grid.min))
    x.centre.range = 0.02*(grid.max - centre.y)
    grid.label.offset = 0.02*(grid.max - centre.y)

    plot.data <- as.data.frame(plot.data)

    #plot.data[,1] <- as.factor(as.character(plot.data[,1]))
    names(plot.data)[1] <- "group"

    var.names <- colnames(plot.data)[-1]  #'Short version of variable names
    #axis.labels [if supplied] is designed to hold 'long version' of variable names
    #with line-breaks indicated using \n

    # calculate total plot extent as radius of outer circle x a
    # user-specifiable scaling factor
    plot.extent.x = (grid.max + abs(centre.y))*plot.extent.x.sf
    plot.extent.y = (grid.max + abs(centre.y))*plot.extent.y.sf

    #Check supplied data makes sense
    if (length(axis.labels) != ncol(plot.data) - 1)
        return("Error: 'axis.labels' contains the wrong number of axis labels")
    if (min(plot.data[, -1]) < centre.y)
        return("Error: plot.data' contains value(s) < centre.y")
    if (max(plot.data[, -1]) > grid.max)
        return("Error: 'plot.data' contains value(s) > grid.max")
    #Declare required internal functions

    CalculateGroupPath <- function(df) {
        #Converts variable values into a set of radial x-y coordinates
        #Code adapted from a solution posted by Tony M to
        #http://stackoverflow.com/questions/9614433/creating-radar-chart-a-k-a-star-plot-spider-plot-using-ggplot2-in-r
        #Args:
        #  df: Col 1 -  group ('unique' cluster / group ID of entity)
        #      Col 2-n:  v1.value to vn.value - values (e.g. group/cluser mean or median) of variables v1 to v.n

        path <- df[,1]

        ##find increment
        angles = seq(from = 0, to = 2*pi, by = (2*pi)/(ncol(df) - 1))
        ##create graph data frame
        graphData = data.frame(seg = "", x = 0, y = 0)
        graphData = graphData[-1,]

        for (i in levels(path)) {
            pathData = subset(df, df[,1] == i)
            for (j in c(2:ncol(df))) {
                #pathData[,j]= pathData[,j]

                graphData = rbind(graphData, data.frame(group = i,
                                x = pathData[,j]*sin(angles[j - 1]),
                                y = pathData[,j]*cos(angles[j - 1])))
            }
            ##complete the path by repeating first pair of coords in the path
            graphData = rbind(graphData, data.frame(group = i,
                            x = pathData[,2]*sin(angles[1]),
                            y = pathData[,2]*cos(angles[1])))
        }
        #Make sure that name of first column matches that of input data (in case !="group")
        colnames(graphData)[1] <- colnames(df)[1]
        graphData #data frame returned by function
    }

    CaclulateAxisPath = function(var.names,min,max) {
        # Calculates x-y coordinates for a set of radial axes (one per variable
        # being plotted in radar plot)
        #Args:
        #var.names - list of variables to be plotted on radar plot
        #min - MININUM value required for the plotted axes (same value will be applied to all axes)
        #max - MAXIMUM value required for the plotted axes (same value will be applied to all axes)
        #var.names <- c("v1","v2","v3","v4","v5")
        n.vars <- length(var.names) # number of vars (axes) required
        #Cacluate required number of angles (in radians)
        angles <- seq(from = 0, to = 2*pi, by = (2*pi)/n.vars)
        #calculate vectors of min and max x+y coords
        min.x <- min*sin(angles)
        min.y <- min*cos(angles)
        max.x <- max*sin(angles)
        max.y <- max*cos(angles)
        #Combine into a set of uniquely numbered paths (one per variable)
        axisData <- NULL
        for (i in 1:n.vars) {
            a <- c(i,min.x[i],min.y[i])
            b <- c(i,max.x[i],max.y[i])
            axisData <- rbind(axisData,a,b)
        }
        #Add column names + set row names = row no. to allow conversion into a data frame
        colnames(axisData) <- c("axis.no","x","y")
        rownames(axisData) <- seq(1:nrow(axisData))
        #Return calculated axis paths
        as.data.frame(axisData)
    }
    funcCircleCoords <- function(center = c(0,0), r = 1, npoints = 100){
        #Adapted from Joran's response to http://stackoverflow.com/questions/6862742/draw-a-circle-with-ggplot2
        tt <- seq(0,2*pi,length.out = npoints)
        xx <- center[1] + r * cos(tt)
        yy <- center[2] + r * sin(tt)
        return(data.frame(x = xx, y = yy))
    }

    ### Convert supplied data into plottable format
    # (a) add abs(centre.y) to supplied plot data
    #[creates plot centroid of 0,0 for internal use, regardless of min. value of y
    # in user-supplied data]
    plot.data.offset <- plot.data
    plot.data.offset[,2:ncol(plot.data)] <- plot.data[,2:ncol(plot.data)] +
                                                    abs(centre.y)

    # (b) convert into radial coords
    group <- NULL
    group$path <- CalculateGroupPath(plot.data.offset)
    group$path$group <- factor(group$path$group,
                               levels = levels(plot.data$group),
                               ordered = TRUE)

    # (c) Calculate coordinates required to plot radial variable axes
    axis <- NULL
    axis$path <- CaclulateAxisPath(var.names,
                                   grid.min + abs(centre.y),
                                   grid.max + abs(centre.y))

    # (d) Create file containing axis labels + associated plotting coordinates
    # labels
    axis$label <- data.frame(
        text = axis.labels,
        x = NA,
        y = NA )

    #axis label coordinates
    n.vars <- length(var.names)
    angles = seq(from = 0, to = 2*pi, by = (2*pi)/n.vars)
    axis$label$x <- sapply(1:n.vars,
                           function(i, x) {((grid.max +
                            abs(centre.y))*axis.label.offset)*sin(angles[i])})
    axis$label$y <- sapply(1:n.vars,
                           function(i, x) {((grid.max +
                            abs(centre.y))*axis.label.offset)*cos(angles[i])})

    # (e) Create Circular grid-lines + labels
    # calculate the cooridinates required to plot circular grid-lines
    # for three user-specified
    # y-axis values: min, mid and max [grid.min; grid.mid; grid.max]
    gridline <- NULL
    gridline$min$path <- funcCircleCoords(c(0, 0), grid.min + abs(centre.y),
                                          npoints = 360)
    gridline$mid$path <- funcCircleCoords(c(0, 0), grid.mid + abs(centre.y),
                                          npoints = 360)
    gridline$max$path <- funcCircleCoords(c(0, 0), grid.max + abs(centre.y),
                                          npoints = 360)

    #gridline labels
    gridline$min$label <- data.frame(y = grid.label.offset,
                                     x = grid.min + abs(centre.y) - grid.label.offset,
                                     text = as.character(grid.min))
    gridline$max$label <- data.frame(y = grid.label.offset,
                                     x = grid.max + abs(centre.y) - grid.label.offset,
                                     text = as.character(grid.max))
    gridline$mid$label <- data.frame(y = grid.label.offset,
                                     x = grid.mid + abs(centre.y) - grid.label.offset,
                                     text = as.character(grid.mid))

    ### Start building up the radar plot

    # Declare 'theme_clear', with or without a plot legend as required by user
    #[default = no legend if only 1 group [path] being plotted]
    theme_clear <- theme_bw(base_size = base.text.size) +
        theme(axis.text.y = element_blank(),
              axis.text.x = element_blank(),
              axis.ticks = element_blank(),
              axis.line = element_blank(),
              panel.grid.major = element_blank(),
              panel.grid.minor = element_blank(),
              panel.border = element_blank(),
              legend.key = element_rect(linetype = "blank"))

    if (plot.legend == FALSE) theme_clear <- theme_clear +
        theme(legend.position = "none")

    #B ase-layer = axis labels + plot extent
    # [need to declare plot extent as well, since the axis labels don't always
    # fit within the plot area automatically calculated by ggplot, even if all
    # included in first plot; and in any case the strategy followed here is to first
    # plot right-justified labels for axis labels to left of Y axis for x< (-x.centre.range)],
    # then centred labels for axis labels almost immediately above/below x= 0
    # [abs(x) < x.centre.range]; then left-justified axis labels to right of Y axis [x>0].
    # This building up the plot in layers doesn't allow ggplot to correctly
    # identify plot extent when plotting first (base) layer]

    #base layer = axis labels for axes to left of central y-axis [x< -(x.centre.range)]
    base <- ggplot(axis$label) + xlab(NULL) + ylab(NULL) + coord_equal() +
        geom_text(data = subset(axis$label,axis$label$x < (-x.centre.range)),
                  aes(x = x, y = y, label = text),
                  size = axis.label.size, hjust = 1,
                  colour = axis.label.colour) +
        scale_x_continuous(limits = c(-1.5*plot.extent.x, 1.5*plot.extent.x)) +
        scale_y_continuous(limits = c(-plot.extent.y, plot.extent.y))

    # + axis labels for any vertical axes [abs(x)<=x.centre.range]
    base <- base + geom_text(data = subset(axis$label,
                                           abs(axis$label$x) <= x.centre.range),
                             aes(x = x, y = y, label = text),
                             size = axis.label.size, hjust = 0.5,
                             colour = axis.label.colour)

    # + axis labels for any vertical axes [x>x.centre.range]
    base <- base + geom_text(data = subset(axis$label,
                                           axis$label$x > x.centre.range),
                             aes(x = x, y = y, label = text),
                             size = axis.label.size, hjust = 0,
                             colour = axis.label.colour)
    # + theme_clear [to remove grey plot background, grid lines,
    #                   axis tick marks and axis text]
    base <- base + theme_clear

    #  + background circle against which to plot radar data
    base <- base + geom_polygon(data = gridline$max$path, aes(x, y),
                                fill = background.circle.colour,
                                alpha = background.circle.transparency)

    # + radial axes
    base <- base + geom_path(data = axis$path, aes(x = x, y = y,
                                                   group = axis.no),
                             colour = grid.line.colour,
                             linetype = grid.line.linetype,
                             alpha = grid.line.alpha,
                             size = grid.line.width)

    #... + amend Legend title
    if (plot.legend == TRUE) base  <- base + labs(size = legend.text.size)

    # ... + circular grid-lines at 'min', 'mid' and 'max' y-axis values
    base <- base +  geom_path(data = gridline$min$path, aes(x = x, y = y),
                              lty = grid.line.linetype,
                              colour = grid.line.colour,
                              size = grid.line.width,
                              alpha = grid.line.alpha)
    base <- base +  geom_path(data = gridline$mid$path, aes(x = x, y = y),
                              lty = grid.line.linetype,
                              colour = grid.line.colour,
                              size = grid.line.width,
                              alpha = grid.line.alpha)
    base <- base +  geom_path(data = gridline$max$path, aes(x = x, y = y),
                              lty = grid.line.linetype,
                              colour = grid.line.colour,
                              size = grid.line.width,
                              alpha = grid.line.alpha)

    # ... + group (cluster) 'paths'
    base <- base + geom_path(data = group$path, aes(x = x, y = y,
                                                    group = group,
                                                    colour = group),
                             size = group.line.width)

    # ... + grid-line labels (max; ave; min) [only add min.
    # gridline label if required]
    if (grid.label.min == TRUE) {
        base <- base + geom_text(aes(x = x, y = y,
                                     label = grid.label.values[1]),
                                 data = gridline$min$label,
                                 size = grid.label.size*0.8, hjust = 1,
                                 colour = grid.label.colour)
        }
    base <- base + geom_text(aes(x = x, y = y, label = grid.label.values[2]),
                             data = gridline$mid$label,
                             size = grid.label.size*0.8, hjust = 1,
                             colour = grid.label.colour)
    base <- base + geom_text(aes(x = x, y = y, label = grid.label.values[3]),
                             data = gridline$max$label,
                             size = grid.label.size*0.8, hjust = 1,
                             colour = grid.label.colour)

    base <- base +
        scale_colour_manual(values = rep(group.linecolors, 100)) +
        theme(text = element_text(size = base.text.size)) +
        theme(legend.text = element_text(size = base.text.size,
                                         colour = legend.text.colour),
              legend.position = "top",
              legend.title = element_blank(),
              legend.key.height = unit(2, "line"),
              legend.key.width = unit(3, "line"))

    return(base)
}
