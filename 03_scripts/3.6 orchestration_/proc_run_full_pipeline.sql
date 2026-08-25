/*
===============================================================================
Stored Procedure: Run Full Pipeline (Master Orchestration)
===============================================================================
Script Purpose:
    Runs the complete bronze -> silver load sequence for the Shop 360 Bike
    warehouse, in dependency order, logging every step to dbo.etl_log.

    Gold layer requires no load step (views refresh automatically).
    FX rates and web events bronze loads are performed by Python scripts
    (fetch_fx_rates.py, generate_web_events.py) BEFORE this procedure runs.

Parameters:
    None.

Usage Example:
    -- Run the two Python ingestion scripts first, then:
    EXEC dbo.run_full_pipeline;
===============================================================================
*/
CREATE OR ALTER PROCEDURE dbo.run_full_pipeline AS
BEGIN
    DECLARE @run_id UNIQUEIDENTIFIER = NEWID();
    DECLARE @batch_start DATETIME2 = GETDATE();

    PRINT '==================================================';
    PRINT 'Starting Full Pipeline Run: ' + CAST(@run_id AS NVARCHAR(50));
    PRINT '==================================================';

    -- ===== BRONZE LAYER =====
    PRINT '>> Bronze: CRM/ERP';
    EXEC dbo.log_and_run @run_id, 'bronze.load_bronze';

    PRINT '>> Bronze: Inventory';
    EXEC dbo.log_and_run @run_id, 'bronze.load_brz_inventory';

    -- ===== SILVER LAYER (waits for ALL bronze to finish) =====
    PRINT '>> Silver: CRM/ERP';
    EXEC dbo.log_and_run @run_id, 'silver.load_silver';

    PRINT '>> Silver: Inventory';
    EXEC dbo.log_and_run @run_id, 'silver.load_slv_inventory';

    PRINT '>> Silver: FX Rates';
    EXEC dbo.log_and_run @run_id, 'silver.load_slv_fx_rates';

    PRINT '>> Silver: Web Events';
    EXEC dbo.log_and_run @run_id, 'silver.load_slv_web_events';

    -- Gold layer: no load needed, views refresh automatically

    DECLARE @batch_end DATETIME2 = GETDATE();
    PRINT '==================================================';
    PRINT 'Pipeline Run Completed';
    PRINT '   - Total Duration: ' + CAST(DATEDIFF(SECOND, @batch_start, @batch_end) AS NVARCHAR) + ' seconds';
    PRINT '   - Run ID: ' + CAST(@run_id AS NVARCHAR(50));
    PRINT '==================================================';
END
GO
