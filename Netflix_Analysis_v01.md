Netflix Movies and TV Shows Analysis
================

## 1. Netflix

![](https://static1.srcdn.com/wordpress/wp-content/uploads/2019/02/Netflix-Originals-logo.jpg)

Netflix is an American subscription video on-demand over-the-top
streaming service. The service primarily distributes original and
acquired films and television shows from various genres, and it is
available internationally in multiple languages.

## 2. Data Source

We’ve just obtained ‘netflix_titles’ dataset from Kaggle, which you can
download the data
[here](https://www.kaggle.com/datasets/shivamb/netflix-shows/data). The
dataset contains 8807 titles, which consists of TV Shows and Movies from
around the world.

This dataset has 8807 titles, which are added between 2010 and 2019. In
this analysis, we want to know

- How Netflix has grown year over year.
- What types of shows are most added to Netflix.

The dataset does not contain values like movie ratings, user reviews,
total watched, total likes or dislikes, and watch later. It makes the
analysis limited to movie demography. The dataset itself only contains
values like.

- Show type
- Show title
- Director
- Cast
- Country
- Date added
- Release year
- Content rating
- Genre
- Duration
- Description

## 2. Importing Data Set

We use Microsoft SQL Server for this analysis. Before we start importing
the dataset, we need to create a new database first. In this analysis,
the new database name would be ‘NetflixMovies’.

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Analysis%2001.png)<!-- -->

After the new database has been created, we can import the dataset using
SQL Server Import and Export Data. We can open this window by right
click the database name NetflixMovies and then dropdown menu will show,
choose Task /> Import Data

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Analysis%2002.png)<!-- -->

Then, we choose Flat File Source, then browse the dataset, and choose
netflix_titles.csv

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Importing%20Data%20Set%2003.png)<!-- -->

## 3. Cleaning

The imported dataset is not clean. We need to clean it first for further
analysis.

### 3.1. Cleaning The date_added Column

#### 3.1.1. Converting from String to Date Data Type

First, we need to cast the column first with this query below.

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Cleaning%2001.png)<!-- -->

We see that there are some rows in the date_added column that contain
empty values. When the empty values are converted into the date data
type, it returns the result ‘1900-01-01’. We will fill this empty values
with the correct information by observing on the internet, so we will
have the complete data in the column.

After did some observations regarding the netflix series or movies added
date, we can write the query below to update the table, so the empty
values can be filled with the correct information.

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Cleaning%2002.png)<!-- -->

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Cleaning%2003.png)<!-- -->

All the empty cells have been filled. Now, we can convert the date_added
column data type from string to date using this query.

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Cleaning%2004.png)<!-- -->

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Cleaning%2005.png)<!-- -->

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Cleaning%2006.png)<!-- -->

Now, the date_added column is clean. We can move to other colum to
perform a similar action.

### 3.2. director Column

#### 3.2.1. Filling Missing Values

The director column also has missing values, based on this query,

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Cleaning%2007.png)<!-- -->

it returns the 2633 missing values

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Cleaning%2008.png)<!-- -->

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Cleaning%2009.png)<!-- -->

We did some observation on the internet, and fill the missing values in
the column with UPDATE clause.

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Cleaning%2010.png)<!-- -->

### 3.3. country Column

#### 3.3.1. Filling Missing Values

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Cleaning%2011.png)<!-- -->

### 3.4. duration Column

duration column has a string data type, but an integer or numeric type
for these values is more suitable for further analysis. We want to
convert these values from string to numeric data type.

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Cleaning%2012.png)<!-- -->

Instead of converting the column, we want to split duration column into
two columns, duration_minutes and seasons columns. The duration_minutes
column is made for the values that contain ‘min’, and seasons column is
made for the values that contain ‘Season’ or ‘Seasons’.

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Cleaning%2013.png)<!-- -->

Below is the query to split the values from duration column to the two
new columns, duration_minutes and seasons.

### 3.5. rating Column

We found strange values in the rating column, ‘66 min’, ‘74 min’, and
‘84 min’. These values should not be located in the rating column. The
duration_minutes column is the correct column to contain these values.
So, to make the dataset tidier, we need to move them from the rating to
the duration_minutes column. We write this query to move the values.

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Cleaning%2014.png)<!-- -->

Now, all the misinput values have been moved to the correct column.
Unfortunately, there are also some shows that have empty values in the
rating column. We need to fill those empty cells with the correct
values. We did an observation on the internet about the content rating
of those shows. Then, we write this query to fill in the empty cells.

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Cleaning%2015.png)<!-- -->

### 3.6. Checking for Duplicates

Now we want to know if the dataset have duplicates, we write this query
to return duplicated rows

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Cleaning%2016.png)<!-- -->

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Cleaning%2017.png)<!-- -->

There is no duplicated rows in the dataset. Now, all the values in the
data set are clean and ready to be used for further analysis.

## 4. Analysis

Now, we want to analyze the data by performing aggregations to the
cleaned dataset.

### 4.1. Counting Shows Per Type

In this analysis, we want to count the numbers of show per type. There
are two types of shows in the dataset, Movie and TV Show. We write this
query to perform the aggregation.

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Analysis%2001.png)<!-- -->

### 4.2. Counting Total Shows Per Genre

There are several genre in the dataset. One show, whether it is movie or
TV show, they have several genres listed in. Here, we want to count the
numbers of genres and also count the numbers of shows listed in each
genre. We write this query to perform this aggregation.

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Analysis%2002.png)<!-- -->

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Analysis%2003.png)<!-- -->

There are 42 different genres based on the query result.

### 4.3. Counting Total Shows Added Per Year

We perform an aggregation to know how many shows added per year, either
they are movies or TV shows. We grouped the total shows based on show
type and the year added.

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Analysis%2004.png)<!-- -->

### 4.4. Counting Total Shows Produced by Country

In this analysis, we want to know the numbers of total shows produced by
country. We write this query to perform the aggregation.

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Analysis%2005.png)<!-- -->

Movies or TV shows that we can watch on Netflix are produced by those
120 countries. The country that produced most of the show was United
States, followed by India and UK. Other countries were also
contributing, but the numbers as not high as United States and India.

### 4.5. Counting The Numbers of Shows Based on Content Rating

Content ratings classify films based on their suitability for viewing
based on age. There are films that are good for children and some that
are not. Content ratings are set to prevent viewers from watching films
or TV shows that are not age appropriate. Here, we want to know, how
many content ratings are available on Netflix. We also want to know the
number of shows classified for each content rating.

We write this query to perform the aggregation.

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Analysis%2006.png)<!-- -->

There are 24 different content ratings on Netflix. Most of the movies
and TV shows are TV-MA rated. TV-MA or Mature Audience is specifically
designed to be viewed by adults and therefore may be inappropriate for
children under 17.

### 4.6. Distribution of Movie Duration

Films generally last between one and three hours. However, some films
may only be less than an hour long like short films, or they may be more
than three hours long, it depends. We will aggregate the dataset and
count the total shows based on their minutes duration. We use the query
below to perform the aggregation.

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Analysis%2007.png)<!-- -->

### 4.7. Distribution of TV Serial Seasons

Unlike movies, TV shows generally produced an episode with 40 minutes
duration long. TV shows generally have some episodes that are packed in
seasons. When the serials are popular, they usually will have another
season. The numbers of seasons indicate how popular the series are. We
use this query to perform the aggregation.

![](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/images/Analysis%2008.png)<!-- -->

## 5. Visualizations

We made the visualizations in Tableau Public. Click this [link](https://public.tableau.com/app/profile/jaenal.aripin/viz/NetflixMoviesandTVShows_17098862814500/Dashboard2) to access the dashboard.


<div class='tableauPlaceholder' id='viz1710756884293' style='position: relative'>
<noscript>
<a href='#'>
<img alt='Netflix Shows ' src='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;Ne&#47;NetflixMoviesandTVShows_17098862814500&#47;Dashboard2&#47;1_rss.png' style='border: none' /></a></noscript><object class='tableauViz'  style='display:none;'>
<param name='host_url' value='https%3A%2F%2Fpublic.tableau.com%2F' /> <param name='embed_code_version' value='3' /> <param name='site_root' value='' />
<param name='name' value='NetflixMoviesandTVShows_17098862814500&#47;Dashboard2' /><param name='tabs' value='no' /><param name='toolbar' value='yes' />
<param name='static_image' value='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;Ne&#47;NetflixMoviesandTVShows_17098862814500&#47;Dashboard2&#47;1.png' />
<param name='animate_transition' value='yes' />
<param name='display_static_image' value='yes' />
<param name='display_spinner' value='yes' />
<param name='display_overlay' value='yes' />
<param name='display_count' value='yes' />
<param name='language' value='en-US' />
</object></div>                
<script type='text/javascript'>                    
var divElement = document.getElementById('viz1710756884293');                    
var vizElement = divElement.getElementsByTagName('object')[0];                    
vizElement.style.width='1366px';vizElement.style.height='1000px';                    
var scriptElement = document.createElement('script');                    
scriptElement.src = 'https://public.tableau.com/javascripts/api/viz_v1.js';                    
vizElement.parentNode.insertBefore(scriptElement, vizElement);                
</script>

##### SQL code

Here is the
[link](https://github.com/jaenalaripin/jaenalaripin.github.io/blob/main/SQL/Netflix_Data_Analysis_06_03_2024_v01.sql)
for the complete SQL queries regarding this analysis.
