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
        page_content="The 'orders' table represents regular orders placed by customers. It contains various columns that provide detailed information about each order, including unique identifiers, timestamps for different stages of the order process, customer details, payment information, and status flags. This table is essential for tracking the lifecycle of an order from placement to delivery or cancellation.",
        metadata={"category": "schema", "table": "orders"}
    ),
    Document(
        page_content="The 'order_details' table contains specific details about each item within an order. It is linked to the 'orders' table through the 'order_code' column in 'order_details' and the 'code' column in 'orders'. This relationship allows for the retrieval of detailed item information for each order, enabling comprehensive order analysis and reporting.",
        metadata={"category": "relationship", "table": "order_details"}
    ),
    Document(
        page_content="To analyze revenue, cancellations, and top-selling items, join the 'orders' table with the 'order_details' table using the condition 'order_details.order_code = orders.code'. This join allows you to aggregate order amounts and item details effectively.",
        metadata={"category": "relationship", "table": "order_details"}
    ),
    Document(
        page_content="When focusing on cancellations, filter the 'orders' table using the 'order_status' column where the status indicates cancellation (e.g., 'canceled', 'auto_canceled'). This will help in identifying all canceled orders.",
        metadata={"category": "synonym", "table": "orders"}
    ),
    Document(
        page_content="To calculate total revenue from orders, sum the 'grand_total' column in the 'orders' table. This provides the total income generated from all completed orders.",
        metadata={"category": "synonym", "table": "orders"}
    ),
    Document(
        page_content="To find the top-selling items, group the results from the 'order_details' table by the item identifier (e.g., 'item_id') and sum the 'quantity' sold. This will yield a list of items sorted by sales volume.",
        metadata={"category": "synonym", "table": "order_details"}
    ),
    Document(
        page_content="For tracking delivery issues, check the 'delivery_api_failed' column in the 'orders' table. A value of 'true' indicates a failure in the delivery API, which may require further investigation.",
        metadata={"category": "synonym", "table": "orders"}
    ),
    Document(
        page_content="To analyze the impact of discounts, filter the 'orders' table by 'coupon_amount' greater than zero. This will show all orders that utilized a discount coupon, allowing for analysis of discount effectiveness.",
        metadata={"category": "synonym", "table": "orders"}
    ),
    Document(
        page_content="To assess the average delivery charge, calculate the average of the 'dc' (delivery charge) column in the 'orders' table. This provides insights into delivery pricing trends.",
        metadata={"category": "synonym", "table": "orders"}
    ),
    Document(
        page_content="To evaluate customer engagement, join the 'orders' table with the 'order_history' table using 'order_history.order_id = orders.code'. This allows for tracking repeat orders and customer behavior over time.",
        metadata={"category": "relationship", "table": "order_history"}
    ),
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
