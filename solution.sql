USE sakila;

-- Step 1: Create the customer rental summary view
CREATE OR REPLACE VIEW customer_rental_summary AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r
    ON c.customer_id = r.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email;

-- Check the view
SELECT *
FROM customer_rental_summary;

-- Step 2: Create temporary table with total paid per customer
CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT
    crs.customer_id,
    SUM(p.amount) AS total_paid
FROM customer_rental_summary crs
JOIN payment p
    ON crs.customer_id = p.customer_id
GROUP BY crs.customer_id;
SELECT *
FROM customer_payment_summary;

-- Step 3: CTE + final customer summary report
WITH customer_summary AS (
    SELECT
        crs.customer_name,
        crs.email,
        crs.rental_count,
        cps.total_paid
    FROM customer_rental_summary crs
    JOIN customer_payment_summary cps
        ON crs.customer_id = cps.customer_id
)

SELECT
    customer_name,
    email,
    rental_count,
    total_paid,
    ROUND(total_paid / rental_count, 2) AS average_payment_per_rental
FROM customer_summary;