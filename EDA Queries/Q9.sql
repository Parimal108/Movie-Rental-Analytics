SELECT
    s.store_id AS CustomerAssignedStoreID,
    ci.city AS StoreCity,
    co.country AS StoreCountry,
    COUNT(DISTINCT c.customer_id) AS NumberOfUniqueCustomersAssigned,
    COUNT(r.rental_id) AS TotalRentalsByCustomersOfThisStore,
    TRUNCATE(COUNT(r.rental_id) / COUNT(DISTINCT c.customer_id), 2) AS AverageRentalsPerCustomer -- Average frequency
FROM
    customer AS c
JOIN
    store AS s ON c.store_id = s.store_id -- Links customer to their assigned store
JOIN
    address AS a ON s.address_id = a.address_id -- Links store to its address
JOIN
    city AS ci ON a.city_id = ci.city_id -- Links address to city
JOIN
    country AS co ON ci.country_id = co.country_id -- Links city to country
JOIN
    rentat AS r ON c.customer_id = r.customer_id -- Links customer to their rentals to count frequency
GROUP BY
    CustomerAssignedStoreID,
    StoreCity,
    StoreCountry
ORDER BY
    AverageRentalsPerCustomer DESC; -- Order to see which store locations have the most frequent renters