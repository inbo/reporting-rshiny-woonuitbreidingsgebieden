library(woonuitbreidingsgebieden)

# specials to check: 11040_01, 44081_02, 73107_10

id_wug <- "73107_10"  #"41048_04"  #"11002_08"  #"11002_02"
xls_file <- "inst/extdata/Afwegingskader_Wug.xlsx"
lu_data_ha <- get_landuse_data_ha(xls_file, id_wug)
create_loss_bar(lu_data_ha)

lu_data_pt <- get_landuse_data_pt(xls_file, id_wug)
create_stacked_bar(lu_data_pt)

esd_data <- get_esd_data(xls_file, id_wug)
create_radar(esd_data, "gemeente")

#---------------------------------

create_radar1 <- function(ESD_data, reference, threshold = 0.5){

    ESD_data <- esd_data
    threshold <- 0.5


    current_sel <- ESD_data %>%
        spread(key = type, value = value) %>%
        mutate(threshold = threshold) %>%
        select(ESD, wug, gemeente, threshold) %>%
        gather(key, value, -ESD) %>%
        mutate(value = round(value, 2)) %>% # round the numbers for improved visualisation
        mutate(key = factor(key, levels = c("gemeente",
                                            "wug",
                                            "threshold"),
                            ordered = TRUE))

    lwd <- 0.5
    fontsize <- 12

    p <- ggplot(current_sel,
                aes(x = ESD, y = value,
                    group = key, color = key)) +
        geom_polygon(aes(), fill = NA, size = lwd,
                     show.legend = FALSE) +
        geom_line(aes(), size = lwd) +
        xlab("") + ylab("") +
        guides(color = guide_legend(ncol = 3, title = NULL)) +
        ylim(c(0, 1)) +
        coord_radar(theta = "x", start = 0) +
        theme(axis.text.x = element_text(size = fontsize, angle = 0),
              axis.ticks.y = element_blank(),
              axis.text.y = element_blank(),
              legend.position = "top",
              legend.text = element_text(size = fontsize, angle = 0)) +
        scale_color_manual(breaks = levels(current_sel$key),
                           values = c("#800000", "#31a354", "#d95f0e"))

    p

    return(radar)
}

id_wug <- "41048_04"
esd_data <- get_esd_data(xls_file, id_wug)
radar <- create_radar (esd_data, "gemeente")
radar


colors <- c("#800000", "#31a354", "#d95f0e")
current_sel <- ESD_data %>%
    spread(key = type, value = value) %>%
    mutate(threshold = threshold) %>%
    select(ESD, wug, gemeente, threshold) %>%
    gather(key, value, -ESD) %>%
    mutate(value = round(value, 2)) %>%
    spread(key = ESD, value = value)

current_sel <- as.data.frame(current_sel)
rownames(current_sel) <- current_sel$key
current_sel$key <- NULL

current_sel <- rbind(rep(1, ncol(current_sel)),
                     rep(0, ncol(current_sel)),
                     current_sel)

## fmsb package
## https://cran.r-project.org/web/packages/fmsb/fmsb.pdf

fmsb::radarchart(df = current_sel, axistype = 1, centerzero = FALSE,
                 pcol = colors, maxmin = TRUE,
                 cglcol = "grey", cglty = 1, axislabcol = "grey", cglwd = 0.8,
                 seg = 3, caxislabels = c(0, 0.25, 0.75, 1))

pcol=colors, pfcol=colors, plwd=4 , plty=1,
cglcol="grey", cglty=1, axislabcol="grey",
caxislabels=seq(0,20,5), cglwd=0.8, vlcex=0.8)


## ggradar
## https://github.com/ricardo-bion/ggradar
## http://rstudio-pubs-static.s3.amazonaws.com/5795_e6e6411731bb4f1b9cc7eb49499c2082.html

colors <- c("#800000", "#31a354", "#d95f0e")
current_sel <- ESD_data %>%
    spread(key = type, value = value) %>%
    mutate(threshold = threshold) %>%
    select(ESD, wug, gemeente, threshold) %>%
    gather(key, value, -ESD) %>%
    mutate(value = round(value, 2)) %>%
    spread(key = ESD, value = value)

p <- ggradar(plot.data = current_sel) +
    theme(axis.text = element_text(size = 12, angle = 0))
p

ggradar2(plot.data = current_sel, values.radar = c(0, 0.5, 1),
         axis.label.size = 4, group.line.width = 0.5,
         gridline.mid.colour = 'grey',
         background.circle.colour = 'grey',
         background.circle.transparency = 0.15)
