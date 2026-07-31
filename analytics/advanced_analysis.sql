/*
===========================================================
Advanced Data Analytics with SQL
===========================================================
Purpose:
This script demonstrates common analytical techniques using SQL,
including:

1. Change-over-time trend analysis
2. Running totals and moving averages using window functions
3. Year-over-year product performance analysis
4. Part-to-whole (percentage contribution) analysis
5. Customer and product segmentation

The queries leverage CTEs, aggregate functions, CASE expressions,
and window functions to transform transactional sales data into
meaningful business insights.
===========================================================
*/

/*

1. Change-Over-Time

*/

-- CHANGE OVER TIME TRENDS --

SELECT
year(order_date) as order_year,
month(order_date) as order_month,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
from gold.fact_sales
WHERE order_date is NOT NULL
GROUP by year(order_date), month(order_date)
ORDER by year(order_date), month(order_date)
GO
SELECT
datetrunc(month, order_date) as order_date,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
from gold.fact_sales
WHERE order_date is NOT NULL
GROUP by datetrunc(month, order_date) 
ORDER by datetrunc(month, order_date) 
GO
-- CUMULATIVE ANALYSIS --

-- Total sales per month and the running total of sales over time -- 
SELECT
order_date,
total_sales,
SUM(total_sales) OVER (partition by order_date ORDER by order_date) as running_total_sales
FROM 
(
SELECT
DATETRUNC(month,order_date) as order_date,
SUM(sales_amount) as total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month,order_date)
)t
GO
-- moving average by year -- 
SELECT
order_date,
total_sales,
AVG (avg_price) OVER (order by order_date) as moving_average_price
FROM 
(
SELECT
DATETRUNC(year,order_date) as order_date,
AVG(price) as avg_price,
SUM(sales_amount) as total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(year,order_date)
)t
GO
-- PERFORMANCE ANALYSIS (Current Value vs Target Value) --

-- analyze yearly performance of products by comparing each products sales
-- to its average sales and previous years sales 
WITH yearly_annual_sales AS
(
SELECT 
year(s.order_date) as order_year,
p.product_name, 
SUM(s.sales_amount) as current_sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
WHERE s.order_date is NOT NULL
GROUP BY year(order_date), p.product_name
)
GO
SELECT
order_year,
product_name,
current_sales,
AVG(current_sales) OVER (Partition by product_name) AS avg_sales,
current_sales - AVG(current_sales) OVER (Partition by product_name)  AS diff_avg,
CASE WHEN current_sales - AVG(current_sales) OVER (Partition by product_name) > 0 THEN 'Above Avg'
	 WHEN current_sales - AVG(current_sales) OVER (Partition by product_name) < 0 THEN 'Below Avg'
	 ELSE 'Avg'
END avg_change,
LAG(current_sales) OVER (Partition by product_name ORDER BY order_year) as py_sales, 
current_sales - LAG(current_sales) OVER (Partition by product_name ORDER BY order_year) as diff_py,
CASE WHEN current_sales - LAG(current_sales) OVER (Partition by product_name ORDER BY order_year) > 0 THEN 'Increase'
	 WHEN current_sales - LAG(current_sales) OVER (Partition by product_name ORDER BY order_year) < 0 THEN 'Decrease'
	 ELSE 'No Change'
END py_change
FROM yearly_annual_sales
ORDER BY product_name, order_year
GO
-- PART-TO-WHOLE: Proportional Analyis --
-- Measure/Total(Measure) * 100 By Dimension -- 

-- Which categories contribute the most to overall sales? --
WITH category_sales AS(
SELECT
category, 
SUM(sales_amount) as total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY category
)
GO
SELECT 
category,
total_sales,
SUM(total_sales) OVER () as  overall_sales,
CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ())* 100,2),'%') as pct_of_sales
FROM category_sales
ORDER BY total_sales DESC
GO

-- DATA SEGMENTATION -- 
-- Measure by Measure -- 
-- Segment products into cost ranges and 
-- count how many products in each segment -- 
With cost_ranges AS(
SELECT
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	 ELSE 'Above 1000'
END as cost_range
FROM gold.dim_products)
GO
SELECT
cost_range,
COUNT(product_key) as total_products
FROM cost_ranges
GROUP by cost_range
ORDER BY total_products DESC
GO
/* Group customers into 3 segments based on spending behavior
vip - 12 month history  & 5000 
regular - 12 mont history  & 5000 or less
new - less than 12 month history

and find total number of customers by each group*/
WITH customer_spending AS(
SELECT
c.customer_key,
SUM(f.sales_amount) as total_spending,
MIN(order_date) as first_order,
MAX(order_date) as last_order,
DATEDIFF (month, MIN(order_date),MAX(order_date)) as lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key)
GO
SELECT
customer_segment, 
COUNT(customer_key) as total_customer
FROM(
SELECT
customer_key,
CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
     WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
	 ELSE 'New'
END as customer_segment
FROM customer_spending)t
GROUP by customer_segment
ORDER by total_customer DESC
GO
