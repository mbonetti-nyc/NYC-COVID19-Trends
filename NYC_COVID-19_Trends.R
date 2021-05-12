#####################################################
# STA 9750 - Basic Software Tools for Data Analysis
# CUNY Bernard M. Baruch College
# Prof. Jeff Collard
# Final Project

# NYC COVID-19 Trends via Zip Codes (MODZCTA)
# PART I - Prepping Code
# Michael S. Bonetti
# May 11, 2021
#####################################################

# Clear Log, Environment, Plots and Memory
rm(list = ls())
cat("\014")
graphics.off()
gc()

####################
# I. Load Libraries
####################

library(tidyverse)    # tidy data wrangling
library(vroom)        # fast reading / importing of data
library(sf)           # spatial data
library(tigris)       # geojoin
library(leaflet)      # interactive maps
library(htmlwidgets)  # interactive map labels

#setwd("~/")
setwd("C:\\Users\\Blwndrpwrmlk\\Desktop\\NYC COVID-19 Trends")

################
# II. Load Data
################

# Download master repo from NYC DoH GitHub
download.file(url = "https://github.com/nychealth/coronavirus-data/archive/refs/heads/master.zip",
              destfile = "coronavirus-data-master.zip")
unzip(zipfile = "coronavirus-data-master.zip")

# Reading Data - Neighborhoods
neighborhoods = read.csv("zip_borough_neighborhood.csv")
neighborhoods$modzcta = as.character(neighborhoods$modzcta)

# Read-in data
percentpos = vroom("coronavirus-data-master/trends/percentpositive-by-modzcta.csv")
caserate = vroom("coronavirus-data-master/trends/caserate-by-modzcta.csv")
testrate = vroom("coronavirus-data-master/trends/testrate-by-modzcta.csv")

# Read in modzcta shapefile and zcta conversion table
modzcta = st_read("coronavirus-data-master/Geography-resources/MODZCTA_2010.shp")
zcta_conv = vroom("coronavirus-data-master/Geography-resources/ZCTA-to-MODZCTA.csv", delim = ",")

#####################################
# III. Pre-Processing: Data Cleaning
#####################################

# Clean and reshape caserate data
caserates = caserate %>% select(-c(2:7))
caserates_long = caserates %>%
  pivot_longer(2:178, names_to = "modzcta",
               names_prefix = "CASERATE_", values_to = "caserate")

# Clean and reshape percentpos data
percentpositives = percentpos %>% select(-c(2:7))
percentpost_long = percentpositives %>%
  pivot_longer(2:178, names_to = 'modzcta',
               names_prefix = "PCTPOS_", values_to = "pctpos")

# Clean and reshape testrate data
testrates = testrate %>% select(-c(2:7))
testrates_long = testrates %>%
  pivot_longer(2:178, names_to = 'modzcta',
               names_prefix = "TESTRATE_", values_to = "testrate")

##############################
# IV. Merge-in Geography Data
##############################

# Combine all three long data frames (and neighborhoods) into one df
all = caserates_long %>%
  left_join(percentpost_long, by = c("week_ending", "modzcta")) %>%
  left_join(testrates_long, by = c("week_ending", "modzcta")) %>%
  left_join(neighborhoods, by = c("modzcta"))

# Merge COVID data with modzcta shapefile
all_modzcta = geo_join(modzcta, all, 'MODZCTA', 'modzcta', how = "inner")

####################################################################################################################
# NOTE: modzcta and zcta are not the same, as modzctas can encompass several small zctas!
# Code below *would* switch between, but multiple zctas can map to one modzcta, so leaving look-up table is helpful
# all_modzcta$MODZCTA = zcta_conv$ZCTA[match(all_modzcta$MODZCTA, zcta_conv$MODZCTA)]

# Convert week_ending from a character to a date
all_modzcta$week_ending = as.Date(all_modzcta$week_ending, format = "%m/%d/%Y")

# Save df for Shiny app
saveRDS(all_modzcta, "all_modzcta.RDS")

#####################
# V. Data Inspection
#####################

# Check distribution of caserate data
all_modzcta %>%
  ggplot(aes(x=as.numeric(caserate))) + 
  geom_histogram(bins = 20, fill = '#69b3a2', color = 'white') +
  labs(title = "Histogram of NYC COVID-19 Case Rate Distribution",
       x = "Case Rate (per 100,000 NYC Residents)", y = "Case Count")
  

##############################################
# VI. Make Interactive Map of Caserate (Test)
##############################################

lables = sprintf(
  "<strong>%s</strong><br/><strong>%s</strong/><br/>%s<br/>%g cases per 100,000 people",
  all_modzcta$neighborhood, all_modzcta$borough, all_modzcta$MODZCTA, all_modzcta$caserate) %>%
  lapply(htmltools::HTML)

pal = colorBin(palette =  "OrRd", 9, pretty = TRUE, domain = all_modzcta$caserate)
# pal = colorNumeric(pallete = "OrRd", 9, domain = all_modzcta$caserate))

map_interactive = all_modzcta %>%
  st_transform(crs = "+init=epsg:4326") %>%
  leaflet() %>%
  addProviderTiles(provider = "CartoDB.Positron") %>%
  addPolygons(label = lables,
              stroke = TRUE,
              smoothFactor = 0.5,
              opacity = 1,
              fillOpacity = 0.7,
              fillColor = ~ pal(caserate),
              color = "lightgrey", weight = 0.45,
              highlightOptions = highlightOptions(weight = 1,
                                                  fillOpacity = 1,
                                                  color = 'grey',
                                                  opacity = 1,
                                                  bringToFront = TRUE)) %>%
  addLegend("bottomright",
            pal = pal,
            values = ~ caserate,
            title = "Cases per 100,000",
            opacity = 0.7)
  
map_interactive
gc()
# saveWidget(map_interactive, "nyc_covid_caserate_map.html")

##############################
# * * * * END PART I * * * * *
##############################