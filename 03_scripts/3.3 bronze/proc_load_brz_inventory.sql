

/*
===============================================================================
Stored Procedure: Load Bronze Inventory (BikeShopOLTP -> Bronze)
===============================================================================
Script Purpose:
    Extracts inventory data from the BikeShopOLTP source system database
    into the bronze layer via a cross-database read.

Usage Example:
    EXEC bronze.load_brz_inventory;
===============================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_brz_inventory AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;
    BEGIN TRY
        PRINT '==================================================';
        PRINT 'Loading Bronze Inventory';
        PRINT '==================================================';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.inventory';
        TRUNCATE TABLE bronze.inventory;

        PRINT '>> Inserting Data Into: bronze.inventory';
        INSERT INTO bronze.inventory (product_number, warehouse, snapshot_date, stock_qty, reorder_level)
        SELECT
            product_number,
            warehouse,
            snapshot_date,
            stock_qty,
            reorder_level
        FROM BikeShopOLTP.dbo.inventory;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '==================================================';
        PRINT 'Loading Bronze Inventory is Completed';
        PRINT '==================================================';
    END TRY
    BEGIN CATCH
        PRINT '==================================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE INVENTORY';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT '==================================================';
        THROW;
    END CATCH
END
GO
