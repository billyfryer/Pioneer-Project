# Plotting Scripts
library(tidyverse)

############################################################
### Definitions and Colors
############################################################

#' Scaled_min = minutes * 9 / innings_played
#' 
#' blue color = 3 Hour Line
#' gold color = 4 hour Line
#' light_green = extra innings
#' light_purple = no extra innings
#' "red" = Knockout Round
#' "blue" = Runner on Second
#' "yellow" = Normal Extra Innings

#########################  Hex Colors #########################  
blue <- "#4169e1"
gold <- "#FFD700"
light_green <- "#AED581"
light_purple <- "#CBC3E3"

#########################  Faceting Plot #########################  
ggplot(pioneer_data, 
       aes(x = scaled_min,
           fill = extras_rule)) +
  geom_density(alpha = 0.250) +
  # 3 Hours line and label
  geom_vline(xintercept = 180,
             color = blue, # Blue
             size = 1.25) + 
  geom_label(label = "3 Hours",
             fill = blue, # Blue
             color = "white", # White text
             x = 180,
             y = .005) +
  # 4 Hours line and label
  geom_vline(xintercept = 240,
             color = gold, # Gold
             size = 1.25) + 
  geom_label(label = "4 Hours",
             fill = gold, # Gold
             x = 240,
             y = .005) +
  facet_wrap(~extras, 
             ncol = 1,
             labeller = labeller(extras = c("TRUE" = "Games that went to Extra Innings",
                                            "FALSE" = "Regulation Games Standardized to 9 Innings"))) +
  labs(title = "Pioneer League Game Length Distribution",
       subtitle = "Games From 2016 - 2021 Excluding 9/11/2021 Boise vs Ogden Playoff Game\nWhere Extra Innings Were Played Without the Knockout Rule in Effect",
       caption = "Data from MLB API via baseballR package and Pointstreak",
       x = "Game Time in Scaled Minutes",
       y = "Density",
       fill = "Extra Innings Rule") +
  scale_fill_manual(values = c("Runner on Second" = "yellow",
                               "Knockout Round" = "red",
                               "Normal Extra Innings" = "blue"
  )) +
  scale_y_continuous(labels = scales::percent_format()) +
  theme(plot.title = element_text(hjust = 0.5, 
                                  size = 16),
        plot.subtitle = element_text(hjust = 0.5,
                                     size = 8),
        plot.caption = element_text(hjust = 0.5),
        legend.text = element_text(hjust = 0.5),
        legend.title = element_text(hjust = 0.5))

# ggsave("Extra Inning Rules Distribution All Games.png",
#        width = 6.5,
#        height = 5)


######################### Faceting Violin Plot #########################
ggplot(data = pioneer_data,
       aes(x = scaled_min,
           y = extras,
           fill = extras)) +
  # 3 Hours line and label
  geom_vline(xintercept = 180,
             color = blue,
             size = 1.25) + 
  # 4 Hours line and label
  geom_vline(xintercept = 240,
             color = gold,
             size = 1.25) + 

  geom_violin(key_glyph = "polygon") +
  facet_wrap(~extras_rule,
             nrow = 1) +
  theme_dark() +
  scale_fill_manual(values = c("TRUE" = light_green,
                               "FALSE" = light_purple),
                    labels = c("Extra Innings Needed",
                               "Game Ended in Regulation")) +
  labs(title = "Pioneer League Game Length Distributions",
       subtitle = "Crossbar Represents Median Game Length in Scaled Minutes",
       caption = "Data from MLB API via baseballr package and Pointstreak",
       x = "Game Length in Minutes Standardized to 9 Innings for Regulation Games",
       y = "Extra Innings") +
  stat_summary(fun = "mean",
               geom = "crossbar",
               width = 0.5,
               color = "black",
               key_glyph = "blank") +
  theme(axis.text.y = element_blank(),
        legend.title = element_blank(),
        legend.position = "bottom",
        plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        plot.caption = element_text(hjust = 0.5))

# ggsave("Violin Faceted by Rule.jpg",
#        width = 6.6,
#        height = 5)
  
#########################  Regular Extras #########################  
ggplot(pioneer_data %>% filter(extras_rule == "Normal Extra Innings"),
       aes(x = scaled_min,
           fill = extras)) +
  geom_density(data = pioneer_data %>% filter(extras_rule == "Normal Extra Innings" & extras),
               fill = light_green) + # light green
  geom_density(data = pioneer_data %>% filter(extras_rule == "Normal Extra Innings" & !extras),
               fill = light_purple) + #light purple
  # 3 Hours line and label
  geom_vline(xintercept = 180,
             color = blue,
             size = 1.25) + 
  geom_label(label = "3 Hours",
             fill = blue,
             color = "white", # White text
             x = 180,
             y = .0025) +
  # 4 Hours line and label
  geom_vline(xintercept = 240,
             color = gold,
             size = 1.25) + 
  geom_label(label = "4 Hours",
             fill = gold,
             x = 240,
             y = .0025) +
  theme_dark() +
  labs(title = "Distribution of Pioneer League Game Lengths 2016-2017",
       subtitle = "Extra Innings Rule: Normal Extra Innings",
       x = "Total Game Time in Standardized Minutes",
       y = "Density",
       caption = "Data from MLB API via baseballr Package"
  ) +
  # Set X and Y dimensions
  xlim(100,350) +
  scale_y_continuous(labels = scales::percent_format(),
                     limits = c(0, 0.02)) +
  annotate("label",
           label ="Purple = Without Extras\nGreen = Extras",
           x = 300,
           y = 0.015) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        plot.caption = element_text(hjust = 0.5)
  )

# ggsave("Normal Extra Innings All Games.png",
#        width = 6.5,
#        height = 5
# )

#########################  Runner on Second #########################  
ggplot(pioneer_data %>% filter(extras_rule == "Runner on Second"),
       aes(x = scaled_min,
           fill = extras)) +
  geom_density(data = pioneer_data %>% filter(extras_rule == "Runner on Second" & extras),
               fill = light_green) +
  geom_density(data = pioneer_data %>% filter(extras_rule == "Runner on Second" & !extras),
               fill = light_purple) +
  # 3 Hours line and label
  geom_vline(xintercept = 180,
             color = blue, # Blue
             size = 1.25) + 
  geom_label(label = "3 Hours",
             fill = blue, # Blue
             color = "white", # White text
             x = 195,
             y = .0025) +
  # 4 Hours line and label
  geom_vline(xintercept = 240,
             color = gold, # Gold
             size = 1.25) + 
  geom_label(label = "4 Hours",
             fill = gold, # Gold
             x = 255,
             y = .0025) +
  theme_dark() +
  labs(title = "Distribution of Pioneer League Game Lengths 2018-2019",
       subtitle = "Extra Innings Rule: Runner on Second",
       x = "Total Game Time in Standardized Minutes",
       y = "Density",
       caption = "Data from MLB API via baseballr Package"  ) +
  # Set X and Y dimensions
  xlim(100,350) +
  scale_y_continuous(labels = scales::percent_format(),
                     limits = c(0, 0.02)) +
  annotate("label",
           label ="Purple = Without Extras\nGreen = Extras",
           x = 300,
           y = 0.015) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        plot.caption = element_text(hjust = 0.5)
  )

# ggsave("Runner on Second All Games.png",
#        width = 6.5,
#        height = 5
# )

#########################  Knockout Round #########################  
ggplot(pioneer_data %>% filter(extras_rule == "Knockout Round"),
       aes(x = scaled_min,
           fill = extras)) +
  geom_density(data = pioneer_data %>% filter(extras_rule == "Knockout Round" & extras),
               fill = light_green,
               color = "black",
               size = 1.25) +
  geom_density(data = pioneer_data %>% filter(extras_rule == "Knockout Round" & !extras),
               fill = light_purple,
               alpha = 0.75) +
  # 3 Hours line and label
  geom_vline(xintercept = 180,
             color = blue, # Blue
             size = 1.25) + 
  geom_label(label = "3 Hours",
             fill = blue, # Blue
             color = "white", # White text
             x = 195,
             y = .0025) +
  # 4 Hours line and label
  geom_vline(xintercept = 240,
             color = gold, # Gold
             size = 1.25) + 
  geom_label(label = "4 Hours",
             fill = gold, # Gold
             x = 255,
             y = .0025) +
  theme_dark() +
  labs(title = "Distribution of Pioneer League Game Lengths 2021",
       subtitle = "Extra Innings Rule: Knockout Round",
       x = "Total Game Time in Standardized Minutes",
       y = "Density",
       caption = "Data from Pointstreak"
  ) +
  # Set X and Y dimensions
  xlim(100,350) +
  scale_y_continuous(labels = scales::percent_format(),
                     limits = c(0, 0.02)) +
  # Color Annotation
  annotate("label",
           label ="Purple = Without Extras\nGreen = Extras",
           x = 300,
           y = 0.0155) +
  # Annotation about 9/11 Boise Ogden
  annotate("label",
           label ="Excluding 9/11/2021\nBoise vs Ogden Playoff Game\nWhere Extra Innings Were Played\nWithout the Knockout Rule in Effect",
           x = 300,
           y = 0.01) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        plot.caption = element_text(hjust = 0.5)
  )

# ggsave("Knockout Round All Games.png",
#        width = 6.5,
#        height = 5
# )
