2022 Datathon (R Ladies Philly / Data Philly)
================
Team 1
4/6/2022

## ElderNet’s Impact in the Community

### Executive Summary

\[WILL ADD WHEN HAPPY WITH CONTENT\]

### Contributors

-   Bulleted List
-   

### Problem Definition

[ElderNet of Lower Merion and Narberth](https://eldernetonline.org/) is
a nonprofit organization that was founded in 1976 by representatives of
community, religious and governmental groups. ElderNet serves adults of
all ages, especially frail older or younger disabled persons with low to
moderate incomes who reside in Lower Merion or Narberth. ElderNet helps
older neighbors remain independent and provides a variety of free,
practical services so they have access to healthcare, food security, and
an improved quality of life. ElderNet also provides information to
individuals who need assistance with housing, nursing care, or other
necessities.

The role of Team 1 in this Datathon was to explore the impact of
ElderNet services on the community it serves.

### Dataset

Data from ElderNet was deitentified and recoded by the Datathon leads
and was provided to the teams as five distinct datasets. Clients were
assigned unique identifier to allow comparison and merging across
datasets.

-   Care Management: A summary of the assistance received by each client
    and the associated benefit to that client
-   Client Info: Basic demographics (County, poverty status, minority
    status, and a blinded age group assignment)
-   Donations: A summary of ElderNet donation information; no client
    information
-   Pantry: A summary of the food provided to each client via the Pantry
    service
-   Volunteer Services: A summary of the rides provided to each client
    and the pusrpose of each ride

Some basic data cleaning was required for the Care Management dataset to
correct for typos etc. A cleaned version of this dataset can be found
[here](https://github.com/brndngrhm/2022_datathon/blob/main/analyses/team1/kathrine_m/care_management_anonymized_cleaned.v1.csv).

There were a large number of missing values in the assistance and
benefit categories within the Care Management dataset. Further, these
variables were split into three assistance and three benefit categories,
to allow capture of multiple assistance events on a single date. To
consolidate this information and minimize NA values, these variables
were merged. The merged version of this dataset can be found
[here](https://github.com/brndngrhm/2022_datathon/blob/main/analyses/team1/kathrine_m/care_management_clean_merge.csv).

\[TO ADD NOTES ON ANY DATA OMITTED/CAVEATS\]

### Results

#### How has ElderNet helped remain in their home for longer?

Without outcome data for each client, it was not possible to infer which
ElderNet services were associated with successfully allowing clients to
remain in their homes. Instead, service usage was reviewed in aggregate
to highlight those that were most heavily used.

Between \[DATE\] and \[DATE\] there were

-   21,504 instances of direct care
-   766 home visits, lasting more than 485 hours
-   Over 638 hours of phone calls
-   145,300 lbs of food issued from the Pantry
-   2,102 rides to doctor’s appointments

The concept of tracking client activity over time was also exploted and
an *Active Client* was defined as a client who had used at least one
service (volunteer services, pantry, or care management) in at least one
of the previous two months. This is a lagging indicator and the impact
of the COVID-19 pandemic can be seen in 2020 and a hopeful uptick in
service usage following vaccination roll out in early 2021 (Figure 1). A
limitation of this metric is that it does not take into account the
intensity of service utilization; however, the inclusion criteria can be
modified to narrow or widen the window as desired.

![Figure 1. Client
activity](https://github.com/brndngrhm/2022_datathon/blob/main/analyses/team1/brendan_g/charts_for_presentation_files/figure-gfm/unnamed-chunk-6-1.png?raw=true)

**Figure 1.** \[LEGEND GOES HERE\]

#### How well is ElderNet connecting participants to the public benefits that they need?

**Health/Medical:** Between April 2015 and December 2021, Eldernet
volunteers provided services to clients 4,100 times, and the largest
share of these (2,102, 51%) were transportation to doctors appointments
(Figure 2).

![Figure 2. Volunteer Services by
Category](https://github.com/brndngrhm/2022_datathon/blob/main/analyses/team1/kathrine_m/images/volunteer_services_plot.png?raw=true)

**Figure 2.** Needs met via ElderNet volunteer services, including
transportation and home visits

**Food Assistance:** The second largest share of volunteer services went
to shopping, impacting \[NUMBER\] clients a total of 1158 times.
Further, the Pantry service has issued 145,000 lbs of food to clients
since 2019, with peaks seen around the winter holidays, when ElderNet
issues holiday baskets and also in the early months of the COVID-19
pandemic in 2020 (Figure 2).

[Figure 3. Pantry
Usage](WHICH%20PANTRY%20CHART%20ARE%20WE%20USING%20HERE?)

**Figure 3.** \[LEGEND GOES HERE\]

#### How do the counties served by ElderNet compare to similar counties where services like ElderNet are not available?

With Team 3 taking a deep dive into geography in the context of service
expansion, Team 1 opted to limit analysis to Montgomery County, PA.
ElderNet currently serves two Townships within the County: Lower Merion
and Narberth. Only 6% of the \[NUMBER\] Montgomery County residents
under the federal poverty level and The estimated median household
income in Lower Merion is $140,000; this is the highest in the County
(2016-2020 American Community Survey, US Census Bureau; Figure 4).
Nonetheless, 490 people in this region required assistance associated
with basic human needs such as food and accessing healthcare in the last
two years. It is clear that if such a need exists in these Townships
there is likely a similar or more pronounced need in neighboring
Townships.

[Figure 4. Poverty and income in Montgomery
County](KM%20to%20add%20map%20and%20chart%20images)

**Figure 4.** Proportion of residents below the federal poverty level in
Montgomery County, PA (A) and the estimated median household income
across the county (B). Lower Merion and Narberth are highlighed in the
red box.

### Conclusions

-   Based on typical usage, transportation, especially to doctor’s
    appointments, is an extremely desired service
-   Access to the food pantry was a consistent and well used service The
    pandemic impacted monthly active clients, but active clients began
    to rise following vaccine roll out
-   Linking this information to the current in-home status of clients
    would allow provide more insight into the effectiveness of these
    services

### Remaining Questions

-   What services were most likely to enable a client to stay in their
    home?
-   Did client COVID-19 vaccination status impact ridership or other
    services?
-   Was the drop in ridership during early pandemic due to reduced
    demand, or reduced availability of drivers?
-   Did the rise in telemedicine impact need for rides to doctor’s
    appointments, that is, what percentage of rides could be eliminated
    if patients were able to access telemedicine?

### References

\[KM TO ADD REFERENCES FOR CENSUS DATA\]
