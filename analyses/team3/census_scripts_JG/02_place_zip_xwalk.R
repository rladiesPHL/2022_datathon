library(tidyverse)
library(tigris)
library(sf)
library(lwgeom)

cty_shp <- counties(state = "PA")

cty_shp <- cty_shp %>% 
  filter(NAME == "Montgomery") %>% 
  select(GEOID, county_name = NAMELSAD)

pa_places <- places(state = "PA")
pa_places <- pa_places %>% 
  select(city_geoid = GEOID, city_name = NAME)

mont_places <- st_intersection(pa_places, cty_shp)


xwalk <- read_csv("https://www2.census.gov/geo/docs/maps-data/data/rel/zcta_place_rel_10.txt", 
                  col_types = cols(.default = "character", ZPOPPCT = "numeric",
                                   ZHUPCT = "numeric", ZAREAPCT = "numeric",
                                   ZAREALANDPCT = "numeric"))
pa_xwalk <- xwalk %>% 
  filter(GEOID %in% mont_places$city_geoid)

pa_xwalk <- pa_xwalk %>% 
  select(ZCTA5, GEOID)

mont_places <- mont_places %>% 
  left_join(pa_xwalk, by = c("city_geoid" = "GEOID"))

write_csv(mont_places %>% 
            as_tibble() %>% 
            select(-geometry), "data/csvs/zip_city_xwalk_montgomery_county.csv")
