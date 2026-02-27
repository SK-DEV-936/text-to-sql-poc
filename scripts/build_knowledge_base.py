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
        page_content="The 'users' table stores essential information about each user in the system. It includes a unique identifier for each user, their email address (which must be unique), a hashed password for authentication purposes, and a timestamp indicating when the user account was created.",
        metadata={"category": "schema", "table": "users"}
    ),
    Document(
        page_content="The 'login_history' table records every login attempt made by users. Each record includes a unique identifier for the login attempt, the user identifier that links to the 'users' table, the timestamp of the login, and the IP address from which the login was made.",
        metadata={"category": "schema", "table": "login_history"}
    ),
    Document(
        page_content="To join the 'login_history' table with the 'users' table, use the 'user_id' column from the 'login_history' table and the 'id' column from the 'users' table. This relationship allows you to retrieve user information alongside their login attempts.",
        metadata={"category": "relationship", "table": "login_history"}
    ),
    Document(
        page_content="When querying for user authentication data, focus on the 'users' table for user details and the 'login_history' table for login attempts. Use the 'user_id' in 'login_history' to filter records by specific users.",
        metadata={"category": "relationship", "table": "login_history"}
    ),
    Document(
        page_content="The term 'user authentication' can be mapped to querying the 'users' table for user details and the 'login_history' table for login attempts. This includes filtering by 'email' and 'password_hash' in the 'users' table and 'login_time' in the 'login_history' table.",
        metadata={"category": "synonym"}
    ),
    Document(
        page_content="'Login frequencies' can be analyzed by counting the number of records in the 'login_history' table grouped by 'user_id'. This will provide insights into how often each user logs in.",
        metadata={"category": "synonym"}
    ),
    Document(
        page_content="'Potential security issues' can be assessed by examining the 'login_history' table for unusual patterns, such as multiple failed login attempts from the same IP address or logins from unfamiliar locations. This can be done by filtering records based on 'ip_address' and 'login_time'.",
        metadata={"category": "synonym"}
    ),
    Document(
        page_content="To retrieve the most recent login time for each user, join the 'users' table with the 'login_history' table and select the maximum 'login_time' for each 'user_id'. This can help identify active users.",
        metadata={"category": "synonym"}
    ),
    Document(
        page_content="When discussing 'user account creation', refer to the 'created_at' column in the 'users' table to filter users based on their account creation date. This can help in analyzing user growth over time.",
        metadata={"category": "synonym"}
    ),
    Document(
        page_content="To find users who have never logged in, perform a left join between the 'users' table and the 'login_history' table, filtering for users where the 'login_history.id' is NULL. This identifies users who have created accounts but have not yet logged in.",
        metadata={"category": "synonym"}
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
