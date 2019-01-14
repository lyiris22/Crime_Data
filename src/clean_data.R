library(tidyverse)

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

crime %>% 
  select('city','year','violent_per_100k','homs_per_100k','rape_per_100k','rob_per_100k','agg_ass_per_100k','total_pop') %>% 
  write_csv('../data/clean_data.csv')