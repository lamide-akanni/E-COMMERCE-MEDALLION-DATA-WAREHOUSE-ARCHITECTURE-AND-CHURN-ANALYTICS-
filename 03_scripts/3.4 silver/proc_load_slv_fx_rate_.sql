/*
===============================================================================
Stored Procedure: Load Silver FX Rates (Bronze -> Silver)
===============================================================================
Script Purpose:
    Cleans and standardises FX rate data from bronze into silver.
    Derives date_key from rate_date to enable joining to gold.dim_date.

Usage Example:
    EXEC silver.load_slv_fx_rates;
===============================================================================
*/
CREATE OR ALTER PROCEDURE silver.load_slv_fx_rates AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;
    BEGIN TRY
        PRINT '==================================================';
        PRINT 'Loading Silver FX Rates';
        PRINT '==================================================';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.fx_rates';
        TRUNCATE TABLE silver.fx_rates;

        PRINT '>> Inserting Data Into: silver.fx_rates';
        INSERT INTO silver.fx_rates (date_key, rate_date, base_currency, target_currency, exchange_rate)
        SELECT
            CAST(CONVERT(VARCHAR(8), rate_date, 112) AS INT) AS date_key, -- derived: joins to gold.dim_date
            rate_date,
            TRIM(base_currency)   AS base_currency,
            TRIM(target_currency) AS target_currency,
            exchange_rate
        FROM bronze.fx_rates;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '==================================================';
        PRINT 'Loading Silver FX Rates is Completed';
        PRINT '==================================================';
    END TRY
    BEGIN CATCH
        PRINT '==================================================';
        PRINT 'ERROR OCCURRED DURING LOADING SILVER FX RATES';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT '==================================================';
        THROW;
    END CATCH
END
GO
