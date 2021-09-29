# Analysis
library(tidyverse)
library(gt)
library(emoji)
library(webshot)

#' Extra Innings Rate is almost half of what it was
#' under affiliated ball

#################### Extra Innings Rate ####################  

pioneer_data %>% 
  group_by(extras_rule) %>% 
    summarize(pextra = sum(extras) / n(),
              extra = sum(extras),
              pnormal = sum(!extras) / n(),
              normal = sum(!extras)) %>% 
  ungroup() %>%  
  gt() %>% 
  fmt_percent(columns = c(pextra, pnormal)) %>%
  cols_label(extras_rule = "Extras Rule",
             pextra = "% of Games with Extras",
             extra = "# of Games with Extras",
             pnormal = "% of Games without Extras",
             normal = "# of Games without Extras") %>%
  cols_align(
    align = "center"
  ) %>% 
  tab_header(
    title = md("**Extra Innings Rates in the Pioneer League**"),
    subtitle = "Data from MLB API and Pointstreak") %>% 
  tab_source_note(source_note = "Games from 2016 - 2021\nExcluding 9/11/2021 Boise vs Ogden Playoff Game")
# %>%
#   gtsave("Extra Innings Rate.png")

#################### Mean and SD Chart ####################  

checkmark <-  emoji::emojis %>% 
  filter(name == "check mark button") %>% 
  pull(emoji)

x_emoji <- emoji::emojis %>% 
  filter(name == "cross mark button") %>% 
  pull(emoji)

pioneer_summary_complete %>% 
  mutate(extras = case_when(extras ~ checkmark,
                           !extras ~ x_emoji)) %>% 
  gt() %>% 
  cols_align(
    align = "center"
  ) %>% 
  cols_label(extras_rule = "Extras Rule",
             extras = "Extras Occured?",
             mu_scaled = "Mean Game Scaled Minutes",
             sd_scaled = "SD Game Scaled Minutes",
             count_scaled = "Number of Games",
             mu_9 = "Mean Game Minutes for 9 Inning Games",
             sd_9 = "SD Game Minutes for 9 Inning Games",
             count_9 = "Number of 9 Inning Games")  %>% 
  tab_header(
    title = md("**Game Lengths in the Pioneer League**"),
    subtitle = "Viz by Billy Fryer (@_b4billy_) | Data from MLB API and Pointstreak") %>% 
  tab_source_note(source_note = "* For Games Scheduled to be < 9 Innings, Minutes Scaled = 9 / Number of Innings Scheduled * Actual Game Length in Minutes") 
# %>% 
#   gtsave("Mean and SD Chart.png")

#################### ANOVA Analysis  ####################
# Normal Model
rule <- "Normal Extra Innings"
normal_model <- lm(scaled_min ~ extras,
                   data = pioneer_data %>% filter(extras_rule == "Normal Extra Innings"))
normal_anova <- anova(normal_model) # Significant Difference
normal_coefs <- coefficients(normal_model)

# Runner on second
rule <- "Runner on Second"
ros_model <- lm(scaled_min ~ extras,
  data = pioneer_data %>% filter(extras_rule == rule))
ros_anova <- anova(ros_model) # Significant Difference
ros_coefs <- coefficients(ros_model)

# Knockout Model
rule <- "Knockout Round"
knockout_model <- lm(scaled_min ~ extras,
                     data = pioneer_data %>% filter(extras_rule == "Knockout Round"))
knockout_anova <- anova(knockout_model)# NOT A SIGNIFICANT DIFFERENCE
knockout_coefs <- coefficients(knockout_model)

# Coefficient Matrix
data.frame(Rule = c("Normal Extra Innings", "Runner On Second","Knockout Round"),
           Intercept = c(normal_coefs[1], ros_coefs[1], knockout_coefs[1]),
           Extras = c(normal_coefs[2], ros_coefs[2], knockout_coefs[2]),
           ANOVAP = c(normal_anova[1,5], ros_anova[1,5], knockout_anova[1,5])) %>% 
  gt() %>% 
  tab_header(
    title = md("**Coefficient Matrix**"),
    subtitle = "Data from MLB API and Pointstreak") %>% 
  cols_align(align = "center") %>% 
  # Highlight Eddy
  tab_style(
    # Yellow Highlight
    style = list(
      cell_fill(color = "lightblue")
    ),
    # Where to Highlight
    locations = cells_body(
      columns = ANOVAP,
      rows = ANOVAP > 0.05)
  ) %>% 
  cols_label(Rule = "Extra Innings Rule",
             Intercept = "Intercept",
             Extras = "Extras Slope",
             ANOVAP = "ANOVA p-value") %>% 
  tab_source_note(source_note = "Light blue color represents statistical significance at the alpha = 0.05 significance level") 
# %>% 
#   gtsave("Coefficient Matrix.png")
  

