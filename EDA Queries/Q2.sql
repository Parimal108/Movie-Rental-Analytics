SELECT
    f.title AS FilmTitle,
    f.rental_rate AS BaseRentalRate,
    COUNT(r.rental_id) AS TotalRentals, -- Measure of demand
    SUM(p.amount) AS TotalRevenue -- Another strong measure of demand/performance
FROM
    film AS f
JOIN
    inventory AS i ON f.film_id = i.film_id
JOIN
    rentat AS r ON i.inventory_id = r.inventory_id
JOIN
    payment AS p ON r.rental_id = p.rental_id -- Join to get total revenue from actual payments
GROUP BY
    f.film_id, -- Group by ID for uniqueness
    f.title,
    f.rental_rate
ORDER BY
    BaseRentalRate DESC, -- Prioritize films with higher base rental rates
    TotalRentals DESC,   -- Then, among those, prioritize films with higher demand (more rentals)
    TotalRevenue DESC    -- Finally, by total revenue if ties persist
LIMIT 20; -- Display the top 20 films that meet these criteria