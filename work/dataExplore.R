
# TEAM 3 -  DATA 

library(tidyverse) # functions
library(scales)    # scale format
library(janitor)   # clean data column names & functions
library(ggplot2)   # data visual
library(here)      # data file management

# --- EDA
library(datawizard)
library(DataExplorer)
library(dlookr)
library(SmartEDA)


# ----- read in the data
careMgnt = read.csv('data/care_management_anonymized.csv')

clientInfo = read_csv('data/client_info_anonymized.csv')

donations = read_csv('data/donations_anonymized.csv')

pantry = read_csv('data/pantry_anonymized.csv')

volunteerServ = read_csv('data/volunteer_services_anonymized.csv')


# -------- create EDA reports

create_report(careMgnt)
create_report(clientInfo, output_dir = getwd())
create_report(donations, output_dir = getwd())
create_report(pantry, output_dir = getwd())
create_report(volunteerServ, output_dir = getwd())


# Basic Statistics
# Raw Counts
# Name	                Value
# Rows	                12,487
# Columns	        14
# Discrete columns	12
# Continuous columns	2
# All missing columns	0
# Missing observations	69,712
# Complete Rows	        4,728
# Total observations	174,818
# Memory allocation	2.1 Mb


ExpReport(careMgnt, op_file = 'careMgnt.html') # very nice report 
# ExpReport(clientInfo, op_file = 'clientInfo.html', op_dir = getwd()) # failed output due to error
ExpReport(donations, op_file = 'donationsReport.html', op_dir = getwd())
ExpReport(pantry, op_file = 'pantryReport.html', op_dir = getwd())
# ExpReport(volunteerServ, op_file = 'volunteerServ_Report.html', op_dir = getwd()) # failed


careMgnt %>% eda_paged_report(output_file='EDA_careMGMT') # best report output 

clientInfo %>% eda_paged_report(output_file='EDA_clientInfo') 

donations %>% eda_paged_report(output_file='EDA_donations') 

pantry %>% eda_paged_report(output_file='EDA_pantry') 

volunteerServ %>% eda_paged_report(output_file='EDA_volunteerServ')









