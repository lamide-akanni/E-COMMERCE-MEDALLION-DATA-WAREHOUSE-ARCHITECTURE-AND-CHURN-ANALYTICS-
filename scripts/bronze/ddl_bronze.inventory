USE DataWarehouse;
GO

IF OBJECT_ID('bronze.inventory', 'U') IS NOT NULL
    DROP TABLE bronze.inventory;
GO

CREATE TABLE bronze.inventory (
    product_number  NVARCHAR(50),
    warehouse       NVARCHAR(50),
    snapshot_date   DATE,
    stock_qty       INT,
    reorder_level   INT
);
GO
