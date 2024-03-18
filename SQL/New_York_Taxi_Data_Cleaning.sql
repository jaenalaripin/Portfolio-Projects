/* We use BigQuery In this analysis, so all the DML queries are done with the help of BigQuery API, there will be no DML queries in this analysis */
------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------CLEANING--------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHECKING NULL VALUES
------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT DISTINCT(pickup_datetime)
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2020`
WHERE pickup_datetime IS NULL; -- NO NULL VALUES

SELECT DISTINCT(dropoff_datetime)
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2020`
WHERE pickup_datetime IS NULL; -- NO NULL VALUES

SELECT DISTINCT(pickup_location_id)
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2020`
WHERE pickup_datetime IS NULL; -- NO NULL VALUES

SELECT DISTINCT(dropoff_location_id)
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2020`
WHERE pickup_datetime IS NULL; -- NO NULL VALUES
------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHECKING ZERO VALUES
------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT total_amount
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2020`
WHERE total_amount = 0;
------------------------------------------------------------------------------------------------------------------------------------------------------
-- EXCLUDING DUPLICATES FROM DATASET AND CREATE NEW TABLE CALLED 'Taxis'
------------------------------------------------------------------------------------------------------------------------------------------------------
WITH duplicates AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY pickup_datetime, dropoff_datetime, vendor_id, passenger_count, trip_distance, rate_code, store_and_fwd_flag, payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount, imp_surcharge, airport_fee, total_amount, pickup_location_id, dropoff_location_id, data_file_year, data_file_month ORDER BY pickup_datetime) AS count
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2020`
)
SELECT *
FROM duplicates
WHERE count = 1;
------------------------------------------------------------------------------------------------------------------------------------------------------
-- MUTATING vendor_name, payment_type, rate_type, AND store_and_forward
------------------------------------------------------------------------------------------------------------------------------------------------------
WITH trips AS (
SELECT 
      pickup_datetime,
      dropoff_datetime,
      pickup_location_id,
      dropoff_location_id,
      passenger_count,
      fare_amount,
      extra,
      mta_tax,
      tip_amount,
      tolls_amount,
      imp_surcharge,
      airport_fee,
      total_amount,
      data_file_year,
      data_file_month,
      -- CREATING NEW COLUMNS vendor_name, payment_type, rate_type, AND store_and_forward
      (CASE
        WHEN vendor_id = '1' THEN 'Creative Mobile Technologies'
        WHEN vendor_id = '2' THEN 'VeriFone Inc.'
      END) as vendor_name,
      (CASE
        WHEN payment_type = '1' THEN 'Credit Card'
        WHEN payment_type = '2' THEN 'Cash'
        WHEN payment_type = '3' THEN 'No Charge'
        WHEN payment_type = '4' THEN 'Dispute'
        WHEN payment_type = '5' THEN 'Unknown'
        WHEN payment_type = '6' THEN 'Voided Trip'
      END) as payment_type,
      (CASE
        WHEN rate_code = '1.0' THEN 'Standard Rate'
        WHEN rate_code = '2.0' THEN 'JFK '
        WHEN rate_code = '3.0' THEN 'Newark'
        WHEN rate_code = '4.0' THEN 'Nassau or Westchester'
        WHEN rate_code = '5.0' THEN 'Negotiated fare'
        WHEN rate_code = '6.0' THEN 'Group ride'
      END) as rate_type,
      (CASE
        WHEN store_and_fwd_flag = 'Y' THEN 'Yes'
        WHEN store_and_fwd_flag = 'N' THEN 'No'
      END) as store_and_forward
FROM oceanic-muse-410205.NewYorkTaxis.Trips
)
------------------------------------------------------------------------------------------------------------------------------------------------------
-- JOINING TABLES AND CREATING A NEW TABLE CALLED TaxiTrips
------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
  pickup_datetime,
  dropoff_datetime,
  -- SELECTING AND RENAMING COLUMNS FROM ZONE TABLE
  pickups.zone_name AS pickup_zone,
  pickups.borough AS pickup_borough,
  pickups.zone_geom AS pickup_geom,
  dropoffs.zone_name AS dropoff_zone,
  dropoffs.borough AS dropoff_borough,
  dropoffs.zone_geom AS dropoff_geom,
  --
  passenger_count,
  fare_amount,
  extra,
  mta_tax,
  tip_amount,
  tolls_amount,
  imp_surcharge,
  airport_fee,
  total_amount,
  data_file_year,
  data_file_month,
  vendor_name,
  payment_type,
  rate_type,
  store_and_forward
FROM 
  trips
INNER JOIN 
  `bigquery-public-data.new_york_taxi_trips.taxi_zone_geom` as pickups
ON 
  trips.pickup_location_id = pickups.zone_id
INNER JOIN 
  `bigquery-public-data.new_york_taxi_trips.taxi_zone_geom` as dropoffs
ON
   trips.dropoff_location_id = dropoffs.zone_id
WHERE total_amount > 0;
------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------ANALYSIS-------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
-- MODIFYING DATE AND TIME
------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT 
 -- SPLITTING datetime TYPE COLUMNS INTO date AND time TYPE COLUMNS
  CAST(pickup_datetime AS date) AS pickup_date,
  CAST(pickup_datetime AS time) AS pickup_time,
  CAST(dropoff_datetime AS date) AS dropoff_date,
  CAST(dropoff_datetime AS time) AS dropoff_time,
  -- MUTATING COLUMN pickup_day
  CASE 
    WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 1 THEN 'Sunday'
    WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 2 THEN 'Monday'
    WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 3 THEN 'Tuesday'
    WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 4 THEN 'Wednesday'
    WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 5 THEN 'Thursday'
    WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 6 THEN 'Friday'
    WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 7 THEN 'Saturday'
  END AS pickup_day,
  * EXCEPT(pickup_datetime, dropoff_datetime)
FROM 
  oceanic-muse-410205.NewYorkTaxis.TaxiTrips;
