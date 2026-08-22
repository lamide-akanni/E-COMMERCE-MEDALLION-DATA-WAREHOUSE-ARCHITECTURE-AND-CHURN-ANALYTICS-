CREATE OR ALTER VIEW gold.fact_web_events AS
SELECT
    sw.event_id                        AS event_id,
    sw.date_key                        AS date_key,
    sw.event_timestamp                 AS event_timestamp,
    sw.session_id                      AS session_id,
    sw.event_type                      AS event_type,
    pr.product_key                     AS product_key,      -- NULL for page_view/search
    cu.customer_key                    AS customer_key,     -- NULL for anonymous
    sw.search_term                     AS search_term
FROM silver.web_events sw
LEFT JOIN gold.dim_products pr
    ON sw.product_number = pr.product_number
LEFT JOIN gold.dim_customers cu
    ON sw.customer_id = cu.customer_id;
GO
