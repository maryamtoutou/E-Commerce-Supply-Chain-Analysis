-- ==============================================================================
-- PROJECT: E-Commerce Supply Chain Bottleneck Analysis (Olist Dataset)
-- ROLE: Data Analyst
-- OBJECTIVE: Identify the root causes of severe delivery delays and pinpoint 
--            whether the bottleneck originates from warehouse operations, 
--            the logistics carrier, or specific sellers/regions.
-- ==============================================================================

/* ---------------------------------------------------------------------------
   PHASE 1: DATA DISCOVERY & FILTERING
   Isolating the problematic orders that never reached the customers.
--------------------------------------------------------------------------- */

-- Q1: How many orders are currently stuck in the pipeline and what is their status?
SELECT 
    order_status, 
    COUNT(order_id) AS total_delayed_orders
FROM `data-analysis-projects-496119.olist_delivery_analysis.orders`
WHERE order_delivered_customer_date IS NULL
GROUP BY order_status
ORDER BY total_delayed_orders DESC;


/* ---------------------------------------------------------------------------
   PHASE 2: ROOT CAUSE ANALYSIS (WAREHOUSE VS. CARRIER)
   Evaluating processing times to find the exact point of failure.
--------------------------------------------------------------------------- */

-- Q2: Is the warehouse taking too long to hand over orders to the carrier?
-- Insight: Calculates average days taken by the warehouse to dispatch overdue orders.
SELECT
    order_status,
    COUNT(order_id) AS order_count,
    ROUND(AVG(TIMESTAMP_DIFF(order_delivered_carrier_date, order_purchase_timestamp, DAY)), 1) AS avg_warehouse_days
FROM `data-analysis-projects-496119.olist_delivery_analysis.orders`
WHERE order_delivered_customer_date IS NULL 
  AND order_estimated_delivery_date < (SELECT MAX(order_purchase_timestamp) FROM `data-analysis-projects-496119.olist_delivery_analysis.orders`)
GROUP BY order_status
ORDER BY order_count DESC;


-- Q3: How long have carriers held onto 'shipped' orders without delivering them?
-- Insight: This reveals the carrier delay compared to the most recent database timestamp.
SELECT
    order_status,
    COUNT(order_id) AS order_count,
    ROUND(AVG(TIMESTAMP_DIFF(
        (SELECT MAX(order_purchase_timestamp) FROM `data-analysis-projects-496119.olist_delivery_analysis.orders`), 
        order_delivered_carrier_date, DAY)), 1) AS avg_carrier_delay_days
FROM `data-analysis-projects-496119.olist_delivery_analysis.orders`
WHERE order_delivered_customer_date IS NULL
GROUP BY order_status
ORDER BY order_count DESC;


/* ---------------------------------------------------------------------------
   PHASE 3: GEO-ANALYSIS & FAULT CATEGORIZATION
   Pinpointing where the failures are happening and labeling the responsible party.
--------------------------------------------------------------------------- */

-- Q4: Which cities are experiencing the highest volume of undelivered orders?
SELECT 
    c.customer_city, 
    COUNT(o.order_id) AS delayed_orders_count
FROM `data-analysis-projects-496119.olist_delivery_analysis.orders` o
LEFT JOIN `data-analysis-projects-496119.olist_delivery_analysis.customers` c
    ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NULL
GROUP BY c.customer_city
ORDER BY delayed_orders_count DESC
LIMIT 10;
 -- Displaying top 10 worst performing cities

-- Q5: Categorizing the root cause of the delay (Carrier Fault vs. Internal Fault) per order.
SELECT
    c.customer_city,
    o.order_id,
    CASE
        WHEN o.order_status = 'shipped' THEN 'Carrier Fault'
        ELSE 'Internal Fault'
    END AS fault_type
FROM `data-analysis-projects-496119.olist_delivery_analysis.orders` o
LEFT JOIN `data-analysis-projects-496119.olist_delivery_analysis.customers` c
    ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NULL;


/* ---------------------------------------------------------------------------
   PHASE 4: DEEP DIVE (HYPOTHESIS TESTING)
   Testing if delays in top cities are caused by specific sellers or freight values.
--------------------------------------------------------------------------- */

-- Q6: Are the delays in Sao Paulo and Rio caused by specific problematic sellers?
-- Insight: A triple join to prove that delays are widespread across sellers, confirming a systemic carrier issue.
SELECT 
    c.customer_city, 
    oi.seller_id, 
    COUNT(o.order_id) AS delayed_boxes
FROM `data-analysis-projects-496119.olist_delivery_analysis.orders` o
LEFT JOIN `data-analysis-projects-496119.olist_delivery_analysis.customers` c
    ON o.customer_id = c.customer_id
LEFT JOIN `data-analysis-projects-496119.olist_delivery_analysis.order_items` oi
    ON o.order_id = oi.order_id
WHERE o.order_delivered_customer_date IS NULL
  AND c.customer_city IN ('sao paulo', 'rio de janeiro')
  AND oi.seller_id IS NOT NULL
GROUP BY c.customer_city, oi.seller_id
ORDER BY delayed_boxes DESC;

-- Q7: Correlation between Freight Value (Shipping Cost) and Carrier Delay.
-- Insight: Does paying premium shipping prevent carrier delays?
SELECT
    c.customer_city,
    ROUND(AVG(oi.freight_value), 2) AS avg_freight_paid,
    ROUND(AVG(TIMESTAMP_DIFF(
        (SELECT MAX(order_purchase_timestamp)
         FROM `data-analysis-projects-496119.olist_delivery_analysis.orders`), 
        o.order_delivered_carrier_date, DAY)), 1) AS avg_carrier_delay
FROM `data-analysis-projects-496119.olist_delivery_analysis.orders` o
JOIN `data-analysis-projects-496119.olist_delivery_analysis.customers` c
    ON o.customer_id = c.customer_id
JOIN `data-analysis-projects-496119.olist_delivery_analysis.order_items` oi
    ON o.order_id = oi.order_id
WHERE o.order_delivered_customer_date IS NULL 
  AND o.order_status = 'shipped'
GROUP BY c.customer_city
ORDER BY avg_carrier_delay DESC;
-- Q8: Detailed breakdown of undelivered shipped orders.
-- Insight: Lists individual orders currently with the carrier, including their city, seller, and how many days they've been delayed.

select
 o.order_id,
 o.order_status,
 c.customer_city,
 oi.seller_id, 
 oi.freight_value,
  TIMESTAMP_DIFF(
    (
      SELECT MAX(order_purchase_timestamp)
      FROM `data-analysis-projects-496119.olist_delivery_analysis.orders`
    ),
    o.order_delivered_carrier_date,
    DAY)
    AS carrier_delay_days
FROM `data-analysis-projects-496119.olist_delivery_analysis.orders` o
JOIN `data-analysis-projects-496119.olist_delivery_analysis.customers` c
    ON o.customer_id = c.customer_id
JOIN `data-analysis-projects-496119.olist_delivery_analysis.order_items` oi
    ON o.order_id = oi.order_id
WHERE o.order_delivered_customer_date IS NULL and  o.order_status = 'shipped' ;





