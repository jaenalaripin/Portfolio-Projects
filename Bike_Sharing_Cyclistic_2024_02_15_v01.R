
                                           # BIKE SHARE: CYCLISTIC CASE STUDY WITH R

#---------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------- PREPARING -------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------
# IMPORTING DATASETS FROM EXTERNAL SOURCE
#---------------------------------------------------------------------------------------------------------------------------
library(readr)                                                           #loading readr package to enable read_csv function                                                              
bike2019 <- read_csv("F:/Data Analytics/Case Studies/Bike Share/R/Divvy_Trips_2019_Q1.csv")        #importing dataset of Q1
bike20192 <- read_csv("F:/Data Analytics/Case Studies/Bike Share/R/Divvy_Trips_2019_Q2.csv")       #importing dataset of Q2
bike20193 <- read_csv("F:/Data Analytics/Case Studies/Bike Share/R/Divvy_Trips_2019_Q3.csv")       #importing dataset of Q3
bike20194 <- read_csv("F:/Data Analytics/Case Studies/Bike Share/R/Divvy_Trips_2019_Q4.csv")       #importing dataset of Q4

#---------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------- CLEANING --------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------
# CHECKING STRUCTURE AND NAMES OF THE COLUMNS
#---------------------------------------------------------------------------------------------------------------------------
library(dplyr)        #loading dplyr package
glimpse(bike2019)     #checking the structure of Q1 data set
glimpse(bike20192)    #checking the structure of Q2 data set
glimpse(bike20193)    #checking the structure of Q3 data set
glimpse(bike20194)    #checking the structure of Q4 data set

#---------------------------------------------------------------------------------------------------------------------------
# CLEANING AND RENAMING Q2 DATASET COLUMNS
#---------------------------------------------------------------------------------------------------------------------------
library(janitor)                          #loading janitor package to perform rename_with function
bike20192 <- clean_names(bike20192)       #cleaning all the column names of Q2 data set
colnames(bike20192)                       #view Q2 data set column names

bike20192 <-                              #Renaming Q2 dataset columns
  bike20192 %>% 
  rename(trip_id = x01_rental_details_rental_id,
         start_time = x01_rental_details_local_start_time,
         end_time = x01_rental_details_local_end_time,
         bikeid = x01_rental_details_bike_id,
         tripduration = x01_rental_details_duration_in_seconds_uncapped,
         from_station_id = x03_rental_start_station_id,
         from_station_name = x03_rental_start_station_name,
         to_station_id = x02_rental_end_station_id,
         to_station_name = x02_rental_end_station_name,
         usertype = user_type,
         gender = member_gender,
         birthyear = x05_member_details_member_birthday_year)

colnames(bike20192)                        #checking the column names    

#---------------------------------------------------------------------------------------------------------------------------
# JOINING DATASET WITH UNION FUNCTION
#---------------------------------------------------------------------------------------------------------------------------
bike2019 <- union_all(bike2019, bike20192)          #joining Q1 and Q2
bike2019 <- union_all(bike2019, bike20193)          #joining Q1,Q2 and Q3
bike2019 <- union_all(bike2019, bike20194)          #joining Q1,Q2,Q3, and Q4

#---------------------------------------------------------------------------------------------------------------------------
# CHECKING AND EXCLUDING OUTLIERS
#---------------------------------------------------------------------------------------------------------------------------
summary(bike2019)                               #view statistical values of the data set

bike2019 <- 
  bike2019 %>% filter(birthyear > 2019-100, 
                      tripduration < 24*3600)   #filtering the data set from outliers

#---------------------------------------------------------------------------------------------------------------------------
# LOOKING FOR DUPLICATES
#---------------------------------------------------------------------------------------------------------------------------
kable(data.frame(duplicates = sum(duplicated(bike2019))))     #checking duplicates
kable(head(bike2019 %>% distinct(usertype)))                  #checking values in usertype column
kable(head(bike2019 %>% distinct(gender)))                    #checking values in gender column

bike2019 <- 
  bike2019 %>% 
  mutate(usertype = case_when(usertype == "Subscriber" ~ "Annual Member",   #renaming columns
                              usertype == "Customer" ~ "Casual"))

#---------------------------------------------------------------------------------------------------------------------------
# RENAMING VALUES IN THE usertype COLUMN
#---------------------------------------------------------------------------------------------------------------------------
bike2019 <- 
  bike2019 %>% 
  mutate(usertype = case_when(usertype == "Subscriber" ~ "Annual Member",   #renaming columns
                              usertype == "Customer" ~ "Casual"))

#---------------------------------------------------------------------------------------------------------------------------
# EXCLUDING NULL VALUES IN THE DATASET
#---------------------------------------------------------------------------------------------------------------------------
bike2019 <-                            #excluding null from the data set
  bike2019 %>%
  drop_na()

#---------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------- ANALYSIS ---------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------
# ADDING days, months, and ages COLUMNS
#---------------------------------------------------------------------------------------------------------------------------
library(lubridate)
bike2019 <-                                                    #creating new columns (ages, days, and months)
  bike2019 %>%                                             
  mutate(ages = year(now())-birthyear) %>% 
  mutate(days = wday(start_time, label = TRUE)) %>%
  mutate(months = factor(month(start_time, label = TRUE)))

#---------------------------------------------------------------------------------------------------------------------------
# CALCULATING TOTAL TRANSACTIONS BY MONTH
#---------------------------------------------------------------------------------------------------------------------------
biketransactionheatmap <-                    #calculating transactions by months and days, will be used to plot a heatmap chart
  bike2019 %>%
  group_by(usertype, months, days) %>%
  summarise(total = n())
#---------------------------------------------------------------------------------------------------------------------------
# CALCULATING AVERAGE DURATION THE USERS SPENT IN RIDING BIKES
#---------------------------------------------------------------------------------------------------------------------------
bike2019durationday <-                        #calculating average trip duration by days
  bike2019 %>% group_by(usertype,days) %>% 
  summarise(average = mean(tripduration)/60)

#---------------------------------------------------------------------------------------------------------------------------
# CALCULATING AGE DISTRIBUTION
#---------------------------------------------------------------------------------------------------------------------------
bike2019ages <-                               #calculating transactions by ages
  bike2019 %>%
  group_by(usertype, ages) %>%
  summarise(total = n())

kable(head(bike2019ages))

#---------------------------------------------------------------------------------------------------------------------------
# CALCULATING TIME DISTRIBUTION
#---------------------------------------------------------------------------------------------------------------------------
bike2019hour <-
  bike2019 %>% 
  mutate(start_time = as.character(start_time)) %>%
  mutate(start_time = str_sub(start_time, 12, 19)) %>%
  mutate(start_time = factor(case_when(
    str_starts(start_time,"00:")~"00:00",
    str_starts(start_time,"01:")~"01:00",
    str_starts(start_time,"02:")~"02:00",
    str_starts(start_time,"03:")~"03:00",
    str_starts(start_time,"04:")~"04:00",
    str_starts(start_time,"05:")~"05:00",
    str_starts(start_time,"06:")~"06:00",
    str_starts(start_time,"07:")~"07:00",
    str_starts(start_time,"08:")~"08:00",
    str_starts(start_time,"09:")~"09:00",
    str_starts(start_time,"10:")~"10:00",
    str_starts(start_time,"11:")~"11:00",
    str_starts(start_time,"12:")~"12:00",
    str_starts(start_time,"13:")~"13:00",
    str_starts(start_time,"14:")~"14:00",
    str_starts(start_time,"15:")~"15:00",
    str_starts(start_time,"16:")~"16:00",
    str_starts(start_time,"17:")~"17:00",
    str_starts(start_time,"18:")~"18:00",  
    str_starts(start_time,"19:")~"19:00",
    str_starts(start_time,"20:")~"20:00",
    str_starts(start_time,"21:")~"21:00",
    str_starts(start_time,"22:")~"22:00",
    str_starts(start_time,"23:")~"23:00",
    str_starts(start_time,"24:")~"24:00",
    .default = "00:00"))) %>%
  group_by(days, start_time, usertype) %>% summarise(total = n()) 


#---------------------------------------------------------------------------------------------------------------------------
# CALCULATING DISTRIBUTION OF GENDERS
#---------------------------------------------------------------------------------------------------------------------------
bikegender <-                   #calculating numbers of each gender
  bike2019 %>% 
  group_by(gender,usertype) %>% 
  summarise(total = n()) 

#---------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------- VISUALIZATIONS ---------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------
# Distribution of Transactions
#---------------------------------------------------------------------------------------------------------------------------
library(tidyverse)                                        #loading tidyverse package                                     
bike2019 %>% ggplot(aes(usertype)) + 
  geom_histogram(aes(x = start_time, fill = usertype),
                 stat = "bin", bins = 30, show.legend = FALSE) + 
  theme_minimal() +
  theme(
    text = element_text(family = "Lato"),
    strip.background = element_blank(), 
    strip.placement = "outside") + 
  labs(
    text = "Distribution of Transactions",
    subtitle = "in 2019\n",
    x = "\nMonths",
    y = "Transactions\n" ) + 
  guides(fill = guide_legend(title = "User")) +
  facet_grid(usertype~.) +
  scale_fill_manual(values=c("#111077", "#f77a20"))

#---------------------------------------------------------------------------------------------------------------------------
# HEATMAP OF TIME
#---------------------------------------------------------------------------------------------------------------------------
bike2019hour %>% filter(usertype == "Annual Member") %>%
  ggplot(aes(x = days, y = start_time, fill = total)) + 
  geom_tile(show.legend = FALSE) +
  theme_minimal() +
  theme(
    text = element_text(family = "Lato"),
    strip.background = element_blank(), 
    strip.placement = "outside")  + 
  labs(title = "Annual Member") + 
  xlab(NULL) +
  ylab(NULL) +
  scale_fill_gradient(low = "#111077", high = "#f77a20")

bike2019hour %>% filter(usertype == "Casual") %>%
  ggplot(aes(x = days, y = start_time, fill = total)) + 
  geom_tile(show.legend = FALSE) +
  scale_fill_gradient(low = "#111077", high = "#f77a20") +
  theme_minimal() +
  theme(
    text = element_text(family = "Lato"),
    strip.background = element_blank(), 
    strip.placement = "outside") + 
  labs(
    title = "Casual User") + 
  xlab(NULL) +
  ylab(NULL) +
  guides(fill = guide_legend(title = "Transactions")) 

#---------------------------------------------------------------------------------------------------------------------------
# DISTRIBUTION OF AGE
#---------------------------------------------------------------------------------------------------------------------------
bike2019 %>% filter(ages < 80) %>% ggplot() + 
  geom_histogram(aes(x = ages, fill = usertype), stat = "bin", bins = 30, show.legend = FALSE) + 
  theme_minimal() +
  theme(
    text = element_text(family = "Lato"), 
    strip.placement = "outside") + 
  labs(
    title = "\nDistribution of Users' Age",
    x = "\nAge",
    y = "Transactions\n") + 
  guides(fill = guide_legend(title = "User")) +
  facet_grid(.~usertype) +
  scale_fill_manual(values=c("#111077", "#f77a20")) 

#---------------------------------------------------------------------------------------------------------------------------
# Average Trip Duration
#---------------------------------------------------------------------------------------------------------------------------
bike2019durationday %>% 
  ggplot(aes(x = days, y = average, fill = usertype)) + geom_col(position = "dodge") + 
  theme_minimal() +
  theme(
    text = element_text(family = "Lato")) + 
  labs(
    title = "\nAverage Duration Per Day",
    subtitle = "Casual vs Member User\n",
    y = "Minutes\n",
  ) +
  xlab(NULL) +
  guides(fill = guide_legend(title = "User")) +
  scale_fill_manual(values=c("#111077", "#f77a20"))

#---------------------------------------------------------------------------------------------------------------------------
# DISTRIBUTION OF GENDERS
#---------------------------------------------------------------------------------------------------------------------------
library(treemapify)      #loading treemapify package to plot the data into tree chart
bikegender %>% ggplot(aes(area = total, fill = gender, label = paste(gender, total, sep = "\n"))) + 
  geom_treemap(show.legend = FALSE) +
  geom_treemap_text(colour = "white",
                    place = "centre",
                    size = 13,
                    family = "Lato Black") +
  scale_fill_manual(values=c("#111077", "#f77a20")) +
  theme_minimal() +
  theme(
    text = element_text(family = "Lato"),
    strip.background = element_blank(), 
    strip.placement = "outside") +
  facet_grid(usertype~.)
