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
xls_file <- "../data/Afwegingskader_Wug_versie2.xlsx"
info_wug_ids <- readxl::read_excel(path = xls_file, sheet = "Info_Wug")
ids_list <-  as.list(get_wug_ids(info_wug_ids))
#province_list <- as.list(unique(info_wug$Provincie))

shinyServer(function(input, output) {

    output$wuglist <- renderUI({
        selectizeInput(
            inputId = "wug",
            label = "WUG code:",
            choices = ids_list,
            selected = NULL,
            options = list(
                placeholder = 'Geef de WUG code in',
                maxOptions = 1900,
                onInitialize = I('function() { this.setValue(""); }'))
        )
    })

    # create landuse figure
    lu_data <- reactive({
                    if (is.null(input$wug)) {
                        get_landuse_data(xls_file, ids_list[1])}
                    else if (input$wug == '') {
                        get_landuse_data(xls_file, ids_list[1])}
                    else {get_landuse_data(xls_file, input$wug)}
                    })
    output$barlu <- renderPlot({
                        create_stacked_bar(lu_data())
                        })

    # create the radar chart
    ESD_data <- reactive({
                    if (is.null(input$wug) | input$wug == '') {
                        get_esd_data(xls_file, ids_list[1])}
                    else {get_esd_data(xls_file, input$wug)}
                    })
    output$radar <- renderChartJSRadar({
        create_radar(ESD_data(), input$ref)
        })

    # Provide current WUG
    output$wug_display <- renderText({
        base_string <- "Huidige visualisatie: WUG"
        if (is.null(input$wug)) {
            paste(base_string, ids_list[1])}
        else if (input$wug == '') {
            paste(base_string, ids_list[1])}
        else {paste(base_string, input$wug)}
        })
})

