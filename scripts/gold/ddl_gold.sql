/*
===========================================================================
DDL Script: Create Gold Views
--------------------------------------------------------------------------
Purpose:
  To create views for Gold Layer in data warehouse.
  This layer represents the final dimnestion and facts tables (star schema)

  Each view performs transformations and combines data from silver layer
  to produce clean and business-ready dataset. 

Usage: 
  To be queried for analytics and reporting
===========================================================================
*/



-- CREATE GOLD CUSTOMER DIMENSION TABLE - 
IF OBJECT_ID('gold.dim_customer', 'V') IS NOT NULL
	DROP TABLE gold.dim_customer;
GO 
  
CREATE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname as last_name,
	la.cntry as country,
	ci.cst_marital_status as marital_status,
	CASE WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr
		 ELSE COALESCE(ca.gen, 'N/A')
	END as gender,
	ca.bdate as birthdate,
	ci.cst_create_date as create_date
FROM
	silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid
GO

-- PRODUCTS --
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
  DROP TABLE gold.dim_products;
GO 
  
CREATE VIEW gold.dim_products AS 
SELECT
ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
pn.prd_id as product_id,
pn.prd_key as product_number,
pn.prd_nm as product_name,
pn.cat_id as category_id,
pc.cat as category,
pc.subcat as subcategory,
pc.maintenance,
pn.prd_cost as cost,
pn.prd_line as product_line,
pn.prd_start_dt as start_date
FROM 
	silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL -- Filter Historical Data
GO

-- SALES -- 
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
  DROP TABLE gold.fact_sales;
GO 
  
CREATE VIEW gold.fact_sales AS
SELECT 
	sd.sls_ord_num as order_number,
	pr.product_key,
	cu.customer_key,
    sd.sls_order_dt as order_date,
    sd.sls_ship_dt as shipping_date,
    sd.sls_due_dt as due_date,
    sd.sls_sales as sales_amount,
    sd.sls_quantity as quantity,
    sd.sls_price as price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr 
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu 
ON sd.sls_cust_id = cu.customer_id
GO    
