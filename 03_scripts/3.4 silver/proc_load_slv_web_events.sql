/*
===============================================================================
Stored Procedure: Load Silver Web Events (Bronze -> Silver)
===============================================================================
Script Purpose:
    Cleans and standardises clickstream event data from bronze into silver.
    Derives date_key from event_timestamp to enable joining to gold.dim_date.

Usage Example:
    EXEC silver.load_slv_web_events;
===============================================================================
*/
CREATE OR ALTER PROCEDURE silver.load_slv_web_events AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;
    BEGIN TRY
        PRINT '==================================================';
        PRINT 'Loading Silver Web Events';
        PRINT '==================================================';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.web_events';
        TRUNCATE TABLE silver.web_events;

        PRINT '>> Inserting Data Into: silver.web_events';
        INSERT INTO silver.web_events (event_id, date_key, event_timestamp, session_id, event_type, product_number, customer_id, search_term)
        SELECT
            event_id,
            CAST(CONVERT(VARCHAR(8), CAST(event_timestamp AS DATE), 112) AS INT) AS date_key, -- derived: joins to gold.dim_date
            event_timestamp,
            TRIM(session_id)   AS session_id,
            TRIM(event_type)   AS event_type,
            TRIM(product_number) AS product_number,
            customer_id,
            TRIM(search_term)  AS search_term
        FROM bronze.web_events;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '==================================================';
        PRINT 'Loading Silver Web Events is Completed';
        PRINT '==================================================';
    END TRY
    BEGIN CATCH
        PRINT '==================================================';
        PRINT 'ERROR OCCURRED DURING LOADING SILVER WEB EVENTS';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT '==================================================';
        THROW;
    END CATCH
END
GO
