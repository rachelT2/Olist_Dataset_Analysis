CREATE VIEW rfm_base_view AS
SELECT 
    c.customer_unique_id,
    o.order_id,
    o.order_purchase_date,
    SUM(oi.price + oi.freight_value) AS order_total
FROM orders_table o
INNER JOIN customers_table c 
    ON o.customer_id = c.customer_id
INNER JOIN order_items_table oi 
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'  -- removed cancelled and unavailable order
GROUP BY c.customer_unique_id, o.order_id, o.order_purchase_date;


SELECT * 
FROM rfm_base_view
LIMIT 10;

CREATE TABLE rfm_data AS
SELECT customer_unique_id,
	DATEDIFF(
		(SELECT MAX(order_purchase_date) FROM rfm_base_view),
        MAX(order_purchase_date)
    ) AS recency,
    
    COUNT(DISTINCT order_id)AS frequency,
    SUM(order_total)AS monetary
FROM rfm_base_view
GROUP BY customer_unique_id;

SELECT * 
FROM rfm_data
LIMIT 10;





