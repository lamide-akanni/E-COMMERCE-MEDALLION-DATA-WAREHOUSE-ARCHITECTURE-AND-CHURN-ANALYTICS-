USE DataWarehouse;
GO

IF OBJECT_ID('bronze.fx_rates', 'U') IS NOT NULL
    DROP TABLE bronze.fx_rates;
GO

CREATE TABLE bronze.fx_rates (
    rate_date       DATE,
    base_currency   NVARCHAR(10),
    target_currency NVARCHAR(10),
    exchange_rate   DECIMAL(18,6)
);
GO


-- python data ingestion
-- python_ingestion/fetch_fx_rates.py
