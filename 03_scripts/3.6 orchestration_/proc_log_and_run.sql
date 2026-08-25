/*
===============================================================================
Stored Procedure: Log and Run (Orchestration Helper)
===============================================================================
Script Purpose:
    Executes a given stored procedure and logs its start time, end time,
    duration, and outcome (SUCCESS/FAILED) into dbo.etl_log.

Parameters:
    @run_id          UNIQUEIDENTIFIER - groups all steps from one pipeline run
    @procedure_name  NVARCHAR(200)    - fully qualified procedure name to execute

Usage Example:
    DECLARE @run_id UNIQUEIDENTIFIER = NEWID();
    EXEC dbo.log_and_run @run_id, 'bronze.load_bronze';
===============================================================================
*/
CREATE OR ALTER PROCEDURE dbo.log_and_run
    @run_id UNIQUEIDENTIFIER,
    @procedure_name NVARCHAR(200)
AS
BEGIN
    DECLARE @start_time DATETIME2 = GETDATE();
    DECLARE @end_time DATETIME2;
    DECLARE @status NVARCHAR(20);
    DECLARE @error_message NVARCHAR(MAX) = NULL;

    BEGIN TRY
        EXEC (@procedure_name);   -- dynamically runs whichever procedure name was passed in
        SET @status = 'SUCCESS';
    END TRY
    BEGIN CATCH
        SET @status = 'FAILED';
        SET @error_message = ERROR_MESSAGE();
    END CATCH

    SET @end_time = GETDATE();

    INSERT INTO dbo.etl_log (run_id, pipeline_step, start_time, end_time, duration_sec, status, error_message)
    VALUES (
        @run_id,
        @procedure_name,
        @start_time,
        @end_time,
        DATEDIFF(SECOND, @start_time, @end_time),
        @status,
        @error_message
    );

    -- Re-raise the error so the master procedure knows this step failed
    IF @status = 'FAILED'
        THROW 50000, @error_message, 1;
END
GO

-- SELECT name FROM sys.procedures WHERE schema_id = SCHEMA_ID('dbo');
