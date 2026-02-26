import os
import sys

# Ensure project root is in path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from langchain_core.documents import Document
from langchain_community.vectorstores import FAISS
from langchain_openai import OpenAIEmbeddings

from boons_text_to_sql_agent.config import Settings

KNOWLEDGE_DOCS = [
    Document(
        page_content="Table: orders. This table containing all high-level regular food orders. Key columns: code (Unique order identifier), customer_id, order_status (e.g., 'cancelled', 'completed'), grand_total (Total revenue/sales amount in dollars), created_date (When the order was placed).",
        metadata={"category": "schema", "table": "orders"}
    ),
    Document(
        page_content="Table: order_details. This table contains the line items for regular orders. Key columns: order_code (Matches orders.code), menu_name (Name of the item ordered), quantity (Number of items), restaurant_id (The specific merchant location ID).",
        metadata={"category": "schema", "table": "order_details"}
    ),
    Document(
        page_content="Table: catering_orders. This table containing large catering orders. Key columns: code (Unique identifier), customer_id, order_status, grand_total (Revenue), created_date.",
        metadata={"category": "schema", "table": "catering_orders"}
    ),
    Document(
        page_content="Table: catering_order_details. This table contains line items for catering orders. Key columns: order_code (Matches catering_orders.code), menu_name, quantity, restaurant_id (The specific merchant location ID).",
        metadata={"category": "schema", "table": "catering_order_details"}
    ),
    Document(
        page_content="RELATIONSHIP RULE: The `orders` table does NOT contain a `restaurant_id` column. If you need to filter regular orders by a specific merchant or restaurant, you MUST perform a JOIN: `FROM orders JOIN order_details ON orders.code = order_details.order_code`.",
        metadata={"category": "relationship"}
    ),
    Document(
        page_content="RELATIONSHIP RULE: The `catering_orders` table does NOT contain a `restaurant_id` column. If you need to filter catering orders by a specific merchant, you MUST perform a JOIN: `FROM catering_orders JOIN catering_order_details ON catering_orders.code = catering_order_details.order_code`.",
        metadata={"category": "relationship"}
    ),
    Document(
        page_content="SEMANTIC SYNONYM: When a user asks for 'revenue', 'sales', 'income', or 'total money', they are referring to the `grand_total` column.",
        metadata={"category": "synonym"}
    ),
    Document(
        page_content="SEMANTIC SYNONYM: When a user asks for 'cancelled orders', they want records where `order_status = 'cancelled'`.",
        metadata={"category": "synonym"}
    ),
    Document(
        page_content="SEMANTIC SYNONYM: When a user asks for 'top selling items' or 'best products', they are referring to the `menu_name` column in the details tables, ordered by the sum of `quantity`.",
        metadata={"category": "synonym"}
    ),
    Document(
        page_content="SEMANTIC SYNONYM: When a user asks for 'dinner orders' or 'dinner sales', filter orders where the time portion of `created_date` is after 17:00:00 (5 PM). Example: `HOUR(created_date) >= 17`.",
        metadata={"category": "synonym"}
    ),
    Document(
        page_content="SEMANTIC SYNONYM: When a user asks for 'lunch orders' or 'lunch sales', filter orders where the time portion of `created_date` is between 11:00:00 and 15:00:00. Example: `HOUR(created_date) BETWEEN 11 AND 15`.",
        metadata={"category": "synonym"}
    ),
    Document(
        page_content="SEMANTIC SYNONYM: If a user asks for 'sales' or 'orders' for a specific meal (like dinner or lunch) without specifying status, ALWAYS filter by `order_status = 'completed'` so you don't include cancelled orders in revenue.",
        metadata={"category": "synonym"}
    ),
    Document(
        page_content="SEMANTIC SYNONYM: When a user asks for 'delivery orders', they mean `delivery_to_pickup = 0` (or `type = 'delivery'`). When they ask for 'pickup orders', they mean `delivery_to_pickup = 1` (or `type = 'pickup'`).",
        metadata={"category": "synonym"}
    ),
    Document(
        page_content="SEMANTIC SYNONYM: When a user asks about 'promos', 'discounts', 'coupons', or 'offers', they are referring to the `coupon_amount` and `coupon_code` columns.",
        metadata={"category": "synonym"}
    ),
    Document(
        page_content="SEMANTIC SYNONYM: 'Active' or 'Pending' orders generally mean `order_status` IN ('pending', 'approved', 'preparing', 'ready', 'in_progress', 'assigned').",
        metadata={"category": "synonym"}
    ),
    Document(
        page_content="SEMANTIC SYNONYM: 'Delayed' or 'Late' orders refer to `delay_status = 1` or checking if `order_delayed_at` IS NOT NULL.",
        metadata={"category": "synonym"}
    ),
    Document(
        page_content="SEMANTIC SYNONYM: 'Big tickets' or 'large orders' usually imply filtering where `grand_total` is greater than 100 or another high threshold.",
        metadata={"category": "synonym"}
    ),
    Document(
        page_content="SEMANTIC SYNONYM: When a user asks who their 'best restaurants', 'top merchants', or 'top spenders' are, group by `customer_id` (which actually represents the merchant) and order descending by the SUM of `grand_total`.",
        metadata={"category": "synonym"}
    ),
    Document(
        page_content="CRITICAL SEMANTIC RULE: In this database structure, the term 'customer' and the column `customer_id` actually refer to a 'Merchant' or 'Restaurant' (the business generating the order), NOT the end diner.",
        metadata={"category": "synonym"}
    ),
    Document(
        page_content="SEMANTIC SYNONYM: When a user asks about 'refunds' or 'refunded orders', they are referring to records where `admin_refund` != '0' or `refund_details` IS NOT NULL.",
        metadata={"category": "synonym"}
    )
]

def build_index():
    print("Building local knowledge base (FAISS)...")
    settings = Settings()
    
    if not settings.llm_api_key:
        print("ERROR: LLM_API_KEY environment variable is missing. Cannot generate embeddings.")
        sys.exit(1)

    embeddings = OpenAIEmbeddings(api_key=settings.llm_api_key)
    
    # Generate vectors
    vectorstore = FAISS.from_documents(KNOWLEDGE_DOCS, embeddings)
    
    # Save locally
    index_path = os.path.join(os.path.dirname(__file__), "..", "faiss_index")
    vectorstore.save_local(index_path)
    
    print(f"Successfully built FAISS index with {len(KNOWLEDGE_DOCS)} documents at: {index_path}")

if __name__ == "__main__":
    build_index()
