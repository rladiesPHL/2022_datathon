#initial modeling for eldernet services zips
#running logit model
library(tidyverse)
library(sf)
library(tigris)
library(mapsf)
library(tmap)
options(tigris_use_cache = TRUE)
#get fixed zips------------

zctas <- tigris::zctas()

pa_counties <- counties(state = "PA")
pa_counties <- pa_counties %>% 
        filter(NAME %in% c("Philadelphia", "Delaware", "Montgomery", "Chester"))


zctas <- zctas %>% 
        st_filter(pa_counties)

#grab census files----------

census <- read_csv("analyses/team3/team3_data/census_model_data/philly_del_chester_subset_zip_vars.csv")


census <- census %>% 
        mutate(GEOID = as.character(GEOID)) %>% 
        distinct()

zctas2 <- zctas %>% 
        select(ZCTA5CE20, geometry) %>% 
        left_join(census, by = c("ZCTA5CE20" = "GEOID")) %>% 
        st_as_sf()

zctas2 <- zctas2 %>% 
        select(-ZCTA5CE20.y)


eldernet <- read_csv("analyses/team3/team3_data/census_model_data/EldnerNet_by_ZIP.csv")
eldernet <- eldernet %>% 
        select(1:6)

eldernet$ZIP <- as.character(eldernet$ZIP)

eldernet <- eldernet %>% 
        mutate(service_dummy = if_else(Total > 0, 1, 0))

eldernet2 <- zctas2 %>% 
        left_join(eldernet, by = c("ZCTA5CE20" = "ZIP"))

eldernet2 <- eldernet2 %>% 
        mutate(over55_share = over55/tot_popE, disabled_share = disability_est/tot_popE)

#lets make it spatial----------

eldernet2 <- eldernet2 %>% 
        filter(!is.na(NAME))

st_write(eldernet2, dsn = "analyses/team3/team3_data/census_model_data/eldernet_big_combined.gpkg", delete_dsn = TRUE)
#making initial maps from the census variables------------

# mf_map(x = eldernet2)
# 
# mf_map(x = eldernet2, var = "tot_popE", type = "prop")
# 
# mf_layout(title = "Total Population- ElderNet Area",
#           credits = "Source: American COommunity Survey 2015-2019, ElderNet")

#tmap going-----------

# tm_shape(zctas2) +
#         tm_polygons(col = "gray") +
#         tm_symbols(size = "tot_popE", col = "dodgerblue", shapeNA = NULL)
