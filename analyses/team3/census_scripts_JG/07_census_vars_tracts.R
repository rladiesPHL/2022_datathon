#grabbinng initial census variables for the proposed eldernet
#zip code level variables...proposed...65+, pop w/disabilities, income

if(!require(pacman)){install.packages("pacman"); library(pacman)}
p_load(mapsf, tidycensus, sf, tigris, tidyverse)

acs_vars <- load_variables(year = 2019, dataset = "acs5", cache = TRUE)

age_vars <- get_acs(geography = "tract", variables = c(males_55_59 = "B01001_017",
                                                      males_60_61 = "B01001_018",
                                                      males_62_64 = "B01001_019",
                                                      males_65_66 = "B01001_020",
                                                      males_67_69 = "B01001_021",
                                                      males_70_74 = "B01001_022",
                                                      males_75_79 = "B01001_023",
                                                      males_80_84 = "B01001_024",
                                                      males_85_plus = "B01001_025",
                                                      females_55_59 = "B01001_041",
                                                      females_60_61 = "B01001_042",
                                                      females_62_64 = "B01001_043",
                                                      females_65_66 = "B01001_044",
                                                      females_67_69 = "B01001_045",
                                                      females_70_74 = "B01001_046",
                                                      females_75_79 = "B01001_047",
                                                      females_80_84 = "B01001_048",
                                                      females_85_plus = "B01001_049"), 
                    year = 2019, state = "PA")

pop_vars <- get_acs(geography = "tract", variables = c(tot_pop = "B01001_001",
                                                      hispanic = "B03003_003",
                                                      nh_white = "B03002_003",
                                                      nh_black = "B03002_004",
                                                      nh_aian = "B03002_005",
                                                      nh_asian = "B03002_006",
                                                      nh_pacislander = "B03002_007",
                                                      non_citizen = "B05001_006"), 
                    state = "PA", year = 2019, output = "wide")

econ_vars <- get_acs(geography = "tract", variables = c(mhi = "B19013_001"), state = "PA",
                     year = 2019, geometry = TRUE)

disability_vars <- get_acs(geography = "tract", table = "B18101", state = "PA", year = 2019)

#starting basic processing...getting 55+

fifty_five_plus <- age_vars %>% 
        group_by(GEOID, NAME) %>% 
        summarise(pop_55_plus = sum(estimate, na.rm = TRUE))

#calculate pop shares
#select the estimates, won't care about MOE's for now
pop2 <- pop_vars %>% 
        select(GEOID, NAME, ends_with("E"))

pop2 <- pop2 %>% 
        mutate(across(.cols = hispanicE:non_citizenE, .fns = ~.x/tot_popE, .names = "{.col}_share"))

#pulling population with disabilities, going to reshape, select columns

disability_wide <- disability_vars %>% 
        pivot_wider(id_cols = GEOID:NAME, names_from = variable, values_from = estimate)

disability_df <- disability_wide %>% 
        select(GEOID, NAME, B18101_004, B18101_007, B18101_010, B18101_013, B18101_016, B18101_019, 
               B18101_023, B18101_026, B18101_029, B18101_032, B18101_035, B18101_038) %>%
        pivot_longer(cols = starts_with("B"), names_to = "variable", values_to = "disability_est") 

disability_df <- disability_df %>% 
        as_tibble() %>% 
        group_by(GEOID, NAME) %>% 
        dplyr::summarise(disability_est = sum(disability_est, na.rm = TRUE))

#fix up econ vars

econ_df <- econ_vars %>% 
        select(GEOID, NAME, mhi = estimate)

#summarize the age vars table

age_df <- age_vars %>% 
        group_by(GEOID, NAME) %>% 
        summarise(over55 = sum(estimate, na.rm = TRUE))

#join into big table

tables_join <- list(pop2, age_df, disability_df, econ_df)

big_table <- reduce(.x = tables_join, .f = left_join, .dir = "forward")
big_table <- big_table %>% 
        st_as_sf()

#bring in counties and prepare to join-------------
pa_counties <- counties(state = "PA")
pa_counties <- pa_counties %>% 
        filter(NAME %in% c("Philadelphia", "Delaware", "Montgomery", "Chester"))

big2 <- big_table %>% 
        st_filter(pa_counties)
st_write(big2, dsn = "analyses/team3/team3_data/thematic_mapping/eldernet_census_tracts_2022_03_28.geojson", 
         delete_dsn = TRUE)
