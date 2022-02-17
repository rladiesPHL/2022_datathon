## About 

The 2022 [RLadies Philly](https://www.rladiesphilly.org/) & [Data Philly](https://www.meetup.com/DataPhilly/) datathon aims to connect and enable data science enthusiasts to learn and collaborate while also making a difference in the broader Philadelphia community. This year, we have partnered with [ElderNet](https://eldernetonline.org/) to explore how different programs for elderly and disabled individuals serve the community. Participants are welcome to use any statistical tool they feel comfortable with (R, Python, SAS, SPSS, etc.), but we will be able to provide most support for questions related to R. Everyone is welcome to participate, and there is no minimum requirement for data science proficiency (but we do require an interest in learning data analysis and data science tools and methods!)

[ElderNet of Lower Merion and Narberth](https://eldernetonline.org/) is a nonprofit organization that was founded in 1976 by representatives of community, religious and governmental groups. ElderNet serves adults of all ages, especially frail older or younger disabled persons with low to moderate incomes who reside in Lower Merion or Narberth. ElderNet helps older neighbors remain independent and provides a variety of free, practical services so they have access to healthcare, food security, and an improved quality of life. ElderNet also provides information to individuals who need assistance with housing, nursing care, or other necessities.

## Structure

### Kickoff Event (Virtual), February 16, 2022, 6-8pm: 

- Introductions, problem background and Q&A with partner; logistics, data overview, and breakout rooms by teams
- See meeting materials for more info: [Meetup event](https://www.meetup.com/rladies-philly/events/282561855/), [Slides](https://docs.google.com/presentation/d/1KIho-PZE9CqAqW8Xr2gXCoNZnkgSXM4xOWbKnXjFN1c/edit?usp=sharing) and Recording (LINK TO FOLLOW)

Afer the kickoff event, teams will work together using Slack, GitHub, and any other online platform of their choosing (zoom, google meet, etc.). Datathon organizers can set up zoom meetings for teams by request (just contact us on Slack!). Questions to ElderNet should be added to an ongoing [Google Doc](https://docs.google.com/document/d/17vAQniQK6KEQsS2pSP564QzXHEA6kIgHz6mgf5fXHqs/edit?usp=sharing), which ElderNet will check regularly and answer asynchronously. Datathon organizers will be available on Slack to answer any other questions. While we recommend weekly meetings for teams, teams have the flexibility to set up their workflow as they see fit. The following week-by-week approach is recommended: 

### Week-by-week outline (recommended):

- Wednesday, 2/16/2022: Set up a plan of action with your team members during the kickoff event
- Week of 2/21/2022: Run descriptives to get to know the datasets and use RMarkdown/Jupyter to document observations (this also gets you started on the report early!)
- Week of 2/28/2022: Wrap up data cleaning; explore data in more depth, documenting process and observations; teams decide on the story to tell through findings
- Week of 3/7/2022: Run analyses towards data story and write up the conclusions and observations as you go along; for data viz, develop a dashboard with your story in mind
- Week of 3/14/2022: Draft a combined RMarkdown/Jupyter report that brings together your team’s most interesting findings and tells your data story; refine your analyses/dashboard 
- Week of 3/21/2022: Polish your report/dashboard, create slide deck for presentation
- Wednesday, 3/30/2022: Present your findings to ElderNet & the other groups
    
### Conclusion Event (Virtual), March 30, 6-8pm: 

- Teams will present their results and discuss their experiences. Each team will have the freedom to choose one or more group members to present the team's results, or to request that a datathon lead presents the team's results if no group members are available to present. The latter option requires some advance coordination. Final report submissions should be done by the end of this week as well. 
- See meeting materials for more info: [Meetup event](https://www.meetup.com/rladies-philly/events/283914368/), Slides (LINK TO FOLLOW) and Recording (LINK TO FOLLOW)

## Deliverables 

Each team is asked to create 2 deliverables by the conclusion meetup:

1. A conclusion presentation (~20 minutes) summarizing the most important findings, including team objectives, main findings, challenges and future directions 
    - See examples of past slide decks from [2021](https://docs.google.com/presentation/d/1KhyCgos30lQfxKHooV9LUQEc7N8ma5j9LtXrJiPhjbU/edit?usp=sharing) and [2019](https://docs.google.com/presentation/d/1lAsyJvLbvl9ALKHirITOl1H2Ds2i83j1zx3-uD4PYpg/edit?usp=sharing)
    - View recordings of past datathon presentations from [2021](https://www.youtube.com/watch?v=fzJhKMcKVX4) and [2020](https://www.youtube.com/watch?v=ZN7HjZ6Glv4)
    
2. A final report including contributors, team objectives, main findings, challenges and future directions
    - See final reports from past years:  [2021](https://github.com/rladiesPHL/2021_datathon/blob/main/analyses/final_report/CombinedReportMerged.pdf); 2020 [team 4](https://github.com/CodeForPhilly/datahack2020/blob/master/analyses/team04/team_04_report_estimate_idus.pdf), [team 6](https://github.com/CodeForPhilly/datahack2020/blob/master/analyses/team06/Final_Report.pdf), [team 8](https://github.com/CodeForPhilly/datahack2020/blob/master/analyses/team08/2020_report_and_presentation/MATchmakerReport_Team8_2020-0424.pdf), [team 11](https://github.com/CodeForPhilly/datahack2020/blob/master/analyses/team11/Final%20Report/2020_DataHackathon_Team11_FinalReport.pdf); [2019](https://github.com/rladiesPHL/2019_datathon/blob/master/Analyses/2019_RladiesDatathon_FinalReport.pdf)

## Teams

- **Team 1: ElderNet's impact in the community**
    - How has ElderNet helped clients remain in their home longer?
    - How well is ElderNet connecting participants to the public benefits they need? (consider number of interactions, type of benefits/assistance provided, duration between `ElderNet enrollment` and first ride or first pantry interaction)
    - How do the counties served by ElderNet compare to similar counties where services like ElderNet are not available? (e.g. combine with Census data)

- **Team 2: Decision-making insights dashboard**
    - Develop an interactive dashboard that will help ElderNet leadership make better informed decisions. Consider volume of work, population served, assistance provided, donations received, and volunteer time, etc.)
    
- **Team 3: Growth Opportunities and Fun Facts**
    - Are there areas of need that ElderNet should focus on in the future? (e.g. you can use Census data to provide an in-depth picture by county/zip code of the population, and their likely needs)
    - Explore ElderNet's growth with regard to number of clients, donors/donation amount, etc.
    - Any other analyses you think would be interesting to do/helpful to ElderNet to better understand their data

## Data

The data is made available as csv files, and includes de-identified information on ElderNet participants and use of services between January 2019 and October 2021. The following datasets are provided:

1. `client_info_anonymized.csv`: includes basic de-identified demographics on clients; variables include client ID, county, poverty status, minority group, and age group label
2. `care_management_anonymized.csv`: includes information on clients' interactions with ElderNet Social Workers primarily, as part of the care mangement program; variables include client ID, assistance date, communication type, who initiated the interactions, and up to 3 types of benefits and assistance per interaction 
3. `volunteer_services_anonymized.csv`: includes information on rides provided by ElderNet volunteers to clients; variables include client ID, client's first ride date ever, client's last ride date, and date of each ride taken and main reason for ride
4. `pantry_anonymized.csv`: includes a history of clients' visits to ElderNet's food pantry; variables include client ID, visit date, type of assistance provided, quantity of food assistance and unit of food assistance
5. `donations_anonymized.csv`: includes donations made in support of ElderNet's activities; variables include donor ID, zip code, whether donor is an organization, amount and campaign

## Code of Conduct

Datathon organizers are dedicated to providing a harassment-free experience for everyone. We do not tolerate harassment of participants in any form. Please refer to the [code of conduct](https://github.com/rladies/starter-kit/wiki/Code-of-Conduct) for more information. Please do not hesitate to contact datathon organizers via Slack if you have any questions or concerns. 

## FAQ

### What if I have questions about the data or about ElderNet?

- ElderNet representatives will answer questions via a [google sheet](https://docs.google.com/document/d/17vAQniQK6KEQsS2pSP564QzXHEA6kIgHz6mgf5fXHqs/edit?usp=sharing). Please write your questions in the shared google doc, and ElderNet representatives, or datathon organizers, will answer them regularly; you can also post your questions in slack and organizers will do their best to answer them, or other datathon participants may be able to help!

### I am new to R. How do I get started?

1. [Install R and R Studio](https://rstudio-education.github.io/hopr/starting.html)
2. Watch the ["Intro to R" webinar by Tess Cherlin](https://youtu.be/80VIvZZegY8?t=1297) on R-Ladies Philly YouTube Channel
3. Download the data
4. Refer to [Rstudio Cheatsheets](https://rstudio.com/resources/cheatsheets/) for quick solutions to coding questions
5. Ask for help on the [RLadies-Philly Slack](https://bit.ly/join-rladies-slack-2020) #help channel

### I've never used Git and GitHub before. What is it and how do I use it?

- Use this guide to [get started with Git and GitHub](https://happygitwithr.com/index.html)
- Use [this step-by-step guide](https://docs.google.com/document/d/1vF7uWo2ITXcifyNoLd8ZTJdNPx0Pd4eXXrdkKVfbAkY/edit) from the 2021 datathon to start participating in the collaborative work for this datathon 
- Ask for help on the [RLadies-Philly Slack](https://bit.ly/join-rladies-slack-2020) #help channel

### I have a question and I can't find the answer in these resources. Where do I go for help?

- Ask for help on the [RLadies-Philly Slack](https://bit.ly/join-rladies-slack-2020) #help channel or in the datathon slack channel #datathon2022

### I missed the kickoff event. Can I still participate?

If you weren't able to attend our Kick-off Meetup, here's how to get involved:

1. Watch the kickoff event and take a look at the slides introducing the project
2. Take a look at the github repo and read the readme
3. If you don’t already have one, create a [github account](https://github.com/join) (see our [github workflow recommendations](https://docs.google.com/document/d/1vF7uWo2ITXcifyNoLd8ZTJdNPx0Pd4eXXrdkKVfbAkY/edit?usp=sharing)).
4. If you haven’t already, install [R](https://www.r-project.org/) and [R-Studio](https://www.rstudio.com/products/rstudio/download/#download) on your computer.
5. If you haven’t already, join the [R-Ladies Philly slack](https://join.slack.com/t/rladies-philly/shared_invite/zt-92p8xec5-XOHRmHtmhYQRaVqmrshCcA).
    + In the R-Ladies Philly slack, join the **#datathon2022** channel (to join channels in slack, click on the *channels* title in the left side bar).
6. Add your details under the team you want to join in [this google doc](https://docs.google.com/document/d/17n4l_eEuVHglAAJQv4S1kJxZgyyeZCx4IVMIPFF9aJA/edit?usp=sharing). Don't worry about group size; the more the merrier!
7. Join your team’s specific slack channel (listed in the google doc above) and introduce yourself to your team members! :smiley: Share your ideas or ask how you can get started.

If you have any questions don't hesitate to get in touch. Send a message in the **#datathon2022* slack channel.

### How do I contact a team?

- Participants will add their names, RLadies Philly Slack IDs and GitHub IDs to [this list](https://docs.google.com/document/d/17n4l_eEuVHglAAJQv4S1kJxZgyyeZCx4IVMIPFF9aJA/edit?usp=sharing) (new rows can be added), according to the team they are in. Once you join the RLadies Philly slack channel, you can reach out to any of these members directly, or join the #datathon2022 channel and address all participants.  

