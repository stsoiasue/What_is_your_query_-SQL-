USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS Actor_Name FROM actor;
 
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT * FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT * FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- * 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
ALTER TABLE actor ADD COLUMN middle_name VARCHAR(45) AFTER first_name;

-- * 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE actor MODIFY COLUMN middle_name BLOB;

-- * 3c. Now delete the `middle_name` column.
ALTER TABLE actor DROP COLUMN middle_name;

-- * 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS last_name_count
FROM actor GROUP BY last_name;
  	
-- * 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS last_name_count 
FROM actor GROUP BY last_name
HAVING last_name_count >= 2;
  	
-- * 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, 
-- the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

SELECT * FROM actor
WHERE last_name = 'Williams';
  	
-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
-- In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, 
-- as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, 
-- HOWEVER! (Hint: update the record using a unique identifier.)
UPDATE actor SET first_name = 'GROUCHO'
WHERE actor_id = 172;

SELECT * FROM actor
WHERE last_name = 'Williams';

-- * 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
CREATE TABLE addy_copy LIKE address;

-- * 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT staff.first_name, staff.last_name, address.address
FROM staff INNER JOIN address
USING(address_id); 

-- * 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. 
SELECT staff.staff_id, staff.first_name, staff.last_name, SUM(payment.amount) AS total
FROM staff INNER JOIN payment
USING(staff_id)
WHERE payment.payment_date LIKE '2005-08%'
GROUP BY staff_id;

-- * 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT film.title, COUNT(film_actor.actor_id) AS actor_count
FROM film INNER JOIN film_actor
USING(film_id)
GROUP BY film.title;

-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT film.title, COUNT(inventory.film_id) AS inventory_count
FROM inventory INNER JOIN film
USING(film_id)
WHERE film.title = 'Hunchback Impossible'
GROUP BY film.title;

-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.customer_id, customer.first_name, customer.last_name, SUM(payment.amount) AS total_paid
FROM customer INNER JOIN payment
USING(customer_id)
GROUP BY customer_id
ORDER BY customer.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title, language_id FROM film
WHERE (title LIKE 'K%' OR title LIKE 'Q%') AND language_id IN 
	(
		SELECT language_id FROM language
		WHERE name = 'English'
	);
-- 7a. solution 2
SELECT title, language_id FROM film
WHERE title REGEXP '^K|^Q' AND language_id IN 
	(
		SELECT language_id FROM language
		WHERE name = 'English'
	);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor
WHERE actor_id IN
	(
		SELECT actor_id FROM film_actor
		WHERE film_id IN
			(
				SELECT film_id FROM film
				WHERE title = 'Alone Trip'
			)
	);
-- 7c. You want to run an email marketing campaign in Canada,
-- for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT CS.first_name, CS.last_name, CS.email FROM customer CS
	JOIN address AD ON CS.address_id = AD.address_id
	JOIN city CI ON CI.city_id = AD.city_id
	JOIN country CO ON CI.country_id = CO.country_id
WHERE CO.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
-- Identify all movies categorized as famiy films.
-- 7d. solution using joins
SELECT F.title FROM film F
	JOIN film_category FC ON F.film_id = FC.film_id
	JOIN category C ON C.category_id = FC.category_id
WHERE C.name = 'Family';
-- 7d. solution using subqueries
SELECT COUNT title FROM film
WHERE film_id IN
	(
		SELECT film_id FROM film_category
		WHERE category_id IN
			(
				SELECT category_id FROM category
				WHERE name = 'Family'
			)
	);

-- 7e. Display the most frequently rented movies in descending order.
SELECT F.title, COUNT(R.rental_id) AS rental_count FROM film F
	JOIN inventory I ON F.film_id = I.film_id
	JOIN rental R ON I.inventory_id = R.inventory_id
GROUP BY F.title
ORDER BY rental_count DESC
LIMIT 10;
    
-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT S.store_id, COUNT(P.payment_id) payment_count, SUM(P.amount) AS total_amount FROM store S
	JOIN inventory I ON S.store_id = I.store_id
    JOIN rental R ON I.inventory_id = R.inventory_id
    JOIN payment P ON R.rental_id = P.rental_id
GROUP BY S.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT S.store_id, CI.city, CO.country FROM store S
	JOIN address A ON A.address_id = S.address_id
    JOIN city CI ON CI.city_id = A.city_id
    JOIN country CO ON CO.country_id = CI.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT C.name, SUM(P.amount) AS gross_revenue FROM category C
	JOIN film_category FC ON FC.category_id = C.category_id
    JOIN inventory I ON I.film_id = FC.film_id
    JOIN rental R ON R.inventory_id = I.inventory_id
    JOIN payment P ON P.rental_id = R.rental_id
GROUP BY C.name
ORDER BY gross_revenue DESC 
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top_5_Genres AS
	SELECT C.name, SUM(P.amount) AS gross_revenue FROM category C
		JOIN film_category FC ON FC.category_id = C.category_id
		JOIN inventory I ON I.film_id = FC.film_id
		JOIN rental R ON R.inventory_id = I.inventory_id
		JOIN payment P ON P.rental_id = R.rental_id
	GROUP BY C.name
	ORDER BY gross_revenue DESC 
	LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM Top_5_Genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW IF EXISTS Top_5_Genres;
