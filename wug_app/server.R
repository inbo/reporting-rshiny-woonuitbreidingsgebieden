#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(INBOtheme)
library(radarchart)

source("../src/visualisations.R")


# extract data
xls_file <- "Afwegingskader_Wug_versie2.xlsx"
info_wug_ids <- readxl::read_excel(path = xls_file, sheet = "Info_Wug")
ids_list <-  as.list(get_wug_ids(info_wug_ids)[1:10])

shinyServer(function(input, output) {

    # output$wuglist <- renderUI({
    #     selectInput(
    #         inputId = "wug",
    #         label = "WUG code:",
    #         choices = list("11002_02", "11002_04", "73107_26")  #ids_list  #selected = ids_list[1]
    #     )
    # })

    # create figure
    output$barlu <- renderPlot({
        lu_data <- reactive({get_landuse_data(xls_file, input$wug)})
        create_stacked_bar(lu_data())
        })

    # create the radar chart
    ESD_data <- reactive({get_esd_data(xls_file, input$wug)})

    output$radar <- renderChartJSRadar({
        create_radar(ESD_data(), input$ref)
        })
})

