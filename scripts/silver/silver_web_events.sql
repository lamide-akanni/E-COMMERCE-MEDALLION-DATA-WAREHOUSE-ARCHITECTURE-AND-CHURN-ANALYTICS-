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

TRUNCATE TABLE silver.web_events;

INSERT INTO silver.web_events (event_id, date_key, event_timestamp, session_id, event_type, product_number, customer_id, search_term)
SELECT
    event_id,
    CAST(CONVERT(VARCHAR(8), CAST(event_timestamp AS DATE), 112) AS INT) AS date_key,
    event_timestamp,
    TRIM(session_id),
    TRIM(event_type),
    TRIM(product_number),
    customer_id,
    TRIM(search_term)
FROM bronze.web_events;
GO
