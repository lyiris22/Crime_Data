library(tidyverse)
library(ggmap)



crime = read_csv('data/ucr_crime_1975_2015.csv')
crime$clean_city_name <- str_replace(crime$department_name,pattern=',.*$',replacement='')

clean_city_lookup <- tribble(
  ~ clean_city_name,    ~ clean_city_name_fixed,
  "Baltimore County",  "Baltimore",
  "Fairfax County", "Fairfax",
  "Miami-Dade County", "Miami",
  "Prince George's County" , "Upper Marlboro",
  "Suffolk County", "Hauppauge",
  "Charlotte-Mecklenburg", "Charlotte",
  "Los Angeles County", "Los Angeles",
  "Montgomery County", "Rockville",
  "Nassau County", "Mineola"
)

crime <- crime %>% 
  left_join(clean_city_lookup)

crime <- crime %>% 
  mutate(city = coalesce(clean_city_name_fixed, clean_city_name))




crime_cleaned <- crime %>% 
  select('city','year','violent_per_100k','homs_per_100k','rape_per_100k','rob_per_100k','agg_ass_per_100k','total_pop') 


# ayla's work
#google will only let use do 2500 entries a day and our data is 2829 values
top_half_crime <- crime_cleaned[1:1500, ]

#top_half_crime <- top_half_crime %>% 
#  mutate_geocode(city, output = c("latlon"), source = "dsk")   #commented out because you can only do 2500 per day so only run when required 

# writes top half of converted lat/longs
write_csv(top_half_crime, 'data/top_half_lat_long.csv' )  


# splits data into chunks for lat/long from google maps
bottom_half_crime <- crime_cleaned[1501:2829,]
bottom_half_crime

#bottom_half_crime<- bottom_half_crime %>% 
#  mutate_geocode(city, output = c("latlon"), source = "dsk")   #commented out because you can only do 2500 per day so only run when required

# writes bottom half of converted lat/longs
write_csv(bottom_half_crime, 'data/bottom_half_lat_long.csv' )



crime_bottom = read_csv('data/bottom_half_lat_long.csv')
crime_top = read.csv('data/top_half_lat_long.csv')


# bind top and bottom to create final cleaned data
crime_latlong <- bind_rows(crime_top, crime_bottom)  

write_csv(crime_latlong, 'data/crime_lat_long.csv' )

###
