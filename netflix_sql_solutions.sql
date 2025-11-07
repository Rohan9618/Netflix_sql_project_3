drop table if exists netflix;
create table netflix( 
	show_id	varchar(6),
	type varchar(10), 	
	title varchar(150), 	
	director varchar(208),	
	casts varchar(1000),	
	country	varchar(150),
	date_added	varchar(50),
	release_year int,	
	rating varchar(10),	
	duration varchar(15),	
	listed_in varchar(150),	
	description varchar(250)
);

select count(*)  as total_content from netflix;


select distinct type from netflix;

--15 Businees Problems
--1. Count the Number of Movies vs TV Shows

select type , count(*) as content from netflix
group by 1;

--2. Find the Most Common Rating for Movies and TV Shows 
select type,rating from
(select  type, rating, count(*), 
rank () over(partition by type order by count(*)desc) as ranking
from netflix
group by 1,2 ) as t1
where ranking = 1

--3. List All Movies Released in a Specific Year (e.g., 2020)

select * from netflix
where release_year=2020 and type='Movie';

--4. Find the Top 5 Countries with the Most Content on Netflix

SELECT unnest(string_to_array(country,',')) as new_country,count(show_id) as content from netflix
group by 1
order by 2 desc
limit 5;

select unnest(string_to_array(country,',')) as new_country from netflix;


--5. Identify the Longest Movie

select * from netflix
where type='Movie' and duration=(select max(duration) from netflix)

-- Find Content Added in the Last 5 Years

select * from netflix
where to_date(date_added, 'Month dd, yyyy') >= current_date- interval '5 years'

--Find All Movies/TV Shows by Director 'Rajiv Chilaka

select * from netflix
where director ilike '%Rajiv Chilaka%'

or 
select * from
(select *, unnest(string_to_array (director, ',')) as director_name from  netflix) as t 
where director_name= 'Rajiv Chilaka';




--8.List All TV Shows with More Than 5 Seasons
select *, 
split_part(duration, ' ', 1) as sessions
from netflix
where type='TV Show'
and split_part(duration, ' ', 1)::numeric>5

--9. Count the Number of Content Items in Each Genre

select unnest(string_to_array(Listed_in,',')) as genre , count(*) from netflix 
group by 1;


--10.Find each year and the average numbers of content release in India on netflix.

select extract(year from to_date(date_added,'Month dd yyy')) as year, 
count(*)  as yearly_content , 
round(count(*)::numeric/(select count(*) from netflix where country ='India')::numeric * 100,2) as avg_content_per_year 
from netflix  
where country ='India'
group by 1 
order by avg_content_per_year desc
limit 5;

--11. List All Movies that are Documentaries

select * from netflix
where listed_in ILIKE '%documentaries%'

-- 12. find all the content without a director

SELECT * 
FROM netflix
WHERE director IS NULL;


--13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
select * from netflix 
where  casts ilike '%salman khan%' and
release_year > extract(year from current_date)- 10


-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India 

select  unnest(string_to_array(casts,',')) as actors ,count(*) from netflix
where country ilike '%India%'
group by 1
order by count(*) desc
limit 10

--15. Categorize Content Based on the Presence of 'Kill' and 'Violence' in the description ,
-- label content contatining these keywords as 'bad'and all other content as ' good '. count how many items fall into each category.

with new_table
as 
(select * ,
case
when description ilike '%kill%' or 
description ilike '%violence%' then 'bad_content'
else 'good_content'
end category


from netflix)

select category, count(*) as total_content from new_table
group by 1









