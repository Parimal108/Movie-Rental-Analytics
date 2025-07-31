WITH FilmCopyCounts AS (
    -- Step 1: Count the number of inventory copies for each film (our proxy for availability)
    SELECT
        film_id,
        COUNT(inventory_id) AS NumberOfCopies
    FROM
        inventory
    GROUP BY
        film_id
),
CustomerLoyaltyType AS (
    -- Step 2: Classify each customer as 'One-Time' or 'Repeat'
    SELECT
        c.customer_id,
        CASE
            WHEN COUNT(r.rental_id) = 1 THEN 'One-Time Customer'
            WHEN COUNT(r.rental_id) > 1 THEN 'Repeat Customer'
            ELSE 'No Rentals'
        END AS CustomerType
    FROM
        customer AS c
    LEFT JOIN rentat AS r ON c.customer_id = r.customer_id
    GROUP BY
        c.customer_id
    HAVING COUNT(r.rental_id) > 0 -- Focus only on customers who have rented
),
RentalDetailsWithAvailabilityAndLoyalty AS (
    -- Step 3: Combine rental details with film copy counts and customer loyalty type
    SELECT
        r.rental_id,
        r.customer_id,
        clt.CustomerType,
        fcc.NumberOfCopies,
        p.amount
    FROM
        rentat AS r
    JOIN
        CustomerLoyaltyType AS clt ON r.customer_id = clt.customer_id
    JOIN
        inventory AS i ON r.inventory_id = i.inventory_id
    JOIN
        FilmCopyCounts AS fcc ON i.film_id = fcc.film_id
    JOIN
        payment AS p ON r.rental_id = p.rental_id
)
-- Step 4: Aggregate to see rental patterns by film copy count (availability proxy) and customer type
SELECT
    NumberOfCopies,
    -- Create "availability bins" if you want to group films by copy count ranges (e.g., 1-5 copies, 6-10 copies)
    -- CASE
    --    WHEN NumberOfCopies BETWEEN 1 AND 5 THEN '1-5 Copies'
    --    WHEN NumberOfCopies BETWEEN 6 AND 10 THEN '6-10 Copies'
    --    ELSE '10+ Copies'
    -- END AS AvailabilityBin,
    CustomerType,
    COUNT(rental_id) AS TotalRentals,
    SUM(amount) AS TotalRevenue,
    TRUNCATE(COUNT(rental_id) / COUNT(DISTINCT customer_id), 2) AS AvgRentalsPerCustomerOfType
FROM
    RentalDetailsWithAvailabilityAndLoyalty
GROUP BY
    NumberOfCopies,
    CustomerType
    -- If using AvailabilityBin, group by that instead: AvailabilityBin, CustomerType
ORDER BY
    NumberOfCopies ASC,
    CustomerType ASC;