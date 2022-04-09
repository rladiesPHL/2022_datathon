# Just trying to generate some of Carl T's charts using R

library(tidyverse)
library(viridis)

volsvc <- read_csv("data/volunteer_services_anonymized.csv") 

unique(volsvc$category2)

summary(volsvc$rider_first_ride_date)

volsvc_plot <- volsvc %>%
  # maybe consolidate the categories a little
  mutate(category2 = case_when(
    category == "Pantry Delivery" ~ "Pantry",
    category == "Skilled Work" | category == "Yard Work" ~ "Skilled &\nYard Work",
    category == "Errands" | category == "Odd Jobs" ~ "Errands &\nOdd Jobs",
    category == "Telephone Reassurance" |
      category == "Friendly Visit" ~ "Friendly Visits\n& Reassurance",
    TRUE ~ category
  )) %>% 
  # drop board/committee meetings as this is not a client interaction/service
  filter(category2 != "Board or Committee Mtg") %>% 
  ggplot(aes(x = fct_infreq(category2), fill = category2)) +
  geom_bar() +
  labs(title = "Total ElderNet Volunteer Services 2015-2021",
       x = "Volunteer Service",
       y = "Count") +
  scale_fill_viridis_d(option = "D") +
  theme_bw() +
  theme(legend.position = "none",
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 8),
        axis.title = element_text(size = 12),
        axis.text = element_text(size = 8),
        plot.title = element_text(size = 14))

ggsave("analyses/team1/kathrine_m/images/volunteer_services_plot.png", volsvc_plot,
       device = "png", height = 5, width = 6, units = "in")
  