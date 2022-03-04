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
               days_since_start = cumsum(days_since_last)) %>% 
        ungroup()

# Take a quick look to see if this generated the desired output        
care_management_clean_merge %>%         
        select(anon_id, assistance_date, days_since_last, days_since_start) %>% 
        head(n = 20L) # looks like it

summary(care_management_clean_merge$days_since_last)

##### Everything beyond here is untested #####
# I don't think this code is doing what I want it to do
# but don't have time to fix it this morning

freq_up_to_monthly <- care_management_clean_merge %>% 
        group_by(anon_id) %>% 
        filter(days_since_last >0 & days_since_last <30)

care_management_clean_merge %>% 
        select(anon_id) %>% 
        unique() %>% 
        nrow() # just a reminder that there are 490 clients

care_management_clean_merge %>% 
        group_by(anon_id) %>% 
        filter(days_since_last >0) %>% 
        pull(anon_id) %>% 
        unique()
# 376 of the 490 clients used the services on more than one day
# let's quickly look at those that did not
# Which services were used?

one_day_only <- care_management_clean_merge %>% 
        group_by(anon_id) %>% 
        filter(days_since_last )
