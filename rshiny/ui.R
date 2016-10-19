#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(radarchart)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  # Application title
  titlePanel("Woonuitbreidingsgebieden"),
  sidebarLayout(

      sidebarPanel(
          #uiOutput("provinces"),
          uiOutput("wuglist")
      ),

      mainPanel(
          tabsetPanel(
              tabPanel("Landgebruik",
                           h2('Procentuele oppervlakte landgebruik'),
                           plotOutput("barlu",
                                      width = "600",
                                      height = "600"),
                           h2('Procentuele verlies oppervlakte landgebruik in gemeente'),
                           plotOutput("barloss",
                                      width = "600",
                                      height = "600")
                       ),
              tabPanel("Ecosysteemdiensten",
                       wellPanel(
                           selectInput("ref", "Vergelijk met:",
                                       list("Gemeente" = "gemeente",
                                            "Vlaanderen" = "vlaanderen",
                                            "WUG gemeente" = "wug_gemeente",
                                            "WUG provincie" = "wug_provincie",
                                            "WUG Vlaanderen" = "wug_vlaanderen")),
                           chartJSRadarOutput("radar",
                                              width = "450",
                                              height = "300"))
                        )
              ),
          textOutput("wug_display")
          )
      )
))

# IDEE ivm landgebruik voorstelling:
# op ha-niveau (niet %) nagaan wat het verlies van landgebruik is



