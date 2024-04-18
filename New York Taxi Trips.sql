------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------CLEANING--------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHECKING NULL VALUES
------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS TaxiTrips;
CREATE TEMPORARY TABLE TaxiTrips AS (
  (
  SELECT * EXCEPT(airport_fee, data_file_month, data_file_year)
  FROM
  `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2020`
  UNION ALL
  SELECT * EXCEPT(airport_fee, data_file_month, data_file_year)
  FROM
  `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2021`)
);

SELECT pickup_datetime, COUNT(*)
FROM TaxiTrips
WHERE pickup_datetime IS NULL
GROUP BY 1; -- NO NULL VALUES

SELECT dropoff_datetime, COUNT(*)
FROM TaxiTrips
WHERE dropoff_datetime IS NULL
GROUP BY 1; -- NO NULL VALUES

SELECT pickup_location_id, COUNT(*)
FROM TaxiTrips
WHERE pickup_location_id IS NULL
GROUP BY 1; -- NO NULL VALUES

SELECT dropoff_location_id, COUNT(*)
FROM TaxiTrips
WHERE dropoff_location_id IS NULL
GROUP BY 1; -- NO NULL VALUES

SELECT rate_code, COUNT(*)
FROM TaxiTrips
WHERE rate_code IS NULL
GROUP BY 1; -- HAS 2720535 ROWS NULL VALUES

SELECT payment_type, COUNT(*)
FROM TaxiTrips
WHERE payment_type IS NULL
GROUP BY 1; -- NO NULL VALUES

SELECT vendor_id, COUNT(*)
FROM TaxiTrips
WHERE vendor_id IS NULL
GROUP BY 1; -- NO NULL VALUES

SELECT trip_distance, COUNT(*)
FROM TaxiTrips
WHERE trip_distance IS NULL
GROUP BY 1; -- NO NULL VALUES

SELECT passenger_count, COUNT(*)
FROM TaxiTrips
WHERE passenger_count IS NULL
GROUP BY 1; -- HAS 3530502 ROWS WITH NULL VALUES
------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHECKING ZERO VALUES
------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT total_amount
FROM TaxiTrips
WHERE total_amount = 0; -- 12983 ROWS WITH 0 total_amount

SELECT trip_distance
FROM TaxiTrips
WHERE trip_distance = 0; -- 919253 ROWS WITH 0 trip_distance
------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHECKING STRANGE VALUES
------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT EXTRACT(YEAR FROM pickup_datetime), COUNT(*)
FROM TaxiTrips
GROUP BY 1; -- CONTAINS UNRELEVANT YEARS LIKE 2009, 2011, 2003, 2008, 2098, 2012, 2002, 2028, 2019, 2004, 2070, 2029, 2023, 2001
------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHECKING FOR DUPLICATES
------------------------------------------------------------------------------------------------------------------------------------------------------
WITH duplicates AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY vendor_id, pickup_datetime, dropoff_datetime, passenger_count, trip_distance, rate_code, store_and_fwd_flag, payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount, imp_surcharge, total_amount, pickup_location_id, dropoff_location_id ORDER BY pickup_datetime) AS count
FROM TaxiTrips
)
SELECT *
FROM duplicates
WHERE count > 1; -- 12950 ROWS IDENTIFIED AS DUPLICATES

------------------------------------------------------------------------------------------------------------------------------------------------------
-- CREATE TEMPORARY TABLE FOR CHECKING DUPLICATES
------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS TaxiTrips;
CREATE TEMPORARY TABLE TaxiTrips AS (
  WITH duplicates AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY vendor_id, pickup_datetime, dropoff_datetime, passenger_count, trip_distance, rate_code, store_and_fwd_flag, payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount, imp_surcharge, total_amount, pickup_location_id, dropoff_location_id ORDER BY pickup_datetime) AS count
  FROM 
  (SELECT * EXCEPT(airport_fee, data_file_month, data_file_year)
  FROM
  `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2020` 
  UNION ALL
  SELECT * EXCEPT(airport_fee, data_file_month, data_file_year)
  FROM
  `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2021`
  ))
  -- EXCLUDING DUPLICATES
SELECT *
FROM duplicates
WHERE count = 1);

------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------ANALYSIS--------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
  CAST(pickup_datetime AS DATE) AS pickup_date,
  EXTRACT(HOUR FROM pickup_datetime) as pickup_hour,
  vendor_id,
  payment_type,
  rate_code,
  pickup_location_id
  dropoff_location_id,
  pickups.zone_name AS pickup_zone,
  pickups.borough AS pickup_borough,
  pickups.zone_geom AS pickup_geom,
  dropoffs.zone_name AS dropoff_zone,
  dropoffs.borough AS dropoff_borough,
  dropoffs.zone_geom AS dropoff_geom,
  (CASE 
    WHEN vendor_id = 1 THEN 'Creative Mobile Technologies, LLC'
    WHEN vendor_id = 2 THEN 'VeriFone Inc.'
  END) AS vendor_name,
  (CASE
    WHEN payment_type = 1 THEN 'Credit Card'
    WHEN payment_type = 2 THEN 'Cash'
    WHEN payment_type = 3 THEN 'No Charge'
    WHEN payment_type = 4 THEN 'Dispute'
    WHEN payment_type = 5 THEN 'Unknown'
    WHEN payment_type = 6 THEN 'Voided Trip'
  END) AS payment_type,
  (CASE
    WHEN rate_code = 1 THEN 'Standard Rate'
    WHEN rate_code = 2 THEN 'JFK '
    WHEN rate_code = 3 THEN 'Newark '
    WHEN rate_code = 4 THEN 'Nassau or Westchester'
    WHEN rate_code = 5 THEN 'Negotiated Fare'
    WHEN rate_code = 6 THEN 'Group Ride'
  END) AS rate_type,
  --
  SUM(passenger_count) AS passenger_count,
  SUM(trip_distance) AS trip_distance,
  SUM(fare_amount) AS fare_amount,
  SUM(extra) AS extra,
  SUM(mta_tax) AS mta_tax,
  SUM(tip_amount) AS tip_amount,
  SUM(tolls_amount) AS tolls_amount,
  SUM(imp_surcharge) AS imp_surcharge,
  SUM(total_amount) AS total_amount,
  COUNT(*) AS total_trips
FROM 
  TaxiTrips AS trips
INNER JOIN
    `bigquery-public-data.new_york_taxi_trips.taxi_zone_geom` AS pickups
    ON trips.pickup_location_id = pickups.zone_id
INNER JOIN
    `bigquery-public-data.new_york_taxi_trips.taxi_zone_geom` AS dropoffs
    ON trips.pickup_dropoff_id = dropoffs.zone_id
WHERE
  -- EXCLUDING NULLS
  rate_code IS NOT NULL AND
  passenger_count IS NOT NULL AND
  pickups.zip_code IS NOT NULL AND
  dropoffs.zip_code IS NOT NULL AND
  -- EXCLUDING OUTLIERS
  trip_distance > 0 AND
  passenger_count > 0 AND
  -- EXCLUDING UNRELEVANT YEARS
  EXTRACT(YEAR FROM pickup_datetime) IN (2020, 2021)
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11;
 

