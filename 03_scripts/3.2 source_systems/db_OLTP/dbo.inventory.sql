-- Create the separate source-system database
-- IF DB_ID('BikeShopOLTP') IS NULL
--   CREATE DATABASE BikeShopOLTP;
-- GO

USE BikeShopOLTP;
GO

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
