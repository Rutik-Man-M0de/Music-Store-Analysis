
					--SQL PROJECT- MUSIC STORE DATA ANALYSIS-- 

SELECT * FROM album

SELECT * FROM artist

SELECT * FROM customer

SELECT * FROM employee

SELECT * FROM genre 

SELECT * FROM invoice

SELECT * FROM invoice_line

SELECT * FROM media_type

SELECT * FROM playlist

SELECT * FROM playlist_track

SELECT * FROM track

						--Question Set 1 - Easy-- 

--Q1: Who is the senior most employee based on job title?

SELECT employee_id, last_name, first_name, title, levels FROM employee
ORDER BY levels DESC
LIMIT 1;


--Q2: Which counties have the most Invoices?

SELECT COUNT(*) AS total_invoice, billing_country
FROM invoice
GROUP BY billing_country
ORDER BY total_invoice DESC
LIMIT 1;


--Q3: What are top 3 values of total invoice?

SELECT (total) FROM invoice
ORDER BY total DESC
LIMIT 3;


--Q4: Which city has the best customers? We would like to throw a promotional Music 
--Festival in the city we made the most money. Write a query that returns one city that 
--has the highest sum of invoice totals. Return both the city name & sum of all invoice 
--totals?

SELECT billing_city, SUM(total) AS total_invoice
FROM invoice
GROUP BY billing_city
ORDER BY total_invoice DESC;


--Q5: Who is the best customer? The customer who has spent the most money will be 
--declared the best customer. Write a query that returns the person who has spent the 
--most money? 

SELECT customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) AS money_spent
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id 
ORDER BY money_spent DESC
LIMIT 1;


					--Question Set 2 – Moderate--

--Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
--Return your list ordered alphabetically by email starting with A.

SELECT DISTINCT email, first_name, last_name FROM customer
JOIN invoice ON customer.customer_id = invoice.invoice_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
		SELECT track_id FROM track
		JOIN genre ON track.genre_id = genre.genre_id 
		WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

				
--Q2: Let's invite the artists who have written the most rock music in our dataset. Write a 
--query that returns the Artist name and total track count of the top 10 rock bands 

SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS total_songs 
FROM track 
JOIN album ON album.album_id = track.album_id 
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY (artist.artist_id) 
ORDER BY total_songs DESC
LIMIT 10 ;


--Q3: Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first 

SELECT name, AVG(milliseconds) AS avg_song_length FROM track
GROUP BY name 
ORDER BY avg_song_length DESC

--= Method 2

SELECT name, milliseconds 
FROM track 
WHERE milliseconds > (
		SELECT AVG(milliseconds) 
		FROM track
		)
ORDER BY milliseconds DESC;


--Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, 
--artist name and total spent

SELECT
     c.customer_id,c.first_name || ' ' || c.last_name AS customer_name,
    ar.name AS artist_name,
    SUM(il.unit_price * il.quantity) AS total_spent
FROM
    customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
GROUP BY
    c.customer_id, c.first_name, c.last_name, ar.artist_id, ar.name
ORDER BY total_spent DESC;


/*Q2: We want to find out the most popular music Genre for each country. We determine the
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres*/


WITH GenreSales AS (
    SELECT i.billing_country, g.name AS genre_name, SUM(il.quantity) AS total_purchases
    FROM
        invoice i
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    GROUP BY i.billing_country, g.genre_id, g.name
),
RankedGenres AS (
    SELECT billing_country, genre_name, total_purchases,
        RANK() OVER (
            PARTITION BY billing_country
            ORDER BY total_purchases DESC
        ) AS genre_rank
    FROM GenreSales
)
SELECT billing_country, genre_name, total_purchases
FROM RankedGenres
WHERE genre_rank = 1
ORDER BY billing_country, genre_name;


/* 3. Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how 
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount */


WITH CustomerSpending AS (
    SELECT c.customer_id, c.first_name || ' ' || c.last_name AS customer_name,
        i.billing_country AS country,
        SUM(i.total) AS total_spent
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country
),
RankedSpending AS (
    SELECT customer_id, customer_name, country, total_spent,
        RANK() OVER (
            PARTITION BY country
            ORDER BY total_spent DESC
        ) AS rank_in_country
    FROM CustomerSpending
)
SELECT country, customer_name, total_spent
FROM RankedSpending
WHERE rank_in_country = 1
ORDER BY country, customer_name;


---= Method 2

WITH CustomerSpending AS (
    SELECT c.customer_id, c.first_name || ' ' || c.last_name AS customer_name,
        i.billing_country AS country,
        SUM(i.total) AS total_spent
    FROM
        customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY
        c.customer_id, c.first_name, c.last_name, i.billing_country
),
RankedSpending AS (
    SELECT customer_id, customer_name, country, total_spent,
        RANK() OVER (
            PARTITION BY country
            ORDER BY total_spent DESC
        ) AS rank_in_country,
        ROW_NUMBER() OVER (
            PARTITION BY country
            ORDER BY total_spent DESC
        ) AS row_number_in_country
    FROM CustomerSpending
)
SELECT country, customer_id, customer_name, total_spent, row_number_in_country
FROM RankedSpending
WHERE rank_in_country = 1
ORDER BY country, customer_name;



 




