:: run_pipeline.bat 
:: SQL Server Express has no SQL Server Agent (Standard/Enterprise only)
:: This batch file + Windows Task Scheduler is the local substitute (see sql_agent_job_reference.sql)

@echo off
cd /d "C:\Users\lamid\Documents\db\shop360bike"

@echo off
cd /d "C:\Users\lamid\Documents\db\shop360bike"

echo ==================================================
echo Starting Shop360Bike pipeline run
echo ==================================================

echo.
echo Step 1: Fetching FX rates...
python fetch_fx_rates.py
if errorlevel 1 (
    echo FAILED at Fetch FX Rates
    python send_slack_alert.py "FAILED at Fetch FX Rates"
    exit /b 1
)

echo.
echo Step 2: Generating web events...
python generate_web_events.py
if errorlevel 1 (
    echo FAILED at Generate Web Events
    python send_slack_alert.py "FAILED at Generate Web Events"
    exit /b 1
)

echo.
echo Step 3: Running SQL pipeline...
sqlcmd -S localhost\SQLEXPRESS -d DataWarehouse -Q "EXEC dbo.run_full_pipeline;" -b
if errorlevel 1 (
    echo FAILED at SQL Pipeline
    python send_slack_alert.py "FAILED at SQL Pipeline"
    exit /b 1
)

echo.
echo ==================================================
echo Pipeline run completed successfully
echo ==================================================
python send_slack_alert.py "SUCCESS"
