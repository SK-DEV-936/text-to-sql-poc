import random
from datetime import datetime
import os

def generate_today_sql():
    # Generate dynamic Base IDs using current timestamp to prevent Primary Key collisions
    base_ts = int(datetime.now().timestamp())
    order_id = base_ts
    order_details_id = base_ts + 100000
    catering_id = base_ts + 200000
    catering_details_id = base_ts + 300000
    history_id = base_ts + 400000
    
    output_lines = ["USE boons;"]
    
    # Target all restaurants
    RESTAURANTS = list(range(1, 21))
    
    # Products
    products = [
        ("Classic Burger", 14.50),
        ("Cheese Pizza", 19.00),
        ("Garden Salad", 10.50),
        ("Spicy Sushi Roll", 24.00),
        ("Cold Brew Coffee", 5.50),
        ("Taco Plate", 15.00)
    ]
    
    override_date = os.getenv("OVERRIDE_DATE")
    if override_date:
        now = datetime.strptime(override_date, '%Y-%m-%d')
    else:
        now = datetime.utcnow()
        
    date_str = now.strftime('%Y-%m-%d %H:%M:%S')
    ts = int(now.timestamp())
    
    for rid in RESTAURANTS:
        # Generate 10 regular orders for today
        for i in range(10):
            item_name, price = random.choice(products)
            qty = random.randint(1, 4)
            total = price * qty
            grand_total = total + 2.0  # tax/fee
            
            code = f"TODAY-REG-{rid}-{i}-{ts}"
            customer_id = rid  # Matching customer_id to restaurant_id for RLS consistency
            
            output_lines.append(f"INSERT INTO `orders` (`id`, `code`, `customer_id`, `total_menu_price`, `grand_total`, `order_status`, `created_date`) VALUES ({order_id}, '{code}', {customer_id}, {total:.2f}, {grand_total:.2f}, 'completed', '{date_str}');")
            output_lines.append(f"INSERT INTO `order_details` (`id`, `order_code`, `menu_name`, `quantity`, `restaurant_id`, `total`) VALUES ({order_details_id}, '{code}', '{item_name}', {qty}, {rid}, '{total:.2f}');")
            output_lines.append(f"INSERT INTO `order_history` (`id`, `order_id`, `process_by`, `particulars`, `time_format`, `created_data`) VALUES ({history_id}, '{code}', 'system', 'Order created today', {ts}, '{date_str}');")
            
            order_id += 1
            order_details_id += 1
            history_id += 1
            
        # Generate 2 catering orders for today
        for i in range(2):
            item_name, price = random.choice(products)
            qty = random.randint(5, 10)
            total = price * qty
            grand_total = total + 10.0
            
            code = f"TODAY-CAT-{rid}-{i}-{ts}"
            customer_id = rid  # Matching customer_id to restaurant_id for RLS consistency
            
            output_lines.append(f"INSERT INTO `catering_orders` (`id`, `code`, `customer_id`, `total_menu_price`, `grand_total`, `order_status`, `partyware`, `order_source`, `order_token`, `token_expiry`, `token_status`, `created_date`) VALUES ({catering_id}, '{code}', {customer_id}, {total:.2f}, {grand_total:.2f}, 'completed', 'premium', 'web', 'TK-{ts}', '2030-01-01', '0', '{date_str}');")
            output_lines.append(f"INSERT INTO `catering_order_details` (`id`, `order_code`, `menu_name`, `quantity`, `restaurant_id`, `total`) VALUES ({catering_details_id}, '{code}', '{item_name}', {qty}, {rid}, '{total:.2f}');")
            output_lines.append(f"INSERT INTO `order_history` (`id`, `order_id`, `process_by`, `particulars`, `time_format`, `created_data`) VALUES ({history_id}, '{code}', 'system', 'Catering order today', {ts}, '{date_str}');")
            
            catering_id += 1
            catering_details_id += 1
            history_id += 1

    with open("/tmp/today_data.sql", "w") as f:
        f.write("\n".join(output_lines))
    print("Generated SQL in /tmp/today_data.sql")

if __name__ == "__main__":
    generate_today_sql()
