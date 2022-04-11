# lab-SQL-subqueries
USE sakila;
# 1. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT title AS Film
		,  count(inventory_id) AS 'Available Copies'
FROM sakila.film f
	JOIN sakila.inventory i 
		USING (film_id)
WHERE title = 'Hunchback Impossible'
GROUP BY film
;


# 2. List all films whose length is longer than the average of all the films.

SELECT title as Film
from sakila.film
WHERE length > (SELECT avg(length) AS avg_length
				FROM sakila.film
                )
;

# 3. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT CONCAT(a.first_name,' ',a.last_name) AS Actor
FROM sakila.actor a
	JOIN sakila.film_actor fa
		USING (actor_id)
WHERE fa.film_id = (SELECT film_id
					FROM sakila.film
                    WHERE title = 'Alone Trip'
                    )
;

# 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT f.title AS 'Family Films'
FROM sakila.film f
	JOIN sakila.film_category fc
		USING (film_id)
WHERE fc.category_id = (SELECT category_id
					 FROM sakila.category
                     WHERE name = 'Family'
                     )
;



#5 Get name and email from customers from Canada using subqueries. Do the same with joins. 
-- Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.


-- Using only subqueries
 
SELECT CONCAT(first_name,' ', last_name) AS 'Customer Name' 
		, email
FROM sakila.customer
WHERE address_id IN (SELECT address_id
					FROM sakila.address
					WHERE city_id IN ( SELECT city_id
									  FROM sakila.city
                                      WHERE country_id = (SELECT country_id
														  FROM sakila.country
                                                          WHERE country = 'Canada'
                                                          )
									)
					)
;


-- Using only joins
SELECT CONCAT(c.first_name,' ', c.last_name) AS 'Customer Name'
		, c.email
FROM sakila.customer c
	JOIN sakila.address a
		USING (address_id)
	JOIN sakila.city ci
		USING (city_id)
	JOIN sakila.country cy
		USING (country_id)
WHERE cy.country = 'Canada'
;


#6 Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
SELECT f.title AS Films
FROM sakila.film_actor fa
	JOIN sakila.film f
		USING (film_id)
WHERE fa.actor_id = (SELECT actor_id
						FROM (SELECT actor_id 
										, COUNT(film_id) as f_count
								FROM sakila.film_actor fa
									JOIN sakila.film f
										USING (film_id)
									JOIN sakila.actor a
										USING (actor_id)
								GROUP BY actor_id
								ORDER BY f_count DESC
								LIMIT 1
							) actor_1
				      )
;

#7 Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

    
SELECT f.title as films
FROM sakila.film f
	JOIN sakila.invemtory i
		USING (film_id)
    JOIN sakila.rental r
		USING (inventory_id)
WHERE r.customerid = (SELECT customer_id
						FROM ( SELECT customer_id
										, SUM(rental_id) AS r_count
								FROM sakila.rental r
									JOIN sakila.customer c
										USING (customer_id)
								GROUP BY customer_id
								ORDER by r_count DESC
								LIMIT 1
								)Customer_1
				)
;



#8 Customers who spent more than the average payments.

-- SELECT DISTINCT CONCAT(first_name,' ',last_name) AS customer
-- FROM sakila.customer c
-- JOIN sakila.payment p
-- USING (customer_id)
-- WHERE p.amount > (SELECT AVG(amount) AS avg_amount
-- 				FROM sakila.payment
--               );


-- SELECT DISTINCT CONCAT(first_name, ' ', last_name) AS customer_name, sum(avg(amount)) as total_payment
-- FROM sakila.payment p
--    JOIN sakila.customer c
-- USING (customer_id)
-- WHERE p.amount > (total_payment)
-- ;





# 8. Customers who spent more than the average payments.
#USE sakila;
SELECT customer_id, 
		sum(amount) as total_payment 
		from payment
GROUP BY customer_id;

CREATE TEMPORARY TABLE temp AS 
(select customer_id, sum(amount) as total_payment from payment
GROUP BY customer_id
);

SELECT first_name, last_name, sum(amount) from customer
JOIN payment using(customer_id)
GROUP BY customer_id
HAVING sum(amount) > (select avg(total_payment) from temp);
