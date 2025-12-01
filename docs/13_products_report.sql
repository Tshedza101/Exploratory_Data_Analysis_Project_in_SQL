/*
================================================================================================================================================
Product Report
================================================================================================================================================
Purpose: 
	- This report contains key product metrics and behaviors

Highlights:
	1. Gathers essential fields such as product name, category, subcategory and cost.
	2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
	3. Aggregate product-level metrics:
		- total orders
		- total sales
		- total quantity sold
		- total customers (unique)
		- lifespan (in months)
	4. Calculates valuable KPI:
		- Recency (months since last sale)
		- Average order revenue
		- Average monthly revenue
=============================================================================================================================================
*/
/*
---------------------------------------------------------------------------------------------------------------------------------------------
Create report gold.report_products
---------------------------------------------------------------------------------------------------------------------------------------------
*/
IF OBJECT_ID('gold.report_products', 'v') IS NOT NULL
	DROP VIEW gold.report_products;
GO
CREATE VIEW gold.report_products AS
WITH base_query AS (
/*
---------------------------------------------------------------------------------------------------------------------------------------------
1. Base Querry: Retrieves core columns from fact_sales and dim_products
---------------------------------------------------------------------------------------------------------------------------------------------
*/

SELECT 
f.order_number,
f.order_date,
f.customer_key,
f.sales_amount,
f.quantity,
p.product_key,
product_name,
p.category,
p.subcategory,
p.product_cost
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
),

-- 3. Aggregate product-level metrics: -Base query CTE

 product_aggregation AS (
/*
---------------------------------------------------------------------------------------------------------------------------------------------
2. Product Aggregations: Summarizes key metrics at the product level
---------------------------------------------------------------------------------------------------------------------------------------------
*/

SELECT 
product_key,
product_name,
category,
subcategory,
product_cost,
DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
MAX(order_date) AS last_sale_date,
COUNT(DISTINCT order_number) AS total_orders,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity,
ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity,0)),1) AS average_selling_price
FROM base_query
GROUP BY
product_key,
product_name,
category,
subcategory,
product_cost
)
/*
---------------------------------------------------------------------------------------------------------------------------------------------
3. FInal Querry: Combines all produc results into one output
---------------------------------------------------------------------------------------------------------------------------------------------
*/
SELECT
product_key,
product_name,
category,
subcategory,
product_cost,
last_sale_date,
DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_month,
CASE WHEN total_sales <50000 THEN 'Higher-Performer'
	 WHEN total_sales >=10000 THEN 'Mid-Range'
	 ELSE 'Low-Performer'
END AS product_segment,
lifespan,
total_orders,
total_sales,
total_quantity,
total_customers,
average_selling_price,
-- Compute average order value
CASE WHEN total_orders = 0 THEN 0
	 ELSE total_sales / total_orders
END AS average_order_revenue,
-- Compute monthly average revenue
CASE WHEN lifespan = 0  then total_sales
	 ELSE total_sales / lifespan
END AS average_monthly_revenue
FROM product_aggregation;
