use movie_rental_analytics;
SELECT
    CASE
        WHEN CustomerRentalSummary.TotalRentals = 1 THEN 'One-Time Customer'
        WHEN CustomerRentalSummary.TotalRentals > 1 THEN 'Repeat Customer'
        ELSE 'No Rentals (Registered but never rented)' -- For customers with 0 rentals
    END AS CustomerType,
    COUNT(CustomerRentalSummary.CustomerID) AS NumberOfCustomers,
    COALESCE(SUM(CustomerRentalSummary.TotalLifetimeSpend), 0.00) AS TotalRevenueFromSegment
FROM (
    -- Subquery: Calculate total rentals and total lifetime spend for each customer
    SELECT
        c.customer_id AS CustomerID,
        COUNT(r.rental_id) AS TotalRentals,
        SUM(p.amount) AS TotalLifetimeSpend
    FROM
        customer AS c
    LEFT JOIN rentat AS r ON c.customer_id = r.customer_id
    LEFT JOIN payment AS p ON r.rental_id = p.rental_id
    GROUP BY
        c.customer_id
) AS CustomerRentalSummary
GROUP BY
    CustomerType
ORDER BY
    CASE -- Custom order for logical display (Repeat usually highest revenue)
        WHEN CustomerType = 'Repeat Customer' THEN 1
        WHEN CustomerType = 'One-Time Customer' THEN 2
        WHEN CustomerType = 'No Rentals (Registered but never rented)' THEN 3
        ELSE 99
    END;