--Q1: Write query to return the email,first name, last name & genre of all Rock Music Listeners.
--Return your list ordered alphabetically by email starting A

Select Distinct email, first_name, last_name
from customer
JOIN invoice ON customer.customer_id=invoice.customer_id
JOIN invoice_line ON invoice.invoice_id=invoice_line.invoice_id
WHERE track_id IN(
    select track_id from track
	JOIN genre ON track.genre_id=genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

--OR

Select Distinct email AS Email, first_name as FirstName, last_name as LastName, genre.name as Name
from customer
JOIN invoice ON customer.customer_id=invoice.customer_id
JOIN invoice_line ON invoice.invoice_id=invoice_line.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;


--Q2: Let's invite the artist who have written the most rock music in our dataset.
--Write a query that returns the artist name and total track count of the top 10 rock bands.

Select artist.artist_id, artist.name, COUNT(artist.artist_id) as number_of_songs
from track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;

--Q3: Return all the track names that have a song length longer than the average song length.
--Return the Name and Milliseconds for each track.
--Order by the song length with the longest songs listed first.

Select name, milliseconds
from track
WHERE milliseconds > (
    Select AVG(milliseconds) AS avg_track_length
	from track
)
ORDER BY milliseconds desc;

