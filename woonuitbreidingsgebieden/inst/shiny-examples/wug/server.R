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

print(getwd())

#xls_file <- paste(system.file('extdata', package = 'woonuitbreidingsgebieden'),
#                  'Afwegingskader_Wug.xlsx', sep = '/')

xls_file <- "../../extdata/Afwegingskader_Wug_versie2_verbeterd.xlsx"

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

## LOAD DATA INTO MEMORY
wug_link_data <- extract_link_table(xls_file, "Info_Wug")
esd_data_all <- extract_esd_data(esd_sheets, xls_file, esd_columns)
lu_data_all <- extract_lu_data(lu_sheets, xls_file, lu_columns)


ids_list <-  as.list(get_wug_ids(wug_link_data))

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
                        get_landuse_data_pt(lu_data_all,
                                            wug_link_data,
                                            ids_list[1])}
                    else if (input$wug == '') {
                        get_landuse_data_pt(lu_data_all,
                                            wug_link_data,
                                            ids_list[1])}
                    else {get_landuse_data_pt(lu_data_all,
                                              wug_link_data,
                                              input$wug)}
                    })
    output$barlu <- renderPlot({
                        create_stacked_bar(lu_data())
                        })
    # create landuse figure percentage loss municipality
    lu_data_ha <- reactive({
        if (is.null(input$wug)) {
            get_landuse_data_ha(lu_data_all, wug_link_data, ids_list[1])}
        else if (input$wug == '') {
            get_landuse_data_ha(lu_data_all, wug_link_data, ids_list[1])}
        else {get_landuse_data_ha(lu_data_all, wug_link_data, input$wug)}
    })
    output$barloss <- renderPlot({
        create_loss_bar(lu_data_ha())
    })

    # create the radar chart
    esd_data <- reactive({
                    if (is.null(input$wug) | input$wug == '') {
                        get_esd_data(esd_data_all, wug_link_data, ids_list[1])}
                    else {get_esd_data(esd_data_all, wug_link_data, input$wug)}
                    })
    output$radar <- renderPlot({
        create_radar(esd_data(), input$ref)
        })

    observeEvent(input$esd_legend, {
        showModal(modalDialog(footer = modalButton("Sluiten"),
            title = "Legende",
            strong("Voedsel"),
            p("Productie van plantaardige en dierlijke organismen die rechtstreeks of onrechtstreeks (via omzetting van voeder naar vlees, melk en eieren) gebruikt worden voor het voorzien in de menselijke behoeften."),
            strong("Houtproductie"),
            p("Productie van houtige biomassa voor het vervaardigen van industriële en huishoudelijke producten."),
            strong("Energie uit maaisel"),
            p("Productie van plantaardige biomassa die naar biogebaseerde brandstof omgezet kan worden of die rechtstreeks voor energieopwekking kan worden aangewend."),
            strong("Nabij groen"),
            p("De nabijheid van groene ruimte voor dagdagelijkse buitenactiviteiten in de woon- en werkomgeving."),
            strong("Bestuiving"),
            p("Bestuiving van bestuivingsafhankelijke teelten door wilde insecten."),
            strong("Erosiecontrole"),
            p("Het verminderen van bodemerosie door water en wind in erosiegevoelige gebieden door vegetatie."),
            strong("Bodemvruchtbaarheid"),
            p("Behoud van het vermogen in van de bodem om planten van de nodige voedingsstoffen, water en lucht te voorzien voor hun groei en bloei."),
            strong("Globaal klimaat bodem"),
            p("Het verlagen van de atmosferische concentratie van het broeikasgas koolstofdioxide door koolstof vast te leggen in bodem."),
            strong("Globaal klimaat hout"),
            p("Het verlagen van de atmosferische concentratie van het broeikasgas koolstofdioxide door koolstof vast te leggen in vegetatie."),
            strong("Geluidsregulatie"),
            p("Regulatie van geluidsoverlast via fysische en psychologische effecten van vegetatie en landschapselementen op geluidsperceptie."),
            strong("Luchtzuivering"),
            p("Afvang van fijn stof en gasvormige polluenten door vegetatie via de processen van droge en natte depositie."),
            strong("Lokaal klimaat"),
            p("Het milderend effect van vegetatie en wateroppervlakte op extreme temperaturen in stedelijk gebied."),
            strong("Waterzuivering"),
            p("Regulatie van de kwaliteit van het water dat door de mens wordt gebruikt, door verwijdering van stikstof in oppervlaktewater en ecosystemen met ondiep grondwater."),
            strong("Grondwaterproductie"),
            p("Geschiktheid voor de aanvulling van diepe grondwaterlagen (infiltratie) en dus voor de productie van grondwater van goede kwaliteit voor menselijk gebruik."),
            strong("Komberging"),
            p("Het onder controle houden van het overstromingsrisico door het (tijdelijk) bergen van water in overstroombare ecosystemen in valleigebieden."),
            strong("Retentie"),
            p("Het onder controle houden van het overstromingsrisico door het vasthouden van water.")
        ))
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
