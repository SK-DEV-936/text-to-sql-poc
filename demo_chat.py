
import requests
import streamlit as st

# FastAPI backend URL
API_URL = "http://localhost:8000/text-to-sql/"

st.set_page_config(page_title="boons analytics AI agent", page_icon="🤖", layout="wide")
st.title("boons analytics AI agent 🤖")

with st.expander("ℹ️ How it works", expanded=False):
    st.markdown("""
    Type a natural question about your orders or restaurant, 
    and the AI agent will securely analyze your data.
    """)

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
                    if message.get("chart_spec"):
                        st.vega_lite_chart(message["chart_spec"], use_container_width=True)

# Define Quick Insights based on Role
merchant_insights = [
    "What are my top 5 selling items overall?",
    "Compare total revenue of catering vs regular orders.",
    "Show me all cancelled orders.",
    "What is the total revenue for today?"
]

internal_insights = [
    "Show me the top 5 highest-earning merchants today.",
    "What is the overall order cancellation rate?",
    "Compare total revenue of catering vs regular orders.",
    "What are the most popular menu items across all restaurants?"
]

def parse_merchant_ids(ids_str):
    if not ids_str.strip():
        return []
    try:
        return [int(x.strip()) for x in ids_str.split(",") if x.strip()]
    except ValueError:
        st.sidebar.error("Invalid Merchant IDs. Please enter comma-separated numbers.")
        return []

# Handle Empty State / Welcome Screen
pre_selected_question = None
if len(st.session_state.messages) == 0:
    st.markdown("### Welcome to your Analytics Assistant! 👋")
    st.markdown("Select a quick insight below to get started, or type a custom question.")
    
    st.write("")
    insights_to_show = merchant_insights if role == "merchant" else internal_insights
    
    # Layout buttons in a 2x2 grid
    col1, col2 = st.columns(2)
    for i, insight in enumerate(insights_to_show):
        target_col = col1 if i % 2 == 0 else col2
        if target_col.button(insight, use_container_width=True):
            pre_selected_question = insight
            
    # Auto-run a Daily Briefing if they haven't clicked anything yet
    if not pre_selected_question:
        with st.spinner("Preparing your daily briefing..."):
            merchant_ids = parse_merchant_ids(merchant_ids_str) if role == "merchant" else []
            briefing_payload = {
                "role": role,
                "merchant_ids": merchant_ids,
                "question": "Give me a brief summary of today's total revenue and total orders.",
                "chat_history": []
            }
            try:
                briefing_res = requests.post(API_URL, json=briefing_payload)
                if briefing_res.status_code == 200:
                    brief_data = briefing_res.json()
                    st.info(f"**Today's Briefing:** {brief_data.get('summary', 'No activity today.')}")
            except Exception:
                pass # Fail silently if backend is still booting

# React to user input or pre-selected button
chat_input = st.chat_input("Ask a question about your data...")
question = pre_selected_question or chat_input
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
        with st.spinner("Analyzing your data..."):
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
                            
                        chart_spec = data.get("chart_spec")
                        if chart_spec:
                            # Inject the row data into the Vega-Lite spec
                            chart_spec["data"] = {"values": data["rows"]}
                            st.vega_lite_chart(chart_spec, use_container_width=True)
                            
                        # Add to history
                        st.session_state.messages.append({
                            "role": "assistant",
                            "final_sql": data["final_sql"],
                            "rows": data["rows"],
                            "summary": data.get("summary"),
                            "warnings": data.get("warnings"),
                            "chart_spec": chart_spec
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
