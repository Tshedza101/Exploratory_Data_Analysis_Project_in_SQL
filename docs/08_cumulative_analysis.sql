/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends (helps identify if the busines is growing or declining).
    - Aggregate the data progressively over time
    

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/
-- Calculate the total sales/month and the running toatal of sales over time.

SELECT order_date, total_sales,
SUM(total_sales) OVER(PARTITION BY order_date ORDER BY order_date) AS running_total_sales,
AVG(average_price) OVER(PARTITION BY order_date ORDER BY order_date) AS running_average
FROM
(
SELECT 
DATETRUNC(MONTH, order_date) AS order_date,
SUM(sales_amount) AS total_sales,
AVG(price) AS average_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
)t;


