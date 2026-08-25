/*
===============================================================================
Stored Procedure: Load Silver Inventory (Bronze -> Silver)
===============================================================================
Script Purpose:
    Cleans and standardizes inventory data from bronze into silver.
    Derives date_key from snapshot_date to enable joining to gold.dim_date.

Usage Example:
    EXEC silver.load_slv_inventory;
===============================================================================
*/
CREATE OR ALTER PROCEDURE silver.load_slv_inventory AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;
    BEGIN TRY
        PRINT '==================================================';
        PRINT 'Loading Silver Inventory';
        PRINT '==================================================';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.inventory';
        TRUNCATE TABLE silver.inventory;

        PRINT '>> Inserting Data Into: silver.inventory';
        INSERT INTO silver.inventory (product_number, warehouse, date_key, snapshot_date, stock_qty, reorder_level)
        SELECT
            TRIM(product_number)                                    AS product_number,
            TRIM(warehouse)                                         AS warehouse,
            CAST(CONVERT(VARCHAR(8), snapshot_date, 112) AS INT)    AS date_key, -- derived: joins to gold.dim_date
            snapshot_date,
            CASE WHEN stock_qty < 0 THEN 0 ELSE stock_qty END       AS stock_qty, -- guard against invalid negative stock
            reorder_level
        FROM bronze.inventory;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '==================================================';
        PRINT 'Loading Silver Inventory is Completed';
        PRINT '==================================================';
    END TRY
    BEGIN CATCH
        PRINT '==================================================';
        PRINT 'ERROR OCCURRED DURING LOADING SILVER INVENTORY';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT '==================================================';
    END CATCH
END
GO
