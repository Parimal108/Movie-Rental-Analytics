WITH LanguageFilmCounts AS (
    -- Step 1: Count how many unique film titles exist for each language (our proxy for 'availability of choice')
    SELECT
        l.language_id,
        l.name AS FilmLanguage,
        COUNT(f.film_id) AS NumberOfUniqueFilmsInLanguage
    FROM
        language AS l
    JOIN
        film AS f ON l.language_id = f.language_id
    GROUP BY
        l.language_id, l.name
),
CustomerLoyaltyType AS (
    -- Step 2: Classify each customer as 'One-Time' or 'Repeat' (from our previous analysis)
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
)
-- Step 3: Aggregate rental data by film language, incorporating its availability proxy and customer loyalty type
SELECT
    lfc.FilmLanguage,
    lfc.NumberOfUniqueFilmsInLanguage, -- Our availability proxy for this language
    COUNT(r.rental_id) AS TotalRentalsForLanguage,
    SUM(p.amount) AS TotalRevenueForLanguage,
    TRUNCATE(
        COUNT(r.rental_id) / COUNT(DISTINCT r.customer_id), 2
    ) AS AvgRentalsPerActiveCustomerForLanguage, -- Avg rentals per customer who rented this language
    SUM(CASE WHEN clt.CustomerType = 'One-Time Customer' THEN 1 ELSE 0 END) AS OneTimeRentalsOfLanguage,
    SUM(CASE WHEN clt.CustomerType = 'Repeat Customer' THEN 1 ELSE 0 END) AS RepeatRentalsOfLanguage,
    TRUNCATE(
        (SUM(CASE WHEN clt.CustomerType = 'Repeat Customer' THEN 1 ELSE 0 END) / COUNT(r.rental_id)) * 100, 2
    ) AS PctRepeatRentalsForLanguage -- Percentage of rentals from repeat customers for this language
FROM
    language AS l
JOIN
    film AS f ON l.language_id = f.language_id
JOIN
    inventory AS i ON f.film_id = i.film_id
JOIN
    rentat AS r ON i.inventory_id = r.inventory_id
JOIN
    payment AS p ON r.rental_id = p.rental_id
JOIN
    CustomerLoyaltyType AS clt ON r.customer_id = clt.customer_id
JOIN
    LanguageFilmCounts AS lfc ON l.language_id = lfc.language_id -- Join to get the pre-calculated film counts
GROUP BY
    lfc.FilmLanguage,
    lfc.NumberOfUniqueFilmsInLanguage
ORDER BY
    lfc.NumberOfUniqueFilmsInLanguage DESC; -- Order by availability to easily see patterns