USE [DataWarehouse]
GO

/****** Object:  StoredProcedure [bronze].[load_bronze]    Script Date: 24/08/2026 10:57:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [bronze].[load_bronze] AS 
BEGIN
  DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
  BEGIN TRY
     SET @batch_start_time = GETDATE();
     PRINT'==================================================';
     PRINT 'Loading Bronze Layer';
     PRINT'==================================================';

     PRINT'-------------------------------------------------';
     PRINT 'Loading CRM Tables';
     PRINT'-------------------------------------------------';

-- load1 the bronze crm cust info data
SET @start_time = GETDATE();
TRUNCATE TABLE bronze.crm_cust_info;

BULK INSERT bronze.crm_cust_info
FROM 'C:\Users\lamid\Documents\dbara\source_crm\cust_info.csv'
WITH(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
SET @end_time = GETDATE();
PRINT '>> Load Duration T1:' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
PRINT ' ___________________________________________________';

-- load2 the bronze crm prd info data
SET @start_time = GETDATE();
TRUNCATE TABLE bronze.crm_prd_info;

BULK INSERT bronze.crm_prd_info
FROM 'C:\Users\lamid\Documents\dbara\source_crm\prd_info.csv'
WITH(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
SET @end_time = GETDATE();
PRINT '>> Load Duration T2:' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
PRINT ' ___________________________________________________';


-- load3 the bronze crm sales details data
SET @start_time = GETDATE();
TRUNCATE TABLE bronze.crm_sales_details;

BULK INSERT bronze.crm_sales_details
FROM 'C:\Users\lamid\Documents\dbara\source_crm\sales_details.csv'
WITH(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
SET @end_time = GETDATE();
PRINT '>> Load Duration T3:' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
PRINT ' ___________________________________________________';
    
    
     PRINT'-------------------------------------------------';
     PRINT 'Loading ERP Tables';
     PRINT'-------------------------------------------------';


-- load4 the bronze erp cust az12 data
SET @start_time = GETDATE();
TRUNCATE TABLE bronze.erp_cust_az12;

BULK INSERT bronze.erp_cust_az12
FROM 'C:\Users\lamid\Documents\dbara\source_erp\cust_az12.csv'
WITH(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
SET @end_time = GETDATE();
PRINT '>> Load Duration T4:' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
PRINT '___________________________________________________';


-- load5 the bronze erp loc a101 data
SET @start_time = GETDATE();
TRUNCATE TABLE bronze.erp_loc_a101;
BULK INSERT bronze.erp_loc_a101
FROM 'C:\Users\lamid\Documents\dbara\source_erp\loc_a101.csv'
WITH(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
SET @end_time = GETDATE();
PRINT '>> Load Duration T5:' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
PRINT ' ___________________________________________________';


-- load6 the bronze erp px cat g1v2 data
SET @start_time = GETDATE();
TRUNCATE TABLE bronze.erp_px_cat_g1v2;

BULK INSERT bronze.erp_px_cat_g1v2
FROM 'C:\Users\lamid\Documents\dbara\source_erp\px_cat_g1v2.csv'
WITH(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
SET @end_time = GETDATE();
PRINT '>> Load Duration T6:' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
PRINT ' ___________________________________________________';

SET @batch_end_time = GETDATE(); 
PRINT '========================================================='
PRINT 'Loading bronse layer  is completed';
PRINT 'Total Load Duration:' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds';
PRINT '=========================================================='
END TRY
 
BEGIN CATCH
    PRINT '==================================================';
    PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
    PRINT '==================================================';
END CATCH

END

GO
