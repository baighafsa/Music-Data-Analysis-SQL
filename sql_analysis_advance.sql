--Q1: Find how much amount spent by each customer on artist?
--Write a query to return customer name, artist name and total spent.

WITH best_selling_artist AS (
   Select artist.artist_id AS artist_id, artist.name AS artist_name, 
   SUM(invoice_line.unit_price+invoice_line.quantity) AS total_sales
   from invoice_line
   join track on track.track_id=invoice_line.track_id
   join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
   Group by 1 --artistID
   order by 3 desc --sales third column in descending
   limit 1
)
Select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
SUM(il.unit_price+il.quantity) AS amount_spent
from invoice i
join customer c ON c.customer_id=i.customer_id
join invoice_line il ON il.invoice_id=i.invoice_id
join track t ON t.track_id=t.track_id
join album alb on alb.album_id=t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc


--Q2: We want to find out the most popular music genre for each country.
--We determine the most popular genre as the genre with the highest amount of purchases.
--Write a query that returns each country along with the top genre.
--For countries where the maximum number of purchases is shared return all genres.

WITH popular_genre AS
(
    Select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
	Row_NUMBER() OVER(Partition By customer.country order by count(invoice_line.quantity)desc) as RowNo
	from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id=invoice.customer_id
	join track on track.track_id=invoice_line.track_id
	join genre on genre.genre_id=track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
Select * from popular_genre where RowNo <= 1

--OR with recursive

WITH RECURSIVE 
    sales_per_country as(
	Select count(*) as purchases_per_genre, customer.country, genre.name, genre.genre_id
	from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id=invoice.customer_id
	join track on track.track_id=invoice_line.track_id
	join genre on genre.genre_id=track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
	),
	max_genre_per_country AS (Select MAX(purchases_per_genre)AS max_genre_number, country
	from sales_per_country
	group by 2
	order by 2)
Select sales_per_country.*
from sales_per_country
join max_genre_per_country ON sales_per_country.country=max_genre_per_country.country
where sales_per_country.purchases_per_genre=max_genre_per_country.max_genre_number


--Q3: Write a query that determines the customer that has spent the most on music for each country.
--Write a query that returns the country along with the top customer and how musch they spent.
--For countries where the top amount spent is shared, provide all customers who spent this amount.

with recursive 
    customer_with_country AS(
	select customer.customer_id, first_name, last_name, billing_country, SUM(total) AS total_spending
	from invoice
	join customer on customer.customer_id = invoice.customer_id
	group by 1,2,3,4
	order by 1,5 desc),
	
	country_max_spending AS(
	    select billing_country, MAX(total_spending) AS max_spending
		from customer_with_country
		group by billing_country)
select cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
from customer_with_country cc
join country_max_spending ms
on cc.billing_country = ms.billing_country
Where cc.total_spending = ms.max_spending
order by 1;

--OR

With customer_with_country AS(
    Select customer.customer_id, first_name, last_name, billing_country, SUM(total) as total_spending,
	ROW_NUMBER() OVER(Partition by billing_country order by sum(total) desc) as RowNo
	from invoice
	join customer on customer.customer_id=invoice.customer_id
	group by 1,2,3,4
	order by 4 asc, 5 desc
)

Select * from customer_with_country where RowNo <= 1




