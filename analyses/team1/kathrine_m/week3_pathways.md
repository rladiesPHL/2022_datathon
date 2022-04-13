Team 1 Week 3: Client Timelines and Pathways
================
Kathrine McAulay
3/6/2022

``` r
library(tidyverse)
library(readxl)
library(forcats)
library(viridis)
```

Start with the cleaned file from week 2, where `Benefit_1`,
`Assistance_1` etc. have been transformed into two variables: `benefit`
and `assistance`. Now make a few changes to add the following variables:

-   `days_since_last` - arranging by `assistance_date` and grouping by
    `anon_id`, then using the `lag()` function to refer to the previous
    `assistance_date`
    -   Note that this renders the first instance for each client as
        `NA`, convert to `0`
-   `first_assist` - similar approach to CarlT here, first
    `assistance_date` per each `anon_id` in this dataset
-   `last_assist` - as above for most recent date
-   `duration` - number of days (rounded up) between `first_assist` and
    `last_assist`
-   `duration_bin` - binning `duration` to subsets

``` r
care_management_clean_merge <- read_csv("care_management_clean_merge.csv") %>%
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
               duration_bin = case_when(
               duration == 0 ~ "One time",
               duration > 0 & duration <= 30 ~ "< 1 month",
               duration > 30 & duration <= 90 ~ "1-3 months",
               duration > 90 & duration <= 180 ~ "3-6 months",
               duration > 180 & duration <= 360 ~ "6-12 months",
               duration > 360 & duration <= 720 ~ "12-24 months",
               TRUE ~ "> 24 months")) %>% 
        ungroup()
```

### Subsetting ElderNet Clients by Duration

Now we can look at the distribution of clients per bin, which reveals
that 20% of clients interact with ElderNet for one day only, and a
further 20% are in the syestem for only one month. Because I’m pretty
bad at this, I had to first pull this out to a new data frame in order
to tabulate the frequencies

``` r
client_timeline <- care_management_clean_merge %>% 
        select(anon_id, duration, duration_bin) %>% 
        unique()

round(100*(prop.table(table(client_timeline$duration_bin))),2)
```

    ## 
    ##    < 1 month  > 24 months   1-3 months 12-24 months   3-6 months  6-12 months 
    ##        20.20        15.10         7.35        17.55         8.16        11.22 
    ##     One time 
    ##        20.41

I then looked at the distribution of benefits between these bins. I did
this in a veery convoluted manner. If anyone believes there is merit in
pursuing this further I would happily brainstorm/accept advice on a
simpler way to do this and to retain the number of clients represented
each time.

``` r
# generate a prop table for each bin
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

# merge the prop tables
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
```

![](https://github.com/brndngrhm/2022_datathon/blob/main/analyses/team1/kathrine_m/benefit_by_bin.png?raw=true)<!-- -->

For the most part, I dislike stacked barcharts to get information across
as interpreting area can be kind of subjective; however, in terms of a
quick eyeball of the data, maybe this is helpful. Looks fairly similar
accross the board with the one interaction only group being somewhat of
an outlier.

**NOTE** I have not captured how many clients are represented here, will
need to go back and do this  
**NOTE** The shorter duration categories could represent newer clients.
This poses two issues:

-   They may continue to use ElderNet now, and simply the sampling time
    may misrepresent them  
-   They may also be skewed by having more benefit data present, since
    we know that this data is incomplete for the earlier interactions

### Clients interacting with ElderNet over 1-2 years

While we can’t define a long or short duration with ElderNet as positive
or negative due to the missing outcome data, what we can say is that:

160 clients received services over a 1-2 year period that presumably
kept them in their homes for that duration. I think this is an important
impact message to get across.

### Caveats/Remaining questions

Some concepts that I am not sure how to address:

-   People binned to `one_time` or `< 1 month` may in fact be newer
    enrollments, how to account for these?
-   We can’t assign a positive or negative attribute to either short or
    long duration in the ElderNet system, so how do we make this
    information outcome agnostic?
-   I appeal to other group members for help with sats/probabilities in
    answering these questions, as it is not my strong point
