IF OBJECT_ID('silver.inventory', 'U') IS NOT NULL
    DROP TABLE silver.inventory;
GO

CREATE TABLE silver.inventory (
    product_number  NVARCHAR(50),
    warehouse       NVARCHAR(50),
    date_key        INT,
    snapshot_date   DATE,
    stock_qty       INT,
    reorder_level   INT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

TRUNCATE TABLE silver.inventory;

-- clean the date
-- integer format lets this fact join to your dim. gold_date

INSERT INTO silver.inventory (product_number, warehouse, date_key, snapshot_date, stock_qty, reorder_level)
SELECT
    TRIM(product_number)                                    AS product_number,
    TRIM(warehouse)                                         AS warehouse,
    CAST(CONVERT(VARCHAR(8), snapshot_date, 112) AS INT)    AS date_key,
    snapshot_date,
    CASE 
       WHEN stock_qty < 0 THEN 0 ELSE stock_qty 
    END                                                      AS stock_qty,
    reorder_level
FROM bronze.inventory;
GO

