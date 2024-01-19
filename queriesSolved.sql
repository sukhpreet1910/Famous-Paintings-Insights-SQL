-- 1) Fetch all the paintings which are not displayed on any museums?

SELECT * 
from WORK w
where w.museum_id is NULL;


-- 2) How many paintings have an asking price of more than their regular price? 
SELECT count(*) as paintings_asking_for_more 
from product_size
where sale_price > regular_price


-- 3) Identify the paintings whose asking price is less than 50% of its regular price

SELECT *
from product_size 
where sale_price < regular_price/2::DECIMAL


-- 4) Which canva size costs the most?

SELECT label, p.sale_price
from product_size p
join canvas_size c 
on p.size_id = c.size_id::text
order by sale_price DESC
limit 1
 

 
SELECT *
FROM
(
select *, rank() over(order by sale_price desc) as rank 
from product_size p
join canvas_size c
on p.size_id = c.size_id::text
) x 
where rank = 1


select cs.label as canva, ps.sale_price
from 
    (select *
    , rank() over(order by sale_price desc) as rnk 
    from product_size) ps
join canvas_size cs 
on cs.size_id::text=ps.size_id
where ps.rnk=1;					 


-- 5) Delete duplicate records from work, product_size, subject and image_link tables

DELETE FROM work
where ctid not in 
(
    select min(ctid)
    from work
)

DELETE FROM product_size
where ctid not in 
(
    select min(ctid)
    from product_size
)

DELETE FROM subject
where ctid not in 
(
    select min(ctid)
    from subject
)

DELETE FROM image_link
where ctid not in 
(
    select min(ctid)
    from image_link
)


-- 6) Identify the museums with invalid city information in the given dataset

select * 
from museum
where city ~ '^[0-9]'

-- 7) Museum_Hours table has 1 invalid entry. Identify it and remove it.

delete 
from museum_hours 
where ctid not in 
(   select min(ctid)
    from museum_hours
    group by museum_id, day
);

SELECT *, ctid
from museum_hours

-- 8) Fetch the top 10 most famous painting subject


-- This is not a right approach bcz there are work_ids present in subject table and
-- this query is calculating count just from subject table
-- but in reality may be there are work_ids present in subject table which are not present in work table
-- so we have to specifically check for those ids which are present in work table and respectively in subject table 
-- we will count subject only for those ids which are present in work table 
SELECT subject, count(subject)
from subject
GROUP BY subject
order by 2 desc
limit 10;


-- Right Approach
SELECT *
from
(
SELECT s.subject, count(1), rank() over(order by count(1) desc) rank
from work w 
join subject s 
on w.work_id = s.work_id
group by subject
)
where rank <= 10


-- 9) Identify the museums which are open on both Sunday and Monday. Display museum name, city.

select m.museum_id, m.name, m.name, m.city, m.state, m.country
from
(
    SELECT museum_id, count(1) count
    from museum_hours
    where day in ('Sunday', 'Monday')
    group by museum_id
) c
join museum m 
on c.museum_id = m.museum_id
where c.count = 2


-- 10) How many museums are open every single day?

SELECT count(*)
from 
(
    SELECT mh.museum_id, count(1) as days_open
    from museum_hours mh 
    join museum m 
    on mh.museum_id = m.museum_id
    GROUP by mh.museum_id
    having count(1) = 7
)

