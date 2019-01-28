library(tidyverse)
library(ggmap)



crime = read_csv('data/ucr_crime_1975_2015.csv')
crime$clean_city_name <- str_replace(crime$department_name,pattern=',.*$',replacement='')

# cleaning county names
clean_city_lookup <- tribble(
  ~ clean_city_name,    ~ clean_city_name_fixed,
  "Fairfax County", "Fairfax",
  "Prince George's County" , "Upper Marlboro",
  "Suffolk County", "Hauppauge",
  "Charlotte-Mecklenburg", "Charlotte",
  "Montgomery County", "Rockville",
  "Nassau County", "Mineola"
)

crime <- crime %>% 
  left_join(clean_city_lookup)

crime <- crime %>% 
  mutate(city = coalesce(clean_city_name_fixed, clean_city_name))



# only selecting columns we are using for the app
crime_cleaned <- crime %>% 
  select('city','year','violent_per_100k','homs_per_100k','rape_per_100k','rob_per_100k','agg_ass_per_100k','total_pop') 


# remove National rows from data set
crime_cleaned<- crime_cleaned %>% 
  filter(city != "National")


# ayla's work
#google will only let use do 2500 entries a day and our data is 2829 values
#top_half_crime <- crime_cleaned[1:1500, ]

#top_half_crime <- top_half_crime %>% 
#  mutate_geocode(city, output = c("latlon"), source = "dsk")   #commented out because you can only do 2500 per day so only run when required 

# writes top half of converted lat/longs
#write_csv(top_half_crime, 'data/top_half_lat_long.csv' )  


# splits data into chunks for lat/long from google maps
#bottom_half_crime <- crime_cleaned[1501:2778,]
#bottom_half_crime

#bottom_half_crime<- bottom_half_crime %>% 
#    mutate_geocode(city, output = c("latlon"), source = "dsk")   #commented out because you can only do 2500 per day so only run when required

# writes bottom half of converted lat/longs
#write_csv(bottom_half_crime, 'data/bottom_half_lat_long.csv' )


# when doing over multiple days you need to read in the geocoded csv files
crime_bottom = read_csv('data/bottom_half_lat_long.csv')
crime_top = read.csv('data/top_half_lat_long.csv')

# bind top and bottom to create final cleaned data
crime_latlong <- bind_rows(crime_top, crime_bottom)  


# these ones was wrongly geocoded had to manually enter for Cleveland lat = 41.489644, long = -81.703132
crime_latlong <- crime_latlong %>% 
  mutate(lon = if_else(city == "Cleveland",  -81.703132, lon)) %>% 
  mutate(lat = if_else(city == "Cleveland",  41.489644, lat))

# Washington, DC lat = 38.889187, long = -77.046176
crime_latlong <- crime_latlong %>% 
  mutate(lon = if_else(city == "Washington",  -77.046176, lon)) %>% 
  mutate(lat = if_else(city == "Washington",  38.889187, lat))

# oakland,  lat = 37.816516, long -122.282147
crime_latlong <- crime_latlong %>% 
  mutate(lon = if_else(city == "Oakland",  -122.282147, lon)) %>% 
  mutate(lat = if_else(city == "Oakland",  37.816516, lat))


# removed Honolulu so the map was centered on the contiental US
crime_latlong<- crime_latlong %>% 
  filter(city != "Honolulu")


# some of the cities are missing 2015 data, which caused rendering issues
# filter out 2015 data out because it is not used 
crime_latlong<- crime_latlong %>% 
  filter(year != "2015")


# arrange the data by year and city to ensure alphabetically city names
crime_latlong <- crime_latlong %>% 
  arrange(year, city)


# writing out final file
write_csv(crime_latlong, 'crime-data-app/crime_lat_long.csv' )


