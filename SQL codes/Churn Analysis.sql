-- ====================================================================
-- CHURN ANALYSIS FEATURE EXTRACTION FROM OLIST_SCHEMA
-- One row per one cutomer_unique_id
-- =====================================================================


-- ====================================================================
-- 1.Base order-level view (RFM foundation only for delivered only)
-- columns : customer_unique_id, order_id, order_purchase_date, order_estimated_delivery_date, order_delivered_customer_date,
-- total price, total_order_price and total_freight_price

-- joined customers_table and order_items_table  to the base table (orders_table) internally.
-- =====================================================================
CREATE OR REPLACE VIEW rfm_base_churn AS
SELECT 
	c.customer_unique_id,
    o.order_id,
    o.order_purchase_date,
    o.order_estimated_delivery_date,
    o.order_delivered_customer_date,
    SUM(oi.price) AS order_price_total,
    SUM(oi.freight_value) AS order_freight_total,
    SUM(oi.price + oi.freight_value) AS order_total
FROM orders_table o
INNER JOIN customers_table c
	ON o.customer_id = c.customer_id
INNER JOIN order_items_table oi
	ON o.order_id = oi.order_id
GROUP BY 
	c.customer_unique_id,
    o.order_id,
    o.order_purchase_date, -- for rfm calculation and avg delivery days and delivery delay
    o.order_estimated_delivery_date, -- to calculate delivery delay
    o.order_delivered_customer_date; -- to calculate avg delivery days

-- Viewing the rfm_base_churn table
SELECT DISTINCT (order_status) FROM rfm_base_churn;


-- ====================================================================
-- 2.RFM : Recency, Frequency, Monetary
-- =====================================================================

CREATE OR REPLACE VIEW rfm_core AS
SELECT 
	customer_unique_id,
	DATEDIFF(
		(SELECT MAX(order_purchase_date) FROM rfm_base_churn),
        MAX(order_purchase_date)
	) AS recency,
    COUNT(order_purchase_date)AS frequency,
    SUM(order_total) AS monetary,
    AVG(order_total) AS avg_order_value
    
FROM rfm_base_churn
GROUP BY customer_unique_id;

-- Viewing and Checking rfm_core table
SELECT * FROM rfm_core LIMIT 10;


-- ====================================================================
-- 3. Delivery performance per customer
-- =====================================================================

CREATE VIEW delivery_features AS
SELECT 
	customer_unique_id,
    AVG(DATEDIFF(order_delivered_customer_date, order_purchase_date)) AS avg_delivery_days,
    AVG(DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)) AS avg_delivery_delay,
    SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
		THEN 1 ELSE 0 END) * 1.0/ COUNT(*) AS pct_late_orders
FROM rfm_base_churn
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY customer_unique_id;

-- Checking delivery_features
SELECT * FROM delivery_features LIMIT 10;

-- There is no negative values in delivery days
SELECT count(*) 
FROM delivery_features
WHERE avg_delivery_days<0;

-- Negative delivery delay means there is no delay.
SELECT count(*) 
FROM delivery_features
WHERE avg_delivery_delay<0;


-- ====================================================================
-- 4. Order reviews score per unique customer id from order reviews table
-- =====================================================================

CREATE OR REPLACE VIEW review_feature AS
SELECT 
	c.customer_unique_id,
    AVG(r.review_score) AS avg_review_score
FROM order_reviews_table r
INNER JOIN orders_table o 
	ON r.order_id = o.order_id
INNER JOIN customers_table c
	ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id;

SELECT * FROM review_feature LIMIT 10;

-- ====================================================================
-- 5. Cancelled order
-- =====================================================================

CREATE VIEW cancellation_feautre AS
SELECT 
	c.customer_unique_id,
    SUM(CASE WHEN o.order_status = "canceled" THEN 1 ELSE 0 END) AS num_cancelled_orders,
    COUNT(*) AS total_orders_all_status
FROM orders_table o
INNER JOIN customers_table c
	ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id;

SELECT * FROM cancellation_feautre 
WHERE num_cancelled_orders >=1
LIMIT 10;


-- ====================================================================
-- 6. Pyament behaviour per customer
-- =====================================================================

CREATE OR REPLACE VIEW payment_feature AS
SELECT 
	c.customer_unique_id,
    AVG(op.payment_installments) AS avg_payment_installments,
    MAX(op.payment_type) AS payment_type_mode
    
FROM orders_table o
INNER JOIN order_payment_table op
	ON o.order_id = op.order_id
INNER JOIN customers_table c
	ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id;

SELECT * FROM payment_feature LIMIT 10;


-- ====================================================================
-- 7. Final table: combine everything into one churn feature table
-- =====================================================================

CREATE OR REPLACE VIEW churn_features AS
SELECT 
	r.customer_unique_id,
    r.recency,
    r.frequency,
    r.monetary,
    r.avg_order_value,
    
    d.avg_delivery_days,
    d.avg_delivery_delay,
    d.pct_late_orders,
    
    re.avg_review_score,
    
    cf.num_cancelled_orders,
    cf.total_orders_all_status,
    
    pf.avg_payment_installments,
    pf.payment_type_mode,
    
    -- is_churned feature
    CASE WHEN r.recency >90 THEN 1 ELSE 0 END AS is_churned

FROM rfm_core r
LEFT JOIN delivery_features d 
	ON r.customer_unique_id = d.customer_unique_id
LEFT JOIN review_feature re 
	ON r.customer_unique_id = re.customer_unique_id
LEFT JOIN cancellation_feautre cf 
	ON r.customer_unique_id = cf.customer_unique_id
LEFT JOIN payment_feature pf
	ON r.customer_unique_id = pf.customer_unique_id;


-- Sanity check
SELECT * FROM churn_features LIMIT 10;

	

















