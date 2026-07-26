/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    To perform quality checks for data consistency, accuracy, and standardization 
    across the 'gold' layer. It includes checks for:
      - uniqueness of surrgoate keys in dimenstion tables
      - validation between relationships in data model for analytic puroses
      - referntial integrity between fact and dimenstion tablkes

Usage Notes:
    - Run these checks after data loading gold Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- QUALITY CHECKS OF GOLD TABLES -- 

-- CUSTOMERS TABLE -- 

SELECT * FROM gold.dim_customers;

  -- DUPLICATES -- 

SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

	-- STANDARIZATION -- 

SELECT DISTINCT gender from gold.dim_customers;

-- PRODUCTS TABLE -- 
SELECT * FROM gold.dim_products; 
	-- UNIQUENESS - 

SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- FACTS SALE TABLE -- 
SELECT * FROM gold.fact_sales; 

-- FK INTEGRITY
SELECT * FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
WHERE c.customer_key IS NULL

SELECT * FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL
