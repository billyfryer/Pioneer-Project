# Pull Data From When the Pioneer League Was Affiliated
library(tidyverse)
# library(devtools)
# install_github("BillPetti/baseballr")
library(baseballr)

#####################################################################
### Getting Game Packs
#####################################################################
get_game_pks <- function(date, level_ids = c(16,5442)) {
  
  # Print Date For Debugging
  print(date)
  
  api_call <- paste0("http://statsapi.mlb.com/api/v1/schedule?sportId=", paste(level_ids, collapse = ','), "&date=", date)
  
  payload <- jsonlite::fromJSON(api_call, flatten = TRUE)
  
  # This Line Added in By Billy Fryer.
  # Allows for scraping of a whole calendar year without messing up
  # Due to games not being played on a certain date
  if(length(payload$dates$games) == 0) {print(paste(date, "Not Availible")); return()}
  
  payload <- payload$dates$games %>%
    as.data.frame() %>%
    rename(game_pk = gamePk)
  
  # Throw error when scores aren't availible,
  # This would be triggered for postponements of all games on a date
  if(is.null(payload$teams.away.score)) {print(paste(date, "Not Availible")); return()}
  
  payload <- payload %>% 
    # Only Selected Columns
    select(officialDate, teams.away.team.name, teams.away.score,
           teams.home.team.name, teams.home.score, game_pk, scheduledInnings) %>% 
    # Rename some columns
    dplyr::rename("date" = "officialDate",
                  "away_team" = "teams.away.team.name",
                  "away_score" = "teams.away.score",
                  "home_team" = "teams.home.team.name",
                  "home_score" = "teams.home.score",
                  "gameid" = "game_pk") %>% 
    mutate(playoffs = FALSE)
  
  return(payload)
}

#####################################################################
### Getting Game Time
#####################################################################
get_game_time <- function(game_pk) {
  
  print(paste("Game ID:", game_pk, "Game Time"))
  
  api_call <- paste0("http://statsapi.mlb.com/api/v1.1/game/", game_pk,"/feed/live")
  
  payload <- jsonlite::fromJSON(api_call)
  
  game_time <- payload$liveData$boxscore$info %>%
    as.data.frame() %>% 
    pivot_wider(names_from = "label",
                values_from = "value")

  
  ################################################################
  ### My adaptation
  ################################################################
  
  # Check for T column.
  if("T" %in% names(game_time) ) {
    # If it exists, pull that value
    game_time <- game_time %>% pull(T)
  } else {
    # Otherwise return an NA
    return(NA)
  }
  
  time_vec <- game_time %>%
    str_split(pattern = ":", simplify = TRUE) %>% 
    as.numeric()
  
  time_in_min <- 60 * time_vec[1] + time_vec[2]
  
  return(time_in_min)
}

#####################################################################
### Getting Number of Innings Actually Played
#####################################################################
get_num_innings_played <- function(game_pk) {
  
  # Debugging
  print(paste("Game ID:", game_pk, "Number of Innings"))
  
  # Scrape the Data From the API
  api_call <- paste0("http://statsapi.mlb.com/api/v1.1/game/", game_pk, "/feed/live")
  payload <- jsonlite::fromJSON(api_call, flatten = TRUE)
  
  if(length(payload$liveData$plays$allPlays) == 0) {return(NA)}
  
  num_innings <- payload$liveData$plays$allPlays %>% 
    select(about.inning) %>% 
    max()
  
  return(num_innings)
}

# This moves fast enough for me to be ok with it...

# Vector of all pioneer teams for 2019
pioneer_teams <- c("Great Falls Voyagers",
                   "Billings Mustangs",
                   "Rocky Mountain Vibes",
                   "Idaho Falls Chukars",
                   "Grand Junction Rockies",
                   "Ogden Raptors",
                   "Boise Hawks",
                   "Missoula Osprey",
                   "Helena Brewers",
                   "Missoula Osprey",
                   "Orem Owls")

#####################################################################
### Putting All of These Functions Together 
#####################################################################
pull_affiliated_data <- function(year) {

# Get Teams, Scores, Scheduled Innings for 2019 Calendar Year
start_date <- paste0(year, '-01-01') %>% as.Date
end_date <- paste0(year, '-12-31') %>% as.Date

pioneer_data <- map_df(.x = seq.Date(start_date, 
                                       end_date, 
                                       'day'),
                           .f = get_game_pks,
                           level_ids = c(16,5442)) %>% 
  # Only Pioneer League Teams
  filter(home_team %in% pioneer_teams)

# Get Game Times
pioneer_data$time_min <- map_dbl(.x = pioneer_data$gameid,
                                      .f = get_game_time)

# Get Innings Played
pioneer_data$innings_played <- map_dbl(.x = pioneer_data$gameid,
                                            .f = get_num_innings_played)

# Mutate On Year and extras columns, then order columns
pioneer_data <- pioneer_data %>% 
  mutate(Year = year,
         extras = case_when(scheduledInnings == innings_played ~ FALSE,
                            TRUE ~ TRUE),
         run_diff = abs(away_score - home_score)) %>% 
  select(gameid, date, Year, home_team, home_score, away_team,
         away_score, scheduledInnings, innings_played, extras, time_min, run_diff)

return(pioneer_data)
}


#####################################################################
### Pulling Years 2016-2019
#####################################################################
tictoc::tic()
pioneer_data19 <- pull_affiliated_data(2019)
tictoc::toc()

# Around 6.5 Minutes
tictoc::tic()
pioneer_data18 <- pull_affiliated_data(2018)
tictoc::toc()

# Around 6.5 Minutes
tictoc::tic()
pioneer_data17 <- pull_affiliated_data(2017)
tictoc::toc()

# Around 6.5 Minutes
tictoc::tic()
pioneer_data16 <- pull_affiliated_data(2016)
tictoc::toc()

