-- Simple seed data for local testing.

INSERT INTO merchants (name, city, status)
VALUES
  ('Demo Merchant A', 'San Francisco', 'active'),
  ('Demo Merchant B', 'New York', 'active'),
  ('Demo Merchant C', 'Los Angeles', 'inactive');

INSERT INTO customers (customer_segment)
VALUES
  ('new'),
  ('loyal'),
  ('churn_risk');

INSERT INTO orders (merchant_id, customer_id, order_status, total_amount, created_at)
VALUES
  (1, 1, 'completed', 25.50, DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (1, 2, 'completed', 40.00, DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (2, 3, 'cancelled', 15.75, DATE_SUB(NOW(), INTERVAL 1 DAY)),
  (2, 1, 'completed', 60.10, DATE_SUB(NOW(), INTERVAL 2 DAY)),
  (3, 2, 'completed', 10.00, DATE_SUB(NOW(), INTERVAL 20 DAY));

INSERT INTO order_items (order_id, menu_item_id, quantity, item_price)
VALUES
  (1, 101, 2, 10.00),
  (1, 102, 1, 5.50),
  (2, 103, 4, 10.00),
  (3, 104, 1, 15.75),
  (4, 105, 3, 20.03),
  (5, 106, 1, 10.00);

