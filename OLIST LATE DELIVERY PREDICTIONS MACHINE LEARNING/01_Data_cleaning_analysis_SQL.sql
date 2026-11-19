use OLISTDB;
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO
SELECT TOP 1 *
FROM olist_orders_dataset;
SELECT COUNT(*),
COUNT(DISTINCT order_id) AS unique_order_id
FROM olist_orders_dataset;
SELECT COUNT(*),
COUNT(DISTINCT order_id) AS unique_orders
FROM olist_order_items_dataset;
GO
SELECT order_id,
ROUND(SUM(Price),2) AS total_price,
ROUND(AVG(Price),2) AS avg_price,
COUNT(*) AS total
FROM olist_order_items_dataset
GROUP BY order_id
ORDER BY total_price DESC;
GO
SELECT
order_status,
COUNT(*) AS missing_rows
FROM olist_orders_dataset o
LEFT JOIN olist_order_items_dataset oi
ON o.order_id=oi.order_id
WHERE oi.order_id IS NULL
GROUP BY order_status
ORDER BY missing_rows;
SELECT order_status,
COUNT(*) AS totals
FROM olist_orders_dataset
GROUP BY order_status;
GO
SELECT COUNT(*) AS order_delivered,
COUNT(order_delivered_customer_date) AS actual_delivery_date,
COUNT(order_estimated_delivery_date) AS estimated_delivery_date
FROM olist_orders_dataset
WHERE order_status = 'delivered';
GO
SELECT COUNT(*) AS total_orders,
SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) AS is_late
FROM olist_orders_dataset
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL
AND order_estimated_delivery_date IS NOT NULL;
go
SELECT TOP 1 * FROM olist_customers_dataset;
SELECT TOP 1 * FROM olist_sellers_dataset;
GO
SELECT
COUNT(*) AS total_orders,
SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) AS late_orders,
SUM(CASE WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 1 ELSE 0 END) AS ontime_orders
FROM olist_orders_dataset
WHERE order_status = 'delivered';
GO
SELECT order_id,
CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END AS late_delivery
FROM olist_orders_dataset
WHERE order_status = 'delivered';

-- CTE 1: CUSTOMER FEATURES
WITH customer_features AS (
SELECT
customer_id,
customer_unique_id,
customer_city,
customer_state
FROM olist_customers_dataset
),
-- CTE 2: ORDER ITEM FEATURES
 order_item_features AS (
 SELECT 
order_id,
COUNT(*) AS total_items,
COUNT(DISTINCT seller_id) AS unique_seller_id,
SUM(TRY_CONVERT(DECIMAL(18,2),Price)) AS total_price,
SUM(TRY_CONVERT(DECIMAL(18,2),Freight_value)) AS total_freight_value,
AVG(TRY_CONVERT(DECIMAL(18,2),Price)) AS avg_price
FROM olist_order_items_dataset
GROUP BY order_id
),
-- CTE 3: PRODUCT FEATURES
product_features AS (
SELECT 
oi.order_id,
COUNT(*) AS product_rows,
SUM(TRY_CONVERT(FLOAT,p.product_weight_g)) AS total_weight,
SUM(TRY_CONVERT(FLOAT,p.product_height_cm)) AS total_height,
SUM(TRY_CONVERT(FLOAT,p.product_length_cm)) AS total_length,
SUM(TRY_CONVERT(FLOAT,p.product_width_cm)) AS total_width,
MAX(TRY_CONVERT(FLOAT,p.product_weight_g)) AS max_weight,
MAX(TRY_CONVERT(FLOAT,p.product_length_cm)) AS max_length,
MAX(TRY_CONVERT(FLOAT,p.product_width_cm)) AS max_width,
MAX(TRY_CONVERT(FLOAT,p.product_height_cm)) AS max_heigth,
AVG(TRY_CONVERT(FLOAT,p.product_height_cm)) AS avg_heigth,
AVG(TRY_CONVERT(FLOAT,p.product_length_cm)) AS avg_length,
AVG(TRY_CONVERT(FLOAT,p.product_width_cm)) AS avg_width,
AVG(TRY_CONVERT(FLOAT,p.product_weight_g)) AS avg_weight
FROM olist_order_items_dataset oi
LEFT JOIN olist_products_dataset p
ON oi.product_id=p.product_id
GROUP BY oi.order_id
),
--CTE 4: PAYMENT FEATURES
payment_features AS (
SELECT 
order_id,
COUNT(*) AS total_payments,
SUM(TRY_CONVERT(DECIMAL(18,2),payment_value)) AS total_value,
MAX(TRY_CONVERT(INT, payment_installments)) AS max_installments
FROM olist_order_payments_dataset
GROUP BY order_id
),
--CTE 5: SELLER FEATURES
seller_features AS(
SELECT
oi.order_id,
COUNT(DISTINCT oi.seller_id) AS total_sellers,
COUNT(DISTINCT s.seller_state) AS seller_state_count,
COUNT(DISTINCT CASE WHEN c.customer_state = s.seller_state THEN oi.seller_id END) AS same_state_seller_count
FROM olist_order_items_dataset oi
JOIN olist_orders_dataset o
ON oi.order_id=o.order_id
LEFT JOIN olist_sellers_dataset s
ON oi.seller_id=s.seller_id
LEFT JOIN olist_customers_dataset c
ON o.customer_id=c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY oi.order_id
),
--CTE 6: ORDER FEATURES
order_features AS (
SELECT
--order identification
o.order_id,
o.customer_id,
--order timing
o.order_purchase_timestamp,
o.order_estimated_delivery_date,
--target variable
CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
THEN 1 ELSE 0 END AS is_late,
--customer features
c.customer_city,
c.customer_state,
--order item features
oi.total_items,
oi.total_price,
oi.total_freight_value,
oi.avg_price,
--product features
p.product_rows,
p.total_weight,
p.total_height,
p.total_length,
p.total_width,
p.max_heigth,
p.max_weight,
p.max_length,
p.max_width,
p.avg_weight,
p.avg_heigth,
p.avg_length,
p.avg_width,
--payment features
pay.total_payments,
pay.total_value,
pay.max_installments,
--seller features
s.total_sellers,
s.seller_state_count,
s.same_state_seller_count

FROM olist_orders_dataset o
JOIN customer_features c
ON o.customer_id=c.customer_id

LEFT JOIN order_item_features oi
ON o.order_id=oi.order_id

LEFT JOIN product_features p
ON o.order_id=p.order_id

LEFT JOIN payment_features pay
ON o.order_id=pay.order_id

LEFT JOIN seller_features s
ON o.order_id=s.order_id

WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
)
SELECT * 
INTO master_late_delivery
FROM order_features;

SELECT TOP 5 * FROM master_late_delivery;