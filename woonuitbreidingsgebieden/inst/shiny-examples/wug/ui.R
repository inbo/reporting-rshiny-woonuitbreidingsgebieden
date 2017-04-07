#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fixedPage(
    titlePanel("Woonuitbreidingsgebieden"),
    verticalLayout(
        uiOutput("wuglist"),
        mainPanel(width = 12, tabsetPanel(
            tabPanel("Landgebruik",
                     h2("Landgebruik"),
                     p("In de eerste grafiek wordt het huidige landgebruik op elke WUG vergeleken met het landgebruik in de overeenkomstige gemeente en provincie waartoe de WUG behoort. De tweede grafiek geeft aan hoeveel procent van de oppervlakte van een landgebruiksklasse binnen de gemeente zou verdwijnen indien de WUG voor woningbouw ontwikkeld zou worden."),
                     h3('Procentuele oppervlakte landgebruik'),
                     plotOutput("barlu", width = "800", height = "600"),
                     h2(textOutput("gemeente_display")),
                     plotOutput("barloss", width = "800", height = "600"),
                     h4("Disclaimer"),
                     p("De berekeningen achter deze tool zijn gebaseerd op een analyse van ecosysteemdiensten op schaal Vlaanderen in het kader van het Natuurrapport 2014 van het INBO. De tool dient dan ook enkel gebruikt te worden als discussietool en niet als beslissingstool. Lokale aftoetsing is immers steeds nodig. Meer informatie over de berekeningen is terug te vinden in het rapport (zie tab", em("Achtergrondinfo"), "). Noch INBO noch RWO kan verantwoordelijk gesteld worden voor eventueel foutief gebruik van de tool.")
                     ),
            tabPanel("Ecosysteemdiensten",
                     h3(textOutput("wug_display")),
                     p("In het webdiagram wordt het gemiddelde aanbod van zestien onderzochte ecosysteemdiensten op het woonuitbreidingsgebied weergegeven (oranje lijn). De assen van het webdiagram zijn geschaald van 0 tot 1 waarbij 0 staat voor geen aanbod en 1 voor een maximaal aanbod. Een aanbod van 0,5 wordt met een rode lijn aangeduid (threshold). Wanneer een piek in het webdiagram deze lijn overschrijdt, wil dat zeggen dat het aanbod voor die ecosysteemdienst bovengemiddeld is ten opzichte van Vlaanderen. Via een drop down menu kan men selecteren met welke referentie (groene lijn) men het ecosysteemdiensten-aanbod van het woonuitbreidingsgebied wil vergelijken: met het gemiddelde aanbod van ecosysteemdiensten op alle WUG’s binnen de gemeente, op alle WUG’s binnen de provincie of op alle Vlaamse WUG’s of met het gemiddelde aanbod van ecosysteemdiensten in de hele gemeente of provincie waarin het woonuitbreidingsgebied ligt of in heel Vlaanderen."),
                     fluidRow(
                         column(width = 8,
                                selectInput("ref", "Vergelijk met:",
                                            list("Gemeente" = "gemeente",
                                                 "Provincie" = "provincie",
                                                 "Vlaanderen" = "vlaanderen",
                                                 "WUG gemeente" = "wug_gemeente",
                                                 "WUG provincie" = "wug_provincie",
                                                 "WUG Vlaanderen" = "wug_vlaanderen"))),
                         column(width = 2, align = "bottom",
                                actionButton("esd_legend", "Legende")),
                         tags$style(type = 'text/css',
                                    "#esd_legend {margin-top: 25px;}")
                         ),
                     plotOutput("radar", width = "800", height = "800"),
                     h4("Disclaimer"),
                     p("De berekeningen achter deze tool zijn gebaseerd op een analyse van ecosysteemdiensten op schaal Vlaanderen in het kader van het Natuurrapport 2014 van het INBO. De tool dient dan ook enkel gebruikt te worden als discussietool en niet als beslissingstool. Lokale aftoetsing is immers steeds nodig. Meer informatie over de berekeningen is terug te vinden in het rapport (zie tab", em("Achtergrondinfo"), "). Noch INBO noch RWO kan verantwoordelijk gesteld worden voor eventueel foutief gebruik van de tool.")
                     ),
            tabPanel("Achtergrondinfo",
                     br(),
                     p("In de natuur spelen zich allerlei processen af die ons als individu en maatschappij onschatbare voordelen opleveren. Deze voordelen noemen we ecosysteemdiensten. Sommige voordelen zijn zeer duidelijk, anderen zijn dat dan weer veel minder. Hierdoor worden ze niet altijd erkend of naar waarde geschat alhoewel ze ons welzijn en onze welvaart mee bepalen."),
                     p("Landgebruiksveranderingen zijn de belangrijkste directe drivers voor veranderingen in het aanbod aan ecosysteemdiensten. Een wijzigend landgebruik heeft vooral een grote impact als de bodembedekking of het fysieke systeem verandert. Beleidskeuzes die we op vlak van ruimtelijke ordening maken, kunnen dus een enorme impact hebben op de kwaliteit van ons leven en dat van de toekomstige generaties. Het is dan ook belangrijk om bij het afwegen van ruimtelijke beslissingen rekening te houden met ecosysteemdiensten."),
                     p("Daarom ontwikkelde het", a(href = "http://www.inbo.be", "INBO"), "(Instituut voor Natuur- en Bosonderzoek) in opdracht van RWO deze tool. Overheden kunnen dit instrument gebruiken als ondersteuning bij discussies over het al dan niet aansnijden van onbebouwde woonuitbreidingsgebieden (WUG’s). Door te kijken naar het huidige", strong("landgebruik"), "op het woonuitbreidingsgebied, in de gemeente en de provincie waartoe de WUG behoort, kunnen eventuele unieke landgebruiken op het gebied gedetecteerd worden. Daarnaast kwantificeert de tool het gemiddelde aanbod aan 16 onderzochte", strong("ecosysteemdiensten"), "op het woonuitbreidingsgebied en in zijn omgeving. Dit aanbod kan makkelijk vergeleken worden met het aanbod op andere gebieden en ook met het aanbod in de gemeente of provincie waarin de WUG ligt. Zo krijgt men in één oogopslag een duidelijk beeld van de ecosysteemdiensten die op dat gebied geleverd worden en van het potentieel belang van het gebied voor zijn omgeving. Op die manier worden voordien verborgen waarden zichtbaar gemaakt waardoor ze meegenomen kunnen worden in de beslissing over het toekomstig gebruik van een gebied."),
                     br(),
                     a(href = "doi.org/10.21436/inbor.12602210", "Meer weten?"),
                     br(), br(),
                     p("De tool kan enkel gebruikt worden als discussietool en niet als beslissingstool aangezien de screening van het aanbod van ecosysteemdiensten op de WUG’s gebeurd is op basis van kaarten ontwikkeld voor Vlaanderen.", strong("Lokale aftoetsing"), "is daarom steeds nodig!"),
                     p("Momenteel is de tool gebaseerd op een statische dataset en niet op het kaartmateriaal zelf. Op termijn zou een dynamische versie kunnen ontwikkeld worden door deze rechtstreeks te verbinden met de kaarten zelf. Hierdoor kunnen dan toekomstige updates van de kaarten onmiddellijk doorvertaald worden naar de resultaten van de analyse. Daarnaast wordt er nu enkel naar de onbebouwde WUG gebieden gekeken, een uitbreiding naar andere gebieden zou ook een meerwaarde kunnen betekenen."),
                     br(),
                     p("Voor opmerkingen en suggesties kunt u terecht bij onderstaande instanties:"),
                     div("Ruimte Vlaanderen (t.a.v. Anneloes van Noordt)", br(),
                         a(href = "mailto:aom@rwo.vlaanderen.be", "aom@rwo.vlaanderen.be"),
                         p("T 02/553.83.79")
                         ),
                     br(),
                     div("Instituut voor Natuur- en Bosonderzoek (t.a.v. Helen Michels en Inne Vught)",
                         br(),
                         a(href = "mailto:Helen.michels@inbo.be", "Helen.michels@inbo.be"),
                         a(href = "mailto:Inne.vught@inbo.be", "Inne.vught@inbo.be"),
                         p("T 02/525 02 00")
                         ),
                     br()
                     )
              )
          )
      )
))




