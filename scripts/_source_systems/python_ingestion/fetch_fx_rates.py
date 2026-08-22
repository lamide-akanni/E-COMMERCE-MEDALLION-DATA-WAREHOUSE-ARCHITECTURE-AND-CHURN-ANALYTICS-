import os
import requests
import pyodbc
from dotenv import load_dotenv
from datetime import date

# Load the API key from .env (never hardcoded)
load_dotenv()
API_KEY = os.getenv("FX_API_KEY")

# Step 1: Call the API
BASE_CURRENCY = "GBP"
url = f"https://v6.exchangerate-api.com/v6/{API_KEY}/latest/{BASE_CURRENCY}"

response = requests.get(url)
data = response.json()

if data.get("result") != "success":
    raise Exception(f"API call failed: {data}")

rates = data["conversion_rates"]
rate_date = date.today()

# Step 2: Pick the currencies we care about
target_currencies = ["USD", "EUR", "CAD", "AUD"]

# Step 3: Connect to SQL Server
conn = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost\\SQLEXPRESS;"
    "DATABASE=DataWarehouse;"
    "Trusted_Connection=yes;"
)
cursor = conn.cursor()

# Step 4: Clear old data, insert fresh rates
cursor.execute("TRUNCATE TABLE bronze.fx_rates")

for currency in target_currencies:
    rate = rates.get(currency)
    if rate is not None:
        cursor.execute(
            "INSERT INTO bronze.fx_rates (rate_date, base_currency, target_currency, exchange_rate) VALUES (?, ?, ?, ?)",
            rate_date, BASE_CURRENCY, currency, rate
        )

conn.commit()
cursor.close()
conn.close()

print(f"Loaded {len(target_currencies)} FX rates for {rate_date} into bronze.fx_rates")
