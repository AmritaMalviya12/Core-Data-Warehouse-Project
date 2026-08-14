/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a database called 'DataWarehouse'.
    Before creating it, the script checks whether the database
    already exists. If it does, the existing database is removed
    and a fresh one is created.

    It also creates three schemas inside the database:
    'bronze', 'silver', and 'gold'.
*/



USE master;
GO 
  
-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

CREATE DATABASE DataWarehouse;
GO
  
USE DataWarehouse;
GO
  
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
