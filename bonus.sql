-- ** How to import your data. **

-- 1. In PgAdmin, right click on Databases (under Servers -> Postgresql 15). Hover over Create, then click Database.

-- 2. Enter in the name ‘Joins’ (not the apostrophes). Click Save.

-- 3. Left click the server ‘Joins’. Left click Schemas. 

-- 4. Right click public and select Restore.

-- 5. Select the folder icon in the filename row. Navigate to the data folder of your repo and select the file movies.backup. Click Restore.


-- ** Movie Database project. See the file movies_erd for table\column info. **

-- 1. Give the name, release year, and worldwide gross of the lowest grossing movie.
SELECT p1.film_title, p1.release_year,p2.worldwide_gross
FROM specs AS p1
JOIN revenue AS p2
ON p1.movie_id = p2.movie_id
ORDER BY p2.worldwide_gross ASC
LIMIT 1;
--ANSWER: Semi-Tough, 1977, worldwide gross $37,187,139

-- 2. What year has the highest average imdb rating?
SELECT p1.release_year,AVG(p2.imdb_rating) AS avg_rating
FROM specs AS p1
JOIN rating AS p2
ON p1.movie_id = p2.movie_id
GROUP BY p1.release_year
ORDER BY AVG(p2.imdb_rating) DESC
LIMIT 1;


--ANSWER: 1991

-- 3. What is the highest grossing G-rated movie? Which company distributed it?
SELECT p1.film_title,p1.mpaa_rating,p2.company_name,p3.worldwide_gross
FROM specs AS p1
JOIN distributors AS p2
ON p2.distributor_id = p1.domestic_distributor_id
JOIN revenue AS p3
ON p1.movie_id= p3.movie_id
WHERE p1.mpaa_rating = 'G'
GROUP BY p1.film_title,p2.company_name,p1.mpaa_rating,p3.worldwide_gross
ORDER BY p3.worldwide_gross DESC
LIMIT 1;
--ANSWER: Toy Story 4, Walt Disney

-- 4. Write a query that returns, for each distributor in the distributors table, the distributor name and the number of movies associated with that distributor in the movies 
-- table. Your result set should include all of the distributors, whether or not they have any movies in the movies table.
SELECT p1.company_name,COUNT(p2.movie_id) AS total_movies
FROM distributors AS p1
LEFT JOIN specs AS p2
ON p2.domestic_distributor_id = p1.distributor_id
GROUP BY p1.company_name
ORDER BY p1.company_name;

-- 5. Write a query that returns the five distributors with the highest average movie budget.
SELECT p1.company_name,ROUND(AVG(p3.film_budget),2) AS avg_budget
FROM specs AS p2
JOIN distributors AS p1
ON p2.domestic_distributor_id=p1.distributor_id
JOIN revenue AS p3
ON p2.movie_id=p3.movie_id 
GROUP BY company_name
ORDER BY avg_budget DESC
LIMIT 5;


-- 6. How many movies in the dataset are distributed by a company which is not headquartered in California? Which of these movies has the highest imdb rating?
SELECT p1.company_name,p1.headquarters,COUNT(p2.movie_id) AS movie_count,p2.film_title,p3.imdb_rating
FROM distributors AS p1
JOIN specs AS p2
ON p1.distributor_id=p2.domestic_distributor_id
JOIN rating AS p3
ON p2.movie_id= p3.movie_id
WHERE headquarters NOT LIKE ('%CA')
GROUP BY company_name,headquarters,film_title,imdb_rating
ORDER BY movie_count;
--ANSWER: Part 1. Two movies
--ANSWER: Part 2. Dirty Dancing by Vestron Pictures from Chicago, Illinois with IMDB 7.0 rating

-- 7. Which have a higher average rating, movies which are over two hours long or movies which are under two hours?
SELECT COUNT(p1.film_title),ROUND(AVG(p2.imdb_rating),2)AS avg_rating,(p1.length_in_min>120) AS greater_120,(p1.length_in_min<120) AS less_than_120, (p1.length_in_min=120) AS equals_120
FROM specs AS p1
JOIN rating AS p2
ON p1.movie_id=p2.movie_id
GROUP By greater_120, less_than_120,equals_120
ORDER BY avg_rating DESC;
--ANSWER: Movies over 2 hours long have higher ratings

--BONUS
-- 1.	Find the total worldwide gross and average imdb rating by decade. Then alter your query so it returns JUST the second highest average imdb rating and its decade. This should result in a table with just one row.

-- 2.	Our goal in this question is to compare the worldwide gross for movies compared to their sequels. 
-- a.	Start by finding all movies whose titles end with a space and then the number 2.
-- b.	For each of these movies, create a new column showing the original film’s name by removing the last two characters of the film title. For example, for the film “Cars 2”, the original title would be “Cars”. Hint: You may find the string functions listed in Table 9-10 of https://www.postgresql.org/docs/current/functions-string.html to be helpful for this. 
-- c.	Bonus: This method will not work for movies like “Harry Potter and the Deathly Hallows: Part 2”, where the original title should be “Harry Potter and the Deathly Hallows: Part 1”. Modify your query to fix these issues. 
-- d.	Now, build off of the query you wrote for the previous part to pull in worldwide revenue for both the original movie and its sequel. Do sequels tend to make more in revenue? Hint: You will likely need to perform a self-join on the specs table in order to get the movie_id values for both the original films and their sequels. Bonus: A common data entry problem is trailing whitespace. In this dataset, it shows up in the film_title field, where the movie “Deadpool” is recorded as “Deadpool “. One way to fix this problem is to use the TRIM function. Incorporate this into your query to ensure that you are matching as many sequels as possible.
-- ​
-- 3.	Sometimes movie series can be found by looking for titles that contain a colon. For example, Transformers: Dark of the Moon is part of the Transformers series of films.
-- ​
-- a.	Write a query which, for each film will extract the portion of the film name that occurs before the colon. For example, “Transformers: Dark of the Moon” should result in “Transformers”.  If the film title does not contain a colon, it should return the full film name. For example, “Transformers” should result in “Transformers”. Your query should return two columns, the film_title and the extracted value in a column named series. Hint: You may find the split_part function useful for this task.
-- b.	Keep only rows which actually belong to a series. Your results should not include “Shark Tale” but should include both “Transformers” and “Transformers: Dark of the Moon”. Hint: to accomplish this task, you could use a WHERE clause which checks whether the film title either contains a colon or is in the list of series values for films that do contain a colon.
-- c.	Which film series contains the most installments?
-- d.	Which film series has the highest average imdb rating? Which has the lowest average imdb rating?
-- ​
-- 4.	How many film titles contain the word “the” either upper or lowercase? How many contain it twice? three times? four times? Hint: Look at the sting functions and operators here: https://www.postgresql.org/docs/current/functions-string.html 
-- ​
-- 5.	For each distributor, find its highest rated movie. Report the company name, the film title, and the imdb rating. Hint: you may find the LATERAL keyword useful for this question. This keyword allows you to join two or more tables together and to reference columns provided by preceding FROM items in later items. See this article for examples of lateral joins in postgres: https://www.cybertec-postgresql.com/en/understanding-lateral-joins-in-postgresql/ 
-- ​
-- 6.	Follow-up: Another way to answer 5 is to use DISTINCT ON so that your query returns only one row per company. You can read about DISTINCT ON on this page: https://www.postgresql.org/docs/current/sql-select.html. 
-- ​
-- 7.	Which distributors had movies in the dataset that were released in consecutive years? For example, Orion Pictures released Dances with Wolves in 1990 and The Silence of the Lambs in 1991. Hint: Join the specs table to itself and think carefully about what you want to join ON. 