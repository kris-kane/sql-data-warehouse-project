/* 

CREATE DATABASE AND SCHEMAS

Purpose: This script creates a new database called 'DataWarehose; after checking if it already exists.
If it exists, it is dropped and recreated. It also sets up three schemas within the database: Bronze, Silver, and Gold. 

WARNING:
Running this script will drop the entire DataWarehouse database if it exists. All data in the databse will be permanently deleted.
Proceed with caution and ensure you have proper backups before running this script!
*/

USE master;
GO

-- Drop and Recreate 'DataWarehouse database -- 
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Create the DataWarehouse database --
CREATE DATABASE DataWarehouse;
GO

-- Join into Datawarehouse database -- 
USE DataWarehouse;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO 
