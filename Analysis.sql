
IF NOT EXISTS (
    SELECT * FROM sys.schemas WHERE name = 'Netflix'
)
BEGIN
    EXEC('CREATE SCHEMA Netflix');
END
--Transfer credits and titles table from dbo schema to Netflix schema.
ALTER SCHEMA Netflix TRANSFER dbo.credits;
ALTER SCHEMA Netflix TRANSFER dbo.titles;
--Remove [] from start and End.
UPDATE netflix.titles
SET 
  genres = CASE 
           WHEN LEFT(genres, 1) = '[' AND RIGHT(genres, 1) = ']' 
           THEN SUBSTRING(genres, 2, LEN(genres) - 2) 
           ELSE genres 
         END,
  production_countries = CASE 
           WHEN LEFT(production_countries, 1) = '[' AND RIGHT(production_countries, 1) = ']' 
           THEN SUBSTRING(production_countries, 2, LEN(production_countries) - 2) 
           ELSE production_countries 
         END;

UPDATE netflix.titles
SET 
  genres = CASE 
             WHEN LEFT(genres, 1) = '''' AND RIGHT(genres, 1) = '''' 
             THEN SUBSTRING(genres, 2, LEN(genres) - 2) 
             ELSE genres 
           END,
  production_countries = CASE 
             WHEN LEFT(production_countries, 1) = '''' AND RIGHT(production_countries, 1) = '''' 
             THEN SUBSTRING(production_countries, 2, LEN(production_countries) - 2) 
             ELSE production_countries 
           END;


select * from Netflix.credits
select * from Netflix.titles

-- What were the top 10 movies according to IMDB score?
select top 10
  title,
  type,
  Round(imdb_score,2) as Imb_Score 
from 
Netflix.titles 
where type='MOVIE'
   and imdb_score>=8
order by imdb_score desc

-- What were the top 10 shows according to IMDB score? 

select top 10
  title,
  type,
  Round(imdb_score,2) as Imb_Score 
from 
Netflix.titles 
where type='SHOW'
   and imdb_score>=8
order by imdb_score desc

-- What were the bottom 10 movies according to IMDB score?

select top 10
  title,
  type,
  round(imdb_score,2) as IMB_Score
from Netflix.titles
where type='MOVIE' and imdb_score is not null
order by imdb_score asc

-- What were the bottom 10 shows according to IMDB score? 

select top 10
  title,
  type,
  round(imdb_score,2) as IMDB_Score
from Netflix.titles
where type='SHOW' and imdb_score is not null
order by imdb_score asc

-- What were the average IMDB and TMDB scores for shows and movies? 

select 
   type,
   ROund(AVG(imdb_score),2) as Avg_IMDB,
   Round(avg(tmdb_score),2) as AVG_TMDB
from Netflix.titles
   group by type

-- Count of movies and shows in each decade
select 
   concat((release_year/10)*10,'S') as Decade,
   count(*) as Total_movie_Show
from
Netflix.titles
   group by (release_year/10)*10 
order by Decade

-- What were the average IMDB and TMDB scores for each production country?
select 
    production_countries,
	round(avg(imdb_score),2) as avg_imdb,
	round(avg(imdb_votes),2) as avg_imdb
from Netflix.titles
    group by production_countries
order by avg(imdb_score) desc

--- What were the 5 most common age certifications for movies?

select top 5
    age_certification,
	count(*) as Certification_No
from Netflix.titles
    where 
	     age_certification is not null and type='MOVIE'
    group by age_certification
order by Certification_No desc

-- Who were the top 20 actors that appeared the most in movies/shows? 
select top 20
   name as Actor_Name,
   count(*) as Appeared
from Netflix.credits
   where role = 'ACTOR'
   group by name
order  by Appeared desc

-- Who were the top 20 directors that directed the most movies/shows?

select top 20
   name as Actor_Name,
   count(*) as Appeared
from Netflix.credits
   where role = 'DIRECTOR'
   group by name
order  by Appeared desc

-- Calculating the average runtime of movies and TV shows separately
select * from Netflix.titles
select  
     type,
	 avg(runtime) as Avg_runtime
from 
     Netflix.titles
where type = 'MOVIE'
     group by type
Union
select  
     type,
	 avg(runtime) as Avg_runtime
from 
     Netflix.titles
where type = 'SHOW'
     group by type

-- Finding the titles and  directors of movies released on or after 2010
select
     title as Movie_Name,
	 name as Director_Name,
	 release_year 
from Netflix.credits c
inner join 
Netflix.titles t
on c.id=t.id
where 
    type = 'MOVIE' and release_year >2010 and role='DIRECTOR'
order by release_year Desc

-- Which shows on Netflix have the most seasons?
select top 10
    title,
	sum(seasons) as Total_Season
from 
Netflix.titles
where type = 'SHOW'
    group by title
order by Total_Season desc

-- Which genres had the most movies? 

select top 10
 genres,
 count(*) Shows_Count
from 
Netflix.titles
where type = 'MOVIE' and genres != ''
  group by genres
order by Shows_Count desc

-- Which genres had the most shows? 
select top 10
 genres,
 count(*) Shows_Count
from 
Netflix.titles
where type = 'SHOW' and genres != ''
  group by genres
order by Shows_Count desc

-- Titles and Directors of movies with high IMDB scores (>7.5) and high TMDB popularity scores (>80) 
  
select 
      title as Title,
	  name as Director_Name
from  
Netflix.credits c
inner join Netflix.titles t 
on c.id=t.id
where 
      type = 'MOVIE'
      and imdb_score > 7.5
      and tmdb_popularity > 80
      and role = 'DIrector'

-- What were the total number of titles for each year?
select * from netflix.titles
select 
     release_year,
	 count(*) as Total_Title
from 
Netflix.titles
     group by release_year
order by release_year desc

-- Actors who have starred in the most highly rated movies or shows.
select 
      name,
	  count(*) Highly_Rated
from Netflix.credits c
inner join Netflix.titles t 
on c.id=t.id
where 
     role ='ACTOR'
	 and type in ('MOVIE','SHOW')
	 and imdb_score > 8
	 and tmdb_score> 8
 group by name
     order by Highly_Rated desc

-- Which actors/actresses played the same character in multiple movies or TV shows? 
select 
   name,
   coalesce(character,'Unknown') as Charecter_Name,
   count(distinct title) as Num_Charecter_Played
from
Netflix.credits c
inner join Netflix.titles t
on c.id=t.id
where 
   role in ('ACTOR','ACTRESS')
group by name,character
having count(distinct title)>1 

-- What were the top 3 most common genres?

select top 3
  genres,
  count(*) as Total_genres
from 
Netflix.titles
  where type='Movie'
  group by genres
order by Total_genres desc


-- Average IMDB score for leading actors/actresses in movies or shows 
SELECT c.name AS actor_actress, 
ROUND(AVG(t.imdb_score),2) AS average_imdb_score
FROM Netflix.credits AS c
JOIN Netflix.titles AS t 
ON c.id = t.id
WHERE c.role = 'actor' OR c.role = 'actress'
AND c.character = 'leading role'
GROUP BY c.name
ORDER BY average_imdb_score DESC;







