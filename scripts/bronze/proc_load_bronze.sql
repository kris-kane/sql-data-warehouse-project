/*
========================================================================================================================
Stored Procedure: Load Bronze Later (Source -> Bronze)
-----------------------------------------------------------
Purpose: To Load Data into 'bronze schema' from external CSV Files. 
It performs the following:
  - Truncates the bronze tables before loading data
  - Uses BULK Insert command to load data from CSV Files to bronze tables

Parameters: None. The stored procedure does not accept any parameters or return any values.

Usage Example:
  EXEC bronze.load_bronze;
========================================================================================================================
*/
-- CREATE PROCEDURE - 
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @bronze_start DATETIME, @bronze_end DATETIME;
	BEGIN TRY
		PRINT '====================================================';
		PRINT 'Load Bronze Layer';
		PRINT '====================================================';
		PRINT '----------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '----------------------------------------------------';
		SET @start_time = GETDATE();
		SET @bronze_start = GETDATE();

		---------------------- CRM_CUST_INFO ---------------------- 
		-- CLEAR TABLE FOR RUNABILITY -- 
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;
		PRINT '>> Inserting Data Into: bronze.crm_cust_info'; 
		BULK INSERT bronze.crm_cust_info
		FROM '..\..\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------'
		---------------------- CRM_PRD_INFO ---------------------- 
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;
		PRINT '>> Inserting Data Into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM '..\..\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------'

		---------------------- CRM_SALES_DETAILS ---------------------- 
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT '>> Inserting Data Into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM '..\..\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------'
		PRINT '----------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '----------------------------------------------------';

		---------------------- ERP_CUST_AZ12 ---------------------- 
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;
		PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM '..\..\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------'
		---------------------- ERP_LOC_A101 ---------------------- 
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;
		PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM '..\..\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------'

		---------------------- ERP_PX_CAT_G1V2 ---------------------- 
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM '..\..\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		SET @bronze_end = GETDATE()
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second,@start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-------------'
		PRINT '====================================================';
		PRINT ' Loading Bronze Layer is Completed! '
		PRINT '>> Bronze Layer Load Duration: ' + CAST (DATEDIFF(second,@bronze_start, @bronze_end) AS NVARCHAR) + ' seconds';
		PRINT '====================================================';
	END TRY
	BEGIN CATCH
		PRINT '====================================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
		PRINT 'ERROR MESSAGE' + CAST (ERROR_MESSAGE()  AS NVARCHAR);
		PRINT 'ERROR MESSAGE' + CAST (ERROR_STATE()  AS NVARCHAR);
		PRINT '====================================================';
	END CATCH
END
