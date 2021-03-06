charts for presentation
================

``` r
#load data
path <-
  list.files(path = here("data"), pattern = ".csv")

file_names <-
  c("care_mgmt", "client_info", "donations", "pantry", "volunteer")

path %>% 
  map( ~ read_csv(here("data", .))) %>% 
  set_names(file_names) %>%
  list2env(., envir = .GlobalEnv)
```

    ## <environment: R_GlobalEnv>

``` r
global_min <-
  min(
    c(
      min(as.Date(care_mgmt$assistance_date)),
      min(as.Date(mdy_hm(pantry$assistance_date))),
      min(as.Date(mdy(volunteer$appt_date)))
    )
  )

global_max <- 
  max(
    c(
      max(as.Date(care_mgmt$assistance_date)),
      max(as.Date(mdy_hm(pantry$assistance_date))),
      max(as.Date(mdy(volunteer$appt_date)))
    )
  )

client_info_adj <- 
  client_info %>%
  select(anon_ID) %>%
  mutate(date = as.Date("2019-01-01")) %>%
  group_by(anon_ID) %>%
  padr::pad(group = "anon_ID", interval = "day", start_val = as.Date(global_min), end_val = as.Date(global_max))

client_info <- 
  client_info %>%
  inner_join(., client_info_adj, "anon_ID") %>%
  mutate(month = floor_date(date, 'month')) %>%
  select(-date) %>%
  ungroup() %>%
  distinct()
```

``` r
care_mgmt_util <-
  care_mgmt %>%
  mutate(month = as.Date(floor_date(assistance_date, 'month'))) %>%
  group_by(anon_ID, month) %>%
  summarise(total_care_mgmt_encounters = n(),
            total_care_mgmt_mins = sum(amount, na.rm = T),
            mean_care_mgmt_mins = mean(amount, na.rm = T))

pantry_util <- 
  pantry %>%
  mutate(month = as.Date(floor_date(mdy_hm(assistance_date), 'month'))) %>%
  group_by(anon_ID, month) %>%
  summarise(total_pantry_encounters = n(),
            total_pantry_pounds = sum(amount, na.rm = T),
            mean_pantry_pounds = mean(amount, na.rm = T))

volunteer_util <- 
  volunteer %>%
  mutate(month = as.Date(floor_date(mdy(appt_date), 'month'))) %>% 
  group_by(anon_ID, month) %>%
  summarise(total_volunteer_encounters = n(),
            total_volunteer_mins = sum(appt_duration, na.rm = T),
            mean_volunteer_mins = mean(appt_duration, na.rm = T))
```

## Combined utulization plot

``` r
cols <- 
  c("#2F3D4B", # purple
    "#b6cf93", # green
    "#847cd4" # lighter purple
    )

data <- 
  bind_rows(
    care_mgmt %>%
      mutate(month = as.Date(floor_date(assistance_date, 'month'))) %>%
      group_by(month) %>%
      summarise(tot_encoutners = n()) %>%
      mutate(type = "Care Management Svcs"),
    
    pantry %>%
      mutate(month = as.Date(floor_date(mdy_hm(assistance_date), 'month'))) %>%
      group_by(month) %>%
      summarise(tot_encoutners = n()) %>%
      mutate(type = "Pantry"),
    
    volunteer %>%
      mutate(month = as.Date(floor_date(mdy(appt_date), 'month'))) %>% 
      group_by(month) %>%
      summarise(tot_encoutners = n()) %>%
      mutate(type = "Volunteer Svcs")
  ) %>%
  filter(month < max(month))

data %>%
  ggplot(.) +
  geom_line(aes(x = month, y = tot_encoutners, color = type)) +
  geom_point(aes(x = month, y = tot_encoutners, color = type)) +
  scale_color_manual(values =cols) +
  scale_x_date(breaks = scales::date_breaks("3 month"), date_labels = "%b %y",
               guide = guide_axis(angle = 45)) +
  labs(x = '', y ='Encounters', title = "Monthly ElderNet Service Utilziation", color = "Service Type") + 
  theme(text = element_text(size=20), legend.position = 'bottom') + 
  
  # https://www.governor.pa.gov/newsroom/wolf-administration-confirms-two-presumptive-positive-cases-of-covid-19/
  geom_vline(xintercept = as.Date("2020-03-06"), linetype = 'dashed', color = '#2F3D4B') +
  annotate("text", x = as.Date("2020-06-30"), y = 675, label = "1st PA Covid-19 case reported\n(3/6/2020)") + 
  
  # https://www.wgal.com/article/pennsylvania-moves-into-phase-1b-covid-vaccine-rollout/36047073
  geom_vline(xintercept = as.Date("2021-04-05"), linetype = 'dashed', color = '#2F3D4B') +
  annotate("text", x = as.Date("2020-12-20"), y = 590, label = "PA Phase 1B Rollout Begins\n(4/5/2021)")
```

![](charts_for_presentation_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

``` r
# prep  active clients
monthly_util <-
  client_info %>%
  left_join(., care_mgmt_util, by = c("anon_ID", "month")) %>%
  left_join(., pantry_util, by = c("anon_ID", "month")) %>% 
  left_join(., volunteer_util, by = c("anon_ID", "month")) %>% 
  ungroup() %>%
  as_tibble() %>% 
  rowwise() %>% 
  mutate(across(where(is.numeric), ~(ifelse(is.na(.x), 0, .)))) %>%
  mutate(used_care_mgmt = ifelse(total_care_mgmt_encounters >= 1, 1, 0),
         used_pantry = ifelse(total_pantry_encounters >= 1, 1, 0),
         used_volunteer = ifelse(total_volunteer_encounters >=1, 1, 0)) %>%
  ungroup() %>%
  rowwise() %>%
  mutate(num_svcs_used = sum(used_care_mgmt, used_pantry, used_volunteer, na.rm = T)) %>%
  as_tibble()

global_min_client_dates <- 
  care_mgmt %>%
  mutate(assistance_date = as.Date(assistance_date)) %>%
  select(anon_ID, care_mgmt_assistance_date = assistance_date) %>%
  left_join(., pantry %>%
              mutate(assistance_date = as.Date(assistance_date, format = '%m/%d/%Y')) %>% 
              select(anon_ID, pantry_assistance_date = assistance_date)) %>%
  left_join(., volunteer %>% 
              mutate(rider_first_ride_date = as.Date(rider_first_ride_date)) %>%
              select(anon_ID, rider_first_ride_date)) %>%
  distinct() %>%
  group_by(anon_ID) %>%
  summarize(min_care_mgmt_assistance_date = min(care_mgmt_assistance_date, na.rm = TRUE),
            min_pantry_assistance_date = min(pantry_assistance_date, na.rm = TRUE),
            min_rider_first_ride_date = min(rider_first_ride_date, na.rm = TRUE))

global_min_client_dates <- 
  tibble(
    anon_ID = global_min_client_dates$anon_ID,
    enrollment_date = apply(global_min_client_dates[, 2:ncol(global_min_client_dates)], 1, min, na.rm = TRUE)
  ) %>% 
  mutate(enrollment_month = floor_date(ymd(enrollment_date), "month"))

monthly_util <- 
  monthly_util %>%
  left_join(., global_min_client_dates) %>%
  mutate(active_period = ifelse(month >= enrollment_month, 1, 0)) %>%
  filter(active_period == 1)

# -----------------------------------------------

# get monthly active clients

get_active_clients <-
  function(data, client, lookback = 2, threshold = 1){
    # 
    # client <- 610
    # data <- monthly_util
    # lookback <- 2

    data %>%
      ungroup() %>%
      filter(anon_ID == {{client}}) %>%
      mutate(lookback_mean_2mo = round(slider::slide_dbl(num_svcs_used, mean, .before = 1, .after = 0), 2),
             lookback_mean_3mo = round(slider::slide_dbl(num_svcs_used, mean, .before = 2, .after = 0), 2),
             
             # used at least 1 svc offered (pantry, volunteer, care mgmt) in 2 of the 2 previous months
             active_client_2mo = ifelse(lookback_mean_2mo >= 1, 1, 0), 
              
             # used at least 1 svc offered (pantry, volunteer, care mgmt) in 3 of the 3 previous months
             active_client_3mo = ifelse(lookback_mean_3mo >= 1, 1, 0),
             
             # used at least 1 svc offered (pantry, volunteer, care mgmt) in 1 of the 2 previous months
             active_client_2mo_relaxed = ifelse(lookback_mean_2mo >= .5, 1, 0),
             
             # used at least 1 svc offered (pantry, volunteer, care mgmt) in 2 of the 3 previous months
             active_client_3mo_relaxed = ifelse(lookback_mean_3mo >= .67, 1, 0),
             
             # used at least 1 svc offered (pantry, volunteer, care mgmt) in 1 of the 3 previous months
             active_client_3mo_extra_relaxed = ifelse(lookback_mean_3mo >= .33, 1, 0)
             ) 
  }

client_ids <- 
  sort(unique(monthly_util$anon_ID))

active_clients <- 
  map_dfr(client_ids, ~get_active_clients(data = monthly_util, client = .x))
```

### monthly active client chart

``` r
active_clients %>%
  ungroup() %>%
  group_by(month) %>%
  summarise(`2 month strict` = sum(active_client_2mo),
            `3 month strict` = sum(active_client_3mo),
            `2 month relaxed`= sum(active_client_2mo_relaxed),
            `3 month relaxed` = sum(active_client_3mo_relaxed),
            `3 month extra relaxed` = sum(active_client_3mo_extra_relaxed),
            ) %>% 
  pivot_longer(2:6) %>%
  filter(name == "2 month relaxed") %>%
  # mutate(category = ifelse(name %in% c("2 month strict", '3 month strict'), 'Strict Definition', "Relaxed Definition")) %>%
  filter(month < max(month)) %>%
  ggplot(., aes(x = month, y = value)) + 
  geom_point(color = "#5D5177") + 
  geom_line(color = "#5D5177") + 
  labs(x = '', y = 'Active Clients', title = 'Monthly Active Clients') + 
  theme(text = element_text(size=20)) + 
  scale_x_date(breaks = scales::date_breaks("3 month"), date_labels = "%b %Y",
               guide = guide_axis(angle = 45)) +
  
  # https://www.governor.pa.gov/newsroom/wolf-administration-confirms-two-presumptive-positive-cases-of-covid-19/
  geom_vline(xintercept = as.Date("2020-03-06"), linetype = 'dashed', color = '#2F3D4B') +
  annotate("text", x = as.Date("2020-06-30"), y = 275, label = "1st PA Covid-19 case reported\n(3/6/2020)") + 
  
  # https://www.wgal.com/article/pennsylvania-moves-into-phase-1b-covid-vaccine-rollout/36047073
  geom_vline(xintercept = as.Date("2021-04-05"), linetype = 'dashed', color = '#2F3D4B') +
  annotate("text", x = as.Date("2020-12-20"), y = 225, label = "PA Phase 1B Rollout Begins\n(4/5/2021)")
```

![](charts_for_presentation_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

``` r
active_clients %>%
  ungroup() %>%
  mutate(poverty_label = ifelse(poverty == "Yes", "Poverty: Yes", "Poverty: No"),
         minority_label = ifelse(minority == "Yes", "Minority: Yes", "Minority: No")) %>%
  filter(month < max(month)) %>%
  group_by(month, poverty_label, minority_label) %>%
  summarise(active_clients = sum(active_client_2mo_relaxed)) %>%
  ggplot(., aes(x = month, y = active_clients, color = poverty_label)) + 
  geom_point() + 
  geom_line() + 
  facet_wrap(vars(minority_label)) + 
  scale_color_manual(values = c("#2F3D4B", "#847cd4")) + 
  scale_x_date(breaks = scales::date_breaks("6 month"), date_labels = "%b %Y",
               guide = guide_axis(angle = 45)) +
  labs(x = '', y = "Count", title = 'Active Clients per Month', color = NULL)+ 
  theme(text = element_text(size=20),
        legend.position = 'bottom')  + 
  
  # https://www.governor.pa.gov/newsroom/wolf-administration-confirms-two-presumptive-positive-cases-of-covid-19/
  geom_vline(xintercept = as.Date("2020-03-06"), linetype = 'dashed', color = '#2F3D4B') +
  annotate("text", x = as.Date("2019-08-30"), y = 150, label = "1st PA Covid-19 \ncase reported\n(3/6/2020)") + 
  
  # https://www.wgal.com/article/pennsylvania-moves-into-phase-1b-covid-vaccine-rollout/36047073
  geom_vline(xintercept = as.Date("2021-04-05"), linetype = 'dashed', color = '#2F3D4B') +
  annotate("text", x = as.Date("2020-11-01"), y = 100, label = "PA Phase 1B\nRollout Begins\n(4/5/2021)")
```

![](charts_for_presentation_files/figure-gfm/unnamed-chunk-7-1.png)<!-- -->
