---
## Datathon 2022 Team 1: Initial Cleaning and Queries
#### date: "2/23/2022"

## Care Management

I edited/combined/merged the values that were clear errors, e.g. modified "Clinet" to "Client", "Eldernet" to "ElderNet" etc.

There remain several entries in the `Assistance_` and `Benefit_` variables that do not match the data dictiorary, often it appears that a benefit value has been entered under assiatance and vice versa. A running list:

Assistance:

* Facilitation
* Medical
* ElderNet

Benefit:

* Information
* Coordination
* Support

Party:

* Care Coordinator (can this be recoded to either ElderNet or Care Manager?)


**QUESTION 1:** How do we approach these, should we ask ElderNet for clarification or just recode to NA/unknown?

**QUESTION 2:** I would like to pivot/merge the three `Assistance_` and `Benefit_` variables into one assiatance and one benefit variable, to generate an output that looks like this:

```
  anon_ID instance   assistance           benefit
1       1        1 Continuation Telecommunication
2       1        2      Support         Financial
3       1        3     Referral    Transportation
4       2        1 Continuation Telecommunication
5       2        2      Support         Financial
6       2        3     Referral    Transportation
```

But I am unsure how to do this with both sets of variables simultaneously, assuming that `Assistance_1` is linked to `Benefit_1` and so on.

A few sub-questions related to this:

**2a:** To Carl T's point, can we actually do anything useful with these variables since there are so many NA's? Is it worth investing time in?

**2b:** What sort of questions could we answer within our remit with these variables?


## Volunteer services

All clients in this dataset have a first and last ride recorded, but this is only 162 of the total 641, so first ride is not helpful as a proxy for enrollment

**Question 3:** What is the `rider_num_rides` variable? All are set to 0

