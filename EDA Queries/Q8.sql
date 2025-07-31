SELECT
    s.staff_id,
    CONCAT(s.first_name, ' ', s.last_name) AS StaffMemberName,
    st.store_id AS StoreID,
    ci.city AS StoreCity,
    co.country AS StoreCountry,
    COUNT(r.rental_id) AS TotalRentalsProcessed,
    SUM(p.amount) AS TotalRevenueProcessed,
    TRUNCATE(AVG(p.amount), 2) AS AverageRentalValueProcessed
FROM
    staff AS s
JOIN
    store AS st ON s.store_id = st.store_id -- Link staff to their store
JOIN
    address AS a ON st.address_id = a.address_id -- Link store to its address
JOIN
    city AS ci ON a.city_id = ci.city_id -- Link address to city
JOIN
    country AS co ON ci.country_id = co.country_id -- Link city to country
JOIN
    rentat AS r ON s.staff_id = r.staff_id -- Link staff to rentals they processed
JOIN
    payment AS p ON r.rental_id = p.rental_id -- Link rentals to their payments
GROUP BY
    s.staff_id,
    StaffMemberName,
    StoreID,
    StoreCity,
    StoreCountry
ORDER BY
    StoreCountry ASC,
    StoreCity ASC,
    TotalRevenueProcessed DESC;