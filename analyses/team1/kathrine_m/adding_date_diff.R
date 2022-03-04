library(tidyverse)
library(readxl)

care_management_clean_merge <- read_csv("analyses/team1/kathrine_m/care_management_clean_merge.csv") %>% 
        # just so I don't have to remember case:
        rename_all(tolower) %>%
        arrange(anon_id, assistance_date) %>% 
        group_by(anon_id) %>% 
        # how many days since the last assistance for this client?
        # output is "## days" and don't know how to drop "days" in same call
        # so need to steps for this to convert to numeric
        mutate(days_since_last = ceiling(difftime(assistance_date,
                                               lag(assistance_date),
                                               units = "days")),
               days_since_last = case_when(is.na(days_since_last) ~ 0,
                                    TRUE ~ as.numeric(days_since_last)),
               # Now count cumulative days since first assistance
               days_since_start = cumsum(days_since_last))

# Take a quick look to see if this generated the desired output        
care_management_clean_merge %>%         
        select(anon_id, assistance_date, days_since_last, days_since_start) %>% 
        head(n = 20L) # looks like it
