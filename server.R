library(shiny)
library(ggplot2)
library(dplyr)
library(plotly)

shinyServer(function(input, output) {
  # Reactive functions
  sliderValue <- reactive({
    input$sliderInput
  })
  
  selectedCountry <- reactive({
    input$countryId
  })
  
  pieChartFrame <- reactive({
    frm <- df[df$region == input$countryId & 
                df$year == input$sliderInput, ]
  })
  
  lineChartFrame <- reactive({
    frm <- df[df$region == input$countryId, ]
  })
  
  mapChartFrame <- reactive({
    frm <- as.data.frame(df.map[df.map$year == input$sliderInput, ])
  })
  
  mapSummaryFrame <- reactive({
    frm <- as.data.frame(df.map.table.summary[df.map.table.summary$year == input$sliderInput, ])
  })
  
  
  
  #What is the religious structure of European population and how did it change over time?
  output$barChart <- renderPlotly({
    frm <- pieChartFrame()
    frm$category <- as.factor(frm$category)
    frm <- dplyr::arrange(frm, desc(Percentage))
    
    plot_ly(data = frm, x = category, y = Percentage, type = "bar")
    plotly::layout(xaxis = list(title = "Religion"), yaxis = list(title = "%"))
    })
  
  
  output$linearChart <- renderPlotly({
    frm <- lineChartFrame()
    frm$category <- as.factor(frm$category)
    
    plot_ly(data = frm, x = year, y = Percentage, color = category)
    plotly::layout(xaxis = list(title = "Year"), yaxis = list(title = "%"))
  })
  
  output$mapChart <- renderPlotly({
    frm <- mapChartFrame()
    g <- list(showframe = FALSE, showcoastlines = FALSE, projection = list(type = "Mercator"))
    l <- list(color = toRGB("grey"), width = 0.5)
    title.year <- sliderValue()
    #frm$region <- as.factor(frm$region)
    frm$code3 <- as.factor(frm$code3)
    #frm$category <- as.factor(frm$category)
    frm$cat2 <- as.numeric(as.factor(frm$category))
    
    
    plot_ly(data = frm, 
            z = cat2, 
            text = paste(region, ", ", category, ": ", round(Percentage, 2), sep = ""),
            color = cat2,
            locations = code3, 
            type = 'choropleth',
            marker = list(line = l),
            colors = c("#F44336", "#673AB7", "#03A9F4", "#4CAF50", "#E91E63", "#FF9800", "#000000", "#9E9E9E"),
            colorbar = list(title = "Religion",
                            tickvals = 1:7,
                            ticks = as.character(levels(as.factor(frm$category))),
                            ticktext = as.character(levels(as.factor(frm$category)))))
    layout(geo = g)
  })
  
  output$mapChartSummary <- renderTable({
    frm <- mapSummaryFrame()
    frm <- frm[, -4]
    names(frm) <- c("Year", "Religion", "Continent", "Population", "Percent")
    frm$Population <- round(frm$Population, 0)
    frm
  })
  
})
