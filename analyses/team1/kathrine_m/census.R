library(tidycensus)
library(tidyverse)
library(forcats)

# census_api_key("YOUR KEY GOES HERE", install = TRUE)

test <- get_acs(geography = "county subdivision", variables = "B17020_001",
                state = "PA", county = "Montgomery", geometry = TRUE, year = 2020)

ggplot(test, aes(fill = estimate, color = estimate)) +
  geom_sf()

# list all the variables
# from most recent ACS
v20 <- load_variables(2020, "acs5")
# from most recent census
# limited data for now
v20census <- load_variables(2020, "pl")

# filter to a specific concept
# everything that contains the word age
v20_age <- v20 %>% 
  filter(str_detect(concept, " AGE"))
# then use this to print the concepts containing age
unique(v20_age$concept)
# from here can use the concepts to search/browse v20

# everything that contains the word poverty
v20_pov <- v20 %>% 
  filter(str_detect(concept, "POVERTY"))
unique(v20_pov$concept)

# Let's look at
# POVERTY STATUS IN THE PAST 12 MONTHS BY AGE
# B17020_001
# This is total income below poverty level by age group

v20_pov %>% 
  filter(name == "B17020_001")

age_vars <- c("below_60-74" = "B17020_007",
              "at_above_60-74" = "B17020_015",
              "below_75-84" = "B17020_008",
              "at_above_75-84" = "B17020_016",
              "below_85+" = "B17020_009",
              "at_above_85+" = "B17020_017")

age_pov <- get_acs(geography = "tract", variables = age_vars,
                   state = "PA", county = "Montgomery", geometry = TRUE, year = 2020,
                   summary_var = "B17020_001")
age_pov %>% 
  ggplot(aes(fill = estimate)) +
  geom_sf() + facet_wrap(~variable)



# This is not actually helpful, the counts are too low

##### POVERTY LEVEL"#####

# Instead can I create a new variable to code above Vs below?


mont_pov <- get_acs(
  geography = "county",
  state = "PA",
  county = "Montgomery",
  variables = c("below" = "B17020_002",
                "at_above" = "B17020_010"),
  summary_var = "B17020_001",
  geometry = TRUE
) %>%
  mutate(percent = 100 * (estimate / summary_est))



mont_TEST <- get_estimates(
  geography = "county",
  product = "population",
  breakdown_labels = TRUE,
  state = "PA",
  county = "Montgomery",
  year = 2019
)




# Taking an example from th resources
demvars <- c(White = "P1_003N",
             Black = "P1_004N",
             Asian = "P1_006N",
             Hispanic = "P2_002N")
# Pull The Census Data 
montgomery <- get_decennial(
  geography = "tract",             
  variables = demvars,
  year = 2020,
  state = "PA", 
  county = "Montgomery", 
  geometry = TRUE,
  summary_var = "P1_001N"
) |>
  # Create pct column 
  mutate(pct = 100 * (value / summary_value))

montgomery %>% ggplot(aes(fill = pct)) +
  facet_wrap(~variable) +
  geom_sf(color = NA) +
  coord_sf(crs = 26915, datum=NA) +
  scale_fill_distiller(palette = "Blues", direction = 1) +
  theme_minimal() +
  labs(title="Population Demographics in Montgomery County",
       subtitle="US Census | 2020 Decennial Census")

# Note: 2020 decennial Census data use differential privacy, a technique that
# introduces errors into data to preserve respondent confidentiality.
# i Small counts should be interpreted with caution.
# This looks like a combination of small counts and low diversity
# not sure if much can be done with this


# Now just pulling stats on race
mont_race <- get_estimates(
  geography = "county",
  product = "characteristics",
  breakdown = "RACE",
  breakdown_labels = TRUE,
  state = "PA",
  county = "Montgomery",
  year = 2019
)

#stacked bar
mont_race[2:7,] %>% 
  mutate(race2 = case_when(RACE != "White alone" ~ "Minority",
                           TRUE ~ "Non-minority")) %>% 
  ggplot(aes(x = race2, y = value, fill = RACE)) +
  geom_col()

# pie
race_pie <- mont_race[2:7,] %>% 
  mutate(race2 = case_when(RACE != "White alone" ~ "Minority",
                           TRUE ~ "Non-minority"),
         pct = round(value/sum(value)*100,1)) %>% 
  group_by(race2) %>% 
  ggplot(aes(x = "", y = value, fill = RACE)) +
  geom_col(color = "black") +
  geom_text(aes(x = 1.3, label = pct),
            position = position_stack(vjust = 0.5)) +
  labs(title = "Montgomery County, PA Racial Demographics",
       subtitle = "Data source: US Census Bureau population estimates & tidycensus R package") +
  coord_polar(theta = "y") +
  theme_void()

# ggsave("montgomery_race_demographics.png", race_pie,
#        device = "png", width = 6, height = 4, units = "in")





  
 # donut
hsize <- 3

mont_race[2:7,] %>% 
  mutate(race2 = case_when(RACE != "White alone" ~ "Minority",
                           TRUE ~ "Non-minority"),
         population = round(value/100000,1),
         x = hsize) %>% 
  ggplot(aes(x = hsize, y = value, fill = RACE)) +
  geom_col(color = "black") +
  coord_polar(theta = "y") +
  xlim(c(0.2, hsize + 0.5))

# age and race
mont_race_age <- get_estimates(
  geography = "county",
  product = "characteristics",
  breakdown = c("RACE", "AGEGROUP"),
  breakdown_labels = TRUE,
  state = "PA",
  county = "Montgomery",
  year = 2019
)

# How does the chart look if we filter to just 65+
mont_race_age %>%
  filter(str_detect(AGEGROUP, "65|70|75|80|85"),
         RACE != "All races",
         !str_detect(RACE, "combination")) %>% 
  mutate(race2 = case_when(RACE != "White alone" ~ "Minority",
                           TRUE ~ "Non-minority"),
         population = round(value/1000,1)) %>% 
  group_by(race2) %>% 
  ggplot(aes(x = "", y = value, fill = RACE)) +
  geom_col() +
  coord_polar(theta = "y") +
  theme_void()
# even less diversity apparently


mont_medincome <- get_acs(
  geography = "tract",
  state = "PA",
  county = "Montgomery",
  variables = c(medinc = "B19013_001",
                medage = "B01002_001"),
  output = "wide",
  year = 2019
)

mont_race_income <- get_acs(
  geography = "tract", 
  state = "PA",  
  county = "Montgomery",
  variables = c(White = "B03002_003", 
                Black = "B03002_004", 
                Asian = "B03002_006",
                Hispanic = "B03002_012"), 
  summary_var = "B19013_001"
) %>%
  group_by(GEOID) %>%
  filter(estimate == max(estimate, na.rm = TRUE)) %>%
  ungroup() %>%
  filter(estimate != 0)

library(ggbeeswarm)

ggplot(mont_race_income, aes(x = variable, y = summary_est, color = summary_est)) +
  geom_quasirandom(alpha = 0.5) + 
  coord_flip() + 
  theme_minimal(base_size = 13) + 
  scale_color_viridis_c(guide = FALSE) + 
  scale_y_continuous(labels = scales::dollar) + 
  labs(x = "Largest group in Census tract", 
       y = "Median household income", 
       title = "Household income distribution by largest racial/ethnic group", 
       subtitle = "Census tracts, Montgomery County, PA", 
       caption = "Data source: 2015-2019 ACS")
# Lack of diversity and potentially small counts are also causing issues here

# Let's just look at income across the board
mont_income <- get_acs(
  geography = "tract", 
  variables = "B19013_001",
  state = "PA",
  county = "Montgomery",
  geometry = TRUE
)

# quick check
plot(mont_income["estimate"])
# now use ggplot for better control
montgomery_income_map <- ggplot(data = mont_income, aes(fill = estimate)) +
  geom_sf() + 
  labs(title = "Median Income in Montgomery County, PA",
       subtitle = "Data source: 2015-2019 5-year ACS, US Census Bureau",
       fill = "ACS Estimated\nMedian Income") +
  theme_void()
# So income is high in some parts of Merion township

# ggsave("montgomery_income_map.png", montgomery_income_map,
#        device = "png")

# repeat the above with median age
mont_age <- get_acs(
  geography = "tract", 
  variables = "B01002_001",
  state = "PA",
  county = "Montgomery",
  geometry = TRUE
)

#quick check
plot(mont_age["estimate"])

montgomery_age_map <- ggplot(data = mont_age, aes(fill = estimate)) +
  geom_sf() + 
  labs(title = "Median Age in Montgomery County, PA",
       subtitle = "Data source: 2015-2019 5-year ACS, US Census Bureau",
       fill = "ACS Estimated\nMedian Income") +
  theme_void()
# Not sure what this tells us and maybe nbeed to change the palette

# ggsave("montgomery_age_map.png", montgomery_age_map,
#        device = "png")


##### NEEDS WORK #####
# Try also with tmap package
library(tmap)

# Look at percent minority and non-minority on the map
# possibly missing variables here, needs work
# mont_race <- get_acs(
#   geography = "tract",
#   state = "PA",
#   county = "Montgomery",
#   variables = c(White = "B03002_003",
#                 Black = "B03002_004",
#                 Native = "B03002_005",
#                 Asian = "B03002_006",
#                 Hispanic = "B03002_012"),
#   summary_var = "B03002_001",
#   geometry = TRUE
# ) %>%
#   mutate(percent = 100 * (estimate / summary_est))

mont_race_nonminority <- filter(mont_race, variable == "White")
tm_shape(mont_race_nonminority) +
  tm_polygons(col = "percent")

mont_race_minority <- filter(mont_race, variable != "White")
tm_shape(mont_race_minority, 
         projection = sf::st_crs(26915)) + 
  tm_polygons(col = "percent",
              style = "jenks",
              n = 5,
              palette = "Purples",
              title = "ACS estimate",
              legend.hist = TRUE) + 
  tm_layout(title = "Percent Minority\nby Census tract",
            frame = FALSE,
            legend.outside = TRUE,
            bg.color = "grey70",
            legend.hist.width = 5,
            fontfamily = "Verdana")


#LIVING ARRANGEMENTS OF ADULTS 18 YEARS AND OVER BY AGE

age_living_arrange <- v20 %>% 
  filter(str_detect(concept, "LIVING ARRANGEMENTS OF ADULTS 18 YEARS AND OVER BY AGE"))

mont_over65 <- get_acs(
  geography = "tract",
  state = "PA",
  county = "Montgomery",
  variables = "B09021_022",
  summary_var = "B09021_001",
  geometry = TRUE
) %>%
  mutate(percent = 100 * (estimate / summary_est))

mont_over65_alone <- get_acs(
  geography = "tract",
  state = "PA",
  county = "Montgomery",
  variables = "B09021_023",
  summary_var = "B09021_022",
  geometry = TRUE
) %>%
  mutate(percent = 100 * (estimate / summary_est))


tm_shape(mont_over65) +
  tm_polygons(col = "percent",
              title = "Proportion of householders over 65") +
  tm_layout(frame = FALSE,
            legend.outside = TRUE)

tm_shape(mont_over65_alone) +
  tm_polygons(col = "percent",
              title = "Proportion of over 65s living alone") +
  tm_layout(frame = FALSE,
            legend.outside = TRUE)


##### PLOTS FOR DECK #####

# let's try just minority / non-minority


minority_pie_stylized <- mont_race[2:7,] %>% 
  mutate(race2 = case_when(RACE != "White alone" ~ "Minority",
                           TRUE ~ "Non-minority"),
         pct = round(value/sum(value)*100,1)) %>% 
  group_by(race2) %>% 
  summarise(pct = sum(pct)) %>% 
  ggplot(aes(x = "", y = pct, fill = race2)) +
  geom_bar(color = "black", stat = "identity") +
  geom_text(aes(x = 1.1, label = paste(pct,"%", sep = ""), color = race2),
            position = position_stack(vjust = 0.5),
            size = 4) +
  scale_fill_manual(values = c("#c6b5c7", "#410A45")) +
  scale_color_manual(values = c("#410A45", "#c6b5c7")) +
  labs(title = "Minority Status of Montgomery County Residents",
       subtitle = "Data source: US Census Bureau population estimates, 2019",
       fill = NULL) +
  coord_polar(theta = "y") +
  guides(color = "none") +
  theme_void() +
  theme(legend.text = element_text(size = 16),
        legend.position = c(1.2, 0.20),
        plot.title = element_text(size = 16),
        plot.subtitle = element_text(size = 12))

ggsave("analyses/team1/kathrine_m/images/montgomery_minority_status.png",
       minority_pie_stylized, device = "png",
       width = 7, height = 4, units = "in")


# Looking at income/poverty status

poverty_pie_stylized <- mont_pov %>% 
  mutate(pct = round(sum(estimate)/summary_est*100,1)) %>% 
  ggplot(aes(x = "", y = pct, fill = fct_relevel(variable, "below", "at_above"))) +
  geom_bar(color = "black", stat = "identity") +
  geom_text(aes(x = 1.3, label = paste(pct,"%", sep = ""),
                color = fct_relevel(variable, "below", "at_above")),
            position = position_stack(vjust = 0.5),
            size = 4) +
  scale_fill_manual(values = c("#c6b5c7", "#410A45"),
                    labels = c("Below Poverty Level",
                               "At/Above Poverty Level")) +
  scale_color_manual(values = c("#410A45", "#c6b5c7")) +
  labs(title = "Poverty Status of Montgomery County Residents",
       subtitle = "Data source: US Census Bureau population estimates, 2019",
       fill = NULL) +
  coord_polar(theta = "y") +
  guides(color = "none") +
  theme_void() +
  theme(legend.text = element_text(size = 16),
        legend.position = c(1.2, 0.2),
        plot.title = element_text(size = 16),
        plot.subtitle = element_text(size = 12))

ggsave("analyses/team1/kathrine_m/images/montgomery_poverty_status.png",
       poverty_pie_stylized, device = "png",
       width = 7, height = 4, units = "in")



##### NOT WORKING #####
# # Microdata
# # see the PUMAs for PA
# 
# library(tigris)
# options(tigris_use_cache = TRUE)
# 
# pa_pumas <- pumas(state = "PA", cb = TRUE, year = 2019)
# 
# ggplot(pa_pumas) + 
#   geom_sf() + 
#   theme_void()
# 
# pa_pumas$NAME10
# # Montgomery County (Southwest)--King of Prussia & Ardmore (East) = 03103
# 
# pa_puma_subset <- get_pums(
#   variables = "AGEP",
#   state = "PA",
#   survey = "acs5",
#   puma = "03103",
#   recode = TRUE
# )
# 
# View(pums_variables)
# 
# 
# pa_puma_subset %>%
#   filter(AGEP >= 65) %>%
#   count(wt = PWGTP)
# 
#
