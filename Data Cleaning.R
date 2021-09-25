library(tidyverse)
library(lubridate)

# Scaled_min = minutes * 9 / innings_played


# Combine all pioneer data into 1 df
pioneer_data <- rbind(pioneer_data16,
                      pioneer_data17,
                      pioneer_data18,
                      pioneer_data19,
                      pioneer_data21) %>% 
  mutate(extras_rule = case_when(Year %in% c(2018,2019) ~ "Runner on Second",
                                 Year == 2021 ~ "Knockout Round",
                                 TRUE ~ "Normal Extra Innings"),
         scaled_min = case_when(
           scheduledInnings != 9 ~ time_min * 9 / scheduledInnings,
           TRUE ~ time_min
         ), # end of scaled_min case_when
         close_game = case_when(
           run_diff <= 4 ~ TRUE,
           extras ~ TRUE,
           TRUE ~ FALSE
         ),         # End of close_game case_when
         date = ymd(date)
  )  %>% # end of mutate
  arrange(date) %>% 
  # Get Rid of 12 Inning Playoff Game in 2021
  filter(gameid != 567571)

# Make extras_rule a factor
pioneer_data$extras_rule <- factor(pioneer_data$extras_rule,
                                   levels = c("Normal Extra Innings",
                                              "Runner on Second",
                                              "Knockout Round")
)


#######################################################
### Get Summary Data
#######################################################

# Scaled minutes but all records
pioneer_summary <- pioneer_data %>% 
  group_by(extras_rule, extras) %>% 
  summarize(
    mu_scaled = mean(scaled_min, na.rm = TRUE),
    sd_scaled = sd(scaled_min, na.rm = TRUE),
    count_scaled = n()
  ) %>% 
  ungroup() %>% 
  arrange(extras_rule, extras)

