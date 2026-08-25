import random
import uuid
import pyodbc
from datetime import datetime, timedelta

# Connect to SQL Server
conn = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost\\SQLEXPRESS;"
    "DATABASE=DataWarehouse;"
    "Trusted_Connection=yes;"
)
cursor = conn.cursor()

# Pull real product numbers from the warehouse
cursor.execute("SELECT product_number FROM gold.dim_products")
products = [row[0] for row in cursor.fetchall()]

# Pull real customer ids (for the ~30% of sessions that are logged in)
cursor.execute("SELECT customer_id FROM gold.dim_customers")
customers = [row[0] for row in cursor.fetchall()]

search_terms = ["mountain bike", "road bike", "helmet", "bike tire", "cycling gloves",
                "bike lock", "water bottle", "touring bike", "kids bike", "bike lights"]

NUM_SESSIONS = 500
events = []
now = datetime.now()

for _ in range(NUM_SESSIONS):
    session_id = str(uuid.uuid4())[:12]
    # 70% of sessions are anonymous, 30% are logged-in customers
    customer_id = random.choice(customers) if random.random() < 0.3 else None
    session_start = now - timedelta(days=random.randint(0, 6), hours=random.randint(0, 23))
    t = session_start

    # Every session starts with a page_view
    events.append((t, session_id, "page_view", None, customer_id, None))
    t += timedelta(seconds=random.randint(5, 60))

    # 60% chance they search
    if random.random() < 0.6:
        term = random.choice(search_terms)
        events.append((t, session_id, "search", None, customer_id, term))
        t += timedelta(seconds=random.randint(5, 60))

    # 40% chance they view a product
    if random.random() < 0.4:
        product = random.choice(products)
        events.append((t, session_id, "product_view", product, customer_id, None))
        t += timedelta(seconds=random.randint(10, 120))

        # 35% of product viewers add to cart
        if random.random() < 0.35:
            events.append((t, session_id, "add_to_cart", product, customer_id, None))
            t += timedelta(seconds=random.randint(10, 90))

            # 40% of cart-adders click purchase
            if random.random() < 0.4:
                events.append((t, session_id, "purchase_click", product, customer_id, None))

# Load into bronze
cursor.execute("TRUNCATE TABLE bronze.web_events")

cursor.executemany(
    "INSERT INTO bronze.web_events (event_timestamp, session_id, event_type, product_number, customer_id, search_term) "
    "VALUES (?, ?, ?, ?, ?, ?)",
    events
)

conn.commit()
cursor.close()
conn.close()

print(f"Loaded {len(events)} web events across {NUM_SESSIONS} sessions into bronze.web_events")
