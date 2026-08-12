
-- =============================================
-- Create the source system database
-- Simulates an external 0perational Inventory System (OLTP)
-- =============================================

IF DB_ID('BikeShopOLTP') IS NULL
    CREATE DATABASE BikeShopOLTP;
GO

USE BikeShopOLTP;
GO

-- Create the inventory table (owned by the "ops team")
IF OBJECT_ID('dbo.inventory', 'U') IS NOT NULL
    DROP TABLE dbo.inventory;
GO

CREATE TABLE dbo.inventory (
    product_number  NVARCHAR(50),   -- joins to dim_products.product_number
    warehouse       NVARCHAR(50),   -- which warehouse holds the stock
    snapshot_date   DATE,           -- the day this stock level was recorded
    stock_qty       INT,            -- units in stock that day
    reorder_level   INT             -- threshold to trigger a reorder
);
GO

-- =============================================
-- Seed the source table with Generated Data
-- =============================================
TRUNCATE TABLE dbo.inventory;

INSERT INTO dbo.inventory (product_number, warehouse, snapshot_date, stock_qty, reorder_level)
SELECT
    p.product_number,
    w.warehouse,
    d.snapshot_date,
    ABS(CHECKSUM(NEWID())) % 200          AS stock_qty,
    25                                     AS reorder_level
FROM (
    SELECT DISTINCT product_number
    FROM DataWarehouse.gold.dim_products
) p
CROSS JOIN (
    VALUES ('London'),('Manchester'),('Edinburgh'),('Glasgow'),('Cardiff'),('Belfast')
) w(warehouse)
CROSS JOIN (
    SELECT CAST(DATEADD(DAY, -n, GETDATE()) AS DATE) AS snapshot_date
    FROM (VALUES (0),(1),(2),(3),(4)) x(n)
) d;
GO
