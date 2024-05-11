
-- Q1. Who is the senior most employee based on job title?

SELECT TOP 1 * FROM employee
ORDER BY levels DESC

-- Q2. Which countries have the most invoices?

SELECT COUNT(total) AS Invoices, billing_country
FROM invoice
GROUP BY billing_country
ORDER BY Invoices DESC

-- Q3. What are top 3 values of total invoice?

SELECT TOP 3 * FROM invoice
ORDER BY total DESC

-- Q4. Which city has the best customers? we would like to throw a promotional music festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. return both the city name and sum of all invoice totals.

SELECT TOP 1 SUM(total) as invoices_total, billing_city
FROM invoice
Group by billing_city
ORDER BY invoices_total DESC

-- Q5. Who is the best customer? the customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money.

SELECT customer.customer_id, customer.first_name, customer.last_name FROM customer SELECT SUM(invoice.total) AS Total
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY Total DESC

-- Q6. Write query to return the email, first name, last name and genre of all rock music listners. Return your list ordered alphabatically by email starting with A.
SELECT * FROM customer
SELECT DISTINCT email, first_name, last_name  FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id 
WHERE track_id IN(SELECT track_id FROM track 
                  JOIN genre ON track.genre_id = genre.genre_id
				  WHERE genre.name = 'Rock')
ORDER BY email;

-- Q7. Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the artist name and total track count of the top 10 rock bands.

SELECT TOP 10 artist.artist_id, artist.name, COUNT(artist.artist_id) AS total_tracks FROM artist
INNER JOIN album ON artist.artist_id = album.artist_id
INNER JOIN track ON album.album_id = track.album_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name = 'Rock'
GROUP BY artist.artist_id, artist.name
ORDER BY total_tracks DESC;


SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id, artist.name
ORDER BY number_of_songs DESC;

-- Q8. Return all the track namea that have a song length longer than the average song length.
-- Return the name and milliseconds for each track. 
-- Order by the song length with the longest song listed first.

SELECT TOP 10 name, milliseconds FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) AS avg_length_track FROM track)
ORDER BY milliseconds DESC;

-- Q9. Find how much amount spent by each customers on artists? Write a query to return customer name, artist name,total spent.

WITH best_selling_artist AS (
     SELECT TOP 1 artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	 FROM invoice_line
	 JOIN track ON track.track_id = invoice_line.track_id
	 JOIN album ON album.album_id = track.track_id
	 JOIN artist ON artist.artist_id = album.artist_id
	 GROUP BY artist.artist_id, artist.name
	 ORDER BY total_sales DESC
)

SELECT customer.customer_id, customer.first_name, customer.last_name, bsa.artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS amount_spent
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN album ON track.album_id = album.album_id
JOIN best_selling_artist AS bsa ON album.artist_id = bsa.artist_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name, bsa.artist_name
ORDER BY amount_spent DESC;


-- Q10. We want to find out the most popular music genre for each country. 
-- We determine the most popular genre as the genre with the highest amount of purchases.
-- Write a query that returns each country along with the top genre. For countries where the maximum number of purchases is shared return all genres.

WITH popular_genre AS 
(
     SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
	 ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo
     FROM invoice_line
	 JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	 JOIN customer ON customer.customer_id = invoice.customer_id
	 JOIN track ON track.track_id = invoice_line.track_id
	 JOIN genre ON genre.genre_id = track.genre_id
	 GROUP BY customer.country, genre.name, genre.genre_id
)
SELECT * FROM popular_genre WHERE RowNo = 1

-- Q11. Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent.
-- For countries where the top amount spent is shared, provide all customers who spent this amount.

WITH customer_with_country AS 
(
     SELECT customer.customer_id, first_name, last_name, billing_country, SUM(total) AS total_spending,
	 ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo
	 FROM invoice
	 JOIN customer ON customer.customer_id = invoice.customer_id
	 GROUP BY customer.customer_id, first_name, last_name, billing_country
)
SELECT * FROM customer_with_country WHERE RowNo = 1;












