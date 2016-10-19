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

source('../src/support.R')
source("../src/get_esd_data.R")
source("../src/get_landuse_data.R")
source("../src/create_radar.R")
source("../src/create_stacked_bar.R")
source("../src/create_loss_bar.R")

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

    # create landuse figure percentages
    lu_data <- reactive({
                    if (is.null(input$wug)) {
                        get_landuse_data_pt(xls_file, ids_list[1])}
                    else if (input$wug == '') {
                        get_landuse_data_pt(xls_file, ids_list[1])}
                    else {get_landuse_data_pt(xls_file, input$wug)}
                    })
    output$barlu <- renderPlot({
                        create_stacked_bar(lu_data())
                        })
    # create landuse figure percentage loss municipality
    lu_data_ha <- reactive({
        if (is.null(input$wug)) {
            get_landuse_data_ha(xls_file, ids_list[1])}
        else if (input$wug == '') {
            get_landuse_data_ha(xls_file, ids_list[1])}
        else {get_landuse_data_ha(xls_file, input$wug)}
    })
    output$barloss <- renderPlot({
        create_loss_bar(lu_data_ha())
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
        base_string <- "Ecosysteemdiensten WUG"
        if (is.null(input$wug)) {
            paste(base_string, ids_list[1])}
        else if (input$wug == '') {
            paste(base_string, ids_list[1])}
        else {paste(base_string, input$wug)}
        })
    # Provide current municipality
    output$gemeente_display <- renderText({
        base_string <- "Procentueel verlies oppervlakte landgebruik"
        if (is.null(input$wug)) {
            base_string}
        else if (input$wug == '') {
            base_string}
        else {paste(base_string, "in", names(lu_data_ha())[3])}
    })


})