SELECT * FROM amazon_delivery LIMIT 20;

-- 1.What percentage of total deliveries are late?
SELECT COUNT(*) AS total_orders, ROUND(AVG(is_late::INT) * 100, 2) AS late_delivery_percent
FROM amazon_delivery;

-- 2.What is the average delivery duration in hours across all orders?
SELECT COUNT(*) total_orders, ROUND(AVG(delivery_hours::INT),2) AS avg_delivery_hour
FROM amazon_delivery;

-- 3.Which traffic conditions cause the highest late delivery rate?
SELECT traffic, COUNT(*) AS total_orders, ROUND(AVG(is_late::INT) * 100, 2) AS late_delivery_percent
FROM amazon_delivery
GROUP BY traffic
HAVING COUNT(*) >= 50
ORDER BY late_delivery_percent DESC;

-- 4.How does weather impact late deliveries?
SELECT weather, COUNT(*) AS total_orders, ROUND(AVG(delivery_hours::INT),2) AS avg_delivery_hours,
ROUND(AVG(CASE WHEN is_late::INT = 1 THEN 1 ELSE 0 END) * 100, 2) AS late_delivery_perc
FROM amazon_delivery
GROUP BY weather
HAVING COUNT(*) > 50
ORDER BY late_delivery_perc DESC;

-- 5.Which vehicle types deliver orders fastest on average?
SELECT vehicle, COUNT(*) AS total_orders, ROUND(AVG(delivery_hours::INT),2) AS avg_delivery_hours,
ROUND(AVG(is_late::INT) * 100, 2) AS late_delivery_percent
FROM amazon_delivery
GROUP BY vehicle
HAVING COUNT(*) > 50
ORDER BY avg_delivery_hours ASC;

-- 6.Which vehicle types have the highest late delivery rate?
SELECT vehicle, COUNT(*) AS total_orders, ROUND(AVG(is_late::INT) * 100, 2) AS late_delivery_percent
FROM amazon_delivery
GROUP BY vehicle
HAVING COUNT(*) > 50
ORDER BY late_delivery_percent DESC;

-- 7.Which areas have the worst SLA performance?
SELECT area, COUNT(*) AS total_orders, ROUND(AVG(is_late::INT) * 100, 2) AS late_delivery_percent
FROM amazon_delivery
GROUP BY area
HAVING COUNT(*) > 50
ORDER BY late_delivery_percent DESC;

-- 8.Does agent rating affect probability of late delivery?
SELECT rating_buckets, COUNT(*) AS total_orders, ROUND(AVG(delivery_hours::INT),2) AS avg_delivery_hours,
ROUND(AVG(is_late::INT) * 100, 2) AS late_delivery_percent
FROM amazon_delivery
GROUP BY rating_buckets
ORDER BY avg_delivery_hours;

-- 9.How are orders distributed across delivery speed categories?
SELECT delivery_speed, COUNT(*) AS total_orders, ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(),2) AS order_percentage
FROM amazon_delivery
GROUP BY delivery_speed
ORDER BY total_orders DESC;

-- 10.Are orders placed at certain hours more likely to be late?
ALTER TABLE amazon_delivery
ADD COLUMN clean_order_time TIME;

UPDATE amazon_delivery
SET clean_order_time = CASE WHEN TRIM(order_time) IN ('NaN', '') THEN NULL ELSE TRIM(order_time)::TIME END;

SELECT EXTRACT(HOUR FROM (clean_order_time)::TIME) AS order_hour, COUNT(*) AS total_orders, 
ROUND(AVG(delivery_hours::INT),2) AS avg_delivery_hours,
ROUND(AVG(is_late::INT) * 100, 2) AS late_delivery_percent
FROM amazon_delivery
WHERE clean_order_time IS NOT NULL
GROUP BY order_hour
ORDER BY order_hour DESC;

-- 11.Which combination of traffic + weather creates the highest delays?
SELECT traffic, weather, COUNT(*) AS total_orders, ROUND(AVG(is_late::INT) * 100, 2) AS late_delivery_percent
FROM amazon_delivery
GROUP BY traffic, weather
HAVING COUNT(*) > 50
ORDER BY late_delivery_percent DESC;

SELECT * FROM amazon_delivery LIMIT 20;
-- 12.Can we see key KPIs in one query for dashboard cards?
SELECT COUNT(*) AS total_orders, ROUND(AVG(delivery_hours::INT),2) AS avg_delivery_hours,
ROUND(AVG(is_late::INT) * 100, 2) AS late_percent
FROM amazon_delivery;
