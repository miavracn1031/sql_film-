
--what is the lowest replacement cost?

SELECT DISTINCT (replacement_cost)
FROM film
ORDER BY replacement_cosT ASC;

/*how many films have a replacement cost in the low group?*/

SELECT 
COUNT (*),
CASE
	WHEN replacement_cost BETWEEN 9.99 AND 19.99 THEN 'LOW'
	WHEN replacement_cost BETWEEN 20.99 AND 24.99 THEN 'MEDIUM'
	ELSE 'HIGH'
END AS cost_range
FROM film
GROUP BY cost_range
ORDER BY COUNT (*);

/*In which catergory is the longest film and how long is it?*/

SELECT
title,
length,
name
FROM film f
LEFT JOIN film_category fc
ON f.film_id = fc.film_id
INNER JOIN category c
ON fc.category_id = c.category_id
WHERE name = 'Drama' OR name ='Sports'
ORDER BY length DESC;

/*which category (name) is the most common among the films*/

SELECT 
c.name,
COUNT (*) as no_titles
FROM film f
LEFT JOIN film_category fc
ON f.film_id = fc.film_id
INNER JOIN category c
ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY no_titles DESC;

/*which actor is part of most movies?*/

SELECT 
DISTINCT (first_name),
last_name,
a.actor_id,
COUNT (*)
FROM actor a
LEFT JOIN film_actor f
ON a.actor_id = f.actor_id
GROUP BY a.actor_id, first_name, last_name
ORDER BY first_name DESC;

/*how many address are that?*/

SELECT 
c.first_name,
c.last_name,
a.address
FROM address a
LEFT JOIN customer c
ON a.address_id = c.address_id
WHERE c.address_id is null;

/*which city has the most sales?*/

SELECT 
cc.city,
SUM (p.amount)
FROM payment p 
LEFT JOIN customer c
ON p.customer_id = c.customer_id
LEFT JOIN address a
ON c.address_id = a.address_id
LEFT JOIN city cc
ON a.city_id = cc.city_id
GROUP BY cc.city 
ORDER BY SUM(p.amount)DESC;

/*which country,city has the least sales?*/

SELECT 
co.country || ', ' || cc.city,
SUM (p.amount)
FROM payment p 
	LEFT JOIN customer c
	ON p.customer_id = c.customer_id
	LEFT JOIN address a
	ON c.address_id = a.address_id
	LEFT JOIN city cc
	ON a.city_id = cc.city_id
	LEFT JOIN country co
	ON cc.country_id=co.country_id
GROUP BY co.country || ', ' || cc.city
ORDER BY SUM(p.amount)ASC;

/*which staff_id makes on average more revenue per customer?*/

SELECT 
staff_id,
ROUND(AVG (total),2)
FROM
(SELECT 
staff_id,
customer_id,
SUM (amount) total
FROM payment
GROUP BY staff_id, customer_id) sub
GROUP BY staff_id;

/*what is the daily average of all sundays?*/

SELECT 
ROUND(AVG(total),2)
FROM
(SELECT 
DATE (payment_date),
EXTRACT(dow from payment_date),
SUM (amount)total 
FROM payment
WHERE EXTRACT(dow from payment_date) = 0
GROUP BY DATE(payment_date),EXTRACT(dow from payment_date)) SUB;

/*which movies are the shortest on the list and how long are they?*/

SELECT
title,
length,
replacement_cost
FROM film f1
WHERE length > (SELECT AVG (length)
						   FROM film f2
						   WHERE f1.replacement_cost = f2.replacement_cost)
ORDER BY  length ASC;


/*which district has the highest average customer lifetime value?*/

SELECT
district,
ROUND(AVG (total),2) total
FROM
(SELECT 
district,
c.customer_id,
SUM (amount)total
FROM payment p
INNER JOIN customer c
ON p.customer_id = c.customer_id
INNER JOIN address a 
ON a.address_id = c.address_id
GROUP BY 
district,
c.customer_id) SUB
GROUP BY district
ORDER BY total desc;


/*what is the total revenue of the category 'Action' and what is the
lowest payment_id in that category 'Action'?*/


SELECT 
title,
amount,
payment_id,
name,
(SELECT SUM (amount)
FROM payment p
LEFT JOIN rental r
ON r.rental_id = p.rental_id
LEFT JOIN inventory i
ON i.inventory_id = r.inventory_id
LEFT JOIN film f
ON f.film_id = i.film_id
LEFT JOIN film_category fc
ON fc.film_id = f.film_id
LEFT JOIN category c2
ON c1.category_id = fc.category_id
WHERE c1.name=c2.name )
FROM payment p
LEFT JOIN rental r
ON r.rental_id = p.rental_id
LEFT JOIN inventory i
ON i.inventory_id = r.inventory_id
LEFT JOIN film f
ON f.film_id = i.film_id
LEFT JOIN film_category fc
ON fc.film_id = f.film_id
LEFT JOIN category c1
ON c1.category_id = fc.category_id
ORDER BY name;
