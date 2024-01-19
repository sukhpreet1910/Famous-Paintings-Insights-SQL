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

-- 11) Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)

select m.name, m.city, m.country, no_of_paintings, x.rank
from 
(
    select w.museum_id, count(1) as no_of_paintings, rank() over(order by count(1) desc) rank
    from museum m
    join work w 
    on m.museum_id = w.museum_id
    group by w.museum_id
    --order by 3
)x
join museum m 
on m.museum_id = x.museum_id
where rank <= 5
order by 5


-- 12) Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)

SELECT 
    w.artist_id, a.full_name, a.nationality, count(1) as no_of_paintings,
    rank() over(order by count(1) DESC) as rank
from work w
join artist a 
on w.artist_id = a.artist_id
group by w.artist_id, full_name, nationality
limit 5


-- 13) Display the 3 least popular canva sizes

SELECT *
FROM
(
    SELECT p.size_id, label, count(1), dense_rank() over(order by count(1)) as rank
    from product_size p
    join canvas_size c
    on p.size_id = c.size_id::text
    GROUP BY p.size_id, label
    order by 2
)
where rank <= 3
order by 4



-- 14) Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?


SELECT *
from(
    select m.name, m.state as city, m.country, day, open, close,
    to_timestamp(close, 'HH:MI:PM') - to_timestamp(open, 'HH:MI:AM') as duration,
    rank() over(order by to_timestamp(close, 'HH:MI:PM') - to_timestamp(open, 'HH:MI:AM') desc ) as rank 
    from museum_hours mh
    join museum m
    on mh.museum_id = m.museum_id
)x
where rank = 1;


-- 15) Which museum has the most no of most popular painting style?


