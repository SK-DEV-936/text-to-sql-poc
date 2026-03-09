# Schema and Table Definitions
The 'orders' table represents regular orders placed by customers. It contains various columns that provide detailed information about each order, including unique identifiers, timestamps for different stages of the order process, customer details, payment information, and status flags. This table is essential for tracking the lifecycle of an order from placement to delivery or cancellation.

# Relationships and Joins
The 'order_details' table contains specific details about each item within an order. It is linked to the 'orders' table through the 'order_code' column in 'order_details' and the 'code' column in 'orders'. This relationship allows for the retrieval of detailed item information for each order, enabling comprehensive order analysis and reporting.

To analyze revenue, cancellations, and top-selling items, join the 'orders' table with the 'order_details' table using the condition 'order_details.order_code = orders.code'. This join allows you to aggregate order amounts and item details effectively.

To evaluate customer engagement, join the 'orders' table with the 'order_history' table using 'order_history.order_id = orders.code'. This allows for tracking repeat orders and customer behavior over time.

If the user asks for 'catering orders', you must query the `catering_orders` and `catering_order_details` tables instead of `orders`. If the user asks for 'all orders' globally across both types, you must use a UNION ALL statement to combine data from `orders` and `catering_orders`.

# Synonyms and Terminology
When focusing on cancellations, you MUST filter the 'orders' table using exactly `order_status = 'cancelled'` (spelled with two L's). Do NOT use 'canceled' or 'auto_canceled'.

To calculate total revenue from orders, sum the 'grand_total' column in the 'orders' table. This provides the total income generated from all completed orders.

To find the top-selling items, group the results from the 'order_details' table by the item identifier (e.g., 'item_id') and sum the 'quantity' sold. This will yield a list of items sorted by sales volume.

For tracking delivery issues, check the 'delivery_api_failed' column in the 'orders' table. A value of 'true' indicates a failure in the delivery API, which may require further investigation.

To analyze the impact of discounts, filter the 'orders' table by 'coupon_amount' greater than zero. This will show all orders that utilized a discount coupon, allowing for analysis of discount effectiveness.

To assess the average delivery charge, calculate the average of the 'dc' (delivery charge) column in the 'orders' table. This provides insights into delivery pricing trends.

When a user asks for 'dinner orders' or 'dinner sales', this specifically means orders placed after 5 PM. You MUST filter the `orders` table using exactly `HOUR(created_date) >= 17`.

When a user asks for 'lunch orders' or 'lunch sales', this specifically means orders placed between 11:30 AM and 3 PM. You MUST filter the `orders` table using exactly `TIME(created_date) BETWEEN '11:30:00' AND '15:00:00'`.

# Metrics and Calculations
To calculate valid 'Realized Revenue' or 'Net Revenue', you MUST ALWAYS filter the `orders` table by `order_status = 'completed'`. You must exclude 'cancelled' or 'returned' orders unless specifically asked about them. Total Revenue is the sum of the `grand_total` column for completed orders.

To calculate the 'Preparation Time' of an order, find the difference in minutes between the `order_preparing_at` and `order_prepared_at` timestamps using TIMESTAMPDIFF(MINUTE, order_preparing_at, order_prepared_at). 'Delivery Time' is the difference between `order_pickup_at` and `order_delivered_at`.

When a user asks for 'today', filter using DATE(created_date) = CURDATE(). For 'yesterday', use DATE(created_date) = CURDATE() - INTERVAL 1 DAY. For 'this month', use MONTH(created_date) = MONTH(CURDATE()) AND YEAR(created_date) = YEAR(CURDATE()).

To analyze where orders are originating from (e.g., Web vs App vs POS), group the `orders` table by the `order_source` column.

To find out how much money was refunded by an admin, inspect the `admin_refund` column. To see the total discount allowed, aggregate the `coupon_amount` and `admin_discount` columns.
