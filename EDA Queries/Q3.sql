SELECT
    s.staff_id,
    CONCAT(s.first_name, ' ', s.last_name) AS StaffMemberName, -- Combine first and last name
    cat.name AS FilmCategory,
    COUNT(r.rental_id) AS TotalRentalsInThisCategory, -- Count of rentals for this category by this staff member
    SUM(p.amount) AS TotalRevenueInThisCategory       -- Total revenue for this category by this staff member
FROM
    staff AS s
JOIN
    rentat AS r ON s.staff_id = r.staff_id
JOIN
    inventory AS i ON r.inventory_id = i.inventory_id
JOIN
    film AS f ON i.film_id = f.film_id
JOIN
    film_category AS fc ON f.film_id = fc.film_id
JOIN
    category AS cat ON fc.category_id = cat.category_id
JOIN
    payment AS p ON r.rental_id = p.rental_id -- Join to get revenue per rental
GROUP BY
    s.staff_id,
    StaffMemberName, -- Group by the concatenated name
    cat.name
ORDER BY
    StaffMemberName ASC,
    TotalRentalsInThisCategory DESC; -- Order to see top categories for each staff member