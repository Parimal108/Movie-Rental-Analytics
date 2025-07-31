SELECT
    st.store_id AS StoreID,
    ci.city AS StoreCity,
    co.country AS StoreCountry,
    DAYNAME(r.rental_date) AS DayOfWeek, -- e.g., 'Monday', 'Tuesday'
    HOUR(r.rental_date) AS HourOfDay,   -- e.g., 0 (midnight), 10 (10 AM), 15 (3 PM)
    COUNT(r.rental_id) AS TotalRentals,
    SUM(p.amount) AS TotalRevenue
FROM
    store AS st
JOIN
    address AS a ON st.address_id = a.address_id
JOIN
    city AS ci ON a.city_id = ci.city_id
JOIN
    country AS co ON ci.country_id = co.country_id
JOIN
    staff AS s ON st.store_id = s.store_id -- Join to staff to link rentals to the store via staff
JOIN
    rentat AS r ON s.staff_id = r.staff_id -- Link rentals processed by staff to the staff themselves
JOIN
    payment AS p ON r.rental_id = p.rental_id -- For revenue
GROUP BY
    StoreID,
    StoreCity,
    StoreCountry,
    DayOfWeek,
    HourOfDay
ORDER BY
    StoreID ASC,
    -- Custom order for DayOfWeek to be chronological (Sunday-Saturday)
    FIELD(DayOfWeek, 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday') ASC,
    HourOfDay ASC;