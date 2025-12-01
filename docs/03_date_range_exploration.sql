/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/
-- Determine the first and last order date and the total duration in months
SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales;

-- Find the youngest and oldest customer based on birthdate
SELECT
MIN(birth_date) AS oldest_customer,
DATEDIFF(year, MIN(birth_date), GETDATE()) AS oldest_age,
MAX(birth_date) AS youngest_customer,
DATEDIFF(year, MAX(birth_date), GETDATE()) AS youngest_age
FROM gold.dim_customers;
