# I have systematically looked at each variable
# and then created a new csv which addresses the previous variable coding issues
# in relation to the data dictionary
# Care management is complete (pending review of questions)

##### LIBRARIES #####
library(tidyverse)
library(readxl)

##### DATA #####

care_management <- read_csv("data/care_management_anonymized.csv")
client_info <- read_csv("data/client_info_anonymized.csv")
volunteer_services <- read_csv("data/volunteer_services_anonymized.csv")
pantry <- read_csv("data/pantry_anonymized.csv")
donations <- read_csv("data/donations_anonymized.csv")


##### CLEANING CARE MANAGEMENT #####

# Use glimpse to see each variable and it's class
glimpse(care_management)
# Now look at each variable individually 
# to see if anything needs attention

##### CLEANING CARE MANAGEMENT: assistance_category #####
# Which unique values exist in this variable
# identify any typos/duplications
unique(care_management$assistance_category)
# How are the values distributed
# and are there any NA values?
table(care_management$assistance_category, useNA = "always")
# Nothing to fix here

##### CLEANING CARE MANAGEMENT: Assistance_ #####

# There are three Assistance_ variables
# What do we expect (from the data dictionary):
# Coordination
# Continuation
# Enrollment
# Filing
# Information
# Referral
# Support

# And what do we see?
unique(care_management$Assistance_1)
# Need to combine coordination and Coordination
# What is facilitation? How often does it occur? Same with Medical
table(care_management$Assistance_1) 
# Once each, add to questions
unique(care_management$Assistance_2)
# Why is there an "ElderNet" value? How often does it occur?
table(care_management$Assistance_2) 
# just once, let's change to NA
unique(care_management$Assistance_3)
# This one looks ok
# So what is the difference between these three variables? 
# To capture multiple services on the same date
# Can they be merged/pivoted?
# Added to questions

##### CLEANING CARE MANAGEMENT: Benefit_ #####

# From the data dictionary:
# ADL
# ElderNet
# Financial
# Food
# Housing
# Legal
# Medical
# Pets
# Safety
# Social
# Telecommunication
# Transportation
# Utilities

unique(care_management$Benefit_1)
# Need to merge Eldernet with ElderNet and Pet with Pets
# What is Information? Is this an assistance value incorrectly logged?
# Recode Benefit_1 to NA
unique(care_management$Benefit_2)
# Need to merge Eldernet with ElderNet and telecommunications with Telecommunication
# What is Coordination? Is this an assistance value incorrectly logged?
unique(care_management$Benefit_3)
# Need to merge Pets with Pet
# What is Support? Is this an assistance value incorrectly logged?

##### CLEANING CARE MANAGEMENT: CommType #####

# from the data dictionary:
# Call
# Email
# In Person
# Mail
# Text Message (includes Facebook message)
# Video Call (includes FaceTime and Zoom)
# Voice Message

# What do we see:
unique(care_management$CommType)
# Looks good

##### CLEANING CARE MANAGEMENT: InitiatedBy #####

# from the data dictionary:
# ElderNet
# Other Party

# What do we see:
unique(care_management$InitiatedBy)
# This is a mess, it is overlapping with the Party variable
# Easy fixes are to merge Eldernet with ElderNet and Other party with Other Party
# More complicated, need to see what is recorded in Party variable for the other entries
# First pull out just those with unwanted values in InitiatedBy
initiation_check <- care_management %>% 
        filter(InitiatedBy == "Client" | InitiatedBy == "Service provider")
# Then check if they equal what is entered in Party
identical(initiation_check$InitiatedBy, initiation_check$Party)
# I also reviewed this by eye as it's a small number of entries (59)
# Therefore it's ok to recode all to "other party"
# Is there any info in Party that can be used when InitiatedBy is NA?
initiation_na <- care_management %>% 
        filter(is.na(InitiatedBy))
table(initiation_na$Party, useNA = "always")
# Yes, only in a few cases and none are ElderNet, so pull this in as "Other Party"


##### CLEANING CARE MANAGEMENT: Party #####
# from the data dictionary:
# Care Manager
# Client
# ElderNet
# Family
# Friend
# Other
# Service Provider
# Social Worker

# What do we see:
unique(care_management$Party)
# Need to merge Eldernet with ElderNet and Clinet with Client
# Recode Care Coordinator to Other as there is no guarantee that this refers to
# either ElderNet or Care Manager
# Add to questions

# Now to apply all of the changes outlined above

care_management_clean <- care_management %>% 
        mutate(Assistance_1 = case_when(Assistance_1 == "coordination" ~ "Coordination",
                                        TRUE ~ Assistance_1),
               Assistance_2 = case_when(Assistance_2 == "ElderNet" ~ NA_character_,
                                        TRUE ~ Assistance_2),
               Benefit_1 = case_when(Benefit_1 == "Eldernet" ~ "ElderNet",
                                     Benefit_1 == "Pet" ~ "Pets",
                                     Benefit_1 == "Benefit_1" ~ NA_character_,
                                     TRUE ~ Benefit_1),
               Benefit_2 = case_when(Benefit_2 == "Eldernet" ~ "ElderNet",
                                     Benefit_2 == "Telecommunications" ~ "Telecommunication",
                                     TRUE ~ Benefit_2),
               Benefit_3 = case_when(Benefit_3 == "Pet" ~ "Pets",
                                     TRUE ~ Benefit_3),
               InitiatedBy = case_when(InitiatedBy == "Eldernet" ~ "ElderNet",
                                       InitiatedBy == "Other party" ~ "Other Party",
                                       InitiatedBy == "Client" ~ "Other Party",
                                       InitiatedBy == "Service Provider" ~ "Other Party",
                                       is.na(InitiatedBy) & !is.na(Party) ~ "Other Party",
                                       TRUE ~ InitiatedBy),
               Party = case_when(Party == "Eldernet" ~ "ElderNet",
                                 Party == "Care Coordinator" ~ "Other",
                                 Party == "Clinet" ~ "Client",
                                 TRUE ~ Party))

# Can write a csv file of this cleaned data
# but keeo commented out for now
# write_csv(care_management_clean, "analyses/team1/care_management_anonymized_cleaned.v1.csv")

##### Collapsing Benefit_ and Assistance variables #####

# To combine the benefit and assistance values into one set of variables
# First split the data frame into lacking the assistance variables
# and one lacking the benefit variables
# Then pivoted each to generate an `assistance` or `benefit`
# variable plus an instance variable to capture the numerical suffix

benefit_df <- care_management_clean %>% 
        select(-Assistance_1, -Assistance_2, -Assistance_3) %>% 
        pivot_longer(cols = starts_with("Benefit_"),
                     names_to = "instance",
                     names_prefix = "Benefit_",
                     values_to = "benefit")
        

assistance_df <- care_management_clean %>% 
        select(-Benefit_1, -Benefit_2, -Benefit_3) %>% 
        pivot_longer(cols = starts_with("Assistance_",
                                        ignore.case = FALSE),
                     names_to = "instance",
                     names_prefix = "Assistance_",
                     values_to = "assistance")

# Finally join back together using all of the shared variables
# Including the new `instance` variable
# to keep `Benefit_1` linked to `Assistance_1` etc.

care_management_clean_merge <- benefit_df %>% 
        full_join(., assistance_df)

# Quality checks
# How many ADL entries did we see in the original df?
care_management_clean %>% 
        filter(Benefit_1 == "ADL") %>% nrow() # 124
care_management_clean %>% 
        filter(Benefit_2 == "ADL") %>% nrow() # 23
care_management_clean %>% 
        filter(Benefit_3 == "ADL") %>% nrow() # 5
124+23+5 # 152
# And how many in the merged dataset?
care_management_clean_merge %>% 
        filter(benefit == "ADL") %>% nrow() # 152

# Can now r=write to a csv if needed:
# write_csv(care_management_clean_merge,
#           "analyses/team1/kathrine_m/care_management_clean_merge.csv")


##### CLEANING CLIENT INFO #####
# Not necessary, organizers already removed the duplicates

##### CLEANING VOLUNTEER SERVICES #####

glimpse(volunteer_services)

# Are there any NAs?
sum(is.na(volunteer_services$rider_first_ride_date))
sum(is.na(volunteer_services$rider_last_ride_date))
# No every client has a first and last ride date recorded
# What does the number of rides distribution look like?
summary(volunteer_services$rider_num_rides)
# Hmm, this variable doesn't seem to be calculated correctly
# as it is zero across the board
# Just ignore the variable for now unless we need this metric

# How many clients are represented here?

volunteer_services %>% 
        select(anon_ID) %>% 
        unique() %>% 
        nrow()
# Only 162

unique(volunteer_services$category)
# This matches the data dictionary

##### CLEANING PANTRY #####

glimpse(pantry)
unique(pantry$assistance_category)
# This matches the data dictionary

unique(pantry$unit)
# This matches the data dictionary

sum(is.na(pantry$assistance_date))
sum(is.na(pantry$assistance_category))
sum(is.na(pantry$amount))
sum(is.na(pantry$unit))
# This looks good


##### CLEANING DONATIONS #####
glimpse(donations)

##### CLEANING DONATIONS: Zip #####

unique(donations$zip)
table(donations$zip, useNA = "always")
# Looks good, a bunch of NA (135)

##### CLEANING DONATIONS: Status #####

unique(donations$status)
table(donations$status, useNA = "always")
# Looks good

##### CLEANING DONATIONS: do_not_mail #####

unique(donations$do_not_mail)
table(donations$do_not_mail, useNA = "always")
# Looks good

##### CLEANING DONATIONS: do_not_call #####

unique(donations$do_not_call)
table(donations$do_not_call, useNA = "always")
# Looks good

##### CLEANING DONATIONS: Organization #####

unique(donations$organisation)
table(donations$organisation, useNA = "always")
# Looks good

##### CLEANING DONATIONS: date #####

unique(donations$date)
table(donations$date, useNA = "always")
# Looks good

##### CLEANING DONATIONS: amount #####

unique(donations$amount)
table(donations$amount, useNA = "always")
# Looks good

##### CLEANING DONATIONS: form #####

unique(donations$form)
table(donations$form, useNA = "always")
# Looks good

##### CLEANING DONATIONS: Campaign #####

# From the data dictionary:
# AMCRC
# Board
# CAC
# Church
# Clients
# Corporatio
# D.Young Fu
# Emerg fund
# Escort Dri
# Fall Towns
# Foundation
# Grants
# In-Kind
# Mem-hon
# Misc
# Newsletter
# Special Pr
# Sprg Evt
# United Way

# What do we see:
unique(donations$campaign)
table(donations$campaign, useNA = "always")
# Looks good, reflects the data dictionary

##### CLEANING DONATIONS: target #####

unique(donations$target)
table(donations$target, useNA = "always")
# Looks good, everything is set to "Gift"


##### QUESTIONS #####

# Q1
# What to do with values that are not defined in the data dictionary?
# Assistance_ variables: Medical, Facilitation, ElderNet (assumed this one should be NA)
# Could these be incorrectly logged Benefit values?
# Propose:
# Recode facilitation to coordination
# Transfer medical to benefit
# transfer ElderNet to benefit
# This is problematic as there is already data recorded under benefit_1

# Q2
# What does "Care Cordinator" refer to in the Party variable?
# Can this be merged with ElderNet or Care Manager? (N.B. I recoded this to "Other")
