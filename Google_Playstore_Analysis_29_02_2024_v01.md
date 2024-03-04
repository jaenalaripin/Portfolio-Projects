Google Play Store Analysis
================

## 1. Ask

![](https://media.cnn.com/api/v1/images/stellar/prod/231219064524-google-play-photo-illustration.jpg)

There are tons of applications like games, social media, productivity
apps, and more that can be found on the Google Play Store. Starting from
indie apps until apps that created by big companies. Google Play
distributes more apps than the Apple Appstore does. It’s because the
global user base for Android surpasses 3.5 billion, while iOS boasts
more than 1.3 billion users. People can use Android on more than one
device or brand, unlike iOS, which only can be used on Apple devices. It
makes the market bigger.

The bigger the market, means the more people making apps. If we want to
develope an app, Choosing the right market will help us growing faster.
In this analysis, we want to answer some questions like:

- How is the market condition in Google Play Store?
- In which category can we get less competition?
- What type of genres should we develop?

## 2. Data Source

We got this data from Kaggle, which you can download the data
[here](https://www.kaggle.com/datasets/lava18/google-play-store-apps/data).
The data was scraped from Google Play by the author LAVANYA on Kaggle,
which was last updated 5 years ago. Since this analysis was conducted in
January, 2024, the data was updated approximately between 2018 - 2019.
This data consists of two csv files :

- *googleplaystore.csv*
- *googleplaystore_user_reviews.csv*

We only need one dataset for this analysis, which is the
*googleplaystore.csv*. We use R studio for the whole analysis. The first
step is to import the csv file into the RStudio with `readr` function
from `tidyverse` package.

``` r
#loading tidyverse package
library(tidyverse)

#importing dataset
applist <-
  read_csv("F:/Data Analytics/Case Studies/Google Playstore/Datasets/googleplaystore.csv")
```

Then, we check the structure of the dataset.

``` r
str(applist)
```

    ## spc_tbl_ [10,841 × 13] (S3: spec_tbl_df/tbl_df/tbl/data.frame)
    ##  $ App           : chr [1:10841] "Photo Editor & Candy Camera & Grid & ScrapBook" "Coloring book moana" "U Launcher Lite – FREE Live Cool Themes, Hide Apps" "Sketch - Draw & Paint" ...
    ##  $ Category      : chr [1:10841] "ART_AND_DESIGN" "ART_AND_DESIGN" "ART_AND_DESIGN" "ART_AND_DESIGN" ...
    ##  $ Rating        : num [1:10841] 4.1 3.9 4.7 4.5 4.3 4.4 3.8 4.1 4.4 4.7 ...
    ##  $ Reviews       : num [1:10841] 159 967 87510 215644 967 ...
    ##  $ Size          : chr [1:10841] "19M" "14M" "8.7M" "25M" ...
    ##  $ Installs      : chr [1:10841] "10,000+" "500,000+" "5,000,000+" "50,000,000+" ...
    ##  $ Type          : chr [1:10841] "Free" "Free" "Free" "Free" ...
    ##  $ Price         : chr [1:10841] "0" "0" "0" "0" ...
    ##  $ Content Rating: chr [1:10841] "Everyone" "Everyone" "Everyone" "Teen" ...
    ##  $ Genres        : chr [1:10841] "Art & Design" "Art & Design;Pretend Play" "Art & Design" "Art & Design" ...
    ##  $ Last Updated  : chr [1:10841] "January 7, 2018" "January 15, 2018" "August 1, 2018" "June 8, 2018" ...
    ##  $ Current Ver   : chr [1:10841] "1.0.0" "2.0.0" "1.2.4" "Varies with device" ...
    ##  $ Android Ver   : chr [1:10841] "4.0.3 and up" "4.0.3 and up" "4.0.3 and up" "4.2 and up" ...
    ##  - attr(*, "spec")=
    ##   .. cols(
    ##   ..   App = col_character(),
    ##   ..   Category = col_character(),
    ##   ..   Rating = col_double(),
    ##   ..   Reviews = col_double(),
    ##   ..   Size = col_character(),
    ##   ..   Installs = col_character(),
    ##   ..   Type = col_character(),
    ##   ..   Price = col_character(),
    ##   ..   `Content Rating` = col_character(),
    ##   ..   Genres = col_character(),
    ##   ..   `Last Updated` = col_character(),
    ##   ..   `Current Ver` = col_character(),
    ##   ..   `Android Ver` = col_character()
    ##   .. )
    ##  - attr(*, "problems")=<externalptr>

## 3. Cleaning The Dataset

The dataset we have just imported is not clean. In this step, we will
perform some cleaning processes. The dataset we’ve imported should be
adjusted, so it can be analyzed in RStudio environment. the dataset also
should be clean from typos, null values, duplicates, and outliers . We
will check the data set if the contains those variables.

#### 3.1. Adjusting Column Names

``` r
#checking column names
colnames(applist)
```

    ##  [1] "App"            "Category"       "Rating"         "Reviews"       
    ##  [5] "Size"           "Installs"       "Type"           "Price"         
    ##  [9] "Content Rating" "Genres"         "Last Updated"   "Current Ver"   
    ## [13] "Android Ver"

We have the column names with spaces, which is not allowed in RStudio.
We need to perform the `clean_names` function from `janitor` package to
convert the column names into the correct naming convention in RStudio.

``` r
#loading janitor package
library(janitor)

#cleaning column names
playstore <-
  clean_names(applist)

#checking column names
colnames(playstore)
```

    ##  [1] "app"            "category"       "rating"         "reviews"       
    ##  [5] "size"           "installs"       "type"           "price"         
    ##  [9] "content_rating" "genres"         "last_updated"   "current_ver"   
    ## [13] "android_ver"

All the column names has followed the RStudio naming convention.

#### 3.2. Removing Duplicates

Next, we check for duplicates in the dataset with the codes below.

``` r
#checking duplicates
a <- sum(duplicated(playstore[,1:2]))

library(knitr)
kable(data.frame(Duplicates = c(a)))
```

| Duplicates |
|-----------:|
|       1096 |

We found duplicates and remove them with the code below.

``` r
#removing duplicates
playstore <- playstore %>% filter(!duplicated(playstore[,1:2]))

#checking duplicates
a <- sum(duplicated(playstore[,1:2]))
kable(data.frame(Duplicates = c(a)))
```

| Duplicates |
|-----------:|
|          0 |

Now all the duplicates have been removed.

#### 3.3. Cleaning Values in Category Column

We found values in category column are not typed in the correct format.

| category            |
|:--------------------|
| ART_AND_DESIGN      |
| AUTO_AND_VEHICLES   |
| BEAUTY              |
| BOOKS_AND_REFERENCE |
| BUSINESS            |
| COMICS              |

We want the values in the dataset as tidy as possible. To do that, we
want to transform the values in the category column into text that is
more readable and appealing to read. We use the codes below.

``` r
#Transforming Category Values
playstore <-
  playstore %>% 
  mutate(category = str_to_title(str_replace_all(category, "_", " ")))

kable(head(playstore %>%
  distinct(category)))
```

| category            |
|:--------------------|
| Art And Design      |
| Auto And Vehicles   |
| Beauty              |
| Books And Reference |
| Business            |
| Comics              |

#### 3.4. Deleting Weird Row

``` r
#Checking Weird Row
kable(head(playstore %>% 
  distinct(category) %>% 
  arrange(category)))
```

| category            |
|:--------------------|
| 1.9                 |
| Art And Design      |
| Auto And Vehicles   |
| Beauty              |
| Books And Reference |
| Business            |

There is a category called “1.9”. We can say that this is not a correct
category. We do further observations regarding this. We check all the
rows with the category “1.9”

``` r
#checking rows in category "1.9"
kable(playstore %>%
  filter(category == 1.9))
```

| app                                     | category | rating | reviews | size   | installs | type | price    | content_rating | genres            | last_updated | current_ver | android_ver |
|:----------------------------------------|:---------|-------:|--------:|:-------|:---------|:-----|:---------|:---------------|:------------------|:-------------|:------------|:------------|
| Life Made WI-Fi Touchscreen Photo Frame | 1.9      |     19 |      NA | 1,000+ | Free     | 0    | Everyone | NA             | February 11, 2018 | 1.0.19       | 4.0 and up  | NA          |

It’s not only the category that return weird values, it also happens to
the other columns, so we need to exlude this row from the analysis.

``` r
#Deleting rows in category "1.9"
playstore <-
  playstore %>%
  filter(category != 1.9)
```

#### 3.5. Transforming Column Value Type

We see several columns are not in the right value type. Columns like
*installs*, *size*, *price*, and *last_updated* need to be adjusted.

##### *installs* Column

The current *installs* column has a character data type, we need to
change it to the numeric type, so it can be used for further analysis.

``` r
#cleaning installs column
playstore <-
  playstore %>% 
  mutate(installs = case_when(installs == "Free" ~ NA, .default = installs),
         installs = str_sub(installs, start = 1L, end = -2L),
         installs = as.numeric(str_replace_all(installs, ",", "")))
```

##### *size* Column

The current *size* column also has a character data type. We also change
the data type into numeric.

``` r
#cleaning size column
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
```

##### *price* Column

The current column “price” data type also need to be transformed into
numeric.

``` r
#cleaning price column
playstore <-
  playstore %>% 
  mutate(price = as.numeric(str_sub(price, start = 2L))) %>%
  replace_na(list(price = 0))
```

##### *last_updated* Column

The *last_updated* column consists of date values, but the values do not
represent date data type. We transform this column from character to
date data type with the codes below.

``` r
#cleaning last_updated column
playstore <- 
  playstore %>% 
  mutate(last_updated = mdy(last_updated))
```

Now, the dataset has been cleaned, let’s see the structure of the
modified dataset.

``` r
str(playstore)
```

    ## tibble [9,744 × 13] (S3: tbl_df/tbl/data.frame)
    ##  $ app           : chr [1:9744] "Photo Editor & Candy Camera & Grid & ScrapBook" "Coloring book moana" "U Launcher Lite – FREE Live Cool Themes, Hide Apps" "Sketch - Draw & Paint" ...
    ##  $ category      : chr [1:9744] "Art And Design" "Art And Design" "Art And Design" "Art And Design" ...
    ##  $ rating        : num [1:9744] 4.1 3.9 4.7 4.5 4.3 4.4 3.8 4.1 4.4 4.7 ...
    ##  $ reviews       : num [1:9744] 159 967 87510 215644 967 ...
    ##  $ size          : num [1:9744] 19 14 8.7 25 2.8 5.6 19 29 33 3.1 ...
    ##  $ installs      : num [1:9744] 1e+04 5e+05 5e+06 5e+07 1e+05 5e+04 5e+04 1e+06 1e+06 1e+04 ...
    ##  $ type          : chr [1:9744] "Free" "Free" "Free" "Free" ...
    ##  $ price         : num [1:9744] 0 0 0 0 0 0 0 0 0 0 ...
    ##  $ content_rating: chr [1:9744] "Everyone" "Everyone" "Everyone" "Teen" ...
    ##  $ genres        : chr [1:9744] "Art & Design" "Art & Design;Pretend Play" "Art & Design" "Art & Design" ...
    ##  $ last_updated  : Date[1:9744], format: "2018-01-07" "2018-01-15" ...
    ##  $ current_ver   : chr [1:9744] "1.0.0" "2.0.0" "1.2.4" "Varies with device" ...
    ##  $ android_ver   : chr [1:9744] "4.0.3 and up" "4.0.3 and up" "4.0.3 and up" "4.2 and up" ...

## 4. Analysis

#### 4.1. Popular Category By Total Reviews

We have known the popularity of the categories based on theirs total
installation. Now, we want to use variable average installation instead
with the codes below.

``` r
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
#previewing table
kable(head(select(highestreviews, !c("app", "no"))))
```

| category      | totalreviews |
|:--------------|-------------:|
| GAME          |    623674697 |
| FAMILY        |    346010311 |
| COMMUNICATION |    285828897 |
| TOOLS         |    229424528 |
| SOCIAL        |    227927801 |
| PHOTOGRAPHY   |    105351270 |

#### 4.2. Popular Category By Total Install

We want to know the most popular category based on the total
installation. We aggregate the total install with the codes below.

``` r
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
#previewing table
kable(head(select(highesttotalinstall, !c("app","no"))))
```

| category      | totalinstalls |
|:--------------|--------------:|
| GAME          |   13928924415 |
| COMMUNICATION |   11039276251 |
| FAMILY        |    8885642505 |
| TOOLS         |    8102771915 |
| PRODUCTIVITY  |    5793091369 |
| SOCIAL        |    5487867902 |

#### 4.3. Popular Category By Average Install

We have known the popularity of the categories based on theirs total
installation and reviews. Now, we want to use variable average
installation instead with the codes below.

``` r
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
#previewing table
kable(head(select(highestaverageinstall, !c("app", "no"))))
```

| category      | averageinstalls |
|:--------------|----------------:|
| COMMUNICATION |        34934419 |
| VIDEO PLAYERS |        23975017 |
| SOCIAL        |        22961790 |
| ENTERTAINMENT |        20722157 |
| PHOTOGRAPHY   |        16545009 |
| PRODUCTIVITY  |        15489549 |

#### 4.4. Total Apps Per Category

We group the data based on category and count the number of apps for
each category with the codes below.

``` r
#Total App Per Category
totalapp <-
playstore %>% 
  group_by(category) %>%
  summarise(totalapp = n()) %>% 
  arrange(desc(totalapp))
#Previewing table
kable(head(totalapp))
```

| category        | totalapp |
|:----------------|---------:|
| Family          |     1909 |
| Game            |      960 |
| Tools           |      829 |
| Business        |      420 |
| Medical         |      396 |
| Personalization |      376 |

#### 4.5. Total Apps vs Total Installs

``` r
#total app vs total installed
totalappvstotalinstalls <-
  playstore %>%
  group_by(category) %>% 
  summarise(totalapp = n(), 
            totalinstalls = sum(installs, na.rm = TRUE),
            averageinstalls = mean(installs, na.rm = TRUE),
            averagerating = mean(rating, na.rm = TRUE),
            .groups = "drop") %>% 
  arrange(desc(totalinstalls))
#Previewing Table
kable(head(totalappvstotalinstalls))
```

| category      | totalapp | totalinstalls | averageinstalls | averagerating |
|:--------------|---------:|--------------:|----------------:|--------------:|
| Game          |      960 |   13928924415 |        14509296 |      4.247645 |
| Communication |      316 |   11039276251 |        34934419 |      4.121401 |
| Family        |     1909 |    8885642505 |         4657045 |      4.187173 |
| Tools         |      829 |    8102771915 |         9774152 |      4.040556 |
| Productivity  |      374 |    5793091369 |        15489549 |      4.183389 |
| Social        |      239 |    5487867902 |        22961790 |      4.247291 |

#### 4.6. Payment Type

We aggregate the numbers of apps that registered either to *Free* or
*Paid* payment type with the codes below.

``` r
#creating summarise table
paymenttype <- 
  playstore %>%
  filter(type != "NaN") %>%
  group_by(type) %>%
  summarise(totalapp = n(),
            averageinstalls = mean(installs)) %>%
  arrange(desc(totalapp))
#previewing the table
kable(paymenttype)
```

| type | totalapp | averageinstalls |
|:-----|---------:|----------------:|
| Free |     8985 |      8890458.84 |
| Paid |      758 |        76340.21 |

#### 4.7. App Population Based On Content Rating

We do not perform any aggregating function here for visualizing the
data, we can see where the apps are populated the most based on content
rating later on in the visualization process. But to show how many apps
listed in each content rating in table, we can try writing this code.

``` r
#creating summarise table
appcontentrating <-
  playstore %>%
  group_by(content_rating) %>%
  summarise(totalapp = n()) %>%
  arrange(desc(totalapp))
#previewing the table
kable(appcontentrating)
```

| content_rating  | totalapp |
|:----------------|---------:|
| Everyone        |     7953 |
| Teen            |     1057 |
| Mature 17+      |      393 |
| Everyone 10+    |      336 |
| Adults only 18+ |        3 |
| Unrated         |        2 |

#### 4.8. Summarizing Top Five Categories

We take five categories, which are popular either from total or average
installation. We summarise the five categories and add three new columns
into the table, including *totalapp*, *totalinstalls*, and
*averageinstalls*

``` r
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
#Previewing The Table
kable(head(sumfivecat))
```

| category      | content_rating | totalapp | totalinstalls |
|:--------------|:---------------|---------:|--------------:|
| Communication | Everyone       |      281 |   10024549591 |
| Communication | Mature 17+     |        8 |     180110010 |
| Communication | Teen           |       27 |     834616650 |
| Family        | Everyone       |     1473 |    5399390608 |
| Family        | Everyone 10+   |      124 |    1256904075 |
| Family        | Mature 17+     |       50 |      63930032 |

#### 4.9. Rating Distribution

To show the rating distribution, we do not need to conduct any
calculations for aggregating the data. We can just use the *playstore*
table to visualize it. Though, if we want to see rating distribution in
a table form, we can write this code.

``` r
#creating rating distribution table
ratingdistribution <-
  playstore %>%
  filter(!is.nan(rating)) %>%
  group_by(rating) %>%
  summarise(totalapp = n()) %>%
  pivot_wider(names_from = "rating",
              values_from = "totalapp")
#previewing the distribution table
kable(ratingdistribution)
```

|   1 | 1.2 | 1.4 | 1.5 | 1.6 | 1.7 | 1.8 | 1.9 |   2 | 2.1 | 2.2 | 2.3 | 2.4 | 2.5 | 2.6 | 2.7 | 2.8 | 2.9 |   3 | 3.1 | 3.2 | 3.3 | 3.4 | 3.5 | 3.6 | 3.7 | 3.8 | 3.9 |   4 | 4.1 | 4.2 | 4.3 | 4.4 | 4.5 | 4.6 | 4.7 | 4.8 | 4.9 |   5 |
|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|
|  16 |   1 |   3 |   3 |   4 |   8 |   8 |  11 |  12 |   8 |  14 |  20 |  19 |  20 |  24 |  23 |  40 |  45 |  81 |  69 |  63 | 100 | 126 | 156 | 167 | 226 | 287 | 361 | 517 | 629 | 816 | 912 | 909 | 862 | 694 | 448 | 221 |  86 | 271 |

#### 4.10. Size Distribution

We also do not need to perform any aggregation for this analysis, there
is a function provided in the `tidyverse` package called
`geom_histogram()` to help plotting the histogram chart. But if we want
to see the size distribution in a form of table, we can use the codes
below.

``` r
#creating size distribution table
sizedistribution <-
  playstore %>%
  filter(!is.na(size)) %>%
  group_by(size) %>%
  summarise(totalapp = n()) %>%
  pivot_wider(names_from = "size",
              values_from = "totalapp")
#previewing the distribution table
kable(sizedistribution)
```

| 0.0085 | 0.011 | 0.014 | 0.017 | 0.018 | 0.02 | 0.023 | 0.024 | 0.025 | 0.026 | 0.027 | 0.028 | 0.029 | 0.033 | 0.034 | 0.039 | 0.041 | 0.044 | 0.045 | 0.048 | 0.05 | 0.051 | 0.054 | 0.055 | 0.058 | 0.061 | 0.067 | 0.07 | 0.072 | 0.073 | 0.074 | 0.078 | 0.079 | 0.081 | 0.082 | 0.089 | 0.091 | 0.093 | 0.097 | 0.103 | 0.108 | 0.116 | 0.118 | 0.121 | 0.122 | 0.141 | 0.143 | 0.144 | 0.153 | 0.154 | 0.157 | 0.16 | 0.161 | 0.164 | 0.169 | 0.17 | 0.172 | 0.173 | 0.175 | 0.176 | 0.186 | 0.19 | 0.191 | 0.192 | 0.193 | 0.196 | 0.2 | 0.201 | 0.203 | 0.206 | 0.208 | 0.209 | 0.21 | 0.219 | 0.22 | 0.221 | 0.222 | 0.226 | 0.228 | 0.232 | 0.234 | 0.237 | 0.238 | 0.239 | 0.24 | 0.241 | 0.243 | 0.245 | 0.246 | 0.251 | 0.253 | 0.257 | 0.259 | 0.266 | 0.269 | 0.27 | 0.28 | 0.283 | 0.288 | 0.292 | 0.293 | 0.306 | 0.308 | 0.309 | 0.313 | 0.314 | 0.317 | 0.318 | 0.319 | 0.322 | 0.323 | 0.329 | 0.334 | 0.335 | 0.35 | 0.351 | 0.353 | 0.364 | 0.371 | 0.373 | 0.375 | 0.376 | 0.378 | 0.383 | 0.387 | 0.4 | 0.404 | 0.411 | 0.412 | 0.414 | 0.417 | 0.42 | 0.421 | 0.429 | 0.43 | 0.437 | 0.442 | 0.444 | 0.454 | 0.458 | 0.459 | 0.46 | 0.467 | 0.47 | 0.473 | 0.475 | 0.478 | 0.485 | 0.496 | 0.498 | 0.499 | 0.5 | 0.506 | 0.511 | 0.514 | 0.516 | 0.518 | 0.523 | 0.525 | 0.526 | 0.54 | 0.544 | 0.545 | 0.549 | 0.551 | 0.552 | 0.554 | 0.556 | 0.562 | 0.569 | 0.582 | 0.585 | 0.592 | 0.597 | 0.598 | 0.6 | 0.601 | 0.608 | 0.609 | 0.613 | 0.619 | 0.624 | 0.626 | 0.629 | 0.636 | 0.642 | 0.643 | 0.647 | 0.655 | 0.656 | 0.658 | 0.663 | 0.676 | 0.683 | 0.688 | 0.691 | 0.695 | 0.696 | 0.704 | 0.705 | 0.713 | 0.714 | 0.716 | 0.717 | 0.72 | 0.721 | 0.728 | 0.73 | 0.743 | 0.746 | 0.749 | 0.754 | 0.756 | 0.772 | 0.775 | 0.778 | 0.779 | 0.78 | 0.782 | 0.784 | 0.785 | 0.787 | 0.801 | 0.809 | 0.811 | 0.812 | 0.816 | 0.818 | 0.837 | 0.84 | 0.842 | 0.847 | 0.853 | 0.857 | 0.86 | 0.861 | 0.862 | 0.865 | 0.872 | 0.874 | 0.879 | 0.881 | 0.885 | 0.887 | 0.892 | 0.898 | 0.899 | 0.902 | 0.903 | 0.904 | 0.913 | 0.914 | 0.916 | 0.92 | 0.921 | 0.924 | 0.93 | 0.939 | 0.94 | 0.942 | 0.948 | 0.951 | 0.953 | 0.954 | 0.957 | 0.961 | 0.963 | 0.965 | 0.97 | 0.975 | 0.976 | 0.98 | 0.981 | 0.982 | 0.986 | 0.992 | 0.994 |   1 | 1.02 | 1.1 | 1.2 | 1.3 | 1.4 | 1.5 | 1.6 | 1.7 | 1.8 | 1.9 |   2 | 2.1 | 2.2 | 2.3 | 2.4 | 2.5 | 2.6 | 2.7 | 2.8 | 2.9 |   3 | 3.1 | 3.2 | 3.3 | 3.4 | 3.5 | 3.6 | 3.7 | 3.8 | 3.9 |   4 | 4.1 | 4.2 | 4.3 | 4.4 | 4.5 | 4.6 | 4.7 | 4.8 | 4.9 |   5 | 5.1 | 5.2 | 5.3 | 5.4 | 5.5 | 5.6 | 5.7 | 5.8 | 5.9 |   6 | 6.1 | 6.2 | 6.3 | 6.4 | 6.5 | 6.6 | 6.7 | 6.8 | 6.9 |   7 | 7.1 | 7.2 | 7.3 | 7.4 | 7.5 | 7.6 | 7.7 | 7.8 | 7.9 |   8 | 8.1 | 8.2 | 8.3 | 8.4 | 8.5 | 8.6 | 8.7 | 8.8 | 8.9 |   9 | 9.1 | 9.2 | 9.3 | 9.4 | 9.5 | 9.6 | 9.7 | 9.8 | 9.9 |  10 |  11 |  12 |  13 |  14 |  15 |  16 |  17 |  18 |  19 |  20 |  21 |  22 |  23 |  24 |  25 |  26 |  27 |  28 |  29 |  30 |  31 |  32 |  33 |  34 |  35 |  36 |  37 |  38 |  39 |  40 |  41 |  42 |  43 |  44 |  45 |  46 |  47 |  48 |  49 |  50 |  51 |  52 |  53 |  54 |  55 |  56 |  57 |  58 |  59 |  60 |  61 |  62 |  63 |  64 |  65 |  66 |  67 |  68 |  69 |  70 |  71 |  72 |  73 |  74 |  75 |  76 |  77 |  78 |  79 |  80 |  81 |  82 |  83 |  84 |  85 |  86 |  87 |  88 |  89 |  90 |  91 |  92 |  93 |  94 |  95 |  96 |  97 |  98 |  99 | 100 |
|-------:|------:|------:|------:|------:|-----:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|-----:|------:|------:|------:|------:|------:|------:|-----:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|-----:|------:|------:|------:|-----:|------:|------:|------:|------:|------:|-----:|------:|------:|------:|------:|----:|------:|------:|------:|------:|------:|-----:|------:|-----:|------:|------:|------:|------:|------:|------:|------:|------:|------:|-----:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|-----:|-----:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|-----:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|----:|------:|------:|------:|------:|------:|-----:|------:|------:|-----:|------:|------:|------:|------:|------:|------:|-----:|------:|-----:|------:|------:|------:|------:|------:|------:|------:|----:|------:|------:|------:|------:|------:|------:|------:|------:|-----:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|----:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|-----:|------:|------:|-----:|------:|------:|------:|------:|------:|------:|------:|------:|------:|-----:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|-----:|------:|------:|------:|------:|-----:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|------:|-----:|------:|------:|-----:|------:|-----:|------:|------:|------:|------:|------:|------:|------:|------:|------:|-----:|------:|------:|-----:|------:|------:|------:|------:|------:|----:|-----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|
|      1 |     1 |     1 |     2 |     2 |    1 |     1 |     1 |     1 |     2 |     1 |     1 |     2 |     2 |     1 |     1 |     1 |     1 |     1 |     1 |    1 |     2 |     1 |     1 |     2 |     1 |     1 |    2 |     2 |     1 |     1 |     1 |     2 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     3 |     1 |     1 |     2 |     1 |     1 |     1 |     1 |     1 |    1 |     1 |     1 |     1 |    1 |     2 |     1 |     1 |     1 |     1 |    1 |     1 |     2 |     1 |     2 |   1 |     3 |     1 |     2 |     1 |     1 |    1 |     1 |    1 |     1 |     1 |     1 |     2 |     1 |     1 |     1 |     1 |     1 |    1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     3 |     1 |    1 |    1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     2 |     1 |     1 |     2 |     1 |     2 |     2 |    1 |     1 |     1 |     2 |     1 |     1 |     3 |     1 |     1 |     1 |     1 |   1 |     1 |     1 |     1 |     1 |     2 |    1 |     1 |     1 |    1 |     1 |     1 |     1 |     1 |     1 |     1 |    1 |     1 |    1 |     2 |     1 |     1 |     1 |     1 |     1 |     1 |   1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |    1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     2 |     1 |     1 |   1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     2 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |    1 |     1 |     1 |    1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |    1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |    1 |     2 |     1 |     1 |     1 |    1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |     1 |    1 |     1 |     1 |    1 |     1 |    1 |     1 |     2 |     1 |     1 |     1 |     2 |     1 |     1 |     1 |    1 |     1 |     1 |    1 |     1 |     1 |     1 |     1 |     1 |   7 |    1 |  32 |  41 |  35 |  36 |  47 |  39 |  40 |  48 |  32 |  48 |  40 |  45 |  68 |  46 |  68 |  49 |  51 |  65 |  67 |  61 |  56 |  55 |  73 |  64 |  51 |  57 |  63 |  60 |  58 |  56 |  50 |  56 |  53 |  41 |  39 |  44 |  33 |  32 |  46 |  54 |  43 |  35 |  44 |  47 |  30 |  30 |  45 |  35 |  34 |  32 |  37 |  30 |  45 |  28 |  31 |  30 |  25 |  25 |  40 |  33 |  24 |  29 |  37 |  27 |  27 |  29 |  26 |  26 |  30 |  23 |  27 |  28 |  29 |  26 |  35 |  24 |  39 |  26 |  27 |  27 |  29 |  33 |  15 |  23 |  23 |  14 |  24 |  30 |  26 | 139 | 183 | 181 | 179 | 178 | 164 | 137 | 147 | 121 | 131 | 125 | 127 | 104 | 105 | 123 | 121 | 143 |  91 |  90 |  92 |  83 |  68 |  59 |  71 |  55 |  64 |  54 |  67 |  51 |  52 |  57 |  42 |  37 |  42 |  60 |  40 |  50 |  35 |  50 |  42 |  36 |  27 |  28 |  33 |  28 |  28 |  26 |  33 |  21 |  27 |  31 |  24 |  25 |  35 |  15 |  10 |  14 |  22 |  15 |  18 |  22 |  13 |  18 |  14 |  14 |   7 |  15 |  12 |  19 |  10 |  12 |  11 |  17 |  12 |   9 |  16 |   7 |   9 |  13 |   9 |   6 |  19 |  12 |  14 |  15 |  16 |  23 |  12 |  14 |  32 |  14 |

#### 4.11. Last Updated Distribution

We can also use the `geom_histogram()` function from `tidyverse` to plot
the data into the histogram chart. Though, we can see the last updated
distribution in a form of table, we use the codes below.

``` r
#creating last updated distribution table
lastupdateddistribution <-
  playstore  %>%
  group_by(last_updated) %>%
  summarise(totalapp = n()) %>%
  pivot_wider(names_from = "last_updated",
              values_from = "totalapp")
#previewing the distribution table
kable(lastupdateddistribution)
```

| 2010-05-21 | 2011-01-30 | 2011-03-16 | 2011-04-11 | 2011-04-16 | 2011-04-18 | 2011-05-12 | 2011-06-23 | 2011-06-26 | 2011-06-29 | 2011-07-10 | 2011-09-20 | 2011-09-22 | 2011-10-12 | 2011-12-01 | 2011-12-03 | 2012-01-12 | 2012-01-17 | 2012-01-18 | 2012-02-06 | 2012-02-08 | 2012-02-27 | 2012-04-09 | 2012-06-01 | 2012-06-17 | 2012-06-19 | 2012-06-27 | 2012-07-20 | 2012-07-30 | 2012-08-17 | 2012-08-18 | 2012-08-24 | 2012-09-19 | 2012-09-27 | 2012-10-08 | 2012-11-08 | 2012-11-11 | 2012-11-22 | 2012-11-26 | 2012-11-28 | 2012-12-19 | 2013-01-25 | 2013-02-03 | 2013-02-10 | 2013-02-11 | 2013-02-12 | 2013-02-15 | 2013-02-18 | 2013-02-22 | 2013-03-06 | 2013-04-05 | 2013-04-10 | 2013-04-22 | 2013-04-25 | 2013-05-02 | 2013-05-06 | 2013-05-09 | 2013-05-14 | 2013-05-18 | 2013-05-21 | 2013-05-22 | 2013-05-25 | 2013-06-02 | 2013-06-04 | 2013-06-05 | 2013-06-12 | 2013-06-15 | 2013-06-25 | 2013-06-26 | 2013-07-01 | 2013-07-03 | 2013-07-17 | 2013-07-18 | 2013-07-20 | 2013-07-26 | 2013-07-27 | 2013-07-31 | 2013-08-01 | 2013-08-07 | 2013-08-08 | 2013-08-09 | 2013-08-10 | 2013-08-14 | 2013-08-15 | 2013-08-16 | 2013-08-17 | 2013-08-19 | 2013-08-22 | 2013-08-26 | 2013-08-27 | 2013-08-30 | 2013-08-31 | 2013-09-04 | 2013-09-05 | 2013-09-08 | 2013-09-11 | 2013-09-13 | 2013-09-16 | 2013-09-19 | 2013-09-23 | 2013-09-24 | 2013-09-25 | 2013-09-27 | 2013-09-28 | 2013-09-30 | 2013-10-01 | 2013-10-04 | 2013-10-07 | 2013-10-11 | 2013-10-22 | 2013-10-28 | 2013-11-01 | 2013-11-05 | 2013-11-12 | 2013-11-13 | 2013-11-18 | 2013-11-20 | 2013-11-22 | 2013-11-25 | 2013-12-02 | 2013-12-05 | 2013-12-12 | 2013-12-13 | 2013-12-17 | 2013-12-18 | 2013-12-19 | 2013-12-23 | 2013-12-26 | 2014-01-08 | 2014-01-11 | 2014-01-13 | 2014-01-15 | 2014-01-17 | 2014-01-19 | 2014-01-20 | 2014-01-21 | 2014-01-22 | 2014-01-23 | 2014-01-24 | 2014-01-28 | 2014-02-02 | 2014-02-05 | 2014-02-06 | 2014-02-11 | 2014-02-12 | 2014-02-13 | 2014-02-16 | 2014-02-17 | 2014-02-18 | 2014-02-21 | 2014-02-22 | 2014-02-23 | 2014-02-26 | 2014-03-03 | 2014-03-05 | 2014-03-06 | 2014-03-07 | 2014-03-09 | 2014-03-11 | 2014-03-13 | 2014-03-20 | 2014-03-23 | 2014-03-25 | 2014-04-04 | 2014-04-10 | 2014-04-11 | 2014-04-13 | 2014-04-17 | 2014-04-22 | 2014-04-23 | 2014-04-25 | 2014-04-30 | 2014-05-01 | 2014-05-03 | 2014-05-06 | 2014-05-14 | 2014-05-16 | 2014-05-18 | 2014-05-19 | 2014-05-20 | 2014-05-24 | 2014-05-26 | 2014-06-03 | 2014-06-05 | 2014-06-06 | 2014-06-09 | 2014-06-13 | 2014-06-17 | 2014-06-24 | 2014-06-30 | 2014-07-01 | 2014-07-02 | 2014-07-03 | 2014-07-04 | 2014-07-06 | 2014-07-09 | 2014-07-10 | 2014-07-11 | 2014-07-12 | 2014-07-18 | 2014-07-23 | 2014-07-26 | 2014-07-28 | 2014-07-30 | 2014-07-31 | 2014-08-02 | 2014-08-04 | 2014-08-05 | 2014-08-07 | 2014-08-09 | 2014-08-11 | 2014-08-12 | 2014-08-17 | 2014-08-19 | 2014-08-21 | 2014-08-25 | 2014-08-26 | 2014-08-27 | 2014-08-28 | 2014-08-30 | 2014-09-06 | 2014-09-10 | 2014-09-12 | 2014-09-16 | 2014-09-20 | 2014-09-22 | 2014-09-30 | 2014-10-02 | 2014-10-06 | 2014-10-07 | 2014-10-10 | 2014-10-11 | 2014-10-16 | 2014-10-17 | 2014-10-18 | 2014-10-22 | 2014-10-25 | 2014-10-28 | 2014-10-29 | 2014-10-30 | 2014-11-03 | 2014-11-04 | 2014-11-05 | 2014-11-06 | 2014-11-09 | 2014-11-10 | 2014-11-12 | 2014-11-13 | 2014-11-14 | 2014-11-15 | 2014-11-20 | 2014-11-21 | 2014-11-25 | 2014-11-26 | 2014-11-27 | 2014-11-30 | 2014-12-02 | 2014-12-03 | 2014-12-04 | 2014-12-06 | 2014-12-09 | 2014-12-13 | 2014-12-15 | 2014-12-17 | 2014-12-18 | 2014-12-22 | 2014-12-26 | 2014-12-29 | 2014-12-31 | 2015-01-01 | 2015-01-07 | 2015-01-08 | 2015-01-09 | 2015-01-11 | 2015-01-13 | 2015-01-14 | 2015-01-15 | 2015-01-18 | 2015-01-19 | 2015-01-20 | 2015-01-22 | 2015-01-25 | 2015-01-26 | 2015-01-30 | 2015-01-31 | 2015-02-02 | 2015-02-03 | 2015-02-05 | 2015-02-10 | 2015-02-11 | 2015-02-12 | 2015-02-13 | 2015-02-14 | 2015-02-15 | 2015-02-18 | 2015-02-20 | 2015-02-23 | 2015-02-25 | 2015-02-27 | 2015-03-04 | 2015-03-05 | 2015-03-06 | 2015-03-08 | 2015-03-09 | 2015-03-10 | 2015-03-11 | 2015-03-12 | 2015-03-13 | 2015-03-14 | 2015-03-16 | 2015-03-17 | 2015-03-20 | 2015-03-21 | 2015-03-22 | 2015-03-25 | 2015-03-26 | 2015-03-27 | 2015-03-29 | 2015-03-30 | 2015-03-31 | 2015-04-02 | 2015-04-03 | 2015-04-07 | 2015-04-10 | 2015-04-14 | 2015-04-15 | 2015-04-20 | 2015-04-23 | 2015-04-24 | 2015-04-26 | 2015-04-29 | 2015-05-01 | 2015-05-02 | 2015-05-04 | 2015-05-06 | 2015-05-08 | 2015-05-10 | 2015-05-11 | 2015-05-13 | 2015-05-14 | 2015-05-15 | 2015-05-16 | 2015-05-19 | 2015-05-21 | 2015-05-24 | 2015-05-25 | 2015-05-26 | 2015-05-27 | 2015-05-30 | 2015-06-03 | 2015-06-04 | 2015-06-05 | 2015-06-06 | 2015-06-08 | 2015-06-09 | 2015-06-10 | 2015-06-11 | 2015-06-14 | 2015-06-15 | 2015-06-16 | 2015-06-17 | 2015-06-18 | 2015-06-19 | 2015-06-23 | 2015-06-24 | 2015-06-25 | 2015-06-26 | 2015-06-28 | 2015-07-01 | 2015-07-02 | 2015-07-06 | 2015-07-07 | 2015-07-10 | 2015-07-11 | 2015-07-14 | 2015-07-15 | 2015-07-16 | 2015-07-17 | 2015-07-18 | 2015-07-19 | 2015-07-23 | 2015-07-25 | 2015-07-26 | 2015-07-28 | 2015-07-29 | 2015-07-30 | 2015-08-01 | 2015-08-03 | 2015-08-05 | 2015-08-06 | 2015-08-07 | 2015-08-08 | 2015-08-10 | 2015-08-11 | 2015-08-12 | 2015-08-13 | 2015-08-16 | 2015-08-18 | 2015-08-20 | 2015-08-21 | 2015-08-22 | 2015-08-24 | 2015-08-25 | 2015-08-26 | 2015-08-28 | 2015-08-30 | 2015-08-31 | 2015-09-01 | 2015-09-02 | 2015-09-03 | 2015-09-05 | 2015-09-06 | 2015-09-07 | 2015-09-08 | 2015-09-09 | 2015-09-11 | 2015-09-12 | 2015-09-13 | 2015-09-14 | 2015-09-15 | 2015-09-17 | 2015-09-21 | 2015-09-22 | 2015-09-23 | 2015-09-24 | 2015-09-25 | 2015-09-26 | 2015-09-27 | 2015-09-29 | 2015-09-30 | 2015-10-01 | 2015-10-02 | 2015-10-03 | 2015-10-04 | 2015-10-05 | 2015-10-07 | 2015-10-08 | 2015-10-09 | 2015-10-11 | 2015-10-12 | 2015-10-13 | 2015-10-14 | 2015-10-15 | 2015-10-16 | 2015-10-17 | 2015-10-19 | 2015-10-20 | 2015-10-21 | 2015-10-22 | 2015-10-26 | 2015-10-27 | 2015-10-29 | 2015-10-30 | 2015-11-02 | 2015-11-03 | 2015-11-04 | 2015-11-05 | 2015-11-08 | 2015-11-09 | 2015-11-11 | 2015-11-12 | 2015-11-13 | 2015-11-14 | 2015-11-16 | 2015-11-19 | 2015-11-20 | 2015-11-23 | 2015-11-25 | 2015-11-26 | 2015-11-27 | 2015-11-28 | 2015-12-01 | 2015-12-03 | 2015-12-04 | 2015-12-07 | 2015-12-08 | 2015-12-09 | 2015-12-10 | 2015-12-11 | 2015-12-14 | 2015-12-15 | 2015-12-16 | 2015-12-17 | 2015-12-18 | 2015-12-19 | 2015-12-20 | 2015-12-21 | 2015-12-22 | 2015-12-23 | 2015-12-24 | 2015-12-26 | 2015-12-28 | 2015-12-30 | 2015-12-31 | 2016-01-01 | 2016-01-04 | 2016-01-05 | 2016-01-07 | 2016-01-08 | 2016-01-10 | 2016-01-11 | 2016-01-12 | 2016-01-13 | 2016-01-15 | 2016-01-16 | 2016-01-17 | 2016-01-18 | 2016-01-19 | 2016-01-20 | 2016-01-23 | 2016-01-24 | 2016-01-25 | 2016-01-26 | 2016-01-27 | 2016-01-29 | 2016-01-30 | 2016-02-01 | 2016-02-02 | 2016-02-03 | 2016-02-04 | 2016-02-05 | 2016-02-07 | 2016-02-08 | 2016-02-09 | 2016-02-10 | 2016-02-11 | 2016-02-12 | 2016-02-15 | 2016-02-16 | 2016-02-17 | 2016-02-18 | 2016-02-19 | 2016-02-20 | 2016-02-22 | 2016-02-23 | 2016-02-24 | 2016-02-25 | 2016-02-26 | 2016-02-27 | 2016-02-29 | 2016-03-01 | 2016-03-02 | 2016-03-03 | 2016-03-04 | 2016-03-05 | 2016-03-07 | 2016-03-08 | 2016-03-10 | 2016-03-11 | 2016-03-12 | 2016-03-14 | 2016-03-15 | 2016-03-16 | 2016-03-17 | 2016-03-18 | 2016-03-19 | 2016-03-20 | 2016-03-21 | 2016-03-22 | 2016-03-23 | 2016-03-24 | 2016-03-25 | 2016-03-28 | 2016-03-29 | 2016-03-30 | 2016-03-31 | 2016-04-01 | 2016-04-02 | 2016-04-03 | 2016-04-04 | 2016-04-05 | 2016-04-06 | 2016-04-07 | 2016-04-08 | 2016-04-10 | 2016-04-11 | 2016-04-12 | 2016-04-13 | 2016-04-14 | 2016-04-15 | 2016-04-17 | 2016-04-19 | 2016-04-20 | 2016-04-21 | 2016-04-22 | 2016-04-23 | 2016-04-24 | 2016-04-25 | 2016-04-27 | 2016-04-28 | 2016-04-29 | 2016-04-30 | 2016-05-01 | 2016-05-02 | 2016-05-03 | 2016-05-04 | 2016-05-05 | 2016-05-07 | 2016-05-09 | 2016-05-10 | 2016-05-11 | 2016-05-12 | 2016-05-13 | 2016-05-14 | 2016-05-15 | 2016-05-16 | 2016-05-17 | 2016-05-18 | 2016-05-19 | 2016-05-22 | 2016-05-23 | 2016-05-25 | 2016-05-26 | 2016-05-27 | 2016-05-29 | 2016-05-30 | 2016-05-31 | 2016-06-01 | 2016-06-02 | 2016-06-03 | 2016-06-06 | 2016-06-07 | 2016-06-08 | 2016-06-09 | 2016-06-10 | 2016-06-11 | 2016-06-13 | 2016-06-14 | 2016-06-15 | 2016-06-16 | 2016-06-17 | 2016-06-18 | 2016-06-19 | 2016-06-20 | 2016-06-21 | 2016-06-22 | 2016-06-23 | 2016-06-24 | 2016-06-25 | 2016-06-27 | 2016-06-28 | 2016-06-29 | 2016-06-30 | 2016-07-01 | 2016-07-04 | 2016-07-05 | 2016-07-07 | 2016-07-08 | 2016-07-09 | 2016-07-10 | 2016-07-11 | 2016-07-12 | 2016-07-13 | 2016-07-14 | 2016-07-15 | 2016-07-16 | 2016-07-18 | 2016-07-19 | 2016-07-20 | 2016-07-21 | 2016-07-22 | 2016-07-23 | 2016-07-24 | 2016-07-25 | 2016-07-26 | 2016-07-27 | 2016-07-28 | 2016-07-29 | 2016-07-30 | 2016-07-31 | 2016-08-02 | 2016-08-03 | 2016-08-04 | 2016-08-05 | 2016-08-06 | 2016-08-07 | 2016-08-08 | 2016-08-09 | 2016-08-10 | 2016-08-12 | 2016-08-13 | 2016-08-14 | 2016-08-15 | 2016-08-16 | 2016-08-18 | 2016-08-19 | 2016-08-20 | 2016-08-23 | 2016-08-24 | 2016-08-26 | 2016-08-27 | 2016-08-28 | 2016-08-29 | 2016-08-31 | 2016-09-01 | 2016-09-03 | 2016-09-04 | 2016-09-05 | 2016-09-06 | 2016-09-07 | 2016-09-08 | 2016-09-09 | 2016-09-10 | 2016-09-11 | 2016-09-12 | 2016-09-13 | 2016-09-14 | 2016-09-15 | 2016-09-16 | 2016-09-17 | 2016-09-19 | 2016-09-20 | 2016-09-21 | 2016-09-22 | 2016-09-23 | 2016-09-26 | 2016-09-27 | 2016-09-28 | 2016-09-29 | 2016-09-30 | 2016-10-01 | 2016-10-02 | 2016-10-03 | 2016-10-04 | 2016-10-05 | 2016-10-06 | 2016-10-07 | 2016-10-08 | 2016-10-10 | 2016-10-12 | 2016-10-13 | 2016-10-14 | 2016-10-16 | 2016-10-17 | 2016-10-18 | 2016-10-19 | 2016-10-20 | 2016-10-21 | 2016-10-22 | 2016-10-23 | 2016-10-24 | 2016-10-25 | 2016-10-26 | 2016-10-27 | 2016-10-28 | 2016-10-30 | 2016-10-31 | 2016-11-01 | 2016-11-02 | 2016-11-03 | 2016-11-04 | 2016-11-05 | 2016-11-06 | 2016-11-07 | 2016-11-08 | 2016-11-09 | 2016-11-10 | 2016-11-11 | 2016-11-14 | 2016-11-15 | 2016-11-16 | 2016-11-17 | 2016-11-18 | 2016-11-19 | 2016-11-20 | 2016-11-21 | 2016-11-22 | 2016-11-23 | 2016-11-24 | 2016-11-25 | 2016-11-26 | 2016-11-28 | 2016-11-29 | 2016-11-30 | 2016-12-01 | 2016-12-02 | 2016-12-03 | 2016-12-04 | 2016-12-05 | 2016-12-06 | 2016-12-07 | 2016-12-08 | 2016-12-09 | 2016-12-10 | 2016-12-11 | 2016-12-12 | 2016-12-13 | 2016-12-14 | 2016-12-15 | 2016-12-16 | 2016-12-17 | 2016-12-18 | 2016-12-19 | 2016-12-20 | 2016-12-21 | 2016-12-22 | 2016-12-23 | 2016-12-24 | 2016-12-25 | 2016-12-26 | 2016-12-29 | 2016-12-30 | 2016-12-31 | 2017-01-02 | 2017-01-03 | 2017-01-04 | 2017-01-05 | 2017-01-06 | 2017-01-07 | 2017-01-08 | 2017-01-09 | 2017-01-10 | 2017-01-11 | 2017-01-12 | 2017-01-13 | 2017-01-14 | 2017-01-15 | 2017-01-16 | 2017-01-17 | 2017-01-18 | 2017-01-19 | 2017-01-20 | 2017-01-21 | 2017-01-22 | 2017-01-23 | 2017-01-24 | 2017-01-25 | 2017-01-26 | 2017-01-27 | 2017-01-28 | 2017-01-29 | 2017-01-30 | 2017-01-31 | 2017-02-01 | 2017-02-02 | 2017-02-03 | 2017-02-04 | 2017-02-05 | 2017-02-06 | 2017-02-07 | 2017-02-08 | 2017-02-09 | 2017-02-10 | 2017-02-11 | 2017-02-12 | 2017-02-13 | 2017-02-14 | 2017-02-15 | 2017-02-16 | 2017-02-17 | 2017-02-18 | 2017-02-20 | 2017-02-21 | 2017-02-22 | 2017-02-23 | 2017-02-24 | 2017-02-25 | 2017-02-26 | 2017-02-27 | 2017-02-28 | 2017-03-01 | 2017-03-02 | 2017-03-03 | 2017-03-04 | 2017-03-05 | 2017-03-06 | 2017-03-07 | 2017-03-08 | 2017-03-09 | 2017-03-10 | 2017-03-11 | 2017-03-12 | 2017-03-13 | 2017-03-14 | 2017-03-15 | 2017-03-16 | 2017-03-17 | 2017-03-19 | 2017-03-20 | 2017-03-21 | 2017-03-22 | 2017-03-23 | 2017-03-24 | 2017-03-25 | 2017-03-26 | 2017-03-27 | 2017-03-28 | 2017-03-29 | 2017-03-30 | 2017-03-31 | 2017-04-01 | 2017-04-02 | 2017-04-03 | 2017-04-04 | 2017-04-05 | 2017-04-06 | 2017-04-08 | 2017-04-10 | 2017-04-11 | 2017-04-12 | 2017-04-13 | 2017-04-14 | 2017-04-15 | 2017-04-16 | 2017-04-17 | 2017-04-18 | 2017-04-19 | 2017-04-20 | 2017-04-21 | 2017-04-22 | 2017-04-23 | 2017-04-24 | 2017-04-25 | 2017-04-26 | 2017-04-27 | 2017-04-28 | 2017-04-29 | 2017-04-30 | 2017-05-01 | 2017-05-02 | 2017-05-03 | 2017-05-04 | 2017-05-05 | 2017-05-08 | 2017-05-09 | 2017-05-10 | 2017-05-11 | 2017-05-12 | 2017-05-13 | 2017-05-14 | 2017-05-15 | 2017-05-16 | 2017-05-17 | 2017-05-18 | 2017-05-19 | 2017-05-20 | 2017-05-22 | 2017-05-23 | 2017-05-24 | 2017-05-25 | 2017-05-26 | 2017-05-27 | 2017-05-29 | 2017-05-30 | 2017-05-31 | 2017-06-01 | 2017-06-02 | 2017-06-03 | 2017-06-04 | 2017-06-05 | 2017-06-06 | 2017-06-07 | 2017-06-08 | 2017-06-09 | 2017-06-10 | 2017-06-11 | 2017-06-12 | 2017-06-13 | 2017-06-14 | 2017-06-15 | 2017-06-16 | 2017-06-17 | 2017-06-18 | 2017-06-19 | 2017-06-20 | 2017-06-21 | 2017-06-22 | 2017-06-23 | 2017-06-24 | 2017-06-25 | 2017-06-26 | 2017-06-27 | 2017-06-28 | 2017-06-29 | 2017-06-30 | 2017-07-01 | 2017-07-02 | 2017-07-03 | 2017-07-04 | 2017-07-05 | 2017-07-06 | 2017-07-07 | 2017-07-08 | 2017-07-09 | 2017-07-10 | 2017-07-11 | 2017-07-12 | 2017-07-13 | 2017-07-14 | 2017-07-15 | 2017-07-16 | 2017-07-17 | 2017-07-18 | 2017-07-19 | 2017-07-20 | 2017-07-21 | 2017-07-22 | 2017-07-23 | 2017-07-24 | 2017-07-25 | 2017-07-26 | 2017-07-27 | 2017-07-28 | 2017-07-29 | 2017-07-30 | 2017-07-31 | 2017-08-01 | 2017-08-02 | 2017-08-03 | 2017-08-04 | 2017-08-05 | 2017-08-06 | 2017-08-07 | 2017-08-08 | 2017-08-09 | 2017-08-10 | 2017-08-11 | 2017-08-12 | 2017-08-13 | 2017-08-14 | 2017-08-15 | 2017-08-16 | 2017-08-17 | 2017-08-18 | 2017-08-19 | 2017-08-20 | 2017-08-21 | 2017-08-22 | 2017-08-23 | 2017-08-24 | 2017-08-25 | 2017-08-26 | 2017-08-27 | 2017-08-28 | 2017-08-29 | 2017-08-30 | 2017-08-31 | 2017-09-01 | 2017-09-02 | 2017-09-03 | 2017-09-04 | 2017-09-05 | 2017-09-06 | 2017-09-07 | 2017-09-08 | 2017-09-09 | 2017-09-10 | 2017-09-11 | 2017-09-12 | 2017-09-13 | 2017-09-14 | 2017-09-15 | 2017-09-17 | 2017-09-18 | 2017-09-19 | 2017-09-20 | 2017-09-21 | 2017-09-22 | 2017-09-23 | 2017-09-24 | 2017-09-25 | 2017-09-26 | 2017-09-27 | 2017-09-28 | 2017-09-29 | 2017-09-30 | 2017-10-01 | 2017-10-02 | 2017-10-03 | 2017-10-04 | 2017-10-05 | 2017-10-06 | 2017-10-07 | 2017-10-09 | 2017-10-10 | 2017-10-11 | 2017-10-12 | 2017-10-13 | 2017-10-14 | 2017-10-15 | 2017-10-16 | 2017-10-17 | 2017-10-18 | 2017-10-19 | 2017-10-20 | 2017-10-21 | 2017-10-22 | 2017-10-23 | 2017-10-24 | 2017-10-25 | 2017-10-26 | 2017-10-27 | 2017-10-28 | 2017-10-29 | 2017-10-30 | 2017-10-31 | 2017-11-01 | 2017-11-02 | 2017-11-03 | 2017-11-04 | 2017-11-05 | 2017-11-06 | 2017-11-07 | 2017-11-08 | 2017-11-09 | 2017-11-10 | 2017-11-11 | 2017-11-12 | 2017-11-13 | 2017-11-14 | 2017-11-15 | 2017-11-16 | 2017-11-17 | 2017-11-18 | 2017-11-19 | 2017-11-20 | 2017-11-21 | 2017-11-22 | 2017-11-23 | 2017-11-24 | 2017-11-25 | 2017-11-26 | 2017-11-27 | 2017-11-28 | 2017-11-29 | 2017-11-30 | 2017-12-01 | 2017-12-02 | 2017-12-03 | 2017-12-04 | 2017-12-05 | 2017-12-06 | 2017-12-07 | 2017-12-08 | 2017-12-09 | 2017-12-10 | 2017-12-11 | 2017-12-12 | 2017-12-13 | 2017-12-14 | 2017-12-15 | 2017-12-16 | 2017-12-17 | 2017-12-18 | 2017-12-19 | 2017-12-20 | 2017-12-21 | 2017-12-22 | 2017-12-23 | 2017-12-24 | 2017-12-25 | 2017-12-26 | 2017-12-27 | 2017-12-28 | 2017-12-29 | 2017-12-30 | 2017-12-31 | 2018-01-01 | 2018-01-02 | 2018-01-03 | 2018-01-04 | 2018-01-05 | 2018-01-06 | 2018-01-07 | 2018-01-08 | 2018-01-09 | 2018-01-10 | 2018-01-11 | 2018-01-12 | 2018-01-13 | 2018-01-14 | 2018-01-15 | 2018-01-16 | 2018-01-17 | 2018-01-18 | 2018-01-19 | 2018-01-20 | 2018-01-21 | 2018-01-22 | 2018-01-23 | 2018-01-24 | 2018-01-25 | 2018-01-26 | 2018-01-27 | 2018-01-28 | 2018-01-29 | 2018-01-30 | 2018-01-31 | 2018-02-01 | 2018-02-02 | 2018-02-03 | 2018-02-04 | 2018-02-05 | 2018-02-06 | 2018-02-07 | 2018-02-08 | 2018-02-09 | 2018-02-10 | 2018-02-11 | 2018-02-12 | 2018-02-13 | 2018-02-14 | 2018-02-15 | 2018-02-16 | 2018-02-17 | 2018-02-18 | 2018-02-19 | 2018-02-20 | 2018-02-21 | 2018-02-22 | 2018-02-23 | 2018-02-24 | 2018-02-25 | 2018-02-26 | 2018-02-27 | 2018-02-28 | 2018-03-01 | 2018-03-02 | 2018-03-03 | 2018-03-04 | 2018-03-05 | 2018-03-06 | 2018-03-07 | 2018-03-08 | 2018-03-09 | 2018-03-10 | 2018-03-11 | 2018-03-12 | 2018-03-13 | 2018-03-14 | 2018-03-15 | 2018-03-16 | 2018-03-17 | 2018-03-18 | 2018-03-19 | 2018-03-20 | 2018-03-21 | 2018-03-22 | 2018-03-23 | 2018-03-24 | 2018-03-25 | 2018-03-26 | 2018-03-27 | 2018-03-28 | 2018-03-29 | 2018-03-30 | 2018-03-31 | 2018-04-01 | 2018-04-02 | 2018-04-03 | 2018-04-04 | 2018-04-05 | 2018-04-06 | 2018-04-07 | 2018-04-08 | 2018-04-09 | 2018-04-10 | 2018-04-11 | 2018-04-12 | 2018-04-13 | 2018-04-14 | 2018-04-15 | 2018-04-16 | 2018-04-17 | 2018-04-18 | 2018-04-19 | 2018-04-20 | 2018-04-21 | 2018-04-22 | 2018-04-23 | 2018-04-24 | 2018-04-25 | 2018-04-26 | 2018-04-27 | 2018-04-28 | 2018-04-29 | 2018-04-30 | 2018-05-01 | 2018-05-02 | 2018-05-03 | 2018-05-04 | 2018-05-05 | 2018-05-06 | 2018-05-07 | 2018-05-08 | 2018-05-09 | 2018-05-10 | 2018-05-11 | 2018-05-12 | 2018-05-13 | 2018-05-14 | 2018-05-15 | 2018-05-16 | 2018-05-17 | 2018-05-18 | 2018-05-19 | 2018-05-20 | 2018-05-21 | 2018-05-22 | 2018-05-23 | 2018-05-24 | 2018-05-25 | 2018-05-26 | 2018-05-27 | 2018-05-28 | 2018-05-29 | 2018-05-30 | 2018-05-31 | 2018-06-01 | 2018-06-02 | 2018-06-03 | 2018-06-04 | 2018-06-05 | 2018-06-06 | 2018-06-07 | 2018-06-08 | 2018-06-09 | 2018-06-10 | 2018-06-11 | 2018-06-12 | 2018-06-13 | 2018-06-14 | 2018-06-15 | 2018-06-16 | 2018-06-17 | 2018-06-18 | 2018-06-19 | 2018-06-20 | 2018-06-21 | 2018-06-22 | 2018-06-23 | 2018-06-24 | 2018-06-25 | 2018-06-26 | 2018-06-27 | 2018-06-28 | 2018-06-29 | 2018-06-30 | 2018-07-01 | 2018-07-02 | 2018-07-03 | 2018-07-04 | 2018-07-05 | 2018-07-06 | 2018-07-07 | 2018-07-08 | 2018-07-09 | 2018-07-10 | 2018-07-11 | 2018-07-12 | 2018-07-13 | 2018-07-14 | 2018-07-15 | 2018-07-16 | 2018-07-17 | 2018-07-18 | 2018-07-19 | 2018-07-20 | 2018-07-21 | 2018-07-22 | 2018-07-23 | 2018-07-24 | 2018-07-25 | 2018-07-26 | 2018-07-27 | 2018-07-28 | 2018-07-29 | 2018-07-30 | 2018-07-31 | 2018-08-01 | 2018-08-02 | 2018-08-03 | 2018-08-04 | 2018-08-05 | 2018-08-06 | 2018-08-07 | 2018-08-08 |
|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|-----------:|
|          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          2 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          3 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          2 |          2 |          2 |          1 |          1 |          2 |          1 |          1 |          2 |          1 |          2 |          1 |          1 |          1 |          2 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          2 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          3 |          1 |          1 |          2 |          1 |          1 |          2 |          2 |          1 |          2 |          1 |          1 |          2 |          2 |          1 |          1 |          2 |          1 |          1 |          3 |          1 |          1 |          1 |          1 |          1 |          1 |          2 |          1 |          1 |          1 |          2 |          1 |          1 |          3 |          1 |          1 |          1 |          1 |          1 |          1 |          2 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          3 |          2 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          4 |          1 |          1 |          2 |          1 |          1 |          1 |          1 |          1 |          1 |          1 |          2 |          1 |          3 |          1 |          3 |          1 |          1 |          3 |          1 |          3 |          1 |          1 |          1 |          1 |          2 |          1 |          1 |          1 |          2 |          2 |          2 |          2 |          1 |          2 |          2 |          2 |          1 |          1 |          2 |          1 |          1 |          1 |          3 |          1 |          2 |          3 |          1 |          1 |          1 |          1 |          1 |          1 |          2 |          2 |          1 |          2 |          1 |          2 |          2 |          1 |          1 |          2 |          1 |          2 |          4 |          1 |          1 |          1 |          1 |          1 |          1 |          2 |          1 |          1 |          2 |          1 |          1 |          1 |          1 |          2 |          3 |          3 |          3 |          1 |          2 |          1 |          1 |          2 |          2 |          2 |          2 |          1 |          1 |          3 |          1 |          2 |          1 |          1 |          1 |          1 |          1 |          2 |          3 |          1 |          1 |          1 |          1 |          1 |          3 |          2 |          2 |          1 |          1 |          2 |          1 |          1 |          2 |          3 |          1 |          3 |          3 |          1 |          1 |          2 |          1 |          1 |          2 |          1 |          1 |          1 |          3 |          2 |          2 |          1 |          2 |          1 |          2 |          4 |          1 |          4 |          1 |          3 |          2 |          2 |          1 |          1 |          1 |          4 |          1 |          2 |          1 |          3 |          3 |          1 |          2 |          1 |          1 |          3 |          1 |          1 |          1 |          2 |          1 |          1 |          3 |          2 |          2 |          2 |          1 |          1 |          2 |          2 |          1 |          7 |          2 |          1 |          3 |          3 |          4 |          3 |          2 |          3 |          1 |          1 |          2 |          2 |          1 |          4 |          1 |          1 |          1 |          4 |          5 |          2 |          2 |          4 |          2 |          1 |          4 |          2 |          1 |          3 |          1 |          1 |          2 |          1 |          2 |          3 |          2 |          1 |          1 |          1 |          1 |          5 |          3 |          3 |          4 |          1 |          2 |          2 |          2 |          2 |          2 |          2 |          3 |          1 |          3 |          2 |          2 |          4 |          1 |          3 |          3 |          3 |          2 |          4 |          1 |          1 |          4 |          3 |          3 |          3 |          3 |          2 |          1 |          1 |          4 |          1 |          1 |          1 |          3 |          3 |          2 |          2 |          1 |          5 |          1 |          1 |          1 |          1 |          2 |          1 |          1 |          1 |          1 |          3 |          1 |          4 |          2 |          1 |          2 |          3 |          1 |          3 |          1 |          3 |          1 |          2 |          3 |          1 |          3 |          2 |          1 |          6 |          1 |          1 |          2 |          1 |          1 |          3 |          3 |          2 |          4 |          3 |          1 |          2 |          2 |          1 |          1 |          3 |          2 |          1 |          1 |          2 |          3 |          3 |          1 |          2 |          1 |          2 |          1 |          1 |          5 |          2 |          2 |          1 |          1 |          3 |          3 |          3 |          2 |          1 |          3 |          1 |          2 |          1 |          2 |          1 |          1 |          2 |          1 |          1 |          1 |          1 |          3 |          1 |          2 |          1 |          3 |          2 |          1 |          3 |          5 |          2 |          2 |          2 |          2 |          1 |          3 |          4 |          1 |          3 |          2 |          1 |          3 |          1 |          1 |          3 |          1 |          2 |          2 |          1 |          2 |          1 |          3 |          1 |          3 |          3 |          2 |          1 |          2 |          3 |          2 |          1 |          3 |          1 |          2 |          1 |          3 |          2 |          1 |          4 |          3 |          2 |          2 |          3 |          1 |          1 |          1 |          3 |          1 |          2 |          2 |          1 |          1 |          1 |          2 |          3 |          2 |          1 |          2 |          2 |          1 |          2 |          1 |          3 |          1 |          2 |          2 |          2 |          1 |          1 |          1 |          1 |          4 |          4 |          1 |          1 |          3 |          2 |          4 |          2 |          1 |          1 |          1 |          1 |          4 |          1 |          2 |          2 |          1 |          2 |          4 |          1 |          2 |          1 |          3 |          2 |          2 |          1 |          2 |          2 |          1 |          3 |          4 |          2 |          3 |          1 |          3 |          1 |          3 |          2 |          2 |          8 |          4 |          1 |          1 |          5 |          1 |          3 |          2 |          4 |          1 |          2 |          2 |          5 |          5 |          2 |          2 |          1 |          2 |          2 |          7 |          5 |          3 |          3 |          4 |          4 |          6 |          2 |          1 |          2 |          2 |          3 |          1 |          6 |          2 |          3 |          5 |          1 |          4 |          6 |          4 |          2 |          1 |          5 |          2 |          4 |          3 |          2 |          2 |          2 |          1 |          4 |          4 |          2 |          3 |          2 |          6 |          1 |          3 |          1 |          1 |          3 |          2 |          5 |          1 |          1 |          3 |          2 |          3 |          2 |          1 |          2 |          3 |          1 |          1 |          1 |          2 |          5 |          1 |          2 |          2 |          3 |          1 |          4 |          4 |          3 |          1 |          4 |          2 |          1 |          6 |          3 |          2 |          2 |          1 |          4 |          2 |          6 |          4 |          2 |          5 |          4 |          1 |          4 |          3 |          6 |          4 |          1 |          3 |          3 |          1 |          2 |          3 |          5 |          5 |          5 |          4 |          2 |          3 |          4 |          5 |          5 |          4 |          3 |          1 |          2 |          5 |          3 |          4 |          1 |          2 |          2 |          6 |          2 |          2 |          2 |          3 |          2 |          3 |          4 |          3 |          2 |          2 |          2 |          4 |          5 |          2 |          1 |          2 |          1 |          5 |          2 |         10 |          5 |          3 |          2 |          2 |          1 |          4 |          4 |          3 |          1 |          3 |          2 |          3 |          1 |          3 |          4 |          3 |          2 |          1 |          3 |          3 |          6 |          5 |          6 |          1 |          6 |          4 |          1 |          2 |          4 |          1 |          3 |          4 |          4 |          4 |          2 |          5 |          5 |          3 |          2 |          4 |          3 |          3 |          1 |          7 |          3 |          2 |          6 |          2 |          4 |          2 |          6 |          4 |          2 |          4 |          5 |          1 |          1 |          1 |          5 |          5 |          7 |          5 |          3 |         24 |          4 |          1 |          4 |          7 |          1 |          2 |          3 |          1 |          3 |          3 |          2 |          8 |          3 |          1 |          8 |          5 |          6 |          4 |          3 |          4 |          6 |          4 |          6 |          5 |          6 |          2 |          3 |          4 |          5 |          5 |          2 |          3 |          5 |          1 |          1 |         13 |         12 |          4 |          4 |          2 |          4 |          5 |          5 |          9 |          1 |          2 |          3 |          3 |          5 |          2 |          3 |          3 |          4 |          1 |          4 |          4 |          4 |          5 |          2 |          1 |          4 |          7 |          2 |          2 |          2 |          1 |          1 |          4 |          4 |          1 |          3 |          4 |          5 |          1 |          5 |          6 |          4 |          5 |          3 |          1 |          5 |          3 |          7 |          5 |          3 |          7 |         11 |          5 |          5 |          5 |          1 |          1 |          8 |          4 |          8 |          7 |          2 |          1 |          3 |          3 |          3 |          1 |          3 |          2 |          7 |          6 |          5 |          7 |          6 |          4 |          1 |          3 |          5 |         10 |          4 |          3 |          2 |          1 |          3 |          5 |          2 |          4 |          5 |          2 |          5 |          3 |          4 |          4 |          1 |          2 |          1 |          4 |          4 |          6 |          4 |          3 |          3 |          1 |          1 |          4 |          3 |          4 |          4 |          9 |          1 |          3 |          8 |          3 |          5 |         10 |          5 |          2 |          3 |          8 |          5 |          4 |          2 |          3 |          5 |          4 |          6 |          6 |          3 |          2 |          6 |          8 |          2 |          5 |          6 |          8 |          5 |          4 |          2 |          1 |          2 |          4 |          8 |          9 |          4 |          5 |          2 |          8 |          4 |          3 |         14 |          4 |          2 |          5 |          7 |          6 |          9 |          6 |          1 |          1 |          2 |          7 |          7 |          8 |          9 |          6 |          2 |          2 |          2 |          6 |          1 |          6 |          5 |          1 |          3 |          3 |         11 |          4 |          8 |          5 |          2 |          4 |          9 |         16 |         15 |          7 |          2 |          1 |          6 |          6 |         13 |          5 |          4 |          3 |          2 |          6 |          8 |          5 |          7 |          9 |          5 |         12 |         10 |          5 |         16 |          3 |          2 |          5 |          7 |          7 |         14 |          8 |          7 |          5 |          3 |          6 |          7 |          8 |         11 |         11 |          5 |          2 |          7 |         12 |          9 |          8 |         11 |          1 |          2 |          8 |         11 |          6 |          7 |         10 |          1 |          3 |          8 |          6 |          7 |          7 |          6 |          3 |          6 |          7 |         14 |          8 |          8 |          9 |          2 |          3 |          8 |          8 |         12 |          6 |         10 |          3 |          5 |         10 |         10 |          5 |         10 |         14 |          2 |          4 |         10 |          5 |         11 |         13 |          6 |          4 |          3 |         13 |         11 |         16 |         14 |          9 |          3 |         10 |         10 |          9 |          8 |          5 |          7 |          4 |          4 |          4 |         16 |         12 |          8 |         11 |         10 |          6 |          7 |         15 |          8 |          4 |          9 |          4 |          9 |         10 |          6 |         19 |          8 |         14 |          9 |          5 |         14 |         11 |          9 |         12 |          8 |          2 |          2 |         11 |         13 |         14 |         18 |          9 |          5 |          6 |          7 |         15 |         15 |          3 |         17 |          6 |          6 |          9 |         12 |         12 |         15 |         16 |          7 |          3 |         12 |         13 |         15 |          7 |         14 |          9 |          9 |         13 |         13 |         11 |         10 |          7 |          7 |          4 |         23 |         22 |          9 |         11 |         16 |         10 |          5 |         10 |         19 |         15 |         12 |         23 |         13 |          7 |         14 |         19 |         11 |         14 |         17 |          6 |          4 |         19 |         17 |         20 |         17 |         16 |         12 |          5 |         15 |         20 |         14 |         19 |         12 |          6 |          3 |         16 |         15 |         17 |         17 |         16 |          2 |          7 |         14 |         21 |         17 |         14 |         15 |          4 |         10 |         21 |         13 |         12 |         31 |         16 |          7 |          6 |         11 |         12 |         17 |         19 |         25 |          7 |         13 |         10 |         14 |         20 |         23 |          9 |         12 |          8 |         14 |         29 |         15 |         20 |         31 |         13 |         13 |         30 |         41 |         40 |         59 |         49 |         14 |         10 |         29 |         32 |         33 |         33 |         27 |         12 |          8 |         20 |         38 |         43 |         32 |         34 |         22 |          9 |         35 |         37 |         50 |         34 |         37 |          9 |          4 |         34 |         41 |         36 |         45 |         26 |          8 |         10 |         53 |         55 |         53 |         43 |         47 |         19 |         22 |         45 |         81 |         50 |         76 |         53 |         24 |         22 |         81 |         43 |         88 |         86 |         74 |         15 |         26 |         96 |         83 |        100 |        100 |         72 |         25 |         21 |        111 |        121 |        129 |        138 |        122 |         49 |         37 |        164 |        211 |        211 |        232 |        257 |         86 |         45 |        116 |         37 |          5 |

#### 4.12. Top Genres In The Top Five Categories

``` r
topgenres <-
  playstore %>%
  group_by(category, genres) %>%
  summarise(reviews = sum(reviews), total = n()) %>%
  arrange(desc(reviews), desc(total))

topgenregame <- 
  topgenres %>%
  filter(category == "Game") %>% 
  slice_head(n=1)

topgenrecommunication <- 
  topgenres %>%
  filter(category == "Communication") %>% 
  slice_head(n=1)

topgenresocial <- 
  topgenres %>%
  filter(category == "Social") %>% 
  slice_head(n=1)

topgenrevideoplayers <- 
  topgenres %>%
  filter(category == "Video Players") %>% 
  slice_head(n=1)

topgenrefamily <-
  topgenres %>%
  filter(category == "Family") %>% 
  slice_head(n=1)

topgenres <-
    topgenregame  %>%
    union_all(topgenrecommunication) %>%
    union_all(topgenresocial) %>%
    union_all(topgenrevideoplayers) %>%
    union_all(topgenrefamily)

kable(topgenres)
```

| category      | genres                  |   reviews | total |
|:--------------|:------------------------|----------:|------:|
| Game          | Action                  | 150947180 |   299 |
| Communication | Communication           | 285828897 |   316 |
| Social        | Social                  | 227927801 |   239 |
| Video Players | Video Players & Editors |  67365366 |   162 |
| Family        | Casual                  | 104050863 |   148 |

Those are the genres that are popular in each category. Next, we want to
know the competitors in each genre.

#### 4.13. Listing Top 10 Apps Based On Genre

**Action**, **Communication**, **Social**, **Video Players & Editors**,
and **Casual** are the genres that we want to focus on for further
analysis. We want to see who are the competitors in each category. We
use the codes below to list the top apps from each genre.

``` r
topapp <-
  playstore %>%
  group_by(genres, app) %>%
  summarise(reviews = sum(reviews), total = n(), price = sum(price)) %>%
  arrange(desc(reviews), desc(total))

topgame <- 
  topapp %>%
  filter(genres == "Action") %>% 
  slice_head(n=10)

topcommunication <- 
  topapp %>%
  filter(genres == "Communication") %>% 
  slice_head(n=10)

topsocial <- 
  topapp %>%
  filter(genres == "Social") %>% 
  slice_head(n=10)

topvideoplayers <- 
  topapp %>%
  filter(genres == "Video Players & Editors") %>% 
  slice_head(n=10)

topcasual <-
  topapp %>%
  filter(genres == "Casual") %>% 
  slice_head(n=10)

top <-
  topgame  %>%
    union_all(topcommunication) %>%
    union_all(topsocial) %>%
    union_all(topvideoplayers) %>%
    union_all(topcasual) 

topgenreapp <-
  top %>%
    mutate(no = rep(1:10, 1)) %>%
    select(no, app, genres)

#preview in wider table
kable(topgenreapp %>%
        pivot_wider(names_from = "genres",
                    values_from = "app"))
```

|  no | Action                                           | Communication                                     | Social                         | Video Players & Editors                            | Casual                |
|----:|:-------------------------------------------------|:--------------------------------------------------|:-------------------------------|:---------------------------------------------------|:----------------------|
|   1 | Shadow Fight 2                                   | WhatsApp Messenger                                | Facebook                       | YouTube                                            | Candy Crush Saga      |
|   2 | Mobile Legends: Bang Bang                        | Messenger – Text and Video Chat for Free          | Instagram                      | VivaVideo - Video Editor & Photo Movie             | My Talking Tom        |
|   3 | Temple Run 2                                     | UC Browser - Fast Download Private & Secure       | Snapchat                       | MX Player                                          | Pou                   |
|   4 | Sniper 3D Gun Shooter: Free Shooting Games - FPS | BBM - Free Calls & Messages                       | Facebook Lite                  | VideoShow-Video Editor, Video Maker, Beauty Camera | My Talking Angela     |
|   5 | Garena Free Fire                                 | Viber Messenger                                   | VK                             | DU Recorder – Screen Recorder, Video Editor, Live  | Farm Heroes Saga      |
|   6 | slither.io                                       | LINE: Free Calls & Messages                       | Tik Tok - including musical.ly | Dubsmash                                           | Yes day               |
|   7 | Gangstar Vegas - mafia game                      | Skype - free IM & video calls                     | Google+                        | Vigo Video                                         | Hay Day               |
|   8 | Pixel Gun 3D: Survival shooter & Battle Royale   | Google Chrome: Fast & Secure                      | Pinterest                      | VLC for Android                                    | Angry Birds 2         |
|   9 | Crossy Road                                      | Truecaller: Caller ID, SMS spam blocking & Dialer | Tango - Live Video Broadcast   | KineMaster – Pro Video Editor                      | Candy Crush Soda Saga |
|  10 | DEER HUNTER CLASSIC                              | WeChat                                            | Badoo - Free Chat & Dating App | Magisto Video Editor & Maker                       | Township              |

#### 4.14. Prices Of Top Ten Apps In Each Genre

We want to know what payment type the apps use in each genre.

``` r
toppricesapp <-
   top %>%
    mutate(type = case_when(price == 0 ~ "Free",
                            .default = "Paid")) %>%
    select(app, type)

#preview in wider table
kable(head(toppricesapp))
```

| genres | app                                              | type |
|:-------|:-------------------------------------------------|:-----|
| Action | Shadow Fight 2                                   | Free |
| Action | Mobile Legends: Bang Bang                        | Free |
| Action | Temple Run 2                                     | Free |
| Action | Sniper 3D Gun Shooter: Free Shooting Games - FPS | Free |
| Action | Garena Free Fire                                 | Free |
| Action | slither.io                                       | Free |

## 5. Visualization

#### 5.1. Popular Category By Total Reviews

![](Google_Playstore_Analysis_29_02_2024_v01_files/figure-gfm/Most%20Popular%20Category%20By%20Reviews-1.png)<!-- -->

Based on the reviews, **Game**, **Family**, and **Communication**
categories have the highest numbers of reviews.

#### 5.2. Popular Category by Total Install

![](Google_Playstore_Analysis_29_02_2024_v01_files/figure-gfm/Most%20Popular%20Category%20By%20Total%20Install-1.png)<!-- -->

Based on total install, **Game**, **Communication**, and **Family**
categories are the most popular among the others. They both have highest
total install. We can consider to create an app in **Game**,
**Communication**, and **Family** categories.

#### 5.3. Popular Category By Average Install

![](Google_Playstore_Analysis_29_02_2024_v01_files/figure-gfm/Most%20Popular%20Category%20By%20Average%20Install-1.png)<!-- -->

Based on the average install, **Communication**, **Video Players**, and
**Social** categories have the highest numbers of average install.
**Communication** category remains popular even when it comes to average
install. We see the game does not stand next to **Communication**
category anymore. Why? We will see the reason in the next visualization.
We also add **Video Players** and **Social** to the list of
considerations to develop an app.

#### 5.4. Total App Listed

![](Google_Playstore_Analysis_29_02_2024_v01_files/figure-gfm/Total%20App%20Listed-1.png)<!-- -->

**Family** along with **Game** category sit on the top of the chart.
There are more competitors in this category, but we can still to put
**Game** and **Family** categories for consideration to develop an app.
These two categories are popular in terms of apps created.

#### 5.5. Payment Type

##### 5.5.1. Total Apps

![](Google_Playstore_Analysis_29_02_2024_v01_files/figure-gfm/Total%20Apps%20Based%20On%20Payment%20Type%20Chart-1.png)<!-- -->

Only a few apps use the *Paid* payment method.

##### 5.5.2. Average Installs

![](Google_Playstore_Analysis_29_02_2024_v01_files/figure-gfm/Average%20Installs%20Based%20On%20Payment%20Type%20Chart-1.png)<!-- -->

If we compare both payment types in terms of average installs, the
difference is too high. If we want to develop an app, and want to
compete and survive longer, we need to avoid using *Paid* payment types,
instead we can use in-app purchases.

#### 5.6. App Population Based On Content Rating

![](Google_Playstore_Analysis_29_02_2024_v01_files/figure-gfm/App%20population%20Based%20On%20Content%20Rating%20Chart-1.png)<!-- -->

We see lots of dots swarming *Everyone* area, it means most applications
are listed with *everyone* content rating, followed by the *teen* and
*mature*. There are only few apps in *Adults only 18+* content rating.

#### 5.7. Distribution

![](Google_Playstore_Analysis_29_02_2024_v01_files/figure-gfm/Rating%20Distribution%20Chart-1.png)<!-- -->

![](Google_Playstore_Analysis_29_02_2024_v01_files/figure-gfm/Size%20Distribution%20Chart-1.png)<!-- -->

![](Google_Playstore_Analysis_29_02_2024_v01_files/figure-gfm/Last%20Updated%20Distribution%20Chart-1.png)<!-- -->

#### 5.8. Analysis on 5 Categories

At this point, we want to focus the analysis on the five popular
categories:

- **Game**
- **Communication**
- **Social**
- **Video Players**
- **Family**

##### 5.8.1. Total Apps Listed

![](Google_Playstore_Analysis_29_02_2024_v01_files/figure-gfm/Total%20App%20Based%20on%20Content%20Rating%20By%20five%20Categories-1.png)<!-- -->

We see that **Family**, **Game**, **Communication**, and **Video
Players** categories have most of their total apps with *Everyone*,
followed by *Teen* and *Mature* content ratings, while **Social**
category have more *Teen* rating app listed, followed by *Everyone* and
*Mature* rating apps.

If we want to develop an app, we consider to develop:

- *Everyone* content rating app for **Family**, **Game**, or
  **Communication** category
- *Teen* content rating app for **Social** and **Video Players**
  category

##### 5.8.2. Total Installation

![](Google_Playstore_Analysis_29_02_2024_v01_files/figure-gfm/Total%20Installs%20Based%20On%20Content%20Rating-1.png)<!-- -->

We see in the **Family**, **Game**, and **Communication** categories,
most apps installed in *Everyone* rating, while **Social** and **Video
Players** categories have more apps installed in *Teen* content rating.

##### 5.8.3. Distribution

![](Google_Playstore_Analysis_29_02_2024_v01_files/figure-gfm/Rating%20Distribution%20Of%205%20Categories-1.png)<!-- -->

We do not see big difference among the five categories in terms of
rating distribution, they have most apps that rated between 4 and 5.

![](Google_Playstore_Analysis_29_02_2024_v01_files/figure-gfm/Size%20Distribution%20of%205%20Categories-1.png)<!-- -->

In the **Communication**, **Social**, and **Video Players** Categories,
the apps overall made below 50 Mb, while in the **Game** and **Family**
categories, the size are more varied, between 1 - 100 Mb.

![](Google_Playstore_Analysis_29_02_2024_v01_files/figure-gfm/Last%20Updated%20Distribution%20Of%205%20Categories-1.png)<!-- -->

There is no difference among them related to the last updated
distribution, most of the apps in the five categories are keep updating
throughout the time. Since this data was scraped in 2018 or 2019, these
charts tell us that most of the apps survived and keep updating their
app until the end of 2018.

##### 5.8.4. Top Genres In Each Category

![](Google_Playstore_Analysis_29_02_2024_v01_files/figure-gfm/Top%20Genres%20In%20Each%20Category-1.png)<!-- -->

##### 5.8.5. Top 10 Apps In Each Genre

Here we will see the top ten apps listed by total installs and reviews.

|  no | Action                                           | Communication                                     | Social                         | Video Players & Editors                            | Casual                |
|----:|:-------------------------------------------------|:--------------------------------------------------|:-------------------------------|:---------------------------------------------------|:----------------------|
|   1 | Shadow Fight 2                                   | WhatsApp Messenger                                | Facebook                       | YouTube                                            | Candy Crush Saga      |
|   2 | Mobile Legends: Bang Bang                        | Messenger – Text and Video Chat for Free          | Instagram                      | VivaVideo - Video Editor & Photo Movie             | My Talking Tom        |
|   3 | Temple Run 2                                     | UC Browser - Fast Download Private & Secure       | Snapchat                       | MX Player                                          | Pou                   |
|   4 | Sniper 3D Gun Shooter: Free Shooting Games - FPS | BBM - Free Calls & Messages                       | Facebook Lite                  | VideoShow-Video Editor, Video Maker, Beauty Camera | My Talking Angela     |
|   5 | Garena Free Fire                                 | Viber Messenger                                   | VK                             | DU Recorder – Screen Recorder, Video Editor, Live  | Farm Heroes Saga      |
|   6 | slither.io                                       | LINE: Free Calls & Messages                       | Tik Tok - including musical.ly | Dubsmash                                           | Yes day               |
|   7 | Gangstar Vegas - mafia game                      | Skype - free IM & video calls                     | Google+                        | Vigo Video                                         | Hay Day               |
|   8 | Pixel Gun 3D: Survival shooter & Battle Royale   | Google Chrome: Fast & Secure                      | Pinterest                      | VLC for Android                                    | Angry Birds 2         |
|   9 | Crossy Road                                      | Truecaller: Caller ID, SMS spam blocking & Dialer | Tango - Live Video Broadcast   | KineMaster – Pro Video Editor                      | Candy Crush Soda Saga |
|  10 | DEER HUNTER CLASSIC                              | WeChat                                            | Badoo - Free Chat & Dating App | Magisto Video Editor & Maker                       | Township              |

We acknowledge these apps as competitors. If we see the table above, top
ten apps in the **Casual** and **Action** genres are mobile games. We
can say that mobile games are more popular than we thought, even the
**Family** category can be this popular because it has games that boost
its total reviews and installation numbers. From the previous charts, we
also knew that these two categories of the two genres, have the most
listed apps in the store. There are plenty of genres of mobile games,
which make the invention of new ideas broader and easier than creating
the other types of apps.

Meanwhile, in the other genres, like **Communication**, **Social**, and
**Video Players & Editors**, the top ten apps listed are mostly made by
big companies, like Meta, ByteDance, Google, Naver, etc. Even though
they have less competitors than mobile games from **Action** and
**Casual** genres, it’s difficult to climb up the ladder. This explains
why the total number of listed apps or competitors in these three genres
is less, as newcomers need extra effort to break into the top ten. It is
also more difficult to invent new ideas in those genres and categories
compared to the mobile games.

##### 5.8.6. Prices Of Apps In Each Genre

![](Google_Playstore_Analysis_29_02_2024_v01_files/figure-gfm/Prices%20of%20Apps%20In%20Each%20Genre-1.png)<!-- -->

None of the apps use the *Paid* payment type. We don’t know if the apps
have other payment systems, such as in-app purchases for example. The
data set does not provide any data about it. But, using the *Pay* before
download will not be the best option to choose. We can consider to earn
money from other sources, like from ads, premium membership, selling
in-app items, etc.

## 6. Key Findings

Overall conditions of the market:

- There are five categories that can be considered as the best options
  to choose for developing an app, which are **Game**, **Family**,
  **Social**, **Communication**, and **Video Players**.
- Apps with *Free* payment type has a lot more installs than the *Paid*
  payment type apps.
- Most apps are *Everyone* rated, followed by *Teen* and *Mature 17+*,
  there are only a few apps listed in *Adults only 18+*.
- Most apps have a 4 stars rating
- Most apps are under 50 Mb
- Most apps are up-to-date

Specific conditions in top five categories:

- **Family**, **Game**, and **Communication** categories mostly are
  *Everyone* rated, while **Social** and **Video Players** mostly are
  *Teen* rated.
- Most apps have a 4 stars rating in the five top categories.
- **Communication**, **Social**, and **Video Players** categories mostly
  have apps under 50 Mb, while app sizes in the **Family** and **Game**
  categories vary more
- **Communication**, **Casual**, **Action**, **Social**, and **Video
  Players & Editors** are genres that we could put as considerations
  based on the top five categories.
- **Family** and **Game** categories have more competitors, but the
  competition is not as tight as in **Communication**, **Social**, and
  **Video Players** categories.
- The top ten apps across all genres are free to download.

## 7. Conclusion

- Develop an app in **Family**, **Game**, **Communication**, **Social**,
  and **Video Players** categories.
- Choose *Everyone* content rating, if we develop an app in **Family**,
  **Game**, and **Communication** categories.
- Choose *Teen* content rating, if we develop an app in **Social** and
  **Video Players** categories.
- Choose the **Action** genre from **Game** category or the **Casual**
  genre from **Family** category for less competition.
- Choose **Social**, **Communication**, and **Video Players & Editors**
  genres, for less competitors, but tighter competition.
- Choose the *Free* payment type, and earn money from other sources like
  ads, premium membership, selling in-app items, etc.
