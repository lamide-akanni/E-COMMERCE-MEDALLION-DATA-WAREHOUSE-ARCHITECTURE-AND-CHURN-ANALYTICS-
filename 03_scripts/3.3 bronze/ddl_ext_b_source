-- DDL Script for Bronze: inventory, fx_rates, web_events
-- These three sources arrive outside the CRM/ERP CSV batch (OLTP database,
-- REST API, and clickstream generator respectively).

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

IF OBJECT_ID('bronze.web_events', 'U') IS NOT NULL
    DROP TABLE bronze.web_events;
GO
CREATE TABLE bronze.web_events (
    event_id        BIGINT IDENTITY(1,1) PRIMARY KEY,
    event_timestamp DATETIME2,
    session_id      NVARCHAR(50),
    event_type      NVARCHAR(30),
    product_number  NVARCHAR(50) NULL,
    customer_id     INT NULL,
    search_term     NVARCHAR(100) NULL
);
GO
