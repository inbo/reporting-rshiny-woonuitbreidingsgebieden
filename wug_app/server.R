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
#xls_file <- "Afwegingskader_Wug_versie2.xlsx"
xls_file <- "../data/Afwegingskader_Wug_versie2.xlsx"

info_wug_ids <- readxl::read_excel(path = xls_file, sheet = "Info_Wug")
ids_list <-  as.list(get_wug_ids(info_wug_ids))

shinyServer(function(input, output) {

    print(dim(ids_list))
    output$wuglist <- renderUI({
        selectInput(
            inputId = "wug",
            label = "WUG code:",
            choices = ids_list,
            # choices = list("11002_02", "11002_04",
            #                "73107_26", "37007_01",
            #                "41024_01", "33021_10",
            #                "23086_05", "71024_01",
            #                "46021_08"),  #id,s_list  #selected = ids_list[1]
            selected = "11002_02"
        )
    })

    # create landuse figure
    output$barlu <- renderPlot({
        lu_data <- reactive(get_landuse_data(xls_file, input$wug))
        create_stacked_bar(lu_data())
        })

    # create the radar chart
    output$radar <- renderChartJSRadar({
        ESD_data <- reactive({get_esd_data(xls_file, input$wug)})
        create_radar(ESD_data(), input$ref)
        })
})

