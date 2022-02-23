
library(dplyr)
library(purrr)
library(here)
library(readr)

path <- list.files(path = here("data"), pattern = ".csv")

file_names <-
        c("care_mgmt", "client_info", "donations", "pantry", "volunteer")

path %>%
        map( ~ read_csv(here("data", .))) %>%
        set_names(file_names)
