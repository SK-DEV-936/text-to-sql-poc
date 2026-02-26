import os
import random
from datetime import datetime, timedelta

def generate_sql():
    # Configuration
    NUM_RESTAURANTS = 20
    DAYS = 30
    START_DATE = datetime.now() - timedelta(days=DAYS)
    
    # We want exactly 10 orders per day per restaurant to sum up to exactly what user asked
    # Or roughly around that. Let's do exactly 10.
    ORDERS_PER_DAY = 10
    
    output_lines = [
        "-- Auto-generated seed data for boons_text_to_sql_agent POC",
        "USE boons;",
        ""
    ]
    
    # We will generate IDs explicitly to link details easily
    order_id_counter = 1
    order_details_id_counter = 1
    
    catering_order_id_counter = 1
    catering_details_id_counter = 1
    
    history_id_counter = 1

    menu_items = [
        ("Burger", 12.50), ("Pizza", 18.00), ("Salad", 9.00),
        ("Fries", 4.50), ("Soda", 2.00), ("Sushi", 22.00)
    ]
    
    statuses = ["completed", "completed", "completed", "cancelled", "returned"]
    
    for restaurant_id in range(1, NUM_RESTAURANTS + 1):
        for day_offset in range(DAYS):
            current_date = START_DATE + timedelta(days=day_offset)
            ts = int(current_date.timestamp())
            date_str = current_date.strftime('%Y-%m-%d %H:%M:%S')
            
            for _ in range(ORDERS_PER_DAY):
                # Decide if it's regular or catering (mostly regular)
                is_catering = random.random() < 0.15 
                
                status = random.choice(statuses)
                
                # generate 1 to 4 items
                num_items = random.randint(1, 4)
                
                items_to_insert = []
                total_menu_price = 0.0
                
                for _ in range(num_items):
                    menu_item, price = random.choice(menu_items)
                    quantity = random.randint(1, 3)
                    total = price * quantity
                    total_menu_price += total
                    items_to_insert.append((menu_item, quantity, total))
                
                # Mock a customer ID
                customer_id = random.randint(1, 100)
                
                code = f"ORD-{restaurant_id}-{ts}-{random.randint(1000, 9999)}"
                
                if not is_catering:
                    code = f"REG-{code}"
                    output_lines.append(f"""INSERT INTO `orders` (`id`, `code`, `customer_id`, `total_menu_price`, `grand_total`, `order_status`, `created_date`) VALUES ({order_id_counter}, '{code}', {customer_id}, {total_menu_price:.2f}, {total_menu_price + 2.50:.2f}, '{status}', '{date_str}');""")
                    
                    for item_name, qty, tot in items_to_insert:
                        output_lines.append(f"""INSERT INTO `order_details` (`id`, `order_code`, `menu_name`, `quantity`, `restaurant_id`, `total`) VALUES ({order_details_id_counter}, '{code}', '{item_name}', {qty}, {restaurant_id}, '{tot:.2f}');""")
                        order_details_id_counter += 1
                        
                    order_id_counter += 1
                else:
                    code = f"CAT-{code}"
                    # Catering tend to be larger quantity
                    total_menu_price *= 5
                    output_lines.append(f"""INSERT INTO `catering_orders` (`id`, `code`, `customer_id`, `total_menu_price`, `grand_total`, `order_status`, `partyware`, `order_source`, `order_token`, `token_expiry`, `token_status`, `created_date`) VALUES ({catering_order_id_counter}, '{code}', {customer_id}, {total_menu_price:.2f}, {total_menu_price + 15.00:.2f}, '{status}', 'standard', 'web', 'TOKEN123', '2030-01-01', '0', '{date_str}');""")
                    
                    for item_name, qty, tot in items_to_insert:
                        output_lines.append(f"""INSERT INTO `catering_order_details` (`id`, `order_code`, `menu_name`, `quantity`, `restaurant_id`, `total`) VALUES ({catering_details_id_counter}, '{code}', '{item_name}', {qty * 5}, {restaurant_id}, '{tot * 5:.2f}');""")
                        catering_details_id_counter += 1
                        
                    catering_order_id_counter += 1
                    
                # History
                output_lines.append(f"""INSERT INTO `order_history` (`id`, `order_id`, `process_by`, `particulars`, `time_format`, `created_data`) VALUES ({history_id_counter}, '{code}', 'system', 'Order placed', {ts}, '{date_str}');""")
                history_id_counter += 1

    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_path = os.path.join(os.path.dirname(script_dir), "db", "init", "03-real-seed-data.sql")
    
    with open(output_path, "w") as f:
        f.write("\n".join(output_lines))
        
    print(f"Generated seed data at {output_path}")
    print(f"  Total Regular Orders: {order_id_counter - 1}")
    print(f"  Total Catering Orders: {catering_order_id_counter - 1}")

if __name__ == "__main__":
    generate_sql()
