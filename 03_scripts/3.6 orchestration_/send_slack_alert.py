# send_slack_alert.py 
# posts a Slack notification (via webhook) reporting pipeline success/failure.
# Called as the final step of run_pipeline.bat; status ("SUCCESS" or a failure message) is passed as an argument.

import sys
import os
import requests
from dotenv import load_dotenv

load_dotenv()
WEBHOOK_URL = os.getenv("SLACK_WEBHOOK_URL")

status = sys.argv[1] if len(sys.argv) > 1 else "UNKNOWN"

if status == "SUCCESS":
    message = "✅ Shop360Bike pipeline completed successfully."
else:
    message = f"❌ Shop360Bike pipeline {status}"

response = requests.post(WEBHOOK_URL, json={"text": message})
print(f"Slack notification sent: {status} (HTTP {response.status_code})")
