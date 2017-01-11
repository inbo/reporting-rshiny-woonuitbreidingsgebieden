#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(woonuitbreidingsgebieden)


xls_file <- paste(system.file('extdata', package = 'woonuitbreidingsgebieden'),
                  'Afwegingskader_Wug.xlsx', sep = '/')

# extract data -> info lists about current excel extraction
esd_columns <- c("Voedsel", "Houtprod", "EnergieMaaisel",
                 "NabijGroen", "Bestuiving", "Erosie",
                 "Bodemvrucht", "Copslag_bodem", "Copslag_hout",
                 "Geluidsregulatie", "Luchtzuivering", "UHI",
                 "Denitrificatie", "DiepGrondwater", "Komberging NOG",
                 "Retentie")

esd_sheets <- c("ESD_Wug","ESD_Wug_Vlaanderen", "ESD_Wug_Provincie",
                "ESD_Wug_Gemeente", "ESD_Vlaanderen", "ESD_provincie",
                "ESD_Gemeente")

lu_columns <- c("Bos", "Grasland", "Halfnatuurlijk grasland",
                "Ander groen", "Heide", "Duinen", "Landbouw (akker)",
                "Landbouw (boomgaard)", "Landbouw (grasland)",
                "Landbouw (groenten & fruit)", "Urbaan bebouwd",
                "Urbaan onbebouwd", "Infrastructuur", "Industrie",
                "Militaire voorziening", "Haven", "Water", "Moeras")

lu_sheets <- c("LG_Wug_ha", "LG_Gemeenten_ha", "LG_Provincies_ha",
               "LG_WUG_%", "LG_Gemeenten_%", "LG_Provincies_%")

lu_data <- extract_lu_data(lu_sheets, xls_file, lu_columns)
esd_data <- extract_esd_data(esd_sheets, xls_file, columns)
wug_link_data <- extract_link_table(xls_file, "Info_Wug")

##


info_wug_ids <- readxl::read_excel(path = xls_file, sheet = "Info_Wug")
ids_list <-  as.list(get_wug_ids(info_wug_ids))

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
    output$radar <- renderPlot({
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
