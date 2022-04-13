if(!require(pacman)){install.packages("pacman"); library(pacman)}
p_load(sf, tidyverse)

elder <- read_csv("data/donations_anonymized.csv")
zips <- st_read("analyses/team3/team3_data/census_model_data/eldernet_big_combined.gpkg") %>% 
        distinct()

elder <- elder %>% 
        mutate(date = lubridate::mdy(date))

donation_year <- elder %>% 
        filter(organisation == "N") %>% 
        group_by(zip, date2 = lubridate::year(date)) %>% 
        summarise(donation_amount = sum(amount, na.rm = TRUE))

donation_year <- donation_year %>% 
        mutate(date2 = paste0(date2,"-01-01"))

donation_year <- donation_year %>% 
        mutate(date2 = lubridate::as_date(date2))

region_zips <- zips %>% 
        select(ZCTA5CE20) %>% 
        distinct()

region_zips <- region_zips %>% 
        left_join(donation_year, by = c("ZCTA5CE20" = "zip"))

st_write(region_zips, "analyses/team3/team3_data/thematic_mapping/donations_by_zip_by_year.gpkg", 
         delete_dsn = TRUE)
