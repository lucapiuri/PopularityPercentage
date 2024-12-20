-- -----------------------------------------------------------------
--                          DISTANCE PER DOLLAR
-- -----------------------------------------------------------------

-- Solving a "Distance Per Dollar" problem
-- SQL interview question from stratascratch.com

/*
You’re given a dataset of uber rides with the traveling distance (‘distance_to_travel’) and cost (‘monetary_cost’) for each ride. First, find the difference between the distance-per-dollar for each date and the average distance-per-dollar for that year-month. Distance-per-dollar is defined as the distance traveled divided by the cost of the ride. Use the calculated difference on each date to calculate absolute average difference in distance-per-dollar metric on monthly basis (year-month).

The output should include the year-month (YYYY-MM) and the absolute average difference in distance-per-dollar (Absolute value to be rounded to the 2nd decimal).

You should also count both success and failed request_status as the distance and cost values are populated for all ride requests. Also, assume that all dates are unique in the dataset. Order your results by earliest request date first.
*/

--@block
-- Create the Uber database:
CREATE DATABASE IF NOT EXISTS Uber;
use Uber;

--@block
-- Create the empty table:
CREATE TABLE IF NOT EXISTS uber_request_logs(
request_id INT,
request_date	DATE,
request_status TEXT,
distance_to_travel DOUBLE (10,2),
monetary_cost	DOUBLE (10,2),
driver_to_client_distance DOUBLE (10,2),
PRIMARY KEY (request_id))
;

--@block
-- I used a Google Sheet with multiple TEXTJOIN formulas to format the data the way SQL needs it

INSERT INTO uber_request_logs (request_id, request_date, request_status, 
distance_to_travel, monetary_cost, driver_to_client_distance)
VALUES 
(1, '2020-01-09', 'success', 70.59, 6.56, 14.36),
(2, '2020-01-24', 'success', 93.36, 22.68, 19.9),
(3, '2020-02-08', 'fail', 51.24, 11.39, 21.32),
(4, '2020-02-23', 'success', 61.58, 8.04, 44.26),
(5, '2020-03-09', 'success', 25.04, 7.19, 1.74),
(6, '2020-03-24', 'fail', 45.57, 4.68, 24.19),
(7, '2020-04-08', 'success', 24.45, 12.69, 15.91),
(8, '2020-04-23', 'success', 48.22, 11.2, 48.82),
(9, '2020-05-08', 'success', 56.63, 4.04, 16.08),
(10, '2020-05-23', 'fail', 19.03, 16.65, 11.22),
(11, '2020-06-07', 'fail', 81, 6.56, 26.6),
(12, '2020-06-22', 'fail', 21.32, 8.86, 28.57),
(13, '2020-07-07', 'fail', 14.74, 17.76, 19.33),
(14, '2020-07-22', 'success', 66.73, 13.68, 14.07),
(15, '2020-08-06', 'success', 32.98, 16.17, 25.34),
(16, '2020-08-21', 'success', 46.49, 1.84, 41.9),
(17, '2020-09-05', 'fail', 45.98, 12.2, 2.46),
(18, '2020-09-20', 'success', 3.14, 24.8, 36.6),
(19, '2020-10-05', 'success', 75.33, 23.04, 29.99),
(20, '2020-10-20', 'success', 53.76, 22.94, 18.74);

--@block
-- Let's check the table has been created properly
select * from uber_request_logs;

--@block
-- To improve process clarity and readibility I solve this problem via creating two intermediate temporary tables to manage the queries.
-- This makes it easier to manage the different "partitions" and "group-by"

-- The first temporary table (uber_1) records:
-- date 
-- "Year-month" tag
-- distance-per-dollar for each single date
-- average distance-per-dollar for each Year-month:

DROP TABLE IF EXISTS uber_1;
CREATE TEMPORARY TABLE uber_1 as 
SELECT 

request_date,

DATE_FORMAT(request_date, '%Y-%m') as 'Y_m',

round(
    AVG(distance_to_travel/monetary_cost)
OVER (PARTITION BY request_date), 2) as "dist",

round(
AVG(distance_to_travel/monetary_cost) 
OVER (PARTITION BY DATE_FORMAT(request_date, '%Y-%m')), 2) as "avg"

from uber_request_logs;

--@block
-- Temporary Table 2, created from querying Temporary Table 1.
-- I use this extra temporary table to be able to perform an operation between the 2 columns which have different partition-scope.

DROP TABLE IF EXISTS uber_2;
create temporary table uber_2 as
select Y_m, abs(round(dist-avg,2)) as "abs" 
from uber_1;

--@block
-- This final query to Temporary Table 2 is used to group the rows by their "Year-month" tag:
select Y_m, round(avg(abs),2)
from uber_2
group by Y_m;


-- Here I used the same "process", but expressed with nested queries instead of relying on temporary tables:

--@block
-- Here using NESTED QUERIES instead of Temp Tables
SELECT Y_m, round(avg(abs),2)
     FROM(
        SELECT Y_m, abs(round(dist-avg,2)) as "abs"  
        FROM(
                    SELECT 
                    request_date,
            
                    DATE_FORMAT(request_date, '%Y-%m') as 'Y_m',
            
                    round(
                        AVG(distance_to_travel/monetary_cost)
                    OVER (PARTITION BY request_date), 2) as "dist",
            
                    round(
                    AVG(distance_to_travel/monetary_cost) 
                    OVER (PARTITION BY DATE_FORMAT(request_date, '%Y-%m')), 2) 
                    as "avg"
            
                    from uber_request_logs) as derived_1
    ) as derived_2
    group by Y_m;
    
