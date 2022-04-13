library(tidyverse)
library(viridis)

vol <- read_csv("data/volunteer_services_anonymized.csv") 

vol_plot <- vol %>% 
  mutate(category2 = case_when(
    category == "Skilled Work" | category == "Yard Work" ~ "Skilled &\n Yard work",
    category == "Pantry Delivery" ~ "Pantry",
    category == "Telephone Reassurance" | category == "Friendly Visit" ~ "Friendly Visits\n& Reassurance",
    category == "Errands" | category == "Odd Jobs" ~ "Errands &\nOdd Jobs",
    TRUE ~ category)) %>% 
  filter(category2 != "Board or Committee Mtg") %>% 
  ggplot(aes(x = fct_infreq(category2), fill = category2)) +
  geom_bar() +
  scale_fill_viridis_d(option = "D") +
  labs(title = "Total ElderNet Volunteer Services, Feb 2019 to Aug 2021",
       x = "Service Category",
       y = "Count") +
  theme_bw() +
  theme(legend.position = "none",
        plot.title = element_text(size = 10),
        axis.title = element_text(size = 10),
        axis.text = element_text(size = 8))

ggsave("analyses/team1/kathrine_m/images/volunteer_services_plot2.png", vol_plot,
       device = "png", height = 4, width = 6)

  

