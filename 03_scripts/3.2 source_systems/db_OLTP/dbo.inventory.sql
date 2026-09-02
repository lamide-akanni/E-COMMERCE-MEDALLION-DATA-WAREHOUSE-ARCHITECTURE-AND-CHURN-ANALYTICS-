-- Create the separate source-system database
-- IF DB_ID('BikeShopOLTP') IS NULL
--   CREATE DATABASE BikeShopOLTP;
-- GO

USE BikeShopOLTP;
GO

-- ============================================================
-- dbo.products
-- The OLTP system's own product catalogue, 
-- load direct from CRM extract.
-- BikeShopOLTP independent of the DataWarehouse 
-- ============================================================
IF OBJECT_ID('dbo.products', 'U') IS NOT NULL
    DROP TABLE dbo.products;
GO

CREATE TABLE dbo.products (
    prd_id       INT,
    prd_key      NVARCHAR(50),
    prd_nm       NVARCHAR(50),
    prd_cost     INT,
    prd_line     NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt   DATETIME
);
GO

BULK INSERT dbo.products
FROM 'C:\Users\lamid\Documents\db\source_crm\prd_info.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
GO

-- ============================================================
-- dbo.inventory
-- Stock snapshots per product, per warehouse, per day.
-- Quantities are randomised - simulated source system data.
-- ============================================================
IF OBJECT_ID('dbo.inventory', 'U') IS NOT NULL
    DROP TABLE dbo.inventory;
GO

CREATE TABLE dbo.inventory (
    product_number  NVARCHAR(50),
    warehouse       NVARCHAR(50),
    snapshot_date   DATE,
    stock_qty       INT,
    reorder_level   INT
);
GO

INSERT INTO dbo.inventory (product_number, warehouse, snapshot_date, stock_qty, reorder_level)
SELECT
    p.product_number,
    w.warehouse,
    d.snapshot_date,
    ABS(CHECKSUM(NEWID())) % 200          AS stock_qty,
    25                                     AS reorder_level
FROM (
    SELECT DISTINCT SUBSTRING(prd_key, 7, LEN(prd_key)) AS product_number
    FROM dbo.products
    WHERE prd_end_dt IS NULL
) p
CROSS JOIN (
    VALUES ('London'),('Manchester'),('Edinburgh'),('Glasgow'),('Cardiff'),('Belfast')
) w(warehouse)
CROSS JOIN (
    SELECT CAST(DATEADD(DAY, -n, GETDATE()) AS DATE) AS snapshot_date
    FROM (VALUES (0),(1),(2),(3),(4)) x(n)
) d;
GO
 
