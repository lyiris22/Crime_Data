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
  
  #write_csv('../data/clean_data.csv')

crime_cleaned


# dont read it out to csv here, read out after

# ayla's work
#google will only let use do 2500 entries a day and our data is 2829 values
top_half_crime <- crime_cleaned[1:1500, ]
top_half_crime

top_half_crime <- top_half_crime %>% 
  mutate_geocode(city, output = c("latlon"), source = "dsk")    # didn't see the cleaned city name used department... will use tomorrow but maxed out values

top_half_crime

write_csv(top_half_crime, 'data/top_half_lat_long.csv' )


# there are over 50 warnings that need to be clean up manually or investigate why those are working specifically 
# they place NA where it gives a warning, there are only about 13 cities 

bottom_half_crime <- crime_cleaned[1501:2829,]
bottom_half_crime

bottom_half_crime<- bottom_half_crime %>% 
  mutate_geocode(city, output = c("latlon"), source = "dsk")

write_csv(bottom_half_crime, 'data/bottom_half_lat_long.csv' )

#crime <- inner_join(top_half_crime, bottom_half_crime)   #not sure if this is the right join try once data written

###
