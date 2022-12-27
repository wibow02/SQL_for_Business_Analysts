-- Exploring the table renting
SELECT * 
FROM renting;   
-- The table renting includes allrecords
-- of movie rentals. Each record has a unique ID renting_id

SELECT movie_id,  -- Select all columns needed to compute the average rating per movie
       rating
FROM renting;

SELECT *
FROM renting
WHERE date_renting BETWEEN '2018-04-01' AND '2018-08-31'
-- from beginning April 2018 to end August 2018
ORDER BY date_renting desc;

SELECT *
FROM movies
WHERE title IN ('Showtime', 'Love Actually', 'The Fighter');
-- Select all movies with the given titles

SELECT *
FROM renting
WHERE date_renting BETWEEN '2018-01-01' AND '2018-12-31' -- Renting in 2018
AND rating IS NOT NULL ; -- Rating 

-- Summarizing customer information
SELECT count(*) -- Count the total number of customers
FROM customers
WHERE date_of_birth between '1980-01-01' and '1989-12-31'; 

SELECT count(distinct country)   -- Count the number of countries
FROM customers;

-- Ratings of movie 25
SELECT min(rating) min_rating, -- Calculate the minimum rating and use alias min_rating
	   max(rating) max_rating, -- Calculate the maximum rating and use alias max_rating
	   avg(rating) avg_rating, -- Calculate the average rating and use alias avg_rating
	   count(rating) number_ratings -- Count the number of ratings and use alias number_ratings
FROM renting
WHERE movie_id = 25; -- Select all records of the movie with ID 25

-- Examining annual rentals
SELECT 
	COUNT(*) AS number_renting,
	AVG(rating) AS average_rating, 
    count(rating) AS number_ratings -- Add the total number of ratings here.
FROM renting
WHERE date_renting >= '2019-01-01';

-- First account for each country.
-- when the first customer accounts were created for each country
ELECT country, -- For each country report the earliest date when an account was created
	MIN(date_account_start) AS first_account
FROM customers
GROUP BY country
ORDER BY first_account;

-- Average movie ratings
SELECT movie_id, 
       AVG(rating) AS avg_rating,
       COUNT(rating) AS number_ratings,
       COUNT(*) AS number_renting
FROM renting
GROUP BY movie_id
ORDER BY avg_rating DESC; -- Order by average rating in decreasing order

-- Average rating per customer
SELECT customer_id, -- Report the customer_id
      AVG(rating),  -- Report the average rating per customer
      COUNT(rating),  -- Report the number of ratings per customer
      COUNT(*)  -- Report the number of movie rentals per customer
FROM renting
GROUP BY customer_id
HAVING COUNT(*) > 7 -- Select only customers with more than 7 movie rentals
ORDER BY AVG; -- Order by the average rating in ascending order

-- Aggregating revenue, rentals and active customers
SELECT 
	sum(renting_price), -- Get the revenue from movie rentals
	COUNT(distinct m.movie_id), -- Count the number of rentals
	COUNT(distinct customer_id)  -- Count the number of customers
FROM renting AS r
LEFT JOIN movies AS m
ON r.movie_id = m.movie_id
-- Only look at movie rentals in 2018
WHERE date_renting BETWEEN '2018-01-01' and  '2018-12-31';

-- which actors play in which movie.
SELECT m.title, -- Create a list of movie titles and actor names
       a.name
FROM actsin ai
LEFT JOIN movies AS m
ON m.movie_id = ai.movie_id
LEFT JOIN actors AS a
ON a.actor_id = ai.actor_id;

-- Income from movies
-- How much income did each movie generate?
SELECT m.title, -- Use a join to get the movie title and price for each movie rental
       m.renting_price
FROM renting AS r
LEFT JOIN movies AS m
ON r.movie_id = m.movie_id;

-- Report the total income for each movie
SELECT title, -- Report the income from movie rentals for each movie 
       sum(renting_price) AS income_movie
FROM
       (SELECT m.title,  
               m.renting_price
       FROM renting AS r
       LEFT JOIN movies AS m
       ON r.movie_id=m.movie_id) AS rm
GROUP BY title
ORDER BY income_movie DESC; -- Order the result by decreasing income


-- Age of actors from the USA
SELECT a.gender, -- Report for male and female actors from the USA 
       MIN(a.year_of_birth), -- The year of birth of the oldest actor
       MAX(a.year_of_birth) -- The year of birth of the youngest actor
FROM
    (SELECT * -- Use a subsequent SELECT to get all information about actors from the USA
    FROM actors
    WHERE nationality = 'USA') AS a -- Give the table the name a
GROUP BY a.gender;

-- Age of actors from the USA
SELECT a.gender, -- Report for male and female actors from the USA 
       MIN(a.year_of_birth), -- The year of birth of the oldest actor
       MAX(a.year_of_birth) -- The year of birth of the youngest actor
FROM
   ( select * 
-- 	Use a subsequen SELECT to get all information about actors from the USA
   FROM actors
   WHERE nationality = 'USA') as a -- Give the table the name a
GROUP BY a.gender;

-- Identify favorite movies for a group of customers
SELECT *
FROM renting AS r
LEFT JOIN customers as c   -- Add customer information
on c.customer_id = r.customer_id
LEFT JOIN movies as m   -- Add movie information
on m.movie_id = r.movie_id;

-- Select only those records of customers born in the 70s.
SELECT *
FROM renting AS r
LEFT JOIN customers AS c
ON c.customer_id = r.customer_id
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
WHERE c.date_of_birth BETWEEN '1970-01-01' AND '1979-12-31'; -- Select customers born in the 70s

SELECT m.title, 
COUNT(*), -- Report number of views per movie
AVG(r.rating) -- Report the average rating per movie
FROM renting AS r
LEFT JOIN customers AS c
ON c.customer_id = r.customer_id
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
WHERE c.date_of_birth BETWEEN '1970-01-01' AND '1979-12-31'
GROUP BY m.title;

SELECT m.title, 
COUNT(*),
AVG(r.rating)
FROM renting AS r
LEFT JOIN customers AS c
ON c.customer_id = r.customer_id
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
WHERE c.date_of_birth BETWEEN '1970-01-01' AND '1979-12-31'
GROUP BY m.title
HAVING COUNT(*) > 1  -- Remove movies with only one rental
ORDER BY AVG DESC; -- Order with highest rating first

-- Identify favorite actors for Spain
SELECT a.name,  c.gender,
       COUNT(*) AS number_views, 
       AVG(r.rating) AS avg_rating
FROM renting as r
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
LEFT JOIN actsin as ai
ON r.movie_id = ai.movie_id
LEFT JOIN actors as a
ON ai.actor_id = a.actor_id
WHERE c.country	= 'Spain' -- Select only customers from Spain
GROUP BY a.name, c.gender
HAVING AVG(r.rating) IS NOT NULL 
AND COUNT(*) > 5 
ORDER BY avg_rating DESC, number_views DESC;

-- KPIs per country
SELECT 
	c.country,                   -- For each country report
	COUNT(r.renting_id) AS number_renting, -- The number of movie rentals
	AVG(r.rating) AS average_rating, -- The average rating
	SUM(m.renting_price) AS revenue         -- The revenue from movie rentals
FROM renting AS r
LEFT JOIN customers AS c
ON c.customer_id = r.customer_id
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
WHERE date_renting >= '2019-01-01'
GROUP BY c.country;

-- Select all information about movies with more than 5 views.
SELECT *
FROM movies
where movie_id in -- Select movie IDs from the inner query
	(SELECT movie_id
	FROM renting
	GROUP BY movie_id
	HAVING COUNT(*) > 5);

-- List all customer information for customers who rented more than 10 movies
SELECT *
FROM customers
WHERE customer_id in -- Select all customers with more than 10 movie rentals
	(SELECT customer_id
	FROM renting
	GROUP BY customer_id
	HAVING COUNT(*) > 10);

-- Movies with rating above average
SELECT movie_id, -- Select movie IDs and calculate the average rating 
       AVG(rating)
FROM renting
GROUP BY movie_id
HAVING AVG(rating) >       -- Of movies with rating above average
	(SELECT AVG(rating)
	FROM renting);

-- Report the movie titles of all movies
-- with average rating higher than the total average
SELECT title 
FROM movies
WHERE movie_id in
	(SELECT movie_id
	 FROM renting
     GROUP BY movie_id
     HAVING AVG(rating) > 
		(SELECT AVG(rating)
		 FROM renting));
		 
-- Analyzing customer behavior
-- Count movie rentals of customer 45
SELECT COUNT(*)
FROM renting
WHERE customer_id=45;
-- select all columns from the customer table where
-- the number of movie rentals is smaller than 5
-- Select customers with less than 5 movie rentals
SELECT *
FROM customers as c
WHERE  5 > 
	(SELECT count(*)
	FROM renting as r
	WHERE r.customer_id = c.customer_id);
	
-- Customers who gave low ratings
-- Calculate the minimum rating of customer with ID 7
SELECT MIN(rating)
FROM renting
WHERE customer_id = 7;

-- Select all customers with a minimum rating smaller than 4
SELECT *
FROM customers c
WHERE 4 > -- Select all customers with a minimum rating smaller than 4 
	(SELECT MIN(rating)
	FROM renting AS r
	WHERE r.customer_id = c.customer_id);

-- Movies and ratings with correlated queries
SELECT *
FROM movies m
WHERE 5 < -- Select all movies with more than 5 ratings
	(SELECT COUNT(rating)
	FROM renting r
	WHERE m.movie_id = r.movie_id );
	
SELECT *
FROM movies AS m
WHERE 8 < -- Select all movies with an average rating higher than 8
	(SELECT AVG(rating)
	FROM renting AS r
	WHERE r.movie_id = m.movie_id);

-- Customers with at least one rating
-- Select all records of movie rentals from customer with ID 115
SELECT *
FROM renting
WHERE customer_id = 115;

SELECT *
FROM renting
WHERE rating is not null -- Exclude those with null ratings
AND customer_id = 115;

SELECT *
FROM renting
WHERE rating is not null -- Exclude null ratings
and customer_id = 1; -- Select all ratings from customer with ID 1

SELECT *
FROM customers c -- Select all customers with at least one rating
WHERE EXISTS 
	(SELECT *
	FROM renting AS r
	WHERE rating IS NOT NULL 
	AND r.customer_id = c.customer_id);

-- Actors in comedies
SELECT * -- Select the records of all actors who play in a Comedy
FROM actsin AS ai
LEFT JOIN movies AS m
ON ai.movie_id = m.movie_id
WHERE m.genre = 'Comedy';

SELECT *
FROM actsin AS ai
LEFT JOIN movies AS m
ON m.movie_id = ai.movie_id
WHERE m.genre = 'Comedy'
AND ai.actor_id = 1; -- Select only the actor with ID 1

-- Create a list of all actors who play in a Comedy
SELECT *
FROM actors AS a
WHERE EXISTS
	(SELECT *
	 FROM actsin AS ai
	 LEFT JOIN movies AS m
	 ON m.movie_id = ai.movie_id
	 WHERE m.genre = 'Comedy'
	 AND ai.actor_id = a.actor_id);
	 
-- Report the nationality and the number of actors for each nationality
SELECT a.nationality, count(*) 
FROM actors AS a
WHERE EXISTS
	(SELECT ai.actor_id
	 FROM actsin AS ai
	 LEFT JOIN movies AS m
	 ON m.movie_id = ai.movie_id
	 WHERE m.genre = 'Comedy'
	 AND ai.actor_id = a.actor_id)
GROUP by a.nationality;

-- Young actors not coming from the USA
SELECT name,  -- Report the name, nationality and the year of birth
       nationality, 
       year_of_birth
FROM actors
where nationality <> 'USA'; -- Of all actors who are not from the USA

SELECT name, 
       nationality, 
       year_of_birth
FROM actors
WHERE year_of_birth > 1990; -- Born after 1990

SELECT name, 
       nationality, 
       year_of_birth
FROM actors
WHERE nationality <> 'USA'
UNION -- Select all actors who are not from the USA and all actors who are born after 1990
SELECT name, 
       nationality, 
       year_of_birth
FROM actors
WHERE year_of_birth > 1990;

SELECT name, 
       nationality, 
       year_of_birth
FROM actors
WHERE nationality <> 'USA'
INTERSECT -- Select all actors who are not from the USA and who are also born after 1990
SELECT name, 
       nationality, 
       year_of_birth
FROM actors
WHERE year_of_birth > 1990;

-- Dramas with high ratings
SELECT movie_id -- Select the IDs of all dramas
FROM movies
WHERE genre = 'Drama';

-- Select the IDs of all movies with average rating higher than 9
SELECT movie_id, AVG(rating) 
FROM renting
GROUP BY movie_id
HAVING AVG(rating) > 9;

SELECT movie_id
FROM movies
WHERE genre = 'Drama'
INTERSECT  -- Select the IDs of all dramas with average rating higher than 9
SELECT movie_id
FROM renting
GROUP BY movie_id
HAVING AVG(rating)>9;

SELECT *
FROM movies
WHERE movie_id in  -- Select all movies of genre drama with average rating higher than 9
   (SELECT movie_id
    FROM movies
    WHERE genre = 'Drama'
    INTERSECT
    SELECT movie_id
    FROM renting
    GROUP BY movie_id
    HAVING AVG(rating)>9);
	
-- Groups of customers
-- Use the CUBE operator to extract the content of 
-- a pivot table from the database
SELECT gender, -- Extract information of a pivot table of gender and country for the number of customers
	   country,
	   count(*)
FROM customers
GROUP BY CUBE (gender, country)
ORDER BY country;

-- Categories of movies
SELECT genre,
       year_of_release,
       COUNT(*)
FROM movies
GROUP BY CUBE(genre,year_of_release)
ORDER BY year_of_release;

-- Analyzing average ratings
-- Augment the records of movie rentals with information about movies and customers
SELECT *
FROM renting r
LEFT JOIN customers c
ON  c.customer_id = r.customer_id 
LEFT JOIN movies m
ON m.movie_id = r.movie_id;

-- Calculate the average rating for each country
SELECT c.country,
    AVG(r.rating)
FROM renting AS r
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
GROUP BY c.country;


-- What is the average rating over all records?
-- Calculate the average rating for all aggregation levels of country and genre
SELECT c.country,
	m.genre, 
	AVG(r.rating) AS avg_rating -- Calculate the average rating 
FROM renting AS r
LEFT JOIN movies AS m
ON m.movie_id = r.movie_id
LEFT JOIN customers AS c
ON r.customer_id = c.customer_id
GROUP BY CUBE(c.country, m.genre); -- For all aggregation levels of country and genre
-- result:A null value in a row indicates that this category was aggregated