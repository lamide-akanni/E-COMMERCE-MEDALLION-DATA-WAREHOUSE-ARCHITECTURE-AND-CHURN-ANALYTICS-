
USE DataWarehouse;
GO

-- Ensure gold schema exists
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')
    EXEC('CREATE SCHEMA gold');
GO

-- Build the date dimension
-- bronze is for raw source data & dim_date has no source. 
-- it's a generated business artefact, hence Gold layer
    
IF OBJECT_ID('gold.dim_date', 'U') IS NOT NULL
    DROP TABLE gold.dim_date;
GO

WITH date_series AS (
    SELECT CAST('2015-01-01' AS DATE) AS the_date
    UNION ALL
    SELECT DATEADD(DAY, 1, the_date)
    FROM date_series
    WHERE the_date < '2035-12-31'
)
SELECT
    CAST(CONVERT(VARCHAR(8), the_date, 112) AS INT) AS date_key,
    the_date                                        AS full_date,
    YEAR(the_date)                                  AS year,
    MONTH(the_date)                                 AS month,
    DATENAME(MONTH, the_date)                       AS month_name,
    DAY(the_date)                                   AS day,
    DATEPART(QUARTER, the_date)                     AS quarter,
    DATENAME(WEEKDAY, the_date)                     AS weekday_name,
    CASE WHEN DATENAME(WEEKDAY, the_date) IN ('Saturday','Sunday')
         THEN 1 ELSE 0 END                          AS is_weekend
INTO gold.dim_date
FROM date_series
OPTION (MAXRECURSION 0);
GO

-- Verification
-- SELECT TOP 50 * FROM gold.dim_date;
-- SELECT COUNT(*) FROM gold.dim_date;   -- expect 7,670

