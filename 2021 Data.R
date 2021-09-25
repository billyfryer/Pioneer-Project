# Import Libraries
library(tidyverse)
library(lubridate)
library(rvest)

############################################################
### Get gameids from webpage
############################################################
tictoc::tic()
# From Season File

# Regular Season seasonid = 33071
# Playoff Season seasonid = 33247

get_gameids_2021 <- function(seasonid = 33073) {
  url <- paste0("http://baseball.pointstreak.com/textstats/menu_games.html?seasonid=", seasonid)
  
  #' All of these functions are from the rvest package
  #' I'm not really sure how they work, or how I got them to work,
  #' but they work. To see the html code for a website, press:
  #' ctrl + shift + i.
  #' 
  #' I kinda looked for familiar things and it worked,
  #' then found the html_attr("href") on stack overflow
  part1 <- url %>% 
    read_html() %>% 
    html_elements("td") %>% 
    html_element("a") %>% 
    # Pulls Attribute from href
    html_attr("href")
  
  gameids <- grep("http", # What to find
                  part1, # Where to find it
                  value = TRUE) %>% # I want the actual values, not the indices
    str_split(pattern = "gameid=") %>% # split based on gameid
    map_chr(~.x[2]) %>% # take only the 2nd element of each vector
    as.numeric() # convert to numeric
  
  return(gameids)
}

############################################################
### Function for Pulling Game Data
############################################################

pull_pioneer_2021 <- function(gameid) {
  
  # gameid = 567571
  
  # Print gameid for progress check
  print(paste("Game ID:", gameid))
  
  ##############################################
  ### Reading In Raw Text File from Internet
  ##############################################

  # URL w/o game_id
  url_short <- "http://pointstreak.com/baseball/boxscoretext.html?gameid="
  
  # Attach gameid
  url <- paste0(url_short, gameid)
  
  # Read the URL as one long String
  data <- read_file(url)
  
  # Split by newline characters
  split_data <- str_split(data, pattern = "\n") %>% 
    unlist()
  
  #' This line was used when I was trying to debug the function
  #' It just makes split_data into a df in order to 
  #' make viewing easier
  split_data_view <- data.frame(split_data)
  
  ##############################################
  ### Pulling Reference Data
  ##############################################

  # Getting the Date of the Game by splitting and then use
  # lubridate package to make date look ok
  date <- unlist(str_split(split_data[1], pattern = ": "))[2] %>% 
    mdy() %>% 
    as.character
  
  # Create Playoff Variable because the Playoffs didn't use
  # The Knockout rule, so these count as "Normal Games"
  playoffs <- ifelse(date >= "2021-09-11", TRUE, FALSE)
  
  # Get Away Team and Score as a vector
  away <- unlist(str_split(split_data[2], pattern = "AT"))[1] %>% 
    # Get rid of leading and trailing white space
    str_trim() %>% 
    # Split into a vector with 2 parts
    str_split(pattern = "  ", n = 2, simplify = TRUE)
  
  # Separate Team Name and Score
  away_team <- away[1]
  away_score <- away[2] %>% as.numeric
  # Clean up environment
  rm(away)
  
  # Get Home Team and Score as a vector
  home <- unlist(str_split(split_data[2], pattern = "AT"))[2] %>% 
    str_trim() %>% 
    str_split(pattern = "  ", n = 2, simplify = TRUE)
  
  # Separate Team Name and Score
  home_team <- home[1]
  home_score <- home[2] %>% 
    substr(start = 1,
           stop = 1) %>% 
    as.numeric()
  # Clean up environment
  rm(home)
  
  ##############################################
  ### Getting Game Time Length
  ##############################################
  
  # Select Column that starts with "T--"
  time_index <- split_data %>% 
    str_detect(pattern = "T--") %>% 
    # Get indices
    which(TRUE)
  
  # Break at the Period
  time_vector <- str_split(split_data[time_index],
                           pattern = ". ",
                           simplify = TRUE)
  
  # Convert time from hh:mm to c(hour,min)
  time_string <- time_vector[1] %>% 
    # str_trim() %>% 
    # str_split(pattern = "", 
    #           n = 2,
    #           simplify = TRUE) %>% 
    substring(4) %>% 
    str_split(pattern = ":", simplify = TRUE) %>% 
    as.numeric()

  # Get a variable that has game time in minutes
  time_min <- 60 * time_string[1] + time_string[2]
  
  if(is.na(time_string[1])) {time_min = NA}
  
  # Knockout?
  extras <- ifelse(away_score == home_score & !playoffs, TRUE, FALSE)
  
  ##############################################
  ### Figure Out Number of Innings in Game
  ##############################################
  #' The boxscore is always the two rows after the
  #' second blank row.
  #' 
  #' The way that I should try to figure it out, is the number
  #' of digits before the "-" which would represent extras.
  
  str_lengths <- split_data %>% 
    str_trim() %>%  # Get of Extra White Space
    str_length() # Convert to lengths

  #' We want the line of text AFTER the 2nd blank
  #' 2nd blank line is given by index
  #' + 1 to represent the index of the line after
  inning_index <- which(str_lengths == 0)[2] + 1
  
  boxscore_vector <- split_data[inning_index] %>%
                        # Get rid of extra whitespace
                        str_squish() %>% 
                        # convert to a vector
                        str_split(pattern = " ") %>% 
                        unlist()
  
  # Find the Dash then count how many elements are before it
  # subtract 2 for the team name and the "-" value itself
  innings_played <- boxscore_vector %>% 
    str_detect(pattern = "-") %>% 
    which(TRUE) - 2
  
  # There's like 1 case where innings_played > 9, so I need to fix that
  # However, the playoffs actually are extra inning games,
  # So that's been fixed too
  innings_played <- if_else(innings_played > 9 & !playoffs, 9, innings_played)
    
  if(is_empty(innings_played)) {innings_played <- 0; extras <- NA}
  
  ##############################################
  ### Prep for Output
  ##############################################
  
  # Convert this all to a vector
  output <- data.frame(date, away_team, away_score, 
                       home_team, home_score, time_min,
                       innings_played, gameid) %>% 
    mutate(extras = case_when(home_score == away_score ~ TRUE,
                              TRUE ~ FALSE),
           Year = 2021,
           scheduledInnings = innings_played
           ) %>% 
    select(gameid, date, Year, home_team, home_score, away_team,
           away_score, scheduledInnings, innings_played, extras, time_min) %>% 
    mutate(run_diff = abs(away_score - home_score))
  
  rm(time_min, split_data, url)
  
  return(output)
}

############################################################
### Getting as much Pioneer League Data as I can
############################################################


# Regular Season Game IDs
gameidvec1 <- get_gameids_2021(seasonid = 33073) %>% sort()
# Playoff Game IDs
gameidvec2 <- get_gameids_2021(seasonid = 33247) %>% sort()

# Combine into 1 vector
gameidvec21 <- c(gameidvec1, gameidvec2)

# Clear environment
rm(gameidvec1, gameidvec2)

# Run it over all gameids
pioneer_data21 <- map_df(gameidvec21,
               pull_pioneer_2021)  %>% 
  arrange(date)

# Clear gameidvec from environment
rm(gameidvec21)
tictoc::toc()