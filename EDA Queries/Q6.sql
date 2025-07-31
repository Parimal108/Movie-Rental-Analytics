WITH CustomerAcquisitionCohort AS (
    -- Step 1: Identify the very first rental date for each customer (their acquisition date)
    -- and assign them to an acquisition cohort (Year-Month of their first rental)
    SELECT
        c.customer_id,
        MIN(r.rental_date) AS first_rental_date,
        DATE_FORMAT(MIN(r.rental_date), '%Y-%m') AS AcquisitionMonthCohort -- Format as YYYY-MM for sorting
    FROM
        customer AS c
    JOIN
        rentat AS r ON c.customer_id = r.customer_id
    GROUP BY
        c.customer_id
),
CohortRentalsWithRevenue AS (
    -- Step 2: For each rental transaction, determine its customer's acquisition cohort
    -- and calculate the month number since that customer's acquisition
    SELECT
        cac.AcquisitionMonthCohort,
        cac.customer_id,
        r.rental_id,
        r.rental_date,
        p.amount,
        -- Calculate months since acquisition (0 for the acquisition month itself, 1 for next month, etc.)
        TIMESTAMPDIFF(MONTH, cac.first_rental_date, r.rental_date) AS MonthsSinceAcquisition
    FROM
        rentat AS r
    JOIN
        CustomerAcquisitionCohort AS cac ON r.customer_id = cac.customer_id
    JOIN
        payment AS p ON r.rental_id = p.rental_id
)
-- Step 3: Aggregate revenue and customer counts by Acquisition Cohort and Months Since Acquisition
SELECT
    AcquisitionMonthCohort,
    MonthsSinceAcquisition,
    COUNT(DISTINCT customer_id) AS NumberOfCustomersInCohort, -- Number of customers active in this 'month since acquisition'
    COUNT(rental_id) AS TotalRentalsFromCohort,
    SUM(amount) AS TotalRevenueFromCohort
FROM
    CohortRentalsWithRevenue
GROUP BY
    AcquisitionMonthCohort,
    MonthsSinceAcquisition
ORDER BY
    AcquisitionMonthCohort ASC,
    MonthsSinceAcquisition ASC;