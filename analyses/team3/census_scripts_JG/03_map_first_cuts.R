library(tidyverse)
library(tmap)
library(sf)

tmap_options(check.and.fix = TRUE)

donations <- donations_anonymized %>% 
        filter(organisation == "N")

donations$date2 <- lubridate::mdy(donations$date)
donations$date2 <- lubridate::year(donations$date2)

don_zip <- donations %>% 
        group_by(zip, date2) %>% 
        summarise(total_amount = sum(amount, na.rm = TRUE))

zip_vars <- zip_vars %>% 
        mutate(over55_share = over55/tot_popE)

zip2 <- zip_vars %>% 
        left_join(don_zip, by = c("GEOID" = "zip"))

zip2 <- zip2 %>% 
        st_make_valid()

zip2 <- zip2 %>% 
        mutate(total_amount = if_else(is.na(total_amount), 0, total_amount))


tm_shape(zip2) +
        tm_borders(col = "black") +
tm_shape(zip2 %>% 
                 filter(date2 == 2019)) +
        tm_polygons(col = "total_amount", colorNA = "gray") +
        tm_layout(frame = FALSE, legend.position = c("left", "bottom"), 
                  main.title = "Total Donations Amount 2019") 

m1 <- tm_shape(zip2) +
        tm_borders(col = "black") +
        tm_shape(zip2) +
        tm_polygons(col = "total_amount", colorNA = "gray") +
        tm_layout(frame = FALSE, legend.position = c("left", "bottom"), 
                  main.title = "Total Donations Amount") +
        tm_facets(along = "date2")


tm_shape(zip2) +
        tm_borders(col = "black") +
        tm_shape(zip2 %>% 
                         filter(date2 == 2020)) +
        tm_polygons(col = "total_amount", colorNA = "gray") +
        tm_layout(frame = FALSE, legend.position = c("left", "bottom"), 
                  main.title = "Total Donations Amount 2020")
