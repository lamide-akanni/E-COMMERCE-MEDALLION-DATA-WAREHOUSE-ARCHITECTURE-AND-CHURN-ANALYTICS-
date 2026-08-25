IF OBJECT_ID('dbo.etl_log', 'U') IS NOT NULL
    DROP TABLE dbo.etl_log;
GO

CREATE TABLE dbo.etl_log (
    log_id          INT IDENTITY(1,1) PRIMARY KEY,
    run_id          UNIQUEIDENTIFIER,
    pipeline_step   NVARCHAR(100),
    start_time      DATETIME2,
    end_time        DATETIME2,
    duration_sec    INT,
    status          NVARCHAR(20),
    error_message   NVARCHAR(MAX) NULL
);
GO
