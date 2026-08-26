/*
===============================================================================
Enable SQL Server Agent Job: Shop360Bike_Full_Pipeline (REFERENCE - NOT RUNNABLE)
===============================================================================
-- Standard/Enterprise only - fails on Express

Script Purpose:
    Documents how the Shop 360 Bike pipeline would be scheduled and monitored
    using SQL Server Agent on Standard/Enterprise edition.

    NOTE: SQL Server Agent is NOT available on SQL Server Express edition.
    This script cannot be executed against a local Express instance.
    For local development, scheduling is instead achieved via Windows Task
    Scheduler invoking run_pipeline.bat (see 3.6 orchestration/task_scheduler/).

Flow:
    Step 1 (CmdExec) -> fetch_fx_rates.py       (pull daily FX rates from API)
    Step 2 (CmdExec) -> generate_web_event.py   (simulate clickstream events)
    Step 3 (T-SQL)   -> EXEC dbo.run_full_pipeline (bronze + silver loads)
    On completion    -> email/slack notification to Operator on failure

Usage (on a supported edition):
    Run this script once to create and schedule the job.
===============================================================================
*/

-- 1. Enable Agent XPs (Standard/Enterprise only)
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Agent XPs', 1;
RECONFIGURE;

-- 2. Create an Operator (who receives notifications)
EXEC msdb.dbo.sp_add_operator
    @name = 'Olamide',
    @email_address = 'akannilmd@gmail.com';

-- 3. Create the Job
EXEC msdb.dbo.sp_add_job
    @job_name = 'Shop360Bike_Full_Pipeline';

-- 4. Step 1: Fetch FX Rates
EXEC msdb.dbo.sp_add_jobstep
    @job_name = 'Shop360Bike_Full_Pipeline',
    @step_id = 1,
    @step_name = 'Fetch FX Rates',
    @subsystem = 'CmdExec',
    @command = 'python "C:\Users\lamid\Documents\db\shop360bike\fetch_fx_rates.py"',
    @on_success_action = 3,  -- go to next step
    @on_fail_action = 2;     -- quit reporting failure

-- 5. Step 2: Generate Web Events
EXEC msdb.dbo.sp_add_jobstep
    @job_name = 'Shop360Bike_Full_Pipeline',
    @step_id = 2,
    @step_name = 'Generate Web Events',
    @subsystem = 'CmdExec',
    @command = 'python "C:\Users\lamid\Documents\db\shop360bike\generate_web_event.py"',
    @on_success_action = 3,
    @on_fail_action = 2;

-- 6. Step 3: Run SQL Pipeline
EXEC msdb.dbo.sp_add_jobstep
    @job_name = 'Shop360Bike_Full_Pipeline',
    @step_id = 3,
    @step_name = 'Run SQL Pipeline',
    @subsystem = 'TSQL',
    @command = 'USE DataWarehouse; EXEC dbo.run_full_pipeline;',
    @database_name = 'DataWarehouse';

-- 7. Set the job's starting step
EXEC msdb.dbo.sp_update_job
    @job_name = 'Shop360Bike_Full_Pipeline',
    @start_step_id = 1;

-- 8. Create the Schedule (daily at 2:00 AM)
EXEC msdb.dbo.sp_add_schedule
    @schedule_name = 'Nightly_Refresh',
    @freq_type = 4,              -- daily
    @freq_interval = 1,
    @active_start_time = 020000; -- 02:00:00

-- 9. Attach schedule to job
EXEC msdb.dbo.sp_attach_schedule
    @job_name = 'Shop360Bike_Full_Pipeline',
    @schedule_name = 'Nightly_Refresh';

-- 10. Enable email notification on failure
EXEC msdb.dbo.sp_update_job
    @job_name = 'Shop360Bike_Full_Pipeline',
    @notify_email_operator_name = 'Olamide',
    @notify_level_email = 2;  -- 1=success, 2=failure, 3=always

-- 11. Attach job to the local server (required step, easy to forget)
EXEC msdb.dbo.sp_add_jobserver
    @job_name = 'Shop360Bike_Full_Pipeline',
    @server_name = '(local)';
    @notify_level_email = 2;  -- notify on failure (3 = always, 1 = success only)
