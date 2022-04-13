##### Libraries & Setup #####
library(tidycensus)
library(tidyverse)
library(viridis)
# census_api_key("YOUR KEY GOES HERE", install = TRUE)

##### Median Income #####
montgomery_acs_2020 <- get_acs(
  geography = "county subdivision",
  state = "PA",
  county = "Montgomery",
  variables = "B19013_001",
  geometry = TRUE,
  year = 2020
)

montgomery_income_map <- ggplot(montgomery_acs_2020,
       aes(fill = estimate, color = estimate)) +
  geom_sf() +
  scale_fill_viridis(direction = -1, option = "I") + 
  scale_color_viridis(direction = -1, option = "I") +
  labs(title = "Median Income Across Montgomery County, PA",
       subtitle = "Data source: US Census Bureau, 2016-2020 ACS",
       fill = "Estimated Median\nIncome (USD)") +
  guides(color = "none") +
  theme_void() +
  theme(plot.title = element_text(size = 17),
        plot.subtitle = element_text(size = 13))

# ggsave("analyses/team1/kathrine_m/images/montgomery_income_map.png",
#        montgomery_income_map,
#        device = "png", height = 4, width = 6, units = "in")

ggsave("analyses/team1/kathrine_m/images/montgomery_income_map2.png",
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

# Using "county subdivision" lets us filter to 
# specific townships afterwards
mont_pov <- get_acs(
  geography = "county",
  state = "PA",
  county = "Montgomery",
  variables = c("below" = "B17020_002",
                "at_above" = "B17020_010"),
  summary_var = "B17020_001",
  geometry = TRUE,
  year = 2020
)

mont_pov %>% 
  filter(str_detect(NAME, "Lower Merion|Narberth")) %>% 
  group_by(variable) %>% 
  summarise(sum(estimate))
# 1 at_above           58198 
# 2 below               2558 

montgomery_poverty_pie <- mont_pov %>% 
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
       fill = NULL) +
  coord_polar(theta = "y") +
  guides(color = "none") +
  theme_void() +
  theme(legend.text = element_text(size = 10),
        plot.title = element_text(size = 14),
        plot.subtitle = element_text(size = 10),
        plot.background = element_rect(colour = ""))

# ggsave("analyses/team1/kathrine_m/images/montgomery_poverty_status.png",
#        montgomery_poverty_pie,
#        device = "png", width = 7, height = 4,
#        units = "in")

# So what about over 65s
# It looks like the poverty by age data is split 
# such that we will need rto look at 60 and above
# Unless we try get_estimates again, but that doesn't allow for 
# county_subdivision

mont_age <- get_estimates(
  geography = "county",
  product = "characteristics",
  breakdown = "AGEGROUP",
  breakdown_labels = TRUE,
  state = "PA",
  county = "Montgomery",
  year = 2019
)

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


# carl_poverty <- data.frame(c("Poverty", "No Poverty"), c(36,64)) %>% 
#   rename(variable = 1, pct = 2)
# 
# 
# eldernet_poverty_pie <- carl_poverty %>%  
#   ggplot(aes(x = "", y = pct, fill = variable)) +
#   geom_bar(color = "black", stat = "identity") +
#   geom_text(aes(x = 1.3, label = paste(pct,"%", sep = ""),
#                 color = variable),
#             position = position_stack(vjust = 0.5),
#             size = 4) +
#   scale_fill_manual(values = c("#c6b5c7", "#410A45")) +
#   scale_color_manual(values = c("#410A45", "#c6b5c7")) +
#   labs(title = "Poverty Status of ElderNet Clients",
#        subtitle = "Data source: Datathon 2022",
#        fill = NULL) +
#   coord_polar(theta = "y") +
#   guides(color = "none") +
#   theme_void() +
#   theme(plot.title = element_text(size = 14),
#         plot.subtitle = element_text(size = 10),
#         legend.position = "none")

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
  scale_fill_manual(values = c("#c6b5c7", "#410A45"),
                    labels = c("Minority",
                               "Non-minority")) +
  scale_color_manual(values = c("#410A45", "#c6b5c7")) +
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

# Can I align all charts for one page in patchwork
# To keep the chart sizes and font size consistent?

library(patchwork)

poverty_charts <- montgomery_poverty_pie + plot_spacer() +
  eldernet_poverty_pie + plot_layout(widths = c(4,0.1,4))

poverty_charts2 <- montgomery_poverty_pie /eldernet_poverty_pie

montgomery_income_map + poverty_charts

ggsave("analyses/team1/kathrine_m/images/poverty_charts.png",
       poverty_charts, device = "png", width = 6.5, height = 3, units = "in")

ggsave("analyses/team1/kathrine_m/images/poverty_charts2.png",
       poverty_charts2, device = "png", height = 6, width = 5, units = "in")



# ggsave("analyses/team1/kathrine_m/images/poverty.png", poverty, device = "png",
#        height = 4, width = 20, units = "in")


mont_race <- get_estimates(
  geography = "county",
  product = "characteristics",
  breakdown = "RACE",
  breakdown_labels = TRUE,
  state = "PA",
  county = "Montgomery",
  year = 2019
)

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
  labs(title = "Montgomery County Residents",
       subtitle = "Data source: US Census Bureau population estimates, 2019",
       fill = NULL) +
  coord_polar(theta = "y") +
  guides(color = "none") +
  theme_void() +
  theme(plot.title = element_text(size = 16),
        plot.subtitle = element_text(size = 12))

minority_charts <- minority_pie_stylized + plot_spacer() +
  eldernet_minority_pie + plot_layout(widths = c(4,0.3,4))

ggsave("analyses/team1/kathrine_m/images/minority_charts.png",
       minority_charts, device = "png", width = 8, height = 3, units = "in")
