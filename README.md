# Rule Changes Affecting Extra Inning Game Length in Pioneer Baseball League

**Abstract:**

In recent years, Major League Baseball has tried furiously to reduce the length of game as well as cut costs of operation. They began doing reducing game length in the 2018 by implementing a rule where a runner starts on second base during extra innings in all levels of Minor League Baseball. This rule was deemed a success and then implemented in MLB games. Then, for the 2021 season, Major League Baseball contracted many Minor League Baseball teams around the country to cut costs of operations. The communities that lost their affiliated team established summer collegiate baseball teams or joined already established, independent leagues such as the Atlantic League. In the Rocky Mountain Region of the US, a whole league was disbanded. Those teams decided to form an independent league under their previous name: the Pioneer League.

Following Major League Baseball, the Pioneer League announced that they also would be changing the rules for extra innings for the 2021 season. Instead of normal extra innings, the league opted for a “Knockout Round” where each team would send a player to compete in a sudden death home run derby to end the game similarly to penalty kicks in soccer. This proposes a unique question of which form of tiebreaker (normal extra innings, extra innings starting with a runner on second, or the “knockout round”) leads to a quicker conclusion of the game after a regulation 9 innings have been played. Using box score data from the Pioneer League, this paper models the total amount of game time of games that went into extra innings compared to game time of games that did not go into extra innings, broken up by which rule for extra innings is in effect.

**File Explanation:**

2019 and Prior Data.R - an adaptation of R code from Bill Petti's baseballr package that pulls relevant data from the MLB API in order for the 2016, 2017, 2018 and 2019 seasons

2021 Data.R - R code that acquires boxscore data from pointstreak.com for the Pioneer League during the 2021 season.

Data Cleaning.R - R code that combines data from all 5 seasons as well as cleans the data for analysis

Analysis.R - R code that creates first order linear regression models prediciting game length given the one hot feature of `extras` - a categorical variable that represents whether the game was completed in regulation or not

Plotting All Games.R - contains all R code needed to make all graphics and tables for this project

Pioneer Project Paper RMD.rmd - R Markdown File used to create the pdf Billy Fryer Pioneer Project Paper

Pioneer Project Paper.pdf - PDF file that contains the output of Pioneer Project Paper RMD - a complete writeup of the project and analysis

Pioneer League Project.Rproj - R Project File used for this study
