--                                     MUSIC STORE DATA ANALYSIS
create database music_database;
use music_database;
show tables;

select * from album2;
select * from artist;
select * from customer;
select * from employee;
select * from genre;
select * from invoice;
select * from invoice_line;
select * from media_type;
select * from playlist_track;
select * from track;


# EASY LEVEL QUETIONS
-- 1) Who is the Senior most employee based on job title
select * from employee
order by levels desc
limit 1;

-- 2) Which country is having the most invoices
select count(*),billing_country from invoice
group by billing_country
having  count(*)>=50
order by count(*) desc;

-- 3) What are the top 3 values of invoices
select * from invoice
order by total desc
limit 3;

/* 4) Which City has the best customer? We would  like throw a promotional Music Festival in the city we made the most money.
Write a  query that returns one City that has the highest sum of invoice totals.
Return both the city name and sum of all invoices total */

select billing_city,sum(total)
from invoice
group by billing_city
order by sum(total) desc
limit 1;


/* 5) Who is best customer? The customer who has spent the most money willl be declared th best customer.
Write a query that returns the person who has spent the most money. */

select c.customer_id,c.first_name,c.last_name,sum(i.total) as total_sum
from customer as c
join invoice as i on c.customer_id=i.customer_id
group by c.customer_id,c.first_name,c.last_name
order by total_sum desc
limit 1;

#MODERATE LEVEL QUETIONS:

/* 1) Write query to return the email, first name, last name and genre of all Rock Music Listeners.
Return your list orderd alphabetically by email starting with A. */

select distinct email,first_name,last_name
from customer
join invoice on invoice.customer_id=customer.customer_id
join invoice_line on invoice_line.invoice_id=invoice.invoice_id
join track on track.track_id=invoice_line.track_id
join genre on genre.genre_id=track.genre_id
where genre.name='Rock'
order by email;

/* 2) Let's invite the artist who have written the most rock music in our dataset.
Write a query that returns the artist name and total track cou t of the top 10 rock bands
*/
select artist.artist_id,artist.name,count(artist.artist_id) as numberofsongs
from artist
join album2 on album2.artist_id=artist.artist_id
join track on track.album_id=album2.album_id
join genre on genre.genre_id=track.genre_id
where genre.name="Rock"
group by artist.artist_id,artist.name
order by numberofsongs desc
limit 10;

/* 3) Return all the names that have a song length longer than the average song length .
Return the name and Millisceonds for each track.
Order by the song length with the longest songs listed first. */

-- CTE concept is used

with averagesonglength as(
select avg(milliseconds) as avg_length
from track
)

select name,milliseconds
from track
where milliseconds>(select avg_length from averagesonglength)
order by milliseconds desc;

#easy way
select name,milliseconds
from track
where milliseconds>(select avg(milliseconds) as avg_track_length
					from track)
order by milliseconds desc;

#  ADVANCELEVEL QUETION
/* 1) Find how much amount spent by each customer on artists? Write a query to return 
customer name, artist name and total spent */
with best_selling_artist as (
select artist.artist_id AS artist_id, artist.name as artist_name, 
SUM(invoice_line.unit_price * invoice_line.quantity) as total_sales
from invoice_line
join track on track.track_id = invoice_line.track_id
join album2 on album2.album_id = track.album_id
join artist on artist.artist_id = album2.artist_id
group by artist.artist_id, artist.name
order by total_sales desc
limit 1
)
select c.customer_id, c.first_name, c.last_name,bsa.artist_name, 
    SUM(il.unit_price * il.quantity) AS amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album2 alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by c.customer_id, c.first_name, c.last_name, bsa.artist_name
order by amount_spent desc;

/* 2)We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres  */
 with popular_genre as 
(
    select COUNT(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id, 
	row_number() over(partition by customer.country order by COUNT(invoice_line.quantity) desc) as RowNo 
    FROM invoice_line 
	join invoice ON invoice.invoice_id = invoice_line.invoice_id
	join customer ON customer.customer_id = invoice.customer_id
	join track ON track.track_id = invoice_line.track_id
	join genre ON genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select  * from popular_genre where RowNo <= 1

/* 3)Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how 
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount  */

with Customter_with_country as (
select customer.customer_id,first_name,last_name,billing_country,SUM(total) as total_spending,
row_number() over(partition by billing_country order by SUM(total) desc) as RowNo 
from invoice
join customer on customer.customer_id = invoice.customer_id
group by 1,2,3,4
order by 4 asc,5 desc)
select * from Customter_with_country where RowNo <= 1;








