-- --------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------CLEANING------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------------------
-- date_added COLUMN
-- --------------------------------------------------------------------------------------------------------------------------------------
-- CONVERT date_added FROM STRING TO DATE
-- --------------------------------------------------------------------------------------------------------------------------------------
SELECT title, date_added, cast(date_added AS date) AS date_added_converted
FROM NetflixMovies.dbo.netflix_titles
ORDER BY date_added;
-- --------------------------------------------------------------------------------------------------------------------------------------
-- INPUT VALUES INTO THE EMPTY CELLS IN THE date_added COLUMN
-- --------------------------------------------------------------------------------------------------------------------------------------
UPDATE NetflixMovies.dbo.netflix_titles
SET date_added = 'September 15, 2014'
WHERE title = 'The Adventures of Figaro Pho';
-- --------------------------------------------------------------------------------------------------------------------------------------
-- UPDATE COLUMN DATA TYPE IN THE netflix_titles TABLE
-- --------------------------------------------------------------------------------------------------------------------------------------
UPDATE NetflixMovies.dbo.netflix_titles
SET date_added = cast(date_added AS date);
-- --------------------------------------------------------------------------------------------------------------------------------------
-- PREVIEW CURRENT TABLE
-- --------------------------------------------------------------------------------------------------------------------------------------
SELECT title, date_added
FROM NetflixMovies.dbo.netflix_titles;

-- -------------------------------------------------------------------------------------------------------------------------------------
-- CONVERTING DURATION COLUMN DATA TYPE FROM STRING TO INTEGER BY SPLITTING IT INTO TWO NEW COLUMNS
-- --------------------------------------------------------------------------------------------------------------------------------------
-- CREATING TWO MORE TABLES
-- --------------------------------------------------------------------------------------------------------------------------------------
ALTER TABLE NetflixMovies.dbo.netflix_titles
ADD duration_minutes INT, seasons INT;
-- --------------------------------------------------------------------------------------------------------------------------------------
-- FILLING duration_minutes TABLE WITH VALUES FROM duration
-- --------------------------------------------------------------------------------------------------------------------------------------
UPDATE NetflixMovies.dbo.netflix_titles
SET duration_minutes = REPLACE(duration, ' min', '')
WHERE duration LIKE '% min%';
-- --------------------------------------------------------------------------------------------------------------------------------------
-- FILLING seasons TABLE WITH VALUES FROM duration
-- --------------------------------------------------------------------------------------------------------------------------------------
UPDATE NetflixMovies.dbo.netflix_titles
SET seasons = CASE
	WHEN duration LIKE '% Seasons' THEN REPLACE(duration, ' Seasons', '')
	WHEN duration LIKE '% Season' THEN REPLACE(duration, ' Season', '')
	END
WHERE duration LIKE '% Seasons' OR duration LIKE '% Season';
-- --------------------------------------------------------------------------------------------------------------------------------------
-- DROP ORIGINAL duration COLUMN
-- --------------------------------------------------------------------------------------------------------------------------------------
ALTER TABLE NetflixMovies.dbo.netflix_titles
DROP COLUMN duration;

---------------------------------------------------------------------------------------------------------------------------------------
-- director COLUMN
-- --------------------------------------------------------------------------------------------------------------------------------------
-- RETURNING EMPTY VALUES IN THE director COLUMN
-- --------------------------------------------------------------------------------------------------------------------------------------
SELECT title, director
FROM NetflixMovies.dbo.netflix_titles
WHERE director = '' AND type = 'Movie';
-- --------------------------------------------------------------------------------------------------------------------------------------
-- INPUT VALUES INTO THE EMPTY CELLS IN THE director COLUMN
-- --------------------------------------------------------------------------------------------------------------------------------------
UPDATE NetflixMovies.dbo.netflix_titles
SET director = 'William Bindley' 
WHERE title = 'Last Summer';

-- --------------------------------------------------------------------------------------------------------------------------------------
-- country COLUMN
-- --------------------------------------------------------------------------------------------------------------------------------------
-- RETURNING EMPTY VALUES IN THE country COLUMN
-- --------------------------------------------------------------------------------------------------------------------------------------
SELECT *
FROM NetflixMovies.dbo.netflix_titles
WHERE cast LIKE '%Tom Holland%';

SELECT *
FROM NetflixMovies.dbo.netflix_titles
WHERE country = '';
-- --------------------------------------------------------------------------------------------------------------------------------------
-- FILLING MISSING VALUES IN THE country COLUMN
-- --------------------------------------------------------------------------------------------------------------------------------------
UPDATE NetflixMovies.dbo.netflix_titles
SET country = 'United States' 
WHERE director LIKE '%Olivier Megaton%';

-- --------------------------------------------------------------------------------------------------------------------------------------
-- CLEANING RATING COLUMN
-- --------------------------------------------------------------------------------------------------------------------------------------
SELECT DISTINCT(rating)
FROM NetflixMovies.dbo.netflix_titles;
-- --------------------------------------------------------------------------------------------------------------------------------------
-- WRONG VALUES IN RATING COLUMN
-- --------------------------------------------------------------------------------------------------------------------------------------
SELECT *
FROM NetflixMovies.dbo.netflix_titles
WHERE rating IN ('66 min', '74 min', '84 min', '');
-- --------------------------------------------------------------------------------------------------------------------------------------
-- FILLING '66 min' and '74 min' VALUES FROM RATING COLUMN TO duration_minutes COLUMN
-- --------------------------------------------------------------------------------------------------------------------------------------
UPDATE NetflixMovies.dbo.netflix_titles
SET duration_minutes = CASE
	WHEN rating = '66 min' THEN 66
	WHEN rating = '74 min' THEN 74
	WHEN rating = '84 min' THEN 84
	ELSE duration_minutes
	END,
	rating = ''
WHERE rating IN ('66 min', '74 min', '84 min');
-- --------------------------------------------------------------------------------------------------------------------------------------
-- FILLING EMPTY CELLS IN CONTENT RATING COLUMN
-- --------------------------------------------------------------------------------------------------------------------------------------
UPDATE NetflixMovies.dbo.netflix_titles
SET rating = CASE
	WHEN title = 'My Honor Was Loyalty' THEN 'PG-13'
	WHEN title = 'Louis C.K.: Live at the Comedy Store' THEN 'TV-MA'
	WHEN title = '13TH: A Conversation with Oprah Winfrey & Ava DuVernay' THEN 'TV-PG'
	WHEN title = 'Gargantia on the Verdurous Planet' THEN 'PG-13'
	WHEN title = 'Little Lunch' THEN 'TV-G'
	WHEN title = 'Louis C.K. 2017' THEN 'TV-MA'
	END
WHERE title IN (
	'My Honor Was Loyalty',
	'Louis C.K.: Live at the Comedy Store',
	'13TH: A Conversation with Oprah Winfrey & Ava DuVernay',
	'Gargantia on the Verdurous Planet',
	'Little Lunch',
	'Louis C.K. 2017');

-- --------------------------------------------------------------------------------------------------------------------------------------
-- CHECKING FOR DUPLICATES
-- --------------------------------------------------------------------------------------------------------------------------------------
WITH duplicates AS (
SELECT *, 
	   ROW_NUMBER() OVER(PARTITION BY type, title, director, cast, country, 
							   date_added, release_year, rating, duration, listed_in,
							   description ORDER BY show_id) as count
FROM NetflixMovies.dbo.netflix_titles ) 

SELECT *
FROM duplicates
WHERE count > 1;

-- --------------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------ANALYSIS-------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------------------
-- COUNTING SHOWS PER TYPE
SELECT type, COUNT(type) AS total
FROM NetflixMovies.dbo.netflix_titles
GROUP BY type
ORDER BY total DESC;

-- -------------------------------------------------------------------------------------------------------------------------------
-- COUNTING TOTAL SHOWS PER GENRE
-- -------------------------------------------------------------------------------------------------------------------------------
WITH 
listed_trimmed AS (
SELECT title, REPLACE(listed_in, ', ', ',') AS listed_in_trimmed
FROM NetflixMovies.dbo.netflix_titles
),
genres AS (
SELECT title, value AS genre
FROM listed_trimmed
	CROSS APPLY STRING_SPLIT(listed_in_trimmed, ',')
	)

SELECT genre, COUNT(genre) AS total
FROM genres
GROUP BY genre
ORDER BY total DESC;

-- -------------------------------------------------------------------------------------------------------------------------------
-- COUNTING TOTAL SHOWS ADDED PER YEAR
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT type, YEAR(date_added) AS year_added, COUNT(date_added) AS total
FROM NetflixMovies.dbo.netflix_titles
GROUP BY type, YEAR(date_added)
ORDER BY total DESC;

-- -------------------------------------------------------------------------------------------------------------------------------
-- COUNTING SHOW NUMBERS PER COUNTRY
-- -------------------------------------------------------------------------------------------------------------------------------
WITH 
countries AS (
SELECT title, REPLACE(country, ', ', ',') AS country
FROM NetflixMovies.dbo.netflix_titles
),
countries_split AS (
SELECT title, value as country
FROM countries
	CROSS APPLY STRING_SPLIT(country, ',')
)

SELECT country, COUNT(*) AS total
FROM countries_split
WHERE country <> '' AND country IS NOT NULL
GROUP BY country
ORDER BY total DESC;

-- -------------------------------------------------------------------------------------------------------------------------------
-- COUNTING SHOW NUMBERS BASED ON RATING
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT type, rating, COUNT(*) AS total
FROM NetflixMovies.dbo.netflix_titles
WHERE rating <> ''
GROUP BY type, rating
ORDER BY total DESC

-- -------------------------------------------------------------------------------------------------------------------------------
-- DISTRIBUTION OF MOVIE DURATION
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT duration_minutes, COUNT(duration_minutes) AS total
FROM NetflixMovies.dbo.netflix_titles
WHERE type = 'Movie' and duration_minutes IS NOT NULL
GROUP BY duration_minutes
ORDER BY duration_minutes;
-- -------------------------------------------------------------------------------------------------------------------------------
-- DISTRIBUTION OF TV SHOW SEASONS
-- -------------------------------------------------------------------------------------------------------------------------------
SELECT seasons, COUNT(seasons) AS total
FROM NetflixMovies.dbo.netflix_titles
WHERE type = 'TV Show' and seasons IS NOT NULL
GROUP BY seasons
ORDER BY seasons;

-- -------------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------CREATING VIEWS FOR VISUALIZATIONS--------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------------------
-- SHOW NUMBERS BY TYPE
-- --------------------------------------------------------------------------------------------------------------------------------------
CREATE VIEW ShowByType AS 
SELECT type, COUNT(type) AS total
FROM NetflixMovies.dbo.netflix_titles
GROUP BY type;
---------------------------------------------------------------------------------------------------------------------------------
-- SHOW NUMBERS BY GENRE
-- --------------------------------------------------------------------------------------------------------------------------------------
CREATE VIEW ShowByGenre AS
WITH 
listed_trimmed AS (
SELECT title, REPLACE(listed_in, ', ', ',') AS listed_in_trimmed
FROM NetflixMovies.dbo.netflix_titles
),
genres AS (
SELECT title, value AS genre
FROM listed_trimmed
	CROSS APPLY STRING_SPLIT(listed_in_trimmed, ',')
	)

SELECT genre, COUNT(genre) AS total
FROM genres
GROUP BY genre;
---------------------------------------------------------------------------------------------------------------------------------
-- SHOWS ADDED PER YEAR
-- --------------------------------------------------------------------------------------------------------------------------------------
CREATE VIEW ShowByYear AS
SELECT type, YEAR(date_added) AS year_added, COUNT(date_added) AS total
FROM NetflixMovies.dbo.netflix_titles
GROUP BY type, YEAR(date_added);
---------------------------------------------------------------------------------------------------------------------------------
-- COUNTING SHOW NUMBERS PER COUNTRY
-- --------------------------------------------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS ShowByCountry
CREATE VIEW ShowByCountry AS
WITH 
countries AS (
SELECT title, REPLACE(country, ', ', ',') AS country
FROM NetflixMovies.dbo.netflix_titles
),
countries_split AS (
SELECT title, value as country
FROM countries
	CROSS APPLY STRING_SPLIT(country, ',')
)

SELECT country, COUNT(*) AS total
FROM countries_split
WHERE country <> '' AND country IS NOT NULL
GROUP BY country;
---------------------------------------------------------------------------------------------------------------------------------
-- COUNTING SHOW NUMBERS BASED ON RATING
-- --------------------------------------------------------------------------------------------------------------------------------------
CREATE VIEW ShowByRating AS
SELECT type, rating, COUNT(*) AS total
FROM NetflixMovies.dbo.netflix_titles
WHERE rating <> ''
GROUP BY type, rating;
---------------------------------------------------------------------------------------------------------------------------------
-- DISTRIBUTION OF MOVIE DURATION
-- --------------------------------------------------------------------------------------------------------------------------------------
CREATE VIEW ShowByDuration AS
SELECT duration_minutes, COUNT(duration_minutes) AS total
FROM NetflixMovies.dbo.netflix_titles
WHERE type = 'Movie' and duration_minutes IS NOT NULL
GROUP BY duration_minutes;
-- --------------------------------------------------------------------------------------------------------------------------------------
-- DISTRIBUTION OF TV SHOW SEASONS
-- --------------------------------------------------------------------------------------------------------------------------------------
CREATE VIEW ShowBySeason AS
SELECT seasons, COUNT(seasons) AS total
FROM NetflixMovies.dbo.netflix_titles
WHERE type = 'TV Show' and seasons IS NOT NULL
GROUP BY seasons;

-- --------------------------------------------------------------------------------------------------------------------------------------
-- CREATE AND EXPORT VIEWS TO BE VISUALIZED LATER ON IN A FORM OF INTERACTIVE DASHBOARD WITH TABLEAU
-- --------------------------------------------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS netflix
CREATE VIEW netflix AS
WITH 
delimited AS (
SELECT show_id, type, title, REPLACE(director, ', ', ',') AS director, REPLACE(cast, ', ', ',') as cast, REPLACE(country, ', ', ',') AS country, date_added, REPLACE(listed_in, ', ', ',') AS genre, rating, duration_minutes, seasons
FROM NetflixMovies.dbo.netflix_titles
),
splitteddirector AS (
SELECT show_id, type, title, value AS director
FROM delimited
CROSS APPLY STRING_SPLIT(director, ',')
),
splittedcast AS (
SELECT show_id, value AS cast
FROM delimited
CROSS APPLY STRING_SPLIT(cast, ',')
),
splittedcountry AS (
SELECT show_id, value AS country, date_added
FROM delimited
CROSS APPLY STRING_SPLIT(country, ',')
),
splittedgenre AS (
SELECT show_id, value AS genre, rating, duration_minutes, seasons
FROM delimited
CROSS APPLY STRING_SPLIT(genre, ',')
)
	
SELECT sd.show_id, sd.type, sd.title, REPLACE(sd.director, ';', '') AS director, REPLACE(sc.cast, ';', '') AS cast, sco.country, sco.date_added, sg. genre, sg.rating, sg.duration_minutes, sg.seasons
FROM splitteddirector AS sd
INNER JOIN splittedcast AS sc
ON sd.show_id = sc.show_id
INNER JOIN splittedcountry AS sco
ON sc.show_id = sco.show_id
INNER JOIN splittedgenre AS sg
ON sco.show_id = sg.show_id;

