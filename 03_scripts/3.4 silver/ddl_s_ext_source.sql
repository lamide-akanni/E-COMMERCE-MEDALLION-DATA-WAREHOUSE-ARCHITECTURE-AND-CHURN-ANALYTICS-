-- DDL Script for Silver: inventory, fx_rates, web_events
-- These three sources arrive after the CRM/ERP batch (OLTP database,
-- REST API, and clickstream generator respectively).

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


IF OBJECT_ID('silver.fx_rates', 'U') IS NOT NULL
    DROP TABLE silver.fx_rates;
GO

CREATE TABLE silver.fx_rates (
    date_key        INT,
    rate_date       DATE,
    base_currency   NVARCHAR(10),
    target_currency NVARCHAR(10),
    exchange_rate   DECIMAL(18,6),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


IF OBJECT_ID('silver.web_events', 'U') IS NOT NULL
    DROP TABLE silver.web_events;
GO

CREATE TABLE silver.web_events (
    event_id        BIGINT,
    date_key        INT,
    event_timestamp DATETIME2,
    session_id      NVARCHAR(50),
    event_type      NVARCHAR(30),
    product_number  NVARCHAR(50) NULL,
    customer_id     INT NULL,
    search_term     NVARCHAR(100) NULL,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
