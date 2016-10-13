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
          selectInput(
              inputId = "wug",
              label = "WUG code:",
              choices = list("11002_02", "11002_04",
                             "73107_26", "37007_01",
                             "41024_01", "33021_10",
                             "23086_05", "71024_01",
                             "46021_08")  #ids_list  #selected = ids_list[1]
          )
      ),

      mainPanel(
          tabsetPanel(
              tabPanel("Landgebruik", plotOutput("barlu",
                                                 width = "600",
                                                 height = "600")),
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
              )
          )
      )
))
