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
