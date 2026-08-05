
USE BikeShopOLTP;
GO

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
