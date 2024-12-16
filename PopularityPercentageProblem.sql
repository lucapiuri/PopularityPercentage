-- ----------------------
-- Creating the table:
-- ----------------------

--@block
CREATE DATABASE facebook;

--@block
DROP TABLE IF EXISTS facebook_friends;
CREATE TABLE facebook_friends(
    user1 INT,
    user2 INT
);

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


-- ----------------------

--@block
-- visualizing the table
select * from facebook_friends;

--@block


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
