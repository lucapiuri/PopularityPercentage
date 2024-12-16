-- ------------------------------------------------------------------
--              Creating the database and the table:
-- ------------------------------------------------------------------
--@block
CREATE DATABASE facebook;

--@block
DROP TABLE IF EXISTS facebook_friends;
CREATE TABLE facebook_friends(
    user1 INT,
    user2 INT
);
-- populating the table with the required values
-- The 'user1' and 'user2' columns are "pairs of friends".
INSERT INTO facebook_friends (user1, user2)
VALUES 
(2,1), 
(1,3),
(4,1),
(1,	5),
(1,	6),
(2,	6),
(7,	2),
(8,	3),
(3,	9);


-- -------------------------------------------------------------------------------------------------------------------------
-- PROBLEM:
-- Find the popularity percentage for each user on Facebook. 
-- The popularity percentage is defined as the total number of friends the user has 
-- divided by the total number of users on the platform, then converted into a percentage by multiplying by 100.
-- Output each user along with their popularity percentage. Order records in ascending order by user id.
-- -------------------------------------------------------------------------------------------------------------------------

--@block
-- visualizing the table
select * from facebook_friends;

--@block
-- we first "mirror" the table and unite it to the original table, in order to take note of "other side" of the "friendship pairings"
-- then we count the number of friends for each user and divide that by the total number of users 
-- (and multiply by 100) to obtain the "popularity percentage"

with friends as(
select * from facebook_friends
union
select user2 as user1, user1 as user2 from facebook_friends
order by user1)

select user1, 
round(
    100*(count(user2)/
    (select count(distinct(user1)
    ) 
from friends))  ,2) as 'pop'
from friends
group by user1
;
