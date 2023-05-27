USE sakila;

-- 1. How many copies of the film Hunchback Impossible exist in the inventory system? +Answer= There are 6.
SELECT COUNT(inventory_id) FROM sakila.inventory
WHERE film_id IN (
	SELECT film_id as film FROM(
		SELECT film_id, title
		FROM sakila.film
		WHERE title = 'Hunchback Impossible') Q1
);

-- 2. List all films whose length is longer than the average of all the films. +Answer= list of 489 films
SELECT title, length FROM sakila.film
WHERE length > (SELECT AVG(length) as 'Average_duration'
				FROM sakila.film);

-- 3. Use subqueries to display all actors who appear in the film Alone Trip. +Answer= 8 actors
SELECT CONCAT(first_name,' ',last_name) AS Actors_in_Alone_Trip FROM sakila.actor
WHERE actor_id IN(
	SELECT actor_id FROM(
		SELECT actor_id, title
		FROM sakila.film
		JOIN sakila.film_actor USING(film_id)
		WHERE title = 'Alone Trip') Q1
);

-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
-- +Answer = 69 family films
SELECT title FROM sakila.film
WHERE film_id IN(
	SELECT film_id FROM(
		SELECT film_id
		FROM sakila.category
		JOIN sakila.film_category USING(category_id)
		WHERE name = 'Family') Q1
);

-- 5. Get name and email from customers from Canada using subqueries. Do the same with joins. 
-- Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
-- +Answer =
SELECT CONCAT(first_name,' ',last_name) AS Canada_customers, email FROM sakila.customer
WHERE address_id IN(
	SELECT address_id FROM sakila.address
	WHERE city_id IN(
		SELECT city_id FROM sakila.city
		WHERE country_id IN(
			SELECT country_id FROM sakila.country
			WHERE country = 'Canada'))
);

-- 6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
CREATE TEMPORARY TABLE most_movies_actor AS(
	SELECT actor_id, COUNT(film_id) FROM sakila.film_actor
	GROUP BY actor_id
	ORDER BY COUNT(film_id) DESC
	LIMIT 1);

SELECT film.title 
FROM sakila.film 
WHERE film_id IN(
	SELECT film_id FROM film_actor
	WHERE actor_id = (SELECT actor_id FROM most_movies_actor) 
);


-- 7. Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable 
-- customer ie the customer that has made the largest sum of payments  +Answer = 44 films
SELECT title
FROM sakila.film
WHERE film_id IN(
	SELECT film_id FROM( 
		SELECT film_id FROM sakila.inventory i
		JOIN sakila.rental r USING(inventory_id)
		WHERE customer_id = (SELECT customer_id FROM (
									SELECT customer_id, SUM(amount) FROM sakila.payment
									GROUP BY customer_id
									ORDER BY SUM(amount) DESC
									LIMIT 1)Q1))Q2
);

-- 8. Customers who spent more than the average payments. +Answer = There are 285 customers that spent more that the avg. payment
SELECT SUM(amount) AS Spent_amount, CONCAT(first_name,' ',last_name) AS Customer FROM sakila.customer
JOIN sakila.payment USING (customer_id)
GROUP BY customer_id
HAVING sum(amount) > (SELECT avg(total_payment) FROM (
								SELECT customer_id, SUM(amount) as total_payment FROM sakila.payment
								GROUP BY customer_id) Q1)
								ORDER BY SUM(amount) DESC;