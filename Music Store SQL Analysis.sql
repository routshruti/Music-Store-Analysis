-- Q1. Who is the senior-most employee based on job title?

SELECT employee_id, concat(first_name,last_name) AS employee_name, title AS job_title
FROM employee
ORDER BY levels DESC
LIMIT 1

-- Q2. Which country has the most Invoices?
	
SELECT billing_country AS country, count(invoice_id) AS invoice_count
FROM invoice
GROUP BY billing_country
ORDER BY invoice_count DESC
LIMIT 1

-- Q3. What are the top 3 values of the total invoice?

SELECT round(CAST(total AS decimal),2) AS total_invoice FROM invoice
ORDER BY total_invoice DESC
LIMIT 3

-- Q4. We would like to throw a promotional Music Festival in the city where we made the most money.
--     Write a query that returns the city that has the highest sum of invoice totals.

SELECT billing_city Scity, round(CAST(SUM(total) AS decimal),2) AS invoice_total
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC
LIMIT 1

-- Q5. Who is the best customer? The customer who has spent the most money will be declared the best customer.

SELECT c.customer_id, first_name, last_name, round(CAST(SUM(total) AS decimal),2) AS invoice_total
FROM customer AS c
JOIN invoice AS i
ON c.customer_id = i.customer_id
GROUP BY 1,2,3
ORDER BY 4 DESC
LIMIT 1

-- Q6. Write a query to return the first name, last name, & email of all Rock Music listeners.
--     Return your list ordered alphabetically by email starting with A.

SELECT DISTINCT first_name, last_name, email
FROM customer AS c
JOIN invoice AS i
on c.customer_id = i.customer_id
JOIN invoice_line AS il
ON i.invoice_id = il.invoice_id
JOIN track AS t
on il.track_id = t.track_id
Where genre_id IN (SELECT genre_id
	               FROM genre
	               WHERE name LIKE 'Rock')
ORDER BY email ASC

-- Q7. Let's invite the artists who have written the most rock music in our dataset.
--     Write a query that returns the Artist name and total track count of the top 10 rock bands.
	
SELECT a.artist_id, a.name AS artist_name, COUNT(track_id) AS no_of_songs
FROM artist AS a
JOIN album AS ab
ON a.artist_id = ab.artist_id
JOIN track AS t
ON ab.album_id = t.album_id
WHERE track_id IN(SELECT track_id
	              FROM track AS t
	              JOIN genre AS g
	              ON t.genre_id = g.genre_id
	              WHERE g.name LIKE 'Rock')
GROUP BY a.artist_id, a.name
ORDER BY no_of_songs DESC
LIMIT 10

-- Q8. Return all the track names that have a song length longer than the average song length. 
--     Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.
	
SELECT name AS song_name, milliseconds AS song_length
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) AS avg_song_length
	                  FROM track)
ORDER BY song_length DESC

-- Q9. Find how much amount is spent by each customer on artists. Write a query to return the customer name, artist name, and total spent.
	
SELECT concat(first_name,last_name) AS customer_name, a.name AS artist_name,
round(CAST(SUM(il.unit_price*il.quantity)AS decimal),2) AS total_spent
FROM customer AS c
JOIN invoice AS i
ON c.customer_id = i.customer_id
JOIN invoice_line AS il
ON i.invoice_id = il.invoice_id
JOIN track  AS t
ON il.track_id = t.track_id
JOIN album AS ab
ON t.album_id = ab.album_id
JOIN artist AS a
on ab.artist_id = a.artist_id
GROUP BY 1,2
ORDER BY 3 DESC

-- Q10. We want to find out the most popular music Genre for each country. 
--      We determine the most popular genre as the genre with the highest amount of purchases. 
--      Write a query that returns each country along with the top Genre.

WITH cte AS
	(SELECT billing_country, g.name, COUNT(quantity) AS no_of_purchases
     FROM invoice AS i
     JOIN invoice_line AS il
     ON i.invoice_id = il.invoice_id
     JOIN track  AS t
     ON il.track_id = t.track_id
     JOIN genre AS g
     ON t.genre_id = g.genre_id
     GROUP BY billing_country, g.name),
	cte1 AS
	(SELECT *,
	row_number() OVER(PARTITION BY billing_country ORDER BY no_of_purchases DESC) AS rw
	FROM cte)
SELECT billing_country AS country, name AS top_genre
FROM cte1
WHERE rw = '1'

-- Q11. Write a query that determines the customer that has spent the most on music for each country.
--      Write a query that returns the country along with the top customer and how much they spent.

WITH cte AS
	(SELECT concat(first_name, last_name) AS customer_name, billing_country AS country,
	round(CAST(SUM(total) AS decimal),2) AS invoice_total
	FROM customer c
	JOIN invoice i
	ON c.customer_id = i.customer_id
	GROUP BY 1,2),
	cte1 AS
	(SELECT *,
	row_number() OVER(PARTITION BY country ORDER BY invoice_total DESC) AS rw
	FROM cte)
SELECT customer_name, country, invoice_total
FROM cte1
WHERE rw = '1'


-- Q12. Who is the most popular artists?
--      We determine the most popular artists as the artists with the highest amount of purchases.

SELECT a.artist_id, a.name as artist_name, COUNT(quantity) AS no_of_purchases
FROM invoice_line AS il
JOIN track t
ON il.track_id = t.track_id
JOIN album AS ab
ON t.album_id = ab.album_id
JOIN artist AS a
ON ab.artist_id = a.artist_id
GROUP BY 1,2
ORDER BY 3 desc
LIMIT 1

-- Q13. Which is the most popular song?
--      We determine the most popular song as the song with the highest amount of purchases.

SELECT t.name AS song, COUNT(quantity) AS no_of_purchases
FROM invoice_line AS il
JOIN track AS t
ON il.track_id = t.track_id
GROUP BY 1
ORDER BY 2 desc
LIMIT 1
	