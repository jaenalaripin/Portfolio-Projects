

                                              # BELLABEAT CASE STUDY WITH R

#----------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------ PROCESS -------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------------------------
# IMPORTING DATASETS
#----------------------------------------------------------------------------------------------------------------------------------
#loading tidyverse package
library(tidyverse)

#Importing csv files
dailyactivity <- 
  read_csv("F:/Data Analytics/Case Studies/Bellabeat/Data Sets/dailyActivity_merged.csv")
hourlycalories <- 
  read_csv("F:/Data Analytics/Case Studies/Bellabeat/Data Sets/hourlyCalories_merged.csv")
hourlyintensities <- 
  read_csv("F:/Data Analytics/Case Studies/Bellabeat/Data Sets/hourlyIntensities_merged.csv")
hourlysteps <- 
  read_csv("F:/Data Analytics/Case Studies/Bellabeat/Data Sets/hourlySteps_merged.csv")
minutescaloriesnarrow <- 
  read_csv("F:/Data Analytics/Case Studies/Bellabeat/Data Sets/minuteCaloriesNarrow_merged.csv")
minutesintensitiesnarrow <- 
  read_csv("F:/Data Analytics/Case Studies/Bellabeat/Data Sets/minuteIntensitiesNarrow_merged.csv")
minutesmetsnarrow <- 
  read_csv("F:/Data Analytics/Case Studies/Bellabeat/Data Sets/minuteMETsNarrow_merged.csv")
minutesstepsnarrow <- 
  read_csv("F:/Data Analytics/Case Studies/Bellabeat/Data Sets/minuteStepsNarrow_merged.csv")

#----------------------------------------------------------------------------------------------------------------------------------
# CLEANING DATA TYPE FROM DATE COLUMNS FROM ALL DATASETS
#----------------------------------------------------------------------------------------------------------------------------------
#dailyactivity
dailyactivity <- 
  dailyactivity %>% 
  mutate(ActivityDate = mdy(ActivityDate))   #convert date columns into date data type

#hourlycalories
hourlycalories<-
  hourlycalories %>% 
  mutate(ActivityHour = mdy_hms(ActivityHour),     #convert ActivityHour column into date time data type                             
         ActivityDate = as.Date(ActivityHour),     #create a ActivityDate column from ActivityHour column                            
         ActivityHour = hms::as_hms(format(ActivityHour, format = "%H:%M:%S"))) #convert ActivityHour column into time data type

#hourlyintensities
hourlyintensities <-
  hourlyintensities %>% 
  mutate(ActivityHour = mdy_hms(ActivityHour),     #convert ActivityHour column into date time data type                             
         ActivityDate = as_date(ActivityHour),     #create a ActivityDate column from ActivityHour column                              
         ActivityHour = hms::as_hms(format(ActivityHour, format = "%H:%M:%S"))) #convert ActivityHour column into time data type

#hourlysteps
hourlysteps <-
  hourlysteps %>% 
  mutate(ActivityHour = mdy_hms(ActivityHour),     #convert ActivityHour column into date time data type                               
         ActivityDate = as_date(ActivityHour),     #create a ActivityDate column from ActivityHour column                                    
         ActivityHour = hms::as_hms(format(ActivityHour, format = "%H:%M:%S"))) #convert ActivityHour column into time data type

#minutescaloriesnarrow
minutescaloriesnarrow <-
  minutescaloriesnarrow %>% 
  mutate(ActivityMinute = mdy_hms(ActivityMinute), #convert ActivityMinute column into date time data type                                 
         ActivityDate = as_date(ActivityMinute),   #create a ActivityDate column from ActivityMinute column                               
         ActivityMinute = hms::as_hms(format(ActivityMinute, format = "%H:%M:%S"))) #convert ActivityMinute column into time data type

#minutesintensitiesnarrow
minutesintensitiesnarrow <-
  minutesintensitiesnarrow %>%                                                      
  mutate(ActivityMinute = mdy_hms(ActivityMinute), #convert ActivityMinute column into date time data type                                  
         ActivityDate = as_date(ActivityMinute),   #create a ActivityDate column from ActivityMinute column                                   
         ActivityMinute = hms::as_hms(format(ActivityMinute, format = "%H:%M:%S"))) #convert ActivityMinute column into time data type

#minutesstepsnarrow
minutesstepsnarrow <-
  minutesstepsnarrow %>% 
  mutate(ActivityMinute = mdy_hms(ActivityMinute), #convert ActivityMinute column into date time data type                                  
         ActivityDate = as_date(ActivityMinute),   #create a ActivityDate column from ActivityMinute column                                 
         ActivityMinute = hms::as_hms(format(ActivityMinute, format = "%H:%M:%S"))) #convert ActivityMinute column into time data type

#minutesmetsnarrow
minutesmetsnarrow <- 
  minutesmetsnarrow %>%                                                           
  mutate(ActivityMinute = mdy_hms(ActivityMinute), #convert ActivityMinute column into date time data type                                   
         ActivityDate = as_date(ActivityMinute),   #create a ActivityDate column from ActivityMinute column                                    
         ActivityMinute = hms::as_hms(format(ActivityMinute, format = "%H:%M:%S"))) #convert ActivityMinute column into time data type

#----------------------------------------------------------------------------------------------------------------------------------
# CHECKING DUPLICATES
#----------------------------------------------------------------------------------------------------------------------------------
#Checking for duplicates
dailyactivityduplicated <-
  sum(duplicated(dailyactivity))

hourlycaloriesduplicated <-
  sum(duplicated(hourlycalories))

hourlyintensitiesduplicated <-
  sum(duplicated(hourlyintensities))

hourlystepsduplicated <-
  sum(duplicated(hourlysteps))

minutescaloriesnarrowduplicated <-
  sum(duplicated(minutescaloriesnarrow))

minutesmetsnarrowduplicated <- 
  sum(duplicated(minutesmetsnarrow))

minutesstepsnarrowduplicated <-
  sum(duplicated(minutesstepsnarrow))

minutesintensitiesnarrowduplicated <-
  sum(duplicated(minutesintensitiesnarrow))

#----------------------------------------------------------------------------------------------------------------------------------
# EXCLUDING OUTLIERS
#----------------------------------------------------------------------------------------------------------------------------------
#removing values 1440 in dailyactivity data set
daily <-
  dailyactivity %>% 
  filter(!SedentaryMinutes >= 1440 & !TotalSteps == 0) 

#----------------------------------------------------------------------------------------------------------------------------------
# CREATING NEW TABLES CALLED 'hourlyactivity' AND 'minutesactivity'
#----------------------------------------------------------------------------------------------------------------------------------
#Creating New Data Set called hourlyactivity
hourlyactivity <- 
  hourlycalories %>% 
  inner_join(hourlyintensities, by = c("Id", "ActivityDate", "ActivityHour")) %>%
  inner_join(hourlysteps, by = c("Id", "ActivityDate", "ActivityHour"))

#Creating New Data Set called minutesactivity
minutesactivity <-
  minutescaloriesnarrow %>%
  inner_join(minutesintensitiesnarrow, by = c("Id", "ActivityDate", "ActivityMinute")) %>%
  inner_join(minutesmetsnarrow, by = c("Id", "ActivityDate", "ActivityMinute")) %>%
  inner_join(minutesstepsnarrow, by = c("Id", "ActivityDate", "ActivityMinute"))

#----------------------------------------------------------------------------------------------------------------------------------
# MUTATING THE METs COLUMN
#----------------------------------------------------------------------------------------------------------------------------------
minutesactivity<-
  minutesactivity %>% mutate(METs = METs/10) #dividing METs values by 10
kable(head(minutesactivity))

#----------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------- ANALYSIS ---------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------------------------
# FREQUENCY LEVEL
#----------------------------------------------------------------------------------------------------------------------------------
#aggregating the total device uses per Id
frequencylevel <- 
  daily %>% 
  group_by(Id) %>% 
  summarise(Total = n()) %>%
  
#grouping people based on the frequency level
mutate(Level = case_when(
    Total <= 10 ~ "Light",
    Total > 10 & Total <= 20 ~ "Moderate",
    Total > 20 & Total <= 31 ~ "Active")) %>%
  
#counting members by frequency level
  group_by(Level) %>%
  summarise(Total = n())

#counting how many times devices are not worn
dailyactivity <-
  dailyactivity %>% 
  mutate(Status = case_when((SedentaryMinutes >= 1440 & TotalSteps == 0) ~ "Not Worn",.default = "Worn")) 

#totalnotworn
totalnotworn <-
  dailyactivity %>%
  group_by(Status) %>%
  summarise(Total = n())

#----------------------------------------------------------------------------------------------------------------------------------
# COUNTING TOTAL DEVICE USE PER DAY
#----------------------------------------------------------------------------------------------------------------------------------
#Aggregating Total Device Use Per Day
totaluseperday<-
  daily %>% 
  mutate(Day = wday(ActivityDate, label = TRUE)) %>% 
  group_by(Day) %>% 
  summarise(Total = n())

#----------------------------------------------------------------------------------------------------------------------------------
# SUMMARIZING VARIABLES THAT MIGHT DEFINED PHYSICAL FITNESS
#----------------------------------------------------------------------------------------------------------------------------------
#summarizing variables in daily table
dailysummary <-
  daily %>% group_by(ActivityDate) %>%
  summarise(TotalDistance = sum(TotalDistance),
            TotalVeryActiveDistance = sum(VeryActiveDistance),
            TotalModeratelyActiveDistance = sum(ModeratelyActiveDistance),
            TotalLightActiveDistance = sum(LightActiveDistance),
            TotalSedentaryActiveDistance = sum(SedentaryActiveDistance),
            TotalVeryActiveMinutes = sum(VeryActiveMinutes),
            TotalFairlyActiveMinutes = sum(FairlyActiveMinutes),
            TotalLightlyActiveMinutes = sum(LightlyActiveMinutes)) 

#summarizing variables in hourlyactivity table
hourlysummary <-
  hourlyactivity %>% group_by(ActivityDate) %>%
  summarise(TotalIntensity = sum(TotalIntensity))

#summarizing variables in minutesactivity table
minutessummary <-
  minutesactivity %>% group_by(ActivityDate) %>%
  summarise(TotalMETs = sum(METs),
            TotalCalories = sum(Calories),
            TotalSteps = sum(Steps))

#creating summary table
summary <- 
  dailysummary %>% 
  inner_join(hourlysummary, by = c("ActivityDate")) %>%
  inner_join(minutessummary, by = c("ActivityDate"))

#----------------------------------------------------------------------------------------------------------------------------------
# GROUPING ACTIVITY BASED ON MET VALUES
#----------------------------------------------------------------------------------------------------------------------------------
#grouping activity based on mets
statusmets <-
  minutesactivity %>% 
  mutate(Intensity = case_when(
    METs > 1.6 & METs <= 3.0 ~ "Light",
    METs > 3.0 & METs <= 6.0 ~ "Moderate",
    METs > 6.0 ~ "Vigorous",
    .default = "Sedentary")) %>%
  group_by(Id, ActivityDate, Intensity) %>%
  summarise(Calories = sum(Calories), Minutes = n(), .groups = 'drop')

#----------------------------------------------------------------------------------------------------------------------------------
# DESCRIBING FITNESS ACHIEVEMENT BASED ON PYSICAL ACTIVITY TARGET QUOTED FROM NHS
#----------------------------------------------------------------------------------------------------------------------------------
#Grouping people based on Physical Activity Target
activitytarget <-
  pivotstatusmets %>% 
  mutate(Week = week(ActivityDate)-14) %>% 
  group_by(Id, Week) %>%
  summarise(MinutesVigorous = sum(MinutesVigorous),
            MinutesModerate = sum(MinutesModerate), 
            .groups = 'drop') %>%
  mutate(Status = case_when(MinutesVigorous + MinutesModerate >= 150 ~ "Achieved!",
                            .default = "Do More Exercise!")) %>%
  select(Id, Week, Status) %>% 
  arrange(Id)

#----------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------- VISUALIZATIONS -----------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------------------------
# FREQUENCY LEVEL OF PEOPLE USING THE DEVICES
#----------------------------------------------------------------------------------------------------------------------------------
frequencylevel %>% 
  ggplot(aes(x = fct_reorder(Level, Total), y = Total, fill = Level)) + 
  geom_col() +
  theme_light() +
  labs(
    title = "Light, Moderate, and Active Users",
    subtitle = "based on 33 samples",
    x = "\nLevel",
    y = "Total\n"
  ) +
  scale_fill_manual(values = c("#dc0000","#fdc500","#fd8c00"))

#----------------------------------------------------------------------------------------------------------------------------------
# HOW OFTEN PEOPLE FORGOT TO USE THEIR DEVICES
#----------------------------------------------------------------------------------------------------------------------------------
# plotting in a bar chart
totalnotworn %>%
  ggplot(aes(x = Status, y = Total, fill = Status)) +
  geom_col() +
  theme_light() +
  labs( title = "Total Devices Worn and Not Worn",
        subtitle = "based on 33 samples",
        x = "\nLevel",
        y = "Total\n" ) +
  scale_fill_manual(values = c("#dc0000", "#fdc500"))

# plotting in a heatmap chart
dailyactivity %>% 
  ggplot(aes(ActivityDate, as.character(Id), fill = Status)) +
  geom_tile() +
  theme_light() +
  labs( title = "Total Devices Worn",
        subtitle = "based on 33 samples",
        x = "\nWeek",
        y = "Id\n" ) +
  scale_fill_manual(values = c("#dc0000", "#fdc500"))

#----------------------------------------------------------------------------------------------------------------------------------
# TOTAL USE PER DAY
#----------------------------------------------------------------------------------------------------------------------------------
totaluseperday %>%
  ggplot(aes(x = Day, y = Total, fill = Day)) + geom_col()+
  theme_light() +
  labs( title = "Total Devices Use Per Day",
        subtitle = "Based On 33 Users",
        x = "\nDay",
        y = "Total Use\n" ) +
  scale_fill_manual(values = c("grey", "grey", "red", "red", "red", "grey", "grey"))

#----------------------------------------------------------------------------------------------------------------------------------
# TOTAL DISTANCE VS TOTAL CALORIES SCATTERPLOT
#----------------------------------------------------------------------------------------------------------------------------------
summary %>%
  ggplot(aes(x = TotalDistance, y = TotalCalories)) +
  geom_point() +
  stat_smooth (formula = 'y ~ x', method = "lm") + 
  theme_light() +
  labs(title = "Total Distance vs Total Calories",
       subtitle = "per date",
       x = "\nTotal Distance",
       y = "Total Calories\n")

#----------------------------------------------------------------------------------------------------------------------------------
# TOTAL ACTIVE MINUTES VS TOTAL CALORIES SCATTERPLOT
#----------------------------------------------------------------------------------------------------------------------------------
summary %>%
  ggplot(aes(x = TotalVeryActiveMinutes+TotalFairlyActiveMinutes+TotalLightlyActiveMinutes, y = TotalCalories)) +
  geom_point() +
  stat_smooth (formula = 'y ~ x', method = "lm") + 
  theme_light() +
  labs(title = "Total Active Minutes vs Total Calories",
       subtitle = "per date",
       x = "\nTotal Active Minutes",
       y = "Total Calories\n")

#----------------------------------------------------------------------------------------------------------------------------------
# TOTAL INTENSITY VS TOTAL CALORIES SCATTERPLOT
#----------------------------------------------------------------------------------------------------------------------------------
summary %>%
  ggplot(aes(x = TotalIntensity, y = TotalCalories)) +
  geom_point() +
  stat_smooth (formula = 'y ~ x', method = "lm") + 
  theme_light() +
  labs(title = "Total Intensity vs Total Calories",
       subtitle = "per date",
       x = "\nTotal Intensity",
       y = "Total Calories\n")

#----------------------------------------------------------------------------------------------------------------------------------
# TOTAL STEPS VS TOTAL CALORIES SCATTERPLOT
#----------------------------------------------------------------------------------------------------------------------------------
summary %>%
  ggplot(aes(x = TotalSteps, y = TotalCalories)) +
  geom_point() +
  stat_smooth (formula = 'y ~ x', method = "lm") + 
  theme_light() +
  labs(title = "Total Steps vs Total Calories",
       subtitle = "per date",
       x = "\nTotal Steps",
       y = "Total Calories\n")

#----------------------------------------------------------------------------------------------------------------------------------
# TOTAL METS VS TOTAL CALORIES SCATTERPLOT
#----------------------------------------------------------------------------------------------------------------------------------
summary %>%
  ggplot(aes(x = TotalMETs, y = TotalCalories)) +
  geom_point() +
  stat_smooth (formula = 'y ~ x', method = "lm") + 
  theme_light() +
  labs(title = "Total METs vs Total Calories",
       subtitle = "per date",
       x = "\nTotal METs",
       y = "Total Calories\n")

#----------------------------------------------------------------------------------------------------------------------------------
# AVERAGE MINUTES PER INTENSITY LEVEL
#----------------------------------------------------------------------------------------------------------------------------------
statusmets %>%
  group_by(Intensity) %>%
  summarise(AverageMinutes = mean(Minutes)) %>%
  ggplot(aes(x = Intensity, y = AverageMinutes, fill = Intensity)) +
  geom_col(show.legend = FALSE) +
  theme_light() +
  labs( title = "Average Minutes Per Intensity",
        subtitle = "of 33 users",
        x = "\nIntensity",
        y = "Average Minutes\n" ) +
  scale_fill_manual(values = c("#fdc500","#fd8c00","grey", "red"))

#----------------------------------------------------------------------------------------------------------------------------------
# HEATMAP OF AVERAGE MET PER USER OVER THE MONTH
#----------------------------------------------------------------------------------------------------------------------------------
minutesactivity %>% 
  group_by(Id, ActivityDate) %>% 
  summarise(METs = mean(METs), 
            .groups = 'drop') %>%
  ggplot(aes(x = ActivityDate, y = as.character(Id), fill = METs)) +
  geom_tile() +
  theme_light() +
  labs( title = "Average MET Values Per Day",
        subtitle = "of 33 users",
        x = "\nDate",
        y = "User Id\n" ) +
  scale_fill_gradient(low = "yellow", high = "red")

#----------------------------------------------------------------------------------------------------------------------------------
# TOTAL FITNESS ACHIEVED STATUS
#----------------------------------------------------------------------------------------------------------------------------------
# in a bar chart
activitytarget %>% 
  group_by(Id, Status) %>% 
  summarise(Total = n(), 
            .groups = 'drop') %>%
  ggplot(aes(x = Total, y = as.character(Id), fill = Status)) + 
  geom_col(show.legend = TRUE) + 
  scale_fill_manual(values = c("orange", "red")) +
  theme_light() +
  labs( title = "Total Achieved Status",
        x = "\nTotal",
        y = "User Id \n" )

# In a heatmap chart
activitytarget %>% 
  mutate(Week = paste0("Week ", as.character(Week))) %>%
  ggplot(aes(x = Week, y = as.character(Id), fill = Status)) +
  geom_tile() +
  scale_fill_manual(values = c("orange", "red"))+
  theme_light() +
  labs( title = "Total Achieved Status",
        x = "\nWeek",
        y = "User Id\n" )

#----------------------------------------------------------------------------------------------------------------------------------
