library(tidyverse)
library(readxl)
library(forcats)
library(viridis)

#####
# Need to figure out to to approach the first assist category
# The following pipe currently contains two different attempts
# at two slightly different metrics:
## did the client get XYZ as their first benefit
## did the client get XYZ in the first 30 days
# neither works as expected, this needs work before sharing

care_management_clean_merge <- read_csv("analyses/team1/kathrine_m/care_management_clean_merge.csv") %>%
        # just so I don't have to remember case:
        rename_all(tolower) %>%
        arrange(anon_id, assistance_date) %>%
        group_by(anon_id) %>%
        # how many days since the last assistance for this client?
        # output is "## days", drop "days"
        mutate(days_since_last = as.numeric(ceiling(difftime(assistance_date,
                                               lag(assistance_date),
                                               units = "days"))),
               # convert NA at each first assistance per client to 0
               days_since_last = case_when(is.na(days_since_last) ~ 0,
                                           TRUE ~ days_since_last),
               # Now add measures like Carl T's first and last assist
               first_assist = min(assistance_date),
               last_assist = max(assistance_date),
               duration = as.numeric(ceiling(difftime(last_assist, first_assist,
                                                      units = "days"))),
               # what about a duration bin?
               duration_bin = case_when(duration == 0 ~ "One time",
                                        duration > 0 & duration <= 30 ~ "< 1 month",
                                        duration > 30 & duration <= 90 ~ "1-3 months",
                                        duration > 90 & duration <= 180 ~ "3-6 months",
                                        duration > 180 & duration <= 360 ~ "6-12 months",
                                        duration > 360 & duration <= 720 ~ "12-24 months",
                                        TRUE ~ "> 24 months")) %>% 
        ungroup()

# Take a quick look to see if this generated the desired output
care_management_clean_merge %>%
        select(anon_id, assistance_date, days_since_last, duration) %>%
        tail(n = 10L) # looks like it

summary(care_management_clean_merge$days_since_last)

# comment this out for now
# don't need to keep re-writing this file unless the code above changes
# write_csv(care_management_clean_merge,
#           "analyses/team1/kathrine_m/care_management_clean_merge_datediff.csv")


# Pull the duration info by client out to a new df
# as was having issues tabulating from the df with multiple observations per client
client_timeline <- care_management_clean_merge %>% 
        select(anon_id, duration, duration_bin) %>% 
        unique()

# create a prop table to eyeball how the clients are distributed in each bin
data.frame(round(100*(prop.table(table(client_timeline$duration_bin))),2)) %>% 
        rename("Duration with ElderNet" = 1,
               "Proportion of Clients (%)" = 2)


# essentially the info from the prop table but in a chart
care_management_clean_merge %>% 
        select(anon_id, duration, duration_bin) %>% 
        unique() %>% 
        ggplot(aes(x = factor(duration_bin,
                              levels = c("One time", "< 1 month",
                                         "1-3 months", "3-6 months",
                                         "6-12 months", "12-24 months",
                                         "> 24 months")))) +
        geom_bar(stat = "count") +
        theme_bw() +
        labs(title = "Client Duration with ElderNet",
             x = "Duration",
             y = "Number of Clients")

# First tried segregating to short term (<=12 months) and long term (>12 months)
# but I didn't like this arbitrary definition
# comment out for now and keep the duration bin option below instead
# short_term_clients <- care_management_clean_merge %>% 
#         filter(duration_bin != "12-24 months" & duration_bin != "> 24 months") %>% 
#         drop_na(benefit)
# 
# short_term_client_benefits <- prop.table(table(short_term_clients$benefit))
# 
# long_term_clients <- care_management_clean_merge %>% 
#         filter(duration_bin == "12-24 months" | duration_bin == "> 24 months") %>% 
#         drop_na(benefit)
# 
# long_term_client_benefits <- prop.table(table(long_term_clients$benefit))
# 
# benefit_by_duration <- Reduce(function(...) merge(..., all = TRUE, by = "Var1"),
#                               list(short_term_client_benefits,
#                                    long_term_client_benefits)) %>% 
#         rename(benefit = 1,
#                short_term = 2,
#                long_term = 3)
# 
# benefit_by_duration %>% 
#         pivot_longer(cols = -benefit,
#                      names_to = "duration",
#                      values_to = "count") %>% 
#         ggplot(aes(x = duration, y = count, fill = benefit)) +
#         geom_col(position = "stack") +
#         scale_fill_viridis(discrete = T, option = "H") +
#         scale_x_discrete(labels = c("Long Term Clients",
#                                     "Short Term Clients")) +
#         labs(title = "Benefits Recieved by Clients Interacting with ElderNet\n
#              Over a Short (< 1 year) or Long (1-2+ years) Term",
#              x = "Duration",
#              y = "Proportion of Clients",
#              fill = "Benefit") +
#         theme_bw()


# So then what if we repeat this for each bin
# i.e. split clients out depending on what bin they fall into
# and then look at benefit distribution
one_time_clients <- care_management_clean_merge %>% 
        filter(duration_bin == "One time") %>% 
        drop_na(benefit)

one_time_client_benefits <- prop.table(table(one_time_clients$benefit))

less_than_one_month_clients <- care_management_clean_merge %>% 
        filter(duration_bin == "< 1 month") %>% 
        drop_na(benefit)

less_than_one_month_client_benefits <- prop.table(table(less_than_one_month_clients$benefit))


one_to_three_month_clients <- care_management_clean_merge %>% 
        filter(duration_bin == "1-3 months") %>% 
        drop_na(benefit)

one_to_three_month_client_benefits <- prop.table(table(one_to_three_month_clients$benefit))


three_to_six_month_clients <- care_management_clean_merge %>% 
        filter(duration_bin == "3-6 months") %>% 
        drop_na(benefit)

three_to_six_month_client_benefits <- prop.table(table(three_to_six_month_clients$benefit))


six_to_twelve_month_clients <- care_management_clean_merge %>% 
        filter(duration_bin == "6-12 months") %>% 
        drop_na(benefit)

six_to_twelve_month_client_benefits <- prop.table(table(six_to_twelve_month_clients$benefit))


twelve_to_twentyfour_month_clients <- care_management_clean_merge %>% 
        filter(duration_bin == "12-24 months") %>% 
        drop_na(benefit)

twelve_to_twentyfour_month_client_benefits <- prop.table(table(twelve_to_twentyfour_month_clients$benefit))


more_than_twentyfour_month_clients <- care_management_clean_merge %>% 
        filter(duration_bin == "> 24 months") %>% 
        drop_na(benefit)

more_than_twentyfour_month_client_benefits <- prop.table(table(more_than_twentyfour_month_clients$benefit))


benefit_by_bin <- Reduce(function(...) merge(..., all = TRUE, by = "Var1"),
                              list(one_time_client_benefits,
                                   less_than_one_month_client_benefits,
                                   one_to_three_month_client_benefits,
                                   three_to_six_month_client_benefits,
                                   six_to_twelve_month_client_benefits,
                                   twelve_to_twentyfour_month_client_benefits,
                                   more_than_twentyfour_month_client_benefits)) %>% 
        rename(benefit = 1,
               "One time" = 2,
               "< 1 month" = 3,
               "1-3 months" = 4,
               "3-6 months" = 5,
               "6-12 months" = 6,
               "12-24 months" = 7,
               "> 24 months" = 8)

benefit_by_bin_plot <- benefit_by_bin %>% 
        pivot_longer(cols = -benefit,
                     names_to = "duration",
                     values_to = "count") %>% 
        ggplot(aes(x = factor(duration,
                              levels = c("One time", "< 1 month",
                                         "1-3 months", "3-6 months",
                                         "6-12 months", "12-24 months",
                                         "> 24 months")),
                   y = count, fill = benefit)) +
        geom_col(position = "stack") +
        scale_fill_viridis(discrete = T, option = "H") +
        labs(title = "Benefits Received by Duration of Interaction with ElderNet",
             x = "Duration",
             y = "Proportion of Clients",
             fill = "Benefit") +
        theme_bw() +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("analyses/team1/kathrine_m/benefit_by_bin.png",
       benefit_by_bin_plot, device = "png",
       height = 6, width = 10, units = "in")

# Concerned that clients in the shorter bins may just represent newer clients
# and that this may be additionally skewed because only the more recent entries 
# have benefit values assigned
# So what if we instead look at all clients in the first month versus latter time points
# This will actually require a different binning system

care_management_clean_merge2 <- care_management_clean_merge %>%
        group_by(anon_id) %>% 
        mutate(days_since_first = as.numeric(ceiling(difftime(assistance_date, first_assist,
                                          units = "days"))),
               time_point_bin = case_when(days_since_first < 30 ~ "first month",
                                          days_since_first >= 30 &
                                                  days_since_first < 90 ~ "1-3 months",
                                          days_since_first >= 90 &
                                                  days_since_first < 180 ~ "3-6 months",
                                          days_since_first >= 180 &
                                                  days_since_first < 360 ~ "6-12 months",
                                          days_since_first >= 360 &
                                                  days_since_first < 720 ~ "12-24 months",
                                          days_since_first >= 720 ~ "> 24 months"),
               time_point_bin = factor(time_point_bin,
                                       levels = c("first month", "1-3 months",
                                                  "3-6 months", "6-12 months",
                                                  "12-24 months", "> 24 months")))


# basic stacked bar plot showing counts
care_management_clean_merge2 %>% 
        drop_na(benefit) %>% 
        ggplot(aes(x = time_point_bin, fill = benefit)) +
        geom_bar(stat = "count", position = "stack") +
        scale_fill_viridis(discrete = TRUE, option = "H") +
        labs(title = "ElderNet Client Benefit Receipt by Time in Service\nData represents 300/490 (61.2%) clients and 4744/37497 (12.7%) records",
             x = "Time of Benefit Receipt Since Enrollment",
             y = "Count of Benefits Received",
             fill = "Benefit") +
        theme_bw()

label_df <- care_management_clean_merge2 %>% group_by(time_point_bin) %>% summarise(n=n())
label_df$benefit <- NA

# now map proportion instead of count to the y axis
# will need to add geom text for total n
care_management_clean_merge2 %>% 
        drop_na(benefit) %>% 
        ggplot(aes(x = time_point_bin, fill = benefit)) +
        geom_bar(stat = "count", position = "fill") +
        #geom_text() can't remember how to use this to add totals
        scale_fill_viridis(discrete = TRUE, option = "H") +
        labs(title = "ElderNet Client Benefit Receipt by Time in Service\nData represents 300/490 (61.2%) clients and 4744/37497 (12.7%) records",
             x = "Time of Benefit Receipt Since Enrollment",
             y = "Proportion of Benefits Received",
             fill = "Benefit") +
        theme_bw()


# How many clients in this dataset?
care_management_clean_merge2 %>% 
        drop_na(benefit) %>% 
        select(anon_id) %>% 
        unique() %>% 
        nrow() # 300

# And how many assistance interactions:
care_management_clean_merge2 %>% 
        drop_na(benefit) %>% 
        nrow() #4744

# It doesn't look like there is a whole lot of difference between the distributions
# Suggests that the clients are using the service for consistent reasons?
# How to approach this mathematically?

test %>% 
        select(anon_id, assistance_date, days_since_first, time_point_bin) %>%
        filter(is.na(time_point_bin))


