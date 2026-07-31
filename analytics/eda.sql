/*
===========================================================================
EDA: Exploratory Data Analysis
--------------------------------------------------------------------------
Purpose:
  To explore the data from the fact and dimension views built in the gold layer.

   - Explores tables and columns of each table
   - Explores dimensions
   - Explores dates within tables
   - Explores measures and creates queries with useful measures
   - Explores magnitude
   - Creates basic rankings of the data

===========================================================================
*/
-- EXPLORE ALL OBJECTS IN THE DATABASE --
SELECT * FROM INFORMATION_SCHEMA.TABLES;
GO

-- EXPLORE ALL COLUMNS IN THE DATABASE --
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'
GO
  
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_products'
GO
  
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'fact_sales'
GO
  
-- EXPLORE DIMENSIONS -- 
SELECT DISTINCT country FROM gold.dim_customers;
GO
SELECT DISTINCT category, subcategory, product_name FROM gold.dim_products
ORDER BY 1,2,3;
GO
-- EXPLORE DATES -- 
-- FIND BOUNDARIES, TIMESPAN -- 
SELECT 
MIN(order_date) as first_order_date,
MAX(order_date) as last_order_date,
DATEDIFF(year, MIN(order_date),MAX(order_date)) AS order_range_years
FROM gold.fact_sales
GO
SELECT
MIN(birthdate) AS oldest_birthdate,
MAX(birthdate) as youngest_birthdate,
DATEDIFF(year,MIN(birthdate),GETDATE()) as oldest_age,
DATEDIFF(year,MAX(birthdate),GETDATE()) as youngest_age
FROM gold.dim_customers
GO
-- EXPLORE MEASURES -- 
-- total sales -- 

SELECT 
SUM(sales_amount) as total_sales
FROM gold.fact_sales
GO
-- total items sold --

SELECT
SUM(quantity) AS total_quantity
FROM gold.fact_sales
GO
-- average selling price -- 

SELECT
AVG(price) as avg_price
FROM gold.fact_sales
GO
-- total number of orders --

SELECT 
COUNT(DISTINCT order_number) as total_orders
FROM gold.fact_sales
GO
-- total number of products --

SELECT 
COUNT(DISTINCT product_key) as total_products
FROM gold.dim_products
GO
-- total number of customers -- 

SELECT 
COUNT(DISTINCT customer_key) as total_customers
FROM gold.dim_customers
GO
-- total number of customers that have placed an order --

SELECT 
COUNT(DISTINCT customer_key) as total_customers_with_orders
FROM gold.fact_sales
GO
-- MEASURE TABLE -- 

SELECT 'Total Sales' as measure_name,  SUM(sales_amount) as measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' as measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL 
SELECT 'Average Price' as measure_name,AVG(price) as measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Number of Orders' as measure_name, COUNT(DISTINCT order_number) as measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Number of Products' as measure_name, COUNT(DISTINCT product_key) asmeasure_value FROM gold.dim_products
UNION ALL
SELECT 'Total Number of Customers' as measure_name, COUNT(DISTINCT customer_key) asmeasure_value FROM gold.dim_customers
GO
-- MAGNITUDE (MEASURE BY DIMENSION) -- 
-- total customers by gender -- 

SELECT
	gender,
	COUNT(customer_key) as total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC
GO
-- total customers by country --

SELECT
	country,
	COUNT(customer_key) as total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC
GO
-- total products by category -- 

SELECT
	category,
	COUNT(product_key) as total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC
GO
-- average cost in each category -- 

SELECT
	category,
	AVG(cost) as avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC
GO
-- total revenue for each category -- 

SELECT 
	p.category, 
	SUM(f.sales_amount) as total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p 
ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC
GO
-- total revenue for each customer -- 

SELECT 
	c.customer_key, 
	c.first_name,
	c.last_name,
	SUM(f.sales_amount) as total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c 
ON c.customer_key = f.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_revenue DESC
GO
-- distribution of sold items across countries -- 

SELECT 
	c.country,
	SUM(f.quantity) as total_sold_items
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c 
ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC
GO

-- RANKING --
-- 5 Products generated highest revenue --

SELECT TOP 5
	p.product_name, 
	SUM(f.sales_amount) as total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p 
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC
GO
-- window function version --
SELECT *
FROM (SELECT
	p.product_name, 
	SUM(f.sales_amount) as total_revenue,
	ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC) as rank_products
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p 
ON p.product_key = f.product_key
GROUP BY p.product_name)t
WHERE rank_products <= 5
GO
-- 5 worst-performing products in terms of sales -- 

SELECT TOP 5
	p.product_name, 
	SUM(f.sales_amount) as total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p 
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC
GO
-- Find Top 10 customers who generated the most revenue -- 

SELECT TOP 10
	c.customer_key, 
	c.first_name,
	c.last_name,
	SUM(f.sales_amount) as total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c 
ON c.customer_key = f.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_revenue DESC
GO
-- Find Top 3 customers with fewest orders placed -- 

SELECT TOP 3
	c.customer_key, 
	c.first_name,
	c.last_name,
	COUNT(DISTINCT order_number) as total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c 
ON c.customer_key = f.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_orders ASC
GO
