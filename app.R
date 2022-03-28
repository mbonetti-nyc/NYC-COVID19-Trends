#####################################################
# STA 9750 - Basic Software Tools for Data Analysis
# CUNY Bernard M. Baruch College
# Prof. Jeff Collard
# Final Project

# NYC COVID-19 Trends via ZIP Codes (MODZCTA)
# PART II - Shiny App
# Michael S. Bonetti
# May 11, 2021
#####################################################

# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com/
#

####################
# I. Load Libraries
####################

library(htmlwidgets)
library(leaflet)
library(shiny)
library(sf)
library(tidyverse)

############################
# II. Set Working Directory
############################

#setwd("C:\\Users\\Blwndrpwrmlk\\Desktop\\NYC COVID-19 Trends")
all_modzcta = readRDS("all_modzcta.RDS")

#################################
# III. Define UI for Application
#################################

ui = fluidPage(
  # Application title
  titlePanel("NYC COVID-19 Trends by ZIP Code (Modified ZCTA)"),
  # Sidebar with a date input
  sidebarLayout(
    sidebarPanel(
      tags$a(href="https://github.com/nychealth/coronavirus-data","Data Repository - GitHub", target="_blank"),
      tags$br(),
      tags$a(href="https://rockedu.rockefeller.edu/people/caitlin-gilbert/","Caitlin Gilbert - The Rockefeller University", target="_blank"),
      tags$hr(), h6("All data metrics are aggregated by week (categorized by weekly 'ending in' dates). Percent positives indicate the percentage of NYC residents who tested for COVID-19 with a positive molecular test."),
      h6("Modified ZCTA (ZIP Code Tabulation Area) is shown instead of ZCTA, whereby unusually small ZCTAs are consolidated into MODZCTAs for better regional comparisons. ZCTA-to-MODZCTA conversion table available in Data Repository."),
      tags$hr(), h6("Special thanks to Caitlin Gilbert, a Rockefeller Graduate Fellow and Ph.D. candidate at the Rockefeller Univerity (New York, NY), for her work, contributions, and tutorials related to the creation of this R code and R Shiny Application."),
      tags$hr(), h6("All data is sourced from the NYC Department of Health."),
      tags$br(), tags$a(href="https://github.com/mbonetti-nyc/NYC-COVID19-Trends","Michael S. Bonetti - GitHub", target="_blank"),
      tags$br(), tags$a(href="https://zicklin.baruch.cuny.edu/","Zicklin School of Business", target="_blank"),
      tags$br(), tags$a(href="https://www.baruch.cuny.edu/","CUNY Bernard M. Baruch College", target="_blank"),
      #h6("Zicklin School of Business"),
      #h6("CUNY Bernard M. Baruch College"),
      selectInput("date",
                  "Select a date (week ending in):",
                  choices = unique(all_modzcta$week_ending))),
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        tabPanel("Case Rate", leafletOutput("cases")),
        tabPanel("Test Rate", leafletOutput("tests")),
        tabPanel("Percent Positive", leafletOutput("pctpos")))))
)

##########################
# IV. Define Server Logic
##########################

server = function(input, output) {
  
  week_zcta     = reactive({
    w = all_modzcta %>% filter(week_ending == input$date)
    return(w)
  })
  
  output$cases  = renderLeaflet({
    pal = colorBin(palette = "YlGn", 9, pretty = TRUE, domain = all_modzcta$caserate)
    
    lables = sprintf(
      "<strong>%s</strong><br/><strong>%s</strong/><br/>%s<br/>%g cases per 100,000 people",
      week_zcta()$neighborhood, week_zcta()$borough, week_zcta()$MODZCTA, week_zcta()$caserate) %>%
      lapply(htmltools::HTML)
    
    week_zcta() %>%
      st_transform(crs = "+init=epsg:4326") %>%
      leaflet() %>%
      addProviderTiles(provider = "CartoDB.Positron") %>%
      setView(-73.9, 40.7, zoom = 10) %>%
      addPolygons(label = lables,
                  stroke = TRUE,
                  smoothFactor = 0.5,
                  opacity = 1,
                  fillOpacity = 0.7,
                  fillColor = ~pal(week_zcta()$caserate),
                  color = "lightgrey", weight = 0.45,
                  highlightOptions = highlightOptions(weight = 1,
                                                      fillOpacity = 1,
                                                      color = 'grey',
                                                      opacity = 1,
                                                      bringToFront = TRUE)) %>%
      addLegend("bottomright",
                pal = pal,
                values = ~caserate,
                title = "Cases per 100,000",
                opacity = 0.7)
  })
  
  output$tests  = renderLeaflet({
    pal = colorBin(palette = "PuBu", 9, pretty = TRUE, domain = all_modzcta$testrate)
    
    lables = sprintf(
      "<strong>%s</strong><br/><strong>%s</strong/><br/>%s<br/>%g tests per 100,000 people",
      week_zcta()$neighborhood, week_zcta()$borough, week_zcta()$MODZCTA, week_zcta()$testrate) %>%
      lapply(htmltools::HTML)
    
    week_zcta() %>%
      st_transform(crs = "+init=epsg:4326") %>%
      leaflet() %>%
      addProviderTiles(provider = "CartoDB.Positron") %>%
      setView(-73.9, 40.7, zoom = 10) %>%
      addPolygons(label = lables,
                  stroke = TRUE,
                  smoothFactor = 0.5,
                  opacity = 1,
                  fillOpacity = 0.7,
                  fillColor = ~pal(week_zcta()$testrate),
                  color = "lightgrey", weight = 0.45,
                  highlightOptions = highlightOptions(weight = 1,
                                                      fillOpacity = 1,
                                                      color = 'grey',
                                                      opacity = 1,
                                                      bringToFront = TRUE)) %>%
      addLegend("bottomright",
                pal = pal,
                values = ~testrate,
                title = "Tests per 100,000",
                opacity = 0.7)
  })
  
  output$pctpos = renderLeaflet({
    pal = colorBin(palette = "OrRd", 9, pretty = TRUE, domain=all_modzcta$pctpos)
    
    lables = sprintf(
      "<strong>%s</strong><br/><strong>%s</strong/><br/>%s<br/>%g pct. per 100,000 people",
      week_zcta()$neighborhood, week_zcta()$borough, week_zcta()$MODZCTA, week_zcta()$pctpos) %>%
      lapply(htmltools::HTML)
    
    week_zcta() %>%
      st_transform(crs = "+init=epsg:4326") %>%
      leaflet() %>%
      addProviderTiles(provider = "CartoDB.Positron") %>%
      setView(-73.9, 40.7, zoom = 10) %>%
      addPolygons(label = lables,
                  stroke = TRUE,
                  smoothFactor = 0.5,
                  opacity = 1,
                  fillOpacity = 0.7,
                  fillColor = ~pal(week_zcta()$pctpos),
                  color = "lightgrey", weight = 0.45,
                  highlightOptions = highlightOptions(weight = 1,
                                                      fillOpacity = 1,
                                                      color = 'grey',
                                                      opacity = 1,
                                                      bringToFront = TRUE)) %>%
      addLegend("bottomright",
                pal = pal,
                values = ~pctpos,
                title = "Percent Positive",
                opacity = 0.7)
  })
}

##########################
# V. Run the Application
##########################

shinyApp(ui = ui, server = server)

#############################
# * * * * END PART II * * * *
#############################
