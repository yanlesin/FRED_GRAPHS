#Components of GDP: Compare their contributions from 1947 to 2018
library(fredr)
library(tidyverse)
library(dygraphs)
library(xts)
library(rvest)

# FRED Key ----------------------------------------------------------------

# fredr_set_key() sets a key as an environment variable for use with 
# the fredr package in the current session. The key can also be set 
# in the .Renviron file at the user or project level scope. You can 
# edit the file manually by appending the line FRED_API_KEY = my_api_key, 
# where my_api_key is your actual key (remember to not surround the key 
# in quotes). The function usethis::edit_r_environ() does this safely. 
# Run base::readRenviron(".Renviron") to set the key in the current 
# session or restart R for it to take effect. The variable will be set 
# in subsequent sessions in the working directory if you set it with 
# project level scope, or everywhere if you set it with user level scope.

readRenviron("~/.Renviron")
# Series info -------------------------------------------------------------

series_info_1 <- fredr_series_search_id(search_text = "PCECC96",
                       limit = 100) %>% 
  filter(observation_start=='1947-01-01') %>% 
  filter(last_updated>='2018-01-01')

series_info_2 <- fredr_series_search_id(search_text = "GCEC1",
                       limit = 100) %>% 
  filter(observation_start=='1947-01-01') %>% 
  filter(last_updated>='2018-01-01')

series_info_3 <- fredr_series_search_id(search_text = "GPDIC1",
                       limit = 100) %>% 
  filter(observation_start=='1947-01-01') %>% 
  filter(last_updated>='2018-01-01')

series_info_4 <- fredr_series_search_id(search_text = "EXPGSC1",
                       limit = 100) %>% 
  filter(observation_start=='1947-01-01') %>% 
  filter(last_updated>='2018-01-01')

series_info_5 <- fredr_series_search_id(search_text = "IMPGSC1",
                       limit = 100) %>% 
  filter(observation_start=='1947-01-01') %>% 
  filter(last_updated>='2018-01-01')

# Data --------------------------------------------------------------------

PCECC96 <- fredr(series_id = "PCECC96",
               observation_start = as.Date("1947-01-01"))

GCEC1 <- fredr(series_id = "GCEC1",
                 observation_start = as.Date("1947-01-01"))

GPDIC1 <- fredr(series_id = "GPDIC1",
                 observation_start = as.Date("1947-01-01"))

EXPGSC1 <- fredr(series_id = "EXPGSC1",
                 observation_start = as.Date("1947-01-01"))

IMPGSC1 <- fredr(series_id = "IMPGSC1",
                 observation_start = as.Date("1947-01-01"))

# Net export calc ---------------------------------------------------------

NET_EXPORT <- EXPGSC1 %>% 
  left_join(IMPGSC1,by='date') %>% 
  transmute(value=value.x-value.y, Date=date) %>% 
  mutate(series_id="NET_EXPORT") %>% 
  select(Date, series_id, value)

# Combining series --------------------------------------------------------

GDP_COMPONENTS <- bind_rows(PCECC96,GCEC1,GPDIC1) %>% 
  spread(series_id,value) %>% 
  left_join(NET_EXPORT, by=c("date"="Date")) %>% 
  mutate(NET_EXPORT=value) %>% 
  select(-series_id,-value)

# XTS object --------------------------------------------------------------

GDP_COMPONENTS_xts <- xts(GDP_COMPONENTS[,-1], order.by=GDP_COMPONENTS$date)  


# Adding Recession Data ---------------------------------------------------

url_Recession_Data <- "https://fredhelp.stlouisfed.org/fred/data/understanding-the-data/recession-bars/"
webpage <- read_html(url_Recession_Data)
Recession_Data_html <- html_nodes(webpage,'p')
Recession_Data <- html_text(Recession_Data_html[3]) 

Recession_Data_df <- Recession_Data %>% 
  str_split("\n", simplify = FALSE) %>% 
  unlist() %>% 
  as.data.frame() %>% 
  transmute(PEAK=str_sub(`.`,1,10),TROUGH=str_sub(`.`,13,22)) %>% 
  filter(PEAK!='Peak, Trou') %>% 
  mutate(PEAK=as.Date(PEAK), TROUGH=as.Date(TROUGH)) %>% 
  filter(TROUGH>=min(GDP_COMPONENTS$date))
  
# dygraph -----------------------------------------------------------------

dygraph_GDP <- dygraph(GDP_COMPONENTS_xts, main = "Components of GDP: Compare their contributions from 1947 to 2018") %>% 
  dyRangeSelector() %>% 
  dySeries("PCECC96", label = series_info_1$title) %>%
  dySeries("GCEC1", label = series_info_2$title) %>%
  dySeries("GPDIC1", label = series_info_3$title) %>% 
  dySeries("NET_EXPORT", label = paste0(series_info_4$title," - ", series_info_5$title)) %>%
#  dySeries("NET_EXPORT", label = paste0(series_info_4$title," - ", str_to_title(series_info_5$title, locale = "EN"))) %>%
  dyOptions(fillGraph = TRUE, fillAlpha = 0.4, maxNumberWidth = 8, stackedGraph = TRUE) %>% 
  dyAxis("y", label = "Billions of Chained 2012 Dollars", axisLabelWidth = 70) %>% 
  dyLegend(show = "follow", hideOnMouseOut = TRUE, labelsSeparateLines = TRUE) %>% 
  dyShading(from = Recession_Data_df$PEAK[1], to = Recession_Data_df$TROUGH[1]) %>% 
  dyShading(from = Recession_Data_df$PEAK[2], to = Recession_Data_df$TROUGH[2]) %>% 
  dyShading(from = Recession_Data_df$PEAK[3], to = Recession_Data_df$TROUGH[3]) %>% 
  dyShading(from = Recession_Data_df$PEAK[4], to = Recession_Data_df$TROUGH[4]) %>% 
  dyShading(from = Recession_Data_df$PEAK[5], to = Recession_Data_df$TROUGH[5]) %>% 
  dyShading(from = Recession_Data_df$PEAK[6], to = Recession_Data_df$TROUGH[6]) %>% 
  dyShading(from = Recession_Data_df$PEAK[7], to = Recession_Data_df$TROUGH[7]) %>% 
  dyShading(from = Recession_Data_df$PEAK[8], to = Recession_Data_df$TROUGH[8]) %>% 
  dyShading(from = Recession_Data_df$PEAK[9], to = Recession_Data_df$TROUGH[9]) %>% 
  dyShading(from = Recession_Data_df$PEAK[10], to = Recession_Data_df$TROUGH[10]) %>% 
  dyShading(from = Recession_Data_df$PEAK[11], to = Recession_Data_df$TROUGH[11])

dygraph_GDP
  
  
  
  