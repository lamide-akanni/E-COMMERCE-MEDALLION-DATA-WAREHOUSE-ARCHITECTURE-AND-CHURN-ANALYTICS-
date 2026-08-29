-- ============================================================
-- 1. gold.dim_customers
-- Source: silver.crm_cust_info + silver.erp_cust_az12 + silver.erp_loc_a101
-- ============================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO
CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id)  AS customer_key,
    ci.cst_id                               AS customer_id,
    ci.cst_key                              AS customer_number,
    ci.cst_firstname                        AS first_name,
    ci.cst_lastname                         AS last_name,
    la.cntry                                AS country,
    ci.cst_marital_status                   AS marital_status,
    CASE
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END                                      AS gender,
    ca.bdate                                AS birthdate,
    ci.cst_create_date                      AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la ON ci.cst_key = la.cid;
GO

-- ============================================================
-- 2. gold.dim_products
-- Source: silver.crm_prd_info + silver.erp_px_cat_g1v2
-- ============================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO
CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
    pn.prd_id       AS product_id,
    pn.prd_key      AS product_number,
    pn.prd_nm       AS product_name,
    pn.cat_id       AS category_id,
    pc.cat          AS category,
    pc.subcat       AS subcategory,
    pc.maintenance  AS maintenance,
    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL;
GO

-- ============================================================
-- 3. gold.dim_currency
-- Source: none (hardcoded static list — no source system provides this)
-- ============================================================
IF OBJECT_ID('gold.dim_currency', 'V') IS NOT NULL
    DROP VIEW gold.dim_currency;
GO
CREATE VIEW gold.dim_currency AS
SELECT
    ROW_NUMBER() OVER (ORDER BY currency_code) AS currency_key,
    currency_code,
    currency_name
FROM (
    VALUES
        ('GBP', 'British Pound'),
        ('USD', 'US Dollar'),
        ('EUR', 'Euro'),
        ('CAD', 'Canadian Dollar'),
        ('AUD', 'Australian Dollar')
) c(currency_code, currency_name);
GO

-- ============================================================
-- 4. gold.fact_sales
-- Source: silver.crm_sales_details, joined to dim_products + dim_customers
-- ============================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO
CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num  AS order_number,
    pr.product_key  AS product_key,
    cu.customer_key AS customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu ON sd.sls_cust_id = cu.customer_id;
GO

-- ============================================================
-- 5. gold.fact_inventory
-- Source: silver.inventory, joined to dim_products
-- ============================================================
IF OBJECT_ID('gold.fact_inventory', 'V') IS NOT NULL
    DROP VIEW gold.fact_inventory;
GO
CREATE VIEW gold.fact_inventory AS
SELECT
    pr.product_key  AS product_key,
    si.date_key     AS date_key,
    si.warehouse    AS warehouse,
    si.stock_qty    AS stock_quantity,
    si.reorder_level AS reorder_level
FROM silver.inventory si
LEFT JOIN gold.dim_products pr ON si.product_number = pr.product_number;
GO

-- ============================================================
-- 6. gold.fact_fx_rates
-- Source: silver.fx_rates, joined to dim_currency TWICE (role-playing dimension)
-- ============================================================
IF OBJECT_ID('gold.fact_fx_rates', 'V') IS NOT NULL
    DROP VIEW gold.fact_fx_rates;
GO
CREATE VIEW gold.fact_fx_rates AS
SELECT
    sf.date_key                     AS date_key,
    bc.currency_key                 AS base_currency_key,
    tc.currency_key                 AS target_currency_key,
    sf.exchange_rate                AS exchange_rate
FROM silver.fx_rates sf
LEFT JOIN gold.dim_currency bc ON sf.base_currency = bc.currency_code
LEFT JOIN gold.dim_currency tc ON sf.target_currency = tc.currency_code;
GO

-- ============================================================
-- 7. gold.fact_web_events
-- Source: silver.web_events, joined to dim_products + dim_customers (both nullable)
-- ============================================================
IF OBJECT_ID('gold.fact_web_events', 'V') IS NOT NULL
    DROP VIEW gold.fact_web_events;
GO
CREATE VIEW gold.fact_web_events AS
SELECT
    sw.event_id        AS event_id,
    sw.date_key         AS date_key,
    sw.event_timestamp  AS event_timestamp,
    sw.session_id       AS session_id,
    sw.event_type       AS event_type,
    pr.product_key      AS product_key,
    cu.customer_key      AS customer_key,
    sw.search_term       AS search_term
FROM silver.web_events sw
LEFT JOIN gold.dim_products pr ON sw.product_number = pr.product_number
LEFT JOIN gold.dim_customers cu ON sw.customer_id = cu.customer_id;
GO

-- ============================================================
-- 8. gold.vw_fx_rates_readable
-- Source: gold.fact_fx_rates + gold.dim_currency (reporting/convenience view)
-- ============================================================
IF OBJECT_ID('gold.vw_fx_rates_readable', 'V') IS NOT NULL
    DROP VIEW gold.vw_fx_rates_readable;
GO
CREATE VIEW gold.vw_fx_rates_readable AS
SELECT
    fr.date_key,
    bc.currency_code AS base_currency,
    tc.currency_code AS target_currency,
    fr.exchange_rate
FROM gold.fact_fx_rates fr
JOIN gold.dim_currency bc ON fr.base_currency_key = bc.currency_key
JOIN gold.dim_currency tc ON fr.target_currency_key = tc.currency_key;
GO

IF OBJECT_ID('gold.dim_security', 'V') IS NOT NULL
    DROP VIEW gold.dim_security;
GO
CREATE VIEW gold.dim_security AS
SELECT user_email, user_name, job_role, country
FROM (
    VALUES
        ('john.smith@shop360bike.com',   'John Smith',   'Location Marketing Manager', 'United States'),
        ('hans.muller@shop360bike.com',  'Hans Muller',  'Location Marketing Manager', 'Germany'),
        ('marie.dupont@shop360bike.com', 'Marie Dupont', 'Location Marketing Manager', 'France'),
        ('tom.hughes@shop360bike.com',   'Tom Hughes',   'Location Marketing Manager', 'United Kingdom'),
        ('sarah.walker@shop360bike.com', 'Sarah Walker', 'Location Marketing Manager', 'Australia'),
        ('luc.roy@shop360bike.com',      'Luc Roy',      'Location Marketing Manager', 'Canada'),
        ('emma.clarke@shop360bike.com',  'Emma Clarke',  'Global Marketing Manager',   'United States'),
        ('emma.clarke@shop360bike.com',  'Emma Clarke',  'Global Marketing Manager',   'United Kingdom'),
        ('emma.clarke@shop360bike.com',  'Emma Clarke',  'Global Marketing Manager',   'Germany'),
        ('emma.clarke@shop360bike.com',  'Emma Clarke',  'Global Marketing Manager',   'France'),
        ('emma.clarke@shop360bike.com',  'Emma Clarke',  'Global Marketing Manager',   'Australia'),
        ('emma.clarke@shop360bike.com',  'Emma Clarke',  'Global Marketing Manager',   'Canada')
) s(user_email, user_name, job_role, country);
GO
