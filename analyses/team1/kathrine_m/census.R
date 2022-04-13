library(tidycensus)
library(tidyverse)
library(forcats)
library(viridis)
library(scales)

# Resources for`tidycensus`:
## Documentation: https://walker-data.com/tidycensus/
## Book: https://walker-data.com/census-r/index.html

# To use `tidycensus` package, first acquire an API key here:
# https://api.census.gov/data/key_signup.html

# Then install it using this code:
# census_api_key("your key goes here", install = TRUE)

# There are a lot of variables in the census datasets
# So it is helpful to create a list of them to search:

# from most recent ACS
v20acs <- load_variables(2020, "acs5")

# from most recent census
v20census <- load_variables(2020, "pl")
# limited data for now
# stick with 5 year ACS for now

# filter to a specific concept
# everything that contains the word age
v20acs_age <- v20acs %>% 
  filter(str_detect(concept, " AGE"))
# then use this to print the concepts containing age
unique(v20acs_age$concept)
# from here can use the concepts to search/browse v20
view(v20acs_age)

# everything that contains the word poverty
v20acs_pov <- v20acs %>% 
  filter(str_detect(concept, "POVERTY"))
unique(v20_pov$concept)
view(v20acs_pov)

##### Median Income #####

v20acs %>% filter(name == "B19013_001") %>% 
  pull(label)
# "Estimate!!Median household income in the past 12 months 
# (in 2020 inflation-adjusted dollars)"

# Pull the 5 year ACS data
# Filtering to just Montgomery County, PA
# By setting geography to "county subdivision"
# we get the numbers by township
# B17020_001 as a summary variable
montgomery_acs_2020 <- get_acs(
  geography = "county subdivision",
  state = "PA",
  county = "Montgomery",
  variables = "B19013_001",
  geometry = TRUE,
  year = 2020
)

# Getting data from the 2016-2020 5-year ACS
# Downloading feature geometry from the Census website.  To cache shapefiles for use in future sessions, set `options(tigris_use_cache = TRUE)`.
# Using FIPS code '42' for state 'PA'
# Using FIPS code '091' for 'Montgomery County'

# Now plot this
montgomery_income_map <- ggplot(montgomery_acs_2020,
                                aes(fill = estimate, color = estimate)) +
  geom_sf() +
  scale_fill_viridis(direction = -1, option = "I",
                     labels = dollar_format()) + 
  scale_color_viridis(direction = -1, option = "I") +
  labs(title = "Median Income Across Montgomery County, PA",
       subtitle = "Data source: US Census Bureau, 2016-2020 ACS",
       fill = "Estimated Median\nIncome (USD)") +
  guides(color = "none") +
  theme_classic() +
  theme(plot.title = element_text(size = 17),
        plot.subtitle = element_text(size = 13),
        axis.line = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank())

ggsave("analyses/team1/kathrine_m/images/montgomery_income_map.png",
       montgomery_income_map,
       device = "png", height = 4, width = 6, units = "in")

montgomery_acs_2020 %>% 
  filter(str_detect(NAME, "Lower Merion|Narberth")) %>% 
  select(NAME, estimate)
# Lower Merion = 140,499
# Narberth = 107,266

#The median income is high here
# In fact LM is the highest in the county
# So who falls below the poverty line?

##### Poverty Status #####

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

mont_pov %>% 
  filter(str_detect(NAME, "Lower Merion|Narberth")) %>% 
  group_by(variable) %>% 
  summarise(sum(estimate))
# 1 at_above           58198 
# 2 below               2558 


summary_pov <- mont_pov %>% 
  group_by(variable) %>% 
  summarise(total = sum(estimate),
            variable = variable)

montgomery_poverty_pie <- mont_pov %>% 
  # group_by(variable) %>% 
  summarise(pct = round(estimate/sum(estimate)*100,0),
            variable = variable) %>%  
  ggplot(aes(x = "", y = pct, fill = fct_relevel(variable, "below", "at_above"))) +
  geom_bar(color = "black", stat = "identity") +
  geom_text(aes(x = 1.3, label = paste(pct,"%", sep = ""),
                color = fct_relevel(variable, "below", "at_above")),
            position = position_stack(vjust = 0.5),
            size = 4) +
  scale_fill_manual(values = c("#c6b5c7", "#410A45"),
                    labels = c("Poverty",
                               "No poverty")) +
  scale_color_manual(values = c("#410A45", "#c6b5c7")) +
  labs(title = "Montgomery County Residents",
       subtitle = "Data source: US Census Bureau, 2016-2020 5-year ACS",
       fill = NULL,
       x = NULL,
       y = NULL) +
  coord_polar(theta = "y") +
  guides(color = "none") +
  theme_classic() +
  theme(legend.text = element_text(size = 10),
        plot.title = element_text(size = 14),
        plot.subtitle = element_text(size = 10),
        axis.line = element_blank(),
        axis.text = element_blank())

ggsave("analyses/team1/kathrine_m/images/montgomery_poverty_status.png",
       montgomery_poverty_pie,
       device = "png", width = 5, height = 4,
       units = "in")


##### Minority Status #####

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
# Filter this to single race categories with all
# "two or more races" collected together (rows 2-7)
# Then recode all non-white races to "minority"
# This was done because the eldernet dataset had only
# minority/non-minority flags
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

# Adding age into the mix
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


##### PLOTS FOR DECK #####

# let's try just minority / non-minority

minority_pie_stylized <- mont_race[2:7,] %>% 
  mutate(race2 = case_when(RACE != "White alone" ~ "Minority",
                           TRUE ~ "Non-minority"),
         pct = round(value/sum(value)*100,0)) %>% 
  group_by(race2) %>% 
  summarise(pct = sum(pct)) %>% 
  ggplot(aes(x = "", y = pct, fill = race2)) +
  geom_bar(color = "black", stat = "identity") +
  geom_text(aes(x = 1.1, label = paste(pct,"%", sep = ""), color = race2),
            position = position_stack(vjust = 0.5),
            size = 4) +
  scale_fill_manual(values = c("#c6b5c7", "#410A45")) +
  scale_color_manual(values = c("#410A45", "#c6b5c7")) +
  labs(title = "Montgomery County Residents",
       subtitle = "Data source: US Census Bureau population estimates, 2019",
       fill = NULL) +
  coord_polar(theta = "y") +
  guides(color = "none") +
  theme_void() +
  theme(plot.title = element_text(size = 16),
        plot.subtitle = element_text(size = 12))

# ggsave("analyses/team1/kathrine_m/images/montgomery_minority_status.png",
#        minority_pie_stylized, device = "png",
#        width = 7, height = 4, units = "in")


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
  theme_bw() +
  theme(legend.text = element_text(size = 16),
        legend.position = c(1.2, 0.2),
        plot.title = element_text(size = 16),
        plot.subtitle = element_text(size = 12))

# ggsave("analyses/team1/kathrine_m/images/montgomery_poverty_status.png",
#        poverty_pie_stylized, device = "png",
#        width = 7, height = 4, units = "in")


##### Carl's data #####

# Recreate Car's data with just the percentages
# This let's us harmonize the formatting but is not ideal

carl_poverty <- data.frame(c("Poverty", "No Poverty"), c(64,36)) %>% 
  rename(variable = 1, pct = 2)


eldernet_poverty_pie <- carl_poverty %>%  
  ggplot(aes(x = "", y = pct,
             fill = fct_relevel(variable, "Poverty",
                                "No poverty"))) +
  geom_bar(color = "black", stat = "identity") +
  geom_text(aes(x = 1.2, label = paste(pct,"%", sep = ""),
                color = fct_relevel(variable, "Poverty",
                                    "No poverty")),
            position = position_stack(vjust = 0.5),
            size = 4) +
  scale_fill_manual(values = c("#c6b5c7", "#410A45"),
                    labels = c("Poverty",
                               "No poverty")) +
  scale_color_manual(values = c("#410A45", "#c6b5c7")) +
  labs(title = "ElderNet Clients",
       subtitle = "Data source: Datathon 2022",
       fill = NULL) +
  coord_polar(theta = "y") +
  guides(color = "none") +
  theme_void() +
  theme(plot.title = element_text(size = 14),
        plot.subtitle = element_text(size = 10),
        legend.position = "none")

# ggsave("analyses/team1/kathrine_m/images/eldernet_poverty_pie.png", eldernet_poverty_pie,
#        device = "png", height = 4, width = 6, units = "in")

carl_minority <- data.frame(c("Minority", "Non-minority"), c(69,31)) %>% 
  rename(variable = 1, pct = 2)


eldernet_minority_pie <- carl_minority %>%  
  ggplot(aes(x = "", y = pct, fill = variable)) +
  geom_bar(color = "black", stat = "identity") +
  geom_text(aes(x = 1.1, label = paste(pct,"%", sep = ""),
                color = variable),
            position = position_stack(vjust = 0.5),
            size = 4) +
  scale_fill_manual(values = c("#410A45", "#c6b5c7"),
                    labels = c("Minority",
                               "Non-minority")) +
  scale_color_manual(values = c("#c6b5c7", "#410A45")) +
  labs(title = "ElderNet Clients",
       subtitle = "Data source: Datathon 2022",
       fill = NULL) +
  coord_polar(theta = "y") +
  guides(color = "none") +
  theme_void() +
  theme(legend.position = "none",
        plot.title = element_text(size = 14),
        plot.subtitle = element_text(size = 10))

# ggsave("analyses/team1/kathrine_m/images/eldernet_minority_pie.png", eldernet_minority_pie,
#        device = "png", height = 4, width = 6, units = "in")

