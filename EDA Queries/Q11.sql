SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS CustomerName,
    c.create_date AS CustomerSince, -- Indicates customer tenure/age in your system
    ci.city AS CustomerCity,
    co.country AS CustomerCountry,
    s.store_id AS AssignedStore, -- The store they are associated with
    SUM(p.amount) AS TotalLifetimeSpend
FROM
    customer AS c
JOIN
    address AS a ON c.address_id = a.address_id
JOIN
    city AS ci ON a.city_id = ci.city_id
JOIN
    country AS co ON ci.country_id = co.country_id
JOIN
    store AS s ON c.store_id = s.store_id -- Link to their assigned store
JOIN
    rentat AS r ON c.customer_id = r.customer_id
JOIN
    payment AS p ON r.rental_id = p.rental_id
GROUP BY
    c.customer_id, CustomerName, c.create_date, CustomerCity, CustomerCountry, AssignedStore
ORDER BY
    TotalLifetimeSpend DESC
LIMIT 50; -- Adjust this LIMIT to define your "highest-spending" group (e.g., top 50, top 100, or a percentile)


