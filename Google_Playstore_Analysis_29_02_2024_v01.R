#Google Playstore Data Analysis
#----------------------------------------------------------------------------------------------------------------------------#
#-------------------------------------------------PREPARE--------------------------------------------------------------------#
#----------------------------------------------------------------------------------------------------------------------------#
# INSTALLING PACKAGES
#----------------------------------------------------------------------------------------------------------------------------#
install.packages("tidyverse")
install.packages("janitor")
install.packages("extrafont")
install.packages("shadowtext")
#----------------------------------------------------------------------------------------------------------------------------#
# LOADING LIBRARIES
#----------------------------------------------------------------------------------------------------------------------------#
library(tidyverse)
library(janitor)
library(extrafont)
library(shadowtext)
#----------------------------------------------------------------------------------------------------------------------------#
# IMPORTING DATASET
#----------------------------------------------------------------------------------------------------------------------------#
#importing dataset
applist <-
  read_csv("F:/Data Analytics/Case Studies/Google Playstore/Datasets/googleplaystore.csv")

#----------------------------------------------------------------------------------------------------------------------------#
#-------------------------------------------------CLEANING-------------------------------------------------------------------#
#----------------------------------------------------------------------------------------------------------------------------#
# CHECKING DATASET STRUCTURE AND CLEANING COLUMN NAMES
#----------------------------------------------------------------------------------------------------------------------------#
# checking structure of the dataset
str(applist)

#checking column names
colnames(applist)

#cleaning column names
playstore <-
  clean_names(applist)

#checking column names
colnames(playstore)

#----------------------------------------------------------------------------------------------------------------------------#
# CHECKING AND REMOVING DUPLICATES
#----------------------------------------------------------------------------------------------------------------------------#
# checking for duplicates
a <- sum(duplicated(playstore[,1:2]))

# removing duplicates
playstore <- playstore %>% filter(!duplicated(playstore[,1:2]))

#----------------------------------------------------------------------------------------------------------------------------#
# CLEANING VALUES IN THE CATEGORY COLUMN
#----------------------------------------------------------------------------------------------------------------------------#
# checking values in category column
head(playstore %>%
             distinct(category))

#Transforming Category Values
playstore <-
  playstore %>% 
  mutate(category = str_to_title(str_replace_all(category, "_", " ")))

#----------------------------------------------------------------------------------------------------------------------------#
# REMOVING STRANGE ROWS
#----------------------------------------------------------------------------------------------------------------------------#
# checking values in the category column
head(playstore %>% 
             distinct(category) %>% 
             arrange(category))

#checking rows in category "1.9"
playstore %>%
        filter(category == 1.9)

#Deleting rows in category "1.9"
playstore <-
  playstore %>%
  filter(category != 1.9)

#----------------------------------------------------------------------------------------------------------------------------#
# TRANSFORMING DATA TYPE FROM THE installs COLUMN
#----------------------------------------------------------------------------------------------------------------------------#
#cleaning installs column
playstore <-
  playstore %>% 
  mutate(installs = case_when(installs == "Free" ~ NA, .default = installs),
         installs = str_sub(installs, start = 1L, end = -2L),
         installs = as.numeric(str_replace_all(installs, ",", "")))

#----------------------------------------------------------------------------------------------------------------------------#
# TRANSFORMING DATA TYPE FROM THE size COLUMN
#----------------------------------------------------------------------------------------------------------------------------#
# cleaning the size column
# transforming from string to numeric data type
playstore <-
  playstore %>% 
  mutate(multiplier = case_when(size == "Varies with device" ~ NA,
                                str_detect(size, "M") ~ 1,
                                str_detect(size, "k") ~ 0.001),
         size = case_when(size == "Varies with device" ~NA,
                          str_detect(size, "M") ~ str_replace(size, "M", ""),
                          str_detect(size, "k") ~ str_replace(size, "k", "")),
         size = as.numeric(size) * multiplier) %>%
  select(!multiplier)

#----------------------------------------------------------------------------------------------------------------------------#
# TRANSFORMING DATA TYPE FROM THE price COLUMN
#----------------------------------------------------------------------------------------------------------------------------#
# cleaning the price column
playstore <-
  playstore %>% 
  mutate(price = as.numeric(str_sub(price, start = 2L))) %>%    # transforming from string to numeric data type
  replace_na(list(price = 0))

#----------------------------------------------------------------------------------------------------------------------------#
# TRANSFORMING DATA TYPE FROM THE last_updated COLUMN
#----------------------------------------------------------------------------------------------------------------------------#
# cleaning the last_updated column
playstore <- 
  playstore %>% 
  mutate(last_updated = mdy(last_updated)) # transforming  from string into date data type

#----------------------------------------------------------------------------------------------------------------------------#
#----------------------------------------------------- ANALYSIS -------------------------------------------------------------#
#----------------------------------------------------------------------------------------------------------------------------#
# POPULAR CATEGORY BY REVIEWS
#----------------------------------------------------------------------------------------------------------------------------#
#Highest reviews of category
highestreviews <- 
  playstore %>% 
  group_by(category) %>% 
  summarise(totalreviews = sum(reviews, na.rm = TRUE)) %>%
  arrange(desc(totalreviews)) %>% 
  
  #codes below is for visualization purpose
  mutate(app = sample(1:2, 33, replace = TRUE),               
         no = c(1:33),
         category = str_to_upper(category)) 

#----------------------------------------------------------------------------------------------------------------------------#
# POPULAR CATEGORY BY TOTAL INSTALL
#----------------------------------------------------------------------------------------------------------------------------#
#Highest total install of category
highesttotalinstall <- 
  playstore %>% 
  group_by(category) %>% 
  summarise(totalinstalls = sum(installs, na.rm = TRUE)) %>%
  arrange(desc(totalinstalls)) %>%
  
  
  #codes below is for visualization purpose
  mutate(app = sample(1:2, 33, replace = TRUE), 
         no = c(1:33),
         category = str_to_upper(category))

#----------------------------------------------------------------------------------------------------------------------------#
# POPULAR CATEGORY BY AVERAGE INSTALL
#----------------------------------------------------------------------------------------------------------------------------#
#Highest average install of category
highestaverageinstall <- 
  playstore %>% 
  group_by(category) %>% 
  summarise(averageinstalls = mean(installs, na.rm = TRUE)) %>%
  arrange(desc(averageinstalls)) %>% 
  
  #codes below is for visualization purpose
  mutate(app = sample(1:2, 33, replace = TRUE),               
         no = c(1:33),
         category = str_to_upper(category))

#----------------------------------------------------------------------------------------------------------------------------#
# TOTAL APPS LISTED PER CATEGORY
#----------------------------------------------------------------------------------------------------------------------------#
#Total App Per Category
totalapp <-
  playstore %>% 
  group_by(category) %>%
  summarise(totalapp = n()) %>% 
  arrange(desc(totalapp))

#----------------------------------------------------------------------------------------------------------------------------#
# PAYMENT TYPE BY TOTAL APPS AND AVERAGE INSTALLS
#----------------------------------------------------------------------------------------------------------------------------#
#creating summarise table
paymenttype <- 
  playstore %>%
  filter(type != "NaN") %>%
  group_by(type) %>%
  summarise(totalapp = n(),
            averageinstalls = mean(installs)) %>%
  arrange(desc(totalapp))

#----------------------------------------------------------------------------------------------------------------------------#
# POPULATION OF APP BASED ON CONTENT RATING
#----------------------------------------------------------------------------------------------------------------------------#
#creating summarise table
appcontentrating <-
  playstore %>%
  group_by(content_rating) %>%
  summarise(totalapp = n()) %>%
  arrange(desc(totalapp))

#----------------------------------------------------------------------------------------------------------------------------#
# SUMMARIZING TOP 5 CATEGORIES
#----------------------------------------------------------------------------------------------------------------------------#
#Summarizing Top five Categories
sumfivecat <-
  playstore %>% filter(category == "Game" |
                         category == "Communication" |
                         category == "Family" |
                         category == "Social" |
                         category == "Video Players") %>%
  group_by(category, content_rating) %>%
  summarise(totalapp = n(), 
            totalinstalls = sum(installs, na.rm = TRUE),
            .groups = "drop")

#----------------------------------------------------------------------------------------------------------------------------#
# RATING DISTRIBUTION
#----------------------------------------------------------------------------------------------------------------------------#
#creating rating distribution table
ratingdistribution <-
  playstore %>%
  filter(!is.nan(rating)) %>%
  group_by(rating) %>%
  summarise(totalapp = n()) %>%
  pivot_wider(names_from = "rating",
              values_from = "totalapp")

#----------------------------------------------------------------------------------------------------------------------------#
# SIZE DISTRIBUTION
#----------------------------------------------------------------------------------------------------------------------------#
#creating size distribution table
sizedistribution <-
  playstore %>%
  filter(!is.na(size)) %>%
  group_by(size) %>%
  summarise(totalapp = n()) %>%
  pivot_wider(names_from = "size",
              values_from = "totalapp")

#----------------------------------------------------------------------------------------------------------------------------#
# LAST UPDATED DISTRIBUTION
#----------------------------------------------------------------------------------------------------------------------------#
#creating last updated distribution table
lastupdateddistribution <-
  playstore  %>%
  group_by(last_updated) %>%
  summarise(totalapp = n()) %>%
  pivot_wider(names_from = "last_updated",
              values_from = "totalapp")

#----------------------------------------------------------------------------------------------------------------------------#
# TOP GENRES IN TOP FIVE CATEGORIES
#----------------------------------------------------------------------------------------------------------------------------#
#Fetching Top Genres from The Five Popular Categories based on reviews and total installs
topgenres <-
  playstore %>%
  group_by(category, genres) %>%
  summarise(reviews = sum(reviews), total = n()) %>%
  arrange(desc(reviews), desc(total))
#Filtering by Game category
topgenregame <- 
  topgenres %>%
  filter(category == "Game") %>% 
  slice_head(n=1)
#Filtering by Communication category
topgenrecommunication <- 
  topgenres %>%
  filter(category == "Communication") %>% 
  slice_head(n=1)
#Filtering by Social category
topgenresocial <- 
  topgenres %>%
  filter(category == "Social") %>% 
  slice_head(n=1)
#Filtering by Video Players category
topgenrevideoplayers <- 
  topgenres %>%
  filter(category == "Video Players") %>% 
  slice_head(n=1)
#Filtering by Family category
topgenrefamily <-
  topgenres %>%
  filter(category == "Family") %>% 
  slice_head(n=1)
#Joining all the tables
topgenres <-
  topgenregame  %>%
  union_all(topgenrecommunication) %>%
  union_all(topgenresocial) %>%
  union_all(topgenrevideoplayers) %>%
  union_all(topgenrefamily)

#----------------------------------------------------------------------------------------------------------------------------#
# LISTING TOP 10 APPS BASED ON THE TOP GENRES
#----------------------------------------------------------------------------------------------------------------------------#
#Listing Top 10 Apps based on reviews and total install
topapp <-
  playstore %>%
  group_by(genres, app) %>%
  summarise(reviews = sum(reviews), total = n(), price = sum(price)) %>%
  arrange(desc(reviews), desc(total))
#Listing Top 10 Apps based on genres
#Filtering by action genre
topgame <- 
  topapp %>%
  filter(genres == "Action") %>% 
  slice_head(n=10)
#Filtering by communication genre
topcommunication <- 
  topapp %>%
  filter(genres == "Communication") %>% 
  slice_head(n=10)
#Filtering by social genre
topsocial <- 
  topapp %>%
  filter(genres == "Social") %>% 
  slice_head(n=10)
#Filtering by video players and editors genre
topvideoplayers <- 
  topapp %>%
  filter(genres == "Video Players & Editors") %>% 
  slice_head(n=10)
#Filtering by casual genre
topcasual <-
  topapp %>%
  filter(genres == "Casual") %>% 
  slice_head(n=10)
#Joining all the top 10 apps in 5 popular genres
top <-
  topgame  %>%
  union_all(topcommunication) %>%
  union_all(topsocial) %>%
  union_all(topvideoplayers) %>%
  union_all(topcasual) 
#mutating column "no" for visualization
topgenreapp <-
  top %>%
  mutate(no = rep(1:10, 1)) %>%
  select(no, app, genres)

#----------------------------------------------------------------------------------------------------------------------------#
# PAYMENT TYPE OF EACH TOP GENRE
#----------------------------------------------------------------------------------------------------------------------------#
#creating a new payment type column
toppricesapp <-
  top %>%
  mutate(type = case_when(price == 0 ~ "Free",
                          .default = "Paid")) %>%
  select(app, type)

#----------------------------------------------------------------------------------------------------------------------------#
#--------------------------------------------------- VISUALIZATIONS ---------------------------------------------------------#
#----------------------------------------------------------------------------------------------------------------------------#
# POPULAR CATEGORIES BY TOTAL REVIEWS
#----------------------------------------------------------------------------------------------------------------------------#
#Popular Category By Total Reviews
library(shadowtext)
highestreviews  %>%  
  mutate(app = sample(1:2, 33, replace = TRUE), 
         no = c(1:33),
         category = str_to_upper(category)) %>%
  ggplot(aes(x = app, y = category, size = totalreviews, alpha = totalreviews, colour = category))  +
  geom_shadowtext(aes(label = category), bg.colour = "white", show.legend = FALSE, position = position_jitterdodge()) +
  scale_size(range = c(0, 15)) +
  scale_alpha(range = c(-0.3, 1)) +
  theme_minimal() +
  xlab(NULL) +
  ylab(NULL) +
  xlim(-2,5) +
  theme(text = element_text(family = "Lato"),
        axis.text = element_blank(),
        panel.grid = element_blank()) +
  scale_color_manual(values = c("#ea4335", "#4285f4", "#fbbc05"),
                     limits = c(highestreviews$category[highestreviews$no <= 3]))

#----------------------------------------------------------------------------------------------------------------------------#
# POPULAR CATEGORY BY TOTAL INSTALL
#----------------------------------------------------------------------------------------------------------------------------#
#Popular Category by Total Install
highesttotalinstall %>%  
  mutate(app = sample(1:2, 33, replace = TRUE), 
         no = c(1:33),
         category = str_to_upper(category)) %>%
  ggplot(aes(x = app, y = category, size = totalinstalls, alpha = totalinstalls, colour = category))  +
  geom_shadowtext(aes(label = category), bg.colour = "white", show.legend = FALSE, position = position_jitterdodge()) +
  scale_size(range = c(0, 15)) +
  scale_alpha(range = c(-0.3, 1)) +
  theme_minimal() +
  xlab(NULL) +
  ylab(NULL) +
  xlim(-2,5) +
  theme(
    text = element_text(family = "Lato"),
    axis.text = element_blank(),
    panel.grid = element_blank()
  ) +
  scale_color_manual(values = c("#ea4335", "#4285f4", "#fbbc05"),
                     limits = c(highesttotalinstall$category[highesttotalinstall$no <= 3]))

#----------------------------------------------------------------------------------------------------------------------------#
# POPULAR CATEGORY BY AVERAGE INSTALLS
#----------------------------------------------------------------------------------------------------------------------------#
#Popular Category By Average Install
highestaverageinstall  %>%  
  mutate(app = sample(1:2, 33, replace = TRUE), 
         no = c(1:33),
         category = str_to_upper(category)) %>%
  ggplot(aes(x = app, y = category, size = averageinstalls, alpha = averageinstalls, colour = category))  +
  geom_shadowtext(aes(label = category), bg.colour = "white", show.legend = FALSE, position = position_jitterdodge()) +
  scale_size(range = c(0, 15)) +
  scale_alpha(range = c(-0.3, 1)) +
  theme_minimal() +
  xlab(NULL) +
  ylab(NULL) +
  xlim(-2,5) +
  theme(text = element_text(family = "Lato"),
        axis.text = element_blank(),
        panel.grid = element_blank()) +
  scale_color_manual(values = c("#ea4335", "#4285f4", "#fbbc05"),
                     limits = c(highestaverageinstall$category[highestaverageinstall$no <= 3]))

#----------------------------------------------------------------------------------------------------------------------------#
# TOTAL APPS LISTED BAR CHART
#----------------------------------------------------------------------------------------------------------------------------#
#Total app
totalapp %>% slice(1:10) %>%
  ggplot(aes(x = totalapp, y = reorder(category, totalapp), fill = category)) +
  geom_col(show.legend = FALSE) +
  theme_minimal() +
  theme(text = element_text(family = "Lato")) +
  labs(title = "10 Highest Total Apps Listed",
       subtitle = "Based On Category") +
  xlab(NULL) +
  ylab(NULL) + 
  scale_fill_manual(values = c("#4285f4", "#ea4335", "#fbbc05", "#4285f4", "#4285f4",
                               "#34a853", "#fbbc05", "#34a853", "#ea4335", "#34a853", 
                               "#4285f4", "#ea4335", "#fbbc05", "#4285f4", "#fbbc05",
                               "#fbbc05", "#4285f4", "#fbbc05", "#4285f4", "#34a853",
                               "#4285f4", "#fbbc05", "#4285f4", "#ea4335", "#34a853",
                               "#34a853", "#ea4335", "#fbbc05", "#4285f4", "#4285f4",
                               "#ea4335", "#ea4335", "#34a853"))

#----------------------------------------------------------------------------------------------------------------------------#
# PAYMENT TYPE BAR CHART
#----------------------------------------------------------------------------------------------------------------------------#
#Total Apps Based On Payment Type
paymenttype %>%
  ggplot(aes(x = type, 
             y = totalapp, 
             fill = type)) + 
  geom_col(show.legend = FALSE, na.rm = TRUE) +
  theme_minimal() +
  theme(text = element_text(family = "Lato"), 
        axis.text.y = element_blank(),
        axis.title = element_blank(),
        panel.background = element_blank(),
        panel.grid = element_blank())+
  scale_fill_manual(values = c("#4285f4", "#ea4335")) 

#Average Installs Based On Payment Type
paymenttype %>%
  ggplot(aes(x = type, 
             y = averageinstalls, 
             fill = type)) + 
  geom_col(show.legend = FALSE, na.rm = TRUE) +
  theme_minimal() +
  theme(text = element_text(family = "Lato"), 
        axis.text.y = element_blank(),
        axis.title = element_blank(),
        panel.background = element_blank(),
        panel.grid = element_blank())+
  scale_fill_manual(values = c("#4285f4", "#ea4335")) 

#----------------------------------------------------------------------------------------------------------------------------#
# APP POPULATION BASED ON CONTENT RATING
#----------------------------------------------------------------------------------------------------------------------------#
#App population based on content rating
playstore %>% 
  ggplot(aes(x = content_rating, 
             y = app, 
             color = content_rating, 
             size = installs)) + 
  geom_jitter(show.legend = FALSE, na.rm = TRUE, alpha = 0.5) + 
  scale_size(range = c(1,3)) +
  theme_minimal() +
  theme(text = element_text(family = "Lato"), 
        axis.text.y = element_blank(),
        axis.title = element_blank(),
        panel.background = element_blank(),
        panel.grid = element_blank())+
  scale_color_manual(values = c("#4285f4", "#ea4335", "#fbbc05", "#4285f4", "#34a853", "grey")) 

#----------------------------------------------------------------------------------------------------------------------------#
# RATING DISTRIBUTION IN HISTOGRAM
#----------------------------------------------------------------------------------------------------------------------------#
#Histogram: distribution of rating
playstore %>%
  ggplot(aes(x = rating)) +
  geom_histogram(fill = "#4285f4", bins = 30, na.rm = TRUE) +
  theme_minimal() +
  theme(text = element_text(family = "Lato")) +
  labs(
    title = "Rating Distribution",
    x = "\nRating",
    y = "Total Apps\n"
  ) 

#----------------------------------------------------------------------------------------------------------------------------#
# SIZE DISTRIBUTION IN HISTOGRAM
#----------------------------------------------------------------------------------------------------------------------------#
#Histogram: distribution of size
playstore %>%
  ggplot(aes(x = size)) +
  geom_histogram(fill = "#fbbc05", bins = 30, na.rm = TRUE) +
  theme_minimal() +
  theme(text = element_text(family = "Lato")) +
  labs(
    title = "Size Distribution",
    x = "\nSize",
    y = "Total Apps\n"
  ) 

#----------------------------------------------------------------------------------------------------------------------------#
# LAST UPDATED DISTRIBUTION IN HISTOGRAM
#----------------------------------------------------------------------------------------------------------------------------#
#Histogram: distribution of last updated
playstore %>%
  ggplot(aes(x = last_updated)) +
  geom_histogram(fill = "#34a853", bins = 30, na.rm = TRUE) +
  theme_minimal() +
  theme(text = element_text(family = "Lato")) +
  labs(
    title = "Last Updated Distribution",
    x = "\nLast Updated",
    y = "Total Apps\n"
  ) 

#----------------------------------------------------------------------------------------------------------------------------#
# ANALYSIS OF TOP FIVE CATEGORIES
#----------------------------------------------------------------------------------------------------------------------------#
# TOTAL APPS LISTED BASED ON CONTENT RATING IN A BAR CHART
#----------------------------------------------------------------------------------------------------------------------------#
#Total App based on content rating by category
sumfivecat %>%
  ggplot(aes(x = content_rating, 
             y = totalapp, 
             fill = content_rating)) + 
  geom_col(show.legend = TRUE, na.rm = TRUE, position = "dodge") +
  theme_light() +
  theme(text = element_text(family = "Lato"),
        plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        axis.text.y = element_blank(),
        axis.text.x = element_blank(),
        panel.background = element_rect())+
  xlab(NULL) +
  ylab(NULL) +
  scale_fill_manual(values = c("#ea4335", "#fbbc05", "#4285f4", "#34a853","grey"),
                    limits = c("Everyone", "Everyone 10+", "Mature 17+", "Teen","Unrated"),
                    name = "Content Rating") +
  labs(title = "Total App For Top five Categories", subtitle = "Based on Content Rating") +
  facet_wrap(~reorder(category, desc(totalapp)), nrow = 2)

#----------------------------------------------------------------------------------------------------------------------------#
# TOTAL INSTALLATIONS BASED ON CONTENT RATING IN A BAR CHART
#----------------------------------------------------------------------------------------------------------------------------#
#Total Installs Based On Content Rating
sumfivecat %>%
  ggplot(aes(x = content_rating, 
             y = totalinstalls, 
             fill = content_rating)) + 
  geom_col(show.legend = TRUE, na.rm = TRUE, position = "dodge") +
  theme_light() +
  theme(text = element_text(family = "Lato"),
        plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5),
        axis.text.y = element_blank(),
        axis.text.x = element_blank(),
        panel.background = element_rect())+
  xlab(NULL) +
  ylab(NULL) +
  scale_fill_manual(values = c("#ea4335", "#fbbc05", "#4285f4", "#34a853","grey"),
                    limits = c("Everyone", "Everyone 10+", "Mature 17+", "Teen","Unrated"),
                    name = "Content Rating") +
  labs(title = "Total Installs For Top five Categories", subtitle = "Based on Content Rating") +
  facet_wrap(~reorder(category, desc(totalapp)), nrow = 2)

#----------------------------------------------------------------------------------------------------------------------------#
# RATING DISTRIBUTION OF EACH CATEGORY
#----------------------------------------------------------------------------------------------------------------------------#
#Histogram: distribution of rating
playstore %>% filter(category == "Game" |
                       category == "Communication" |
                       category == "Family" |
                       category == "Social" |
                       category == "Video Players") %>%
  ggplot(aes(x = rating)) +
  geom_histogram(fill = "#4285f4", bins = 30, na.rm = TRUE) +
  theme_light() +
  theme(text = element_text(family = "Lato")) +
  labs(title = "Rating Distribution",
       subtitle = "of Five Categories",
       x = "\nRating",
       y = "Total Apps\n") +
  facet_wrap(~category)

#----------------------------------------------------------------------------------------------------------------------------#
# SIZE DISTRIBUTION OF EACH CATEGORY
#----------------------------------------------------------------------------------------------------------------------------#
#Histogram: distribution of size
playstore %>% filter(category == "Game" |
                       category == "Communication" |
                       category == "Family" |
                       category == "Social" |
                       category == "Video Players") %>%
  ggplot(aes(x = size)) +
  geom_histogram(fill = "#fbbc05", bins = 30, na.rm = TRUE) +
  theme_light() +
  theme(text = element_text(family = "Lato")) +
  labs(title = "Size Distribution",
       subtitle = "of Five Categories",
       x = "\nSize",
       y = "Total Apps\n") +
  facet_wrap(~category)

#----------------------------------------------------------------------------------------------------------------------------#
# LAST UPDATED DISTRIBUTION OF EACH CATEGORY
#----------------------------------------------------------------------------------------------------------------------------#
#Histogram: distribution of Last Updated
playstore %>% filter(category == "Game" |
                       category == "Communication" |
                       category == "Family" |
                       category == "Social" |
                       category == "Video Players") %>%
  ggplot(aes(x = last_updated)) +
  geom_histogram(fill = "#34a853", bins = 30, na.rm = TRUE) +
  theme_light() +
  theme(text = element_text(family = "Lato")) +
  labs(title = "Last Updated Distribution",
       subtitle = "of Five Categories",
       x = "\nLast Updated",
       y = "Total Apps\n") +
  facet_wrap(~category, nrow = 2)

#----------------------------------------------------------------------------------------------------------------------------#
# TOP GENRES IN EACH CATEGORY
#----------------------------------------------------------------------------------------------------------------------------#
#Top Genres in Five Categories
topgenres %>% 
  mutate(no = "no") %>% 
  ggplot(aes(x = no, y = category, size = reviews, color = genres)) + 
  geom_text(aes(label = genres), show.legend = FALSE) + 
  theme_minimal() + 
  xlab(NULL) + ylab(NULL) + 
  theme(text = element_text(family = "Lato"), 
        axis.text.x = element_blank(),
        panel.grid.major.x = element_blank()) +
  scale_size(range = c(8, 15)) + 
  scale_color_manual(values = c("#4285f4", "#ea4335", "#4285f4", "#fbbc05", "#34a853"))

#----------------------------------------------------------------------------------------------------------------------------#
# TOP TEN APPS IN EACH GENRE
#----------------------------------------------------------------------------------------------------------------------------#
#preview in wider table
topgenreapp %>%
        pivot_wider(names_from = "genres",
                    values_from = "app")

#----------------------------------------------------------------------------------------------------------------------------#
# PAYMENT TYPE ACCROS TOP 5 CATEGORIES
#----------------------------------------------------------------------------------------------------------------------------#
#Payment Type Across All Five Popular Categories
toppricesapp %>% 
  mutate(no = "no") %>%
  ggplot(aes(x = type, y = no, color = type)) +
  geom_count(show.legend = FALSE) +
  scale_size(range = c(0,25)) +
  xlim("Free", "Paid") +
  theme_minimal() + 
  xlab(NULL) + ylab(NULL) + 
  theme(text = element_text(family = "Lato"), 
        axis.text.y = element_blank(),
        panel.grid.major.x = element_blank()) +
  scale_color_manual(values = c("#4285f4", "#ea4335"))

#----------------------------------------------------------------------------------------------------------------------------#

