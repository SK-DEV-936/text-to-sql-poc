
import requests
import streamlit as st

# FastAPI backend URL
API_URL = "http://localhost:8000/text-to-sql/"

st.set_page_config(page_title="Boons Text-to-SQL Agent", page_icon="🤖", layout="wide")
st.title("Boons Text-to-SQL Agent 🤖")
st.markdown(
    "Ask natural language questions about your data, "
    "and the AI agent will generate and execute secure SQL safely."
)

# Sidebar for Configuration
st.sidebar.header("User Context")
role = st.sidebar.selectbox("User Role", ["internal", "merchant"], index=0)

merchant_ids_str = ""
if role == "merchant":
    merchant_ids_str = st.sidebar.text_input("Merchant IDs (comma separated)", value="1, 2")
    st.sidebar.caption("Required for the 'merchant' role to enforce Row-Level Security.")

# Initialize chat history
if "messages" not in st.session_state:
    st.session_state.messages = []

# Display chat messages from history on app rerun
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        if message["role"] == "user":
            st.markdown(message["content"])
        else:
            # Display assistant response
            if "error" in message:
                st.error(message["error"])
            else:
                if message.get("final_sql") is None:
                    # It's a conversation message
                    if "summary" in message and message["summary"]:
                        st.markdown(message["summary"])
                else:
                    if "summary" in message and message["summary"]:
                        st.markdown(message['summary'])

def parse_merchant_ids(ids_str):
    if not ids_str.strip():
        return []
    try:
        return [int(x.strip()) for x in ids_str.split(",") if x.strip()]
    except ValueError:
        st.sidebar.error("Invalid Merchant IDs. Please enter comma-separated numbers.")
        return []

# React to user input
question = st.chat_input("Ask a question about your data...")
if question:
    # Display user message in chat message container
    st.chat_message("user").markdown(question)
    # Add user message to chat history
    st.session_state.messages.append({"role": "user", "content": question})

    # Prepare Payload
    merchant_ids = parse_merchant_ids(merchant_ids_str) if role == "merchant" else []
    
    # Extract last 5 messages for context, excluding the current question
    history_to_send = st.session_state.messages[-6:-1]
    chat_history = []
    for m in history_to_send:
        if m["role"] == "user":
            chat_history.append({"role": "user", "content": m["content"]})
        elif m["role"] == "assistant" and m.get("summary"):
            chat_history.append({"role": "assistant", "content": m["summary"]})
            
    payload = {
        "role": role,
        "merchant_ids": merchant_ids,
        "question": question,
        "chat_history": chat_history
    }

    # Display assistant response in chat message container
    with st.chat_message("assistant"):
        with st.spinner("Generating and executing SQL..."):
            try:
                response = requests.post(API_URL, json=payload)
                if response.status_code == 200:
                    data = response.json()
                    
                    # Display conversational message if no SQL was generated
                    if data.get("final_sql") is None:
                        if data.get("summary"):
                            st.markdown(data["summary"])
                        else:
                            st.markdown("Okay, I wasn't sure how to respond to that.")
                        
                        st.session_state.messages.append({
                            "role": "assistant",
                            "summary": data.get("summary"),
                            "final_sql": None,
                            "rows": None
                        })
                    else:
                        if data.get("summary"):
                            st.markdown(data['summary'])
                            
                        # Add to history
                        st.session_state.messages.append({
                            "role": "assistant",
                            "final_sql": data["final_sql"],
                            "rows": data["rows"],
                            "summary": data.get("summary"),
                            "warnings": data.get("warnings")
                        })
                else:
                    error_msg = f"API Error {response.status_code}: {response.text}"
                    st.error(error_msg)
                    st.session_state.messages.append({
                        "role": "assistant",
                        "error": error_msg
                    })
            except Exception as e:
                error_msg = f"Failed to connect to backend: {str(e)}"
                st.error(error_msg)
                st.session_state.messages.append({
                    "role": "assistant",
                    "error": error_msg
                })
