library(shiny)
library(ggplot2)
library(dplyr)
library(plotly)


shinyUI(fluidPage(
  # Application title
  titlePanel("Religions across the world"),
  

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      selectInput("countryId", 
                  label = "Choose country", 
                  choices = c("Europe", "United States of America"),
                  selected = "Europe"),
      
      sliderInput("sliderInput",
                  label = "Year",
                  min = 1945,
                  max = 2010,
                  value = 2010,
                  step = 5,
                  animate = animationOptions(interval = 1000, loop = FALSE))
    ),

    # Main panel
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Structure", column(width = 12,
                                               h4("Religion structure"),
                                               plotly::plotlyOutput("barChart"))),
                  tabPanel("Trend", column(width = 12, 
                                           h4("Changes in religion structure over time"),
                                           plotly::plotlyOutput("linearChart"))),
                  tabPanel("Map", column(width = 12,
                                         h4("Most popular religions on every region (continent)"),
                                         plotly::plotlyOutput("mapChart", width = "100%", height = "500px"),
                                         h4("Summary"),
                                         tableOutput("mapChartSummary")))
      )))
))
