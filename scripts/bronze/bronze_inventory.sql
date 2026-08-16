USE DataWarehouse;
GO

IF OBJECT_ID('bronze.inventory', 'U') IS NOT NULL
    DROP TABLE bronze.inventory;
GO
-- ==== create table 
CREATE TABLE bronze.inventory (
    product_number  NVARCHAR(50),
    warehouse       NVARCHAR(50),
    snapshot_date   DATE,
    stock_qty       INT,
    reorder_level   INT
);
GO

TRUNCATE TABLE bronze.inventory;
-- load data
INSERT INTO bronze.inventory (product_number, warehouse, snapshot_date, stock_qty, reorder_level)
SELECT
    product_number,
    warehouse,
    snapshot_date,
    stock_qty,
    reorder_level
FROM BikeShopOLTP.dbo.inventory;   -- ← cross-database read
GO


