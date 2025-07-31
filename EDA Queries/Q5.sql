WITH CustomerRentalSummary AS (
    -- Step 1: Classify each customer as 'One-Time' or 'Repeat' based on their total rentals
    SELECT
        c.customer_id,
        CASE
            WHEN COUNT(r.rental_id) = 1 THEN 'One-Time Customer'
            WHEN COUNT(r.rental_id) > 1 THEN 'Repeat Customer'
            ELSE 'No Rentals' -- For customers who are registered but have never rented
        END AS CustomerType
    FROM
        customer AS c
    LEFT JOIN rentat AS r ON c.customer_id = r.customer_id
    GROUP BY
        c.customer_id
    HAVING COUNT(r.rental_id) > 0 -- Exclude 'No Rentals' from this summary if you only care about renters
)
-- Step 2: Aggregate film language popularity for each customer type
SELECT
    crs.CustomerType,
    l.name AS FilmLanguage,
    COUNT(r.rental_id) AS TotalRentalsInLanguage,
    SUM(p.amount) AS TotalRevenueInLanguage
FROM
    CustomerRentalSummary AS crs
JOIN
    rentat AS r ON crs.customer_id = r.customer_id
JOIN
    inventory AS i ON r.inventory_id = i.inventory_id
JOIN
    film AS f ON i.film_id = f.film_id
JOIN
    language AS l ON f.language_id = l.language_id
JOIN
    payment AS p ON r.rental_id = p.rental_id
GROUP BY
    crs.CustomerType,
    l.name
ORDER BY
    crs.CustomerType ASC, -- Order by customer type first
    TotalRentalsInLanguage DESC; -- Then by most rented language within that type