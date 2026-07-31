/* 

====================================================================
Product Report
====================================================================
Purpose: 
	- This report consolidates key product metrics and bhaviors

Highlights:
	1. Gathers essential fields like product name, category, subcategory, and cost
	2. Segments products by revenue to identify high, mid, and low peformers
	3. Aggregates product level metrics: 
		- total orders
		- total sales
		- total quantity sold
		- lifespan in months
	4. Calculates valuable KPIs:
		- recency (months since last sale)
		- average order revenue
		- average monthly revenue

====================================================================
*/
CREATE VIEW gold.report_products AS
-- BASE QUERY
WITH base_query AS
(
SELECT
f.order_number,
f.order_date,
f.customer_key,
f.sales_amount,
f.quantity,
p.product_key,
p.product_name,
p.category,
p.subcategory,
p.cost
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
)
,product_aggregations AS
(
SELECT
product_key,
product_name,
category,
subcategory,
cost,
DATEDIFF (month, MIN(order_date),MAX(order_date)) as lifespan,
MAX(order_date) as last_sale_date,
COUNT(DISTINCT order_number) as total_orders,
COUNT(DISTINCT customer_key) as total_customers,
SUM(sales_amount) as total_sales,
SUM(quantity) as total_quantity,
ROUND(AVG(CAST(sales_amount as FLOAT)/NULLIF(quantity,0)), 1) as avg_selling_price
FROM base_query
GROUP BY product_key,
product_name,
category,
subcategory,
cost
)
SELECT
product_key,
product_name,
category,
subcategory,
cost,
last_sale_date,
DATEDIFF(month, last_sale_date, GETDATE()) AS recency_in_months, 
CASE WHEN total_sales > 50000 THEN 'High Performer'
     WHEN total_sales BETWEEN 10000 AND 50000 THEN 'Mid-Range Performer'
	 ELSE 'Low Performer'
END as product_segment,
lifespan,
total_orders,
total_customers,
total_sales,
total_quantity,
avg_selling_price,
CASE WHEN total_orders = 0 THEN 0
	ELSE total_sales / total_orders
END as avg_order_revenue,
CASE when lifespan = 0 THEN total_sales
	ELSE total_sales / lifespan
END AS avg_monthly_revenue
FROM product_aggregations;
