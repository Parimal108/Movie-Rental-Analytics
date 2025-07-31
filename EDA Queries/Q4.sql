SELECT
    co.country AS CustomerCountry,
    ci.city AS CustomerCity,
    YEAR(r.rental_date) AS RentalYear,
    MONTH(r.rental_date) AS RentalMonth,
    -- QUARTER(r.rental_date) AS RentalQuarter, -- Uncomment this line and add to GROUP BY if you want a quarterly view
    COUNT(DISTINCT c.customer_id) AS NumberOfUniqueCustomers, -- How many unique customers rented in this period/location
    COUNT(r.rental_id) AS TotalRentals, -- Total rentals in this period/location
    SUM(p.amount) AS TotalRevenue -- Total revenue in this period/location
FROM
    customer AS c
JOIN
    address AS a ON c.address_id = a.address_id
JOIN
    city AS ci ON a.city_id = ci.city_id
JOIN
    country AS co ON ci.country_id = co.country_id
JOIN
    rentat AS r ON c.customer_id = r.customer_id
JOIN
    payment AS p ON r.rental_id = p.rental_id -- Ensure payments are linked
GROUP BY
    co.country,
    ci.city,
    RentalYear,
    RentalMonth
    -- If using RentalQuarter, add it here: , RentalQuarter
ORDER BY
    CustomerCountry ASC,
    CustomerCity ASC,
    RentalYear ASC,
    RentalMonth ASC;
    -- If using RentalQuarter, add it here: , RentalQuarter