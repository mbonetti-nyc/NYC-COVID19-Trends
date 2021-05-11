<img src="https://user-images.githubusercontent.com/83367900/117875598-5a89e580-b270-11eb-881e-c1342ef558d7.jpg" width="100%" height="100%">

# NYC COVID-19 Trends
### Michael S. Bonetti
#### Zicklin School of Business
#### CUNY Bernard M. Baruch College
#
#### Brief Description

This project aims to examine COVID-19 (novel coronavirus) trends throughout the 5 boroughs of New York City, from August 2020 until the present. Measurements are the cases per 100,000, tests per 100,000, percent of NYC residents who tested positive based on a positive molecular test for COVID-19. Data repository is mapped weekly from the NYC Department of Health, per ZIP codes (MODZCTA).
https://github.com/nychealth/coronavirus-data

All data metrics are aggregated by week (categorized by weekly 'ending in' dates). Percent positives indicate the percentage of NYC residents who tested for COVID-19 with a positive molelcular test. Modified ZCTA (ZIP Code Tabulation Area) shown instead of ZCTA, whereby unusually small ZCTAs are consolidated into MODZCTAs for better regional comparions. ZCTA-to-MODZCTA coversion table available in the NYC Health Coronavirus Data Repository. All data is coursed from the NYC Department of Health.

#
#### Special Thanks to
Caitlin Gilbert, a Rockefeller Graduate Fellow and PhD candidate at the Rockefeller Univerity (New York, NY), for her work, contributions, and tutorials related to the creation of this R code and R Shiny Application.

#
#### I. Data Prepping
#
#### Data Pre-Processing
Data was directly downloaded from the GitHUB NYC Health Coronovirus repository, including geographical data, percent positive rates, case rates, and test rates. These datasets were all cleaned and reshaped, in order to create one massive dataframe to be utilized. Additionally, my personal dataset of MODZCTA (ZIP codes), neighborhoods, and boroughs was also loaded, in order to better identify affected areas within NYC for further analysis.

#
#### Data Merging & Date Conversions
Using MODZCTA as the shared item among all datasets, case rates, percent positives, test rates, neighborhoods and boroughs were left joined via MODZCTA (ZIP codes), and geo joined by the shapefile. Afterwards, dates were reformated as the goal would be for users to search by a week-ending date, as new data is available from the repository on a weekly basis.

#
#### Data Inspection
<img src="https://user-images.githubusercontent.com/83367900/117878955-58c22100-b274-11eb-838d-5b889e49ac90.png" width="45%" height="45%">

A quick examination of the case rate data reveals it is severely right-skewed, as the first datasets recorderd were nearly at the height of the COVID-19 pandemic in the summer of 2020, with cases decreasing as more people practiced social distancing and vaccines became more widespread throughout 2021.

#
#### II. Creating Shiny App
#
#### Defining UI & Server Logic
After preparing .RDS and .HTML files, a user-friendly interface (UI) was created with information and user input oriented to the left, and the City's geographical map on the right, with three easily-navigable tabs: Case Rate, Test Rate, and Percent Positives.
Server logic was defined to be reactive function and dependent on user input, isolatied per week instead of the entire dataframe. Therefore, rendered leaflet outputs were created for cases, tests, and percent positives, respectively before publishing.

#
####  Results & Observations
#
#### Week ending 01-09-2021
* For the week ending 01-09-2021, at the height of the second COVID-19 wave in NYC following the 2020 holiday season, the following three snapshots were taken of percent positives, test rates, and case rates respectively:

<img src="https://user-images.githubusercontent.com/83367900/117882411-519d1200-b278-11eb-83ec-92038d6501c3.png" width="29.75%" height="29.75%"> <img src="https://user-images.githubusercontent.com/83367900/117883443-6b8b2480-b279-11eb-989d-75334819dbf9.png" width="30%" height="30%"> <img src="https://user-images.githubusercontent.com/83367900/117883605-9a08ff80-b279-11eb-9f73-f2954c6fbe9c.png" width="30%" height="30%">

* Noticeable hotspots were in the Bronx, Southwestern Queens, Southwestern Brooklyn, and Staten Island.
* Cases increased predominantly in the outer boroughs, faster than Manhattan.
* Yet, testing substantially increased in more affluent areas of NYC, most noticeably in Manhattan below 135th St, Staten Island, and the Riverdale section of the Bronx.

#
#### Closing Thoughts
Text
