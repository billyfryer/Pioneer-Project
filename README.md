# Rule Changes Affecting Extra Inning Game Length in Pioneer Baseball League

**Abstract:**

In recent years, Major League Baseball has tried to reduce the length of games as well as cut costs of
operation. They began attempting to reduce game time in 2018 by implementing a rule in all levels of
Minor League Baseball that during extra innings there will be a runner starting on second base. This rule
was deemed a success and was then implemented in MLB games. Then, for the 2021 season, Major League
Baseball contracted many Minor League Baseball teams around the country to cut costs of player salaries.
Many communities that lost their affiliated team established summer collegiate baseball teams or joined
already established independent leagues such as the Atlantic League. In the Rocky Mountain Region of the
US, one league was completely disbanded. Those teams decided to form an independent league under their
previous name: the Pioneer League.

Following the lead of Major League Baseball, the Pioneer Baseball League announced that they too would
change the rules for extra innings for the 2021 season in an attempt to reduce game length. Instead of
traditional baseball extra innings, the league opted for a “Knockout Round” where each team would send
a player to compete in a sudden death homerun derby, effectively ending the game in a similar fashion to
penalty kicks in soccer. This proposes a unique question of which form of tiebreaker (normal extra innings,
extra innings starting with a runner on second, and this Knockout Round) leads to a quicker conclusion of
the game after a regulation 9 innings was played. Using box score data from the Pioneer Baseball League,
this paper models the total amount of game time of games that went into extra innings compared to the
game time of games that did not go into extra innings, broken up by the rule in place for extra innings.

**Awards and Presentations:**
This project won Honorable Mention at the 2021 UConn Sports Analytics Symposium Poster Session and was also presented at the NC State Sidewalk Symposium.

**File Explanation:**

2019 and Prior Data.R - An adaptation of R code from Bill Petti's baseballr package that pulls relevant data from the MLB API in order for the 2016-2019 seasons.

2021 Data.R - R script that acquires boxscore data from pointstreak.com for the Pioneer League during the 2021 season.

Data Cleaning.R - R script that combines data from all 5 seasons as well as cleans the data for analysis.

Analysis.R - R code that creates first order linear regression models prediciting game length given the indicator variable of `extras` - a categorical variable that represents whether the game was completed in regulation or not. All tables in the paper were also created in this script.

Plotting All Games.R - R script that contains all R code needed to make all graphics for this project.

Pioneer Project Paper RMD.rmd - An R Markdown File used to create Pioneer Project Paper.pdf.

Pioneer Project Paper.pdf - A PDF file that contains the output of Pioneer Project Paper RMD - a complete writeup of the project and analysis.

Pioneer League Project.Rproj - The R Project File used for this study.

UCSAS Slides.ppt - Powerpoint used for presenting at the UCONN Sports Analytics Sympoisum

Plots Folder - A folder that contains all graphics and tables for this project in eith .png or .jpg form.

Last Updated on 10/5/2021
