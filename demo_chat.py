
import requests
import streamlit as st
import pandas as pd

# FastAPI backend URL
API_URL = "http://localhost:8000/text-to-sql/"

st.set_page_config(page_title="Boons Analytics AI", page_icon="🤖", layout="wide", initial_sidebar_state="expanded")

# ==========================================
# CUSTOM CSS INJECTION
# ==========================================
st.markdown("""
<style>
/* Base Fonts & Colors */
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap');

html, body, [class*="css"]  {
    font-family: 'Inter', sans-serif;
}

/* Adjust top padding so UI is tighter to the top */
.block-container {
    padding-top: 1.5rem !important;
    padding-bottom: 2rem !important;
    max-width: 95% !important;
}

/* Chat Input Styling */
[data-testid="stChatInput"] {
    border-radius: 12px;
}

/* Sidebar Customization */
[data-testid="stSidebar"] {
    background-color: #f8f9fa;
    border-right: 1px solid #e9ecef;
}

/* Metric / Canvas Cards */
.canvas-card {
    background: white;
    padding: 1.5rem;
    border-radius: 12px;
    box-shadow: 0 4px 6px rgba(0,0,0,0.05);
    border: 1px solid #edf2f7;
    margin-bottom: 1rem;
}

/* Chat bubble styling for user */
[data-testid="stChatMessage"]:has([data-testid="stMarkdownContainer"] > div > span > strong:contains("user")) {
    background-color: #f0f7ff !important;
    border-radius: 12px;
    padding: 10px 15px;
}

/* Hide Streamlit branding */
#MainMenu {visibility: hidden;}
footer {visibility: hidden;}

</style>
""", unsafe_allow_html=True)


# ==========================================
# STATE MANAGEMENT
# ==========================================
if "messages" not in st.session_state:
    st.session_state.messages = []
if "canvas_data" not in st.session_state:
    st.session_state.canvas_data = None  # To hold {"type": "chart"|"table"|"text", "data": ...}

# Sidebar settings setup
st.sidebar.header("User Context")
role = st.sidebar.selectbox("User Role", ["internal", "merchant"], index=0)

merchant_ids_str = ""
if role == "merchant":
    merchant_ids_str = st.sidebar.text_input("Merchant IDs (comma separated)", value="1, 2")
    st.sidebar.caption("Required for the 'merchant' role to enforce Row-Level Security.")

if "context_role" not in st.session_state:
    st.session_state.context_role = role
if "context_merchant_ids" not in st.session_state:
    st.session_state.context_merchant_ids = merchant_ids_str

def clear_chat():
    st.session_state.messages = []
    st.session_state.canvas_data = None
    st.session_state.context_role = role
    st.session_state.context_merchant_ids = merchant_ids_str

if st.sidebar.button("🗑️ Clear Chat History", use_container_width=True):
    clear_chat()
    st.rerun()

if st.session_state.context_role != role or st.session_state.context_merchant_ids != merchant_ids_str:
    clear_chat()

def parse_merchant_ids(ids_str):
    if not ids_str.strip():
        return []
    try:
        return [int(x.strip()) for x in ids_str.split(",") if x.strip()]
    except ValueError:
        st.sidebar.error("Invalid Merchant IDs. Please enter comma-separated numbers.")
        return []

# Define Quick Insights based on Role
merchant_insights = [
    "What are my top 5 selling items overall?",
    "Show me all cancelled orders.",
    "What is the total revenue for today?"
]

internal_insights = [
    "Show me the top 5 highest-earning merchants today.",
    "What is the overall order cancellation rate?",
    "What are the most popular menu items across all restaurants?"
]

# ==========================================
# UI LAYOUT: TWO PANES
# ==========================================
st.markdown("## Boons Analytics AI 🤖")

chat_col, canvas_col = st.columns([1, 2.2], gap="large")

# ------------------------------------------
# LEFT PANE: CHAT INTERFACE
# ------------------------------------------
with chat_col:
    st.markdown("#### Conversation")
    
    # Render chat history
    chat_container = st.container(height=600)
    with chat_container:
        # Handle Empty State / Welcome Screen
        if len(st.session_state.messages) == 0:
            st.markdown("👋 **Welcome!** Ask a question about your data to get started.")
            
            # Quick Insights Buttons
            st.markdown("##### Quick Insights")
            insights_to_show = merchant_insights if role == "merchant" else internal_insights
            for i, insight in enumerate(insights_to_show):
                if st.button(f"💡 {insight}", key=f"btn_{i}", use_container_width=True):
                    # Set a temporary thought variable to trigger chat
                    st.session_state.prompt = insight
                    st.rerun()

        for message in st.session_state.messages:
            with st.chat_message(message["role"]):
                if message["role"] == "user":
                    st.markdown(message["content"])
                else:
                    if "error" in message:
                        st.error(message["error"])
                    else:
                        st.markdown(message.get("summary", "I processed that request."))
                        # Provide a link/indicator if this created a visual
                        if message.get("has_visual"):
                            st.caption("➡️ _Visual generated on Canvas_")

    # Chat Input
    chat_input = st.chat_input("Ask a question...")
    
    # Check if a fast-insight button was clicked
    if getattr(st.session_state, "prompt", None):
        chat_input = st.session_state.prompt
        del st.session_state.prompt

    if chat_input:
        # Append User Message
        st.session_state.messages.append({"role": "user", "content": chat_input})
        with chat_container:
            with st.chat_message("user"):
                st.markdown(chat_input)
                
        # Prepare Payload
        merchant_ids = parse_merchant_ids(merchant_ids_str) if role == "merchant" else []
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
            "question": chat_input,
            "chat_history": chat_history
        }

        with chat_container:
            with st.chat_message("assistant"):
                with st.status("Analyzing your business context...", expanded=True) as status:
                    st.write("Gathering relevant data insights...")
                    try:
                        response = requests.post(API_URL, json=payload)
                        if response.status_code == 200:
                            data = response.json()
                            status.update(label="Complete!", state="complete", expanded=False)
                            
                            summary_text = data.get("summary") or "Okay, I processed your request."
                            st.markdown(summary_text)

                            # Determine what to show on Canvas
                            has_visual = False
                            if data.get("chart_spec"):
                                chart_spec = data["chart_spec"]
                                chart_spec["data"] = {"values": data["rows"]}
                                st.session_state.canvas_data = {"type": "chart", "spec": chart_spec, "title": chat_input}
                                has_visual = True
                            elif data.get("rows") and len(data["rows"]) > 1:
                                st.session_state.canvas_data = {"type": "table", "data": data["rows"], "title": chat_input}
                                has_visual = True
                            elif data.get("final_sql"):
                                # Fallback to showing raw rows if it's a single value
                                st.session_state.canvas_data = {"type": "table", "data": data.get("rows", []), "title": chat_input}
                                has_visual = True
                            
                            st.session_state.messages.append({
                                "role": "assistant",
                                "summary": summary_text,
                                "has_visual": has_visual
                            })
                            st.rerun()
                        else:
                            error_msg = f"API Error {response.status_code}: {response.text}"
                            status.update(label="Error", state="error")
                            st.error(error_msg)
                            st.session_state.messages.append({"role": "assistant", "error": error_msg})
                    except Exception as e:
                        error_msg = f"Failed to connect to backend: {str(e)}"
                        status.update(label="Connection Failed", state="error")
                        st.error(error_msg)
                        st.session_state.messages.append({"role": "assistant", "error": error_msg})


# ------------------------------------------
# RIGHT PANE: DATA CANVAS
# ------------------------------------------
with canvas_col:
    st.markdown("#### Data Canvas")
    
    if st.session_state.canvas_data is None:
        st.info("👈 Ask a question to generate charts or tables here.")
        
        # Optionally show a "Daily Briefing" if empty
        if len(st.session_state.messages) == 0:
            with st.spinner("Loading daily overview..."):
                merchant_ids = parse_merchant_ids(merchant_ids_str) if role == "merchant" else []
                brief_res = requests.post(API_URL, json={
                    "role": role, 
                    "merchant_ids": merchant_ids, 
                    "question": "Brief summary of today's revenue and orders.", 
                    "chat_history": []
                })
                if brief_res.status_code == 200:
                    st.markdown("<div class='canvas-card'>", unsafe_allow_html=True)
                    st.markdown("##### 📈 Daily Briefing")
                    st.markdown(brief_res.json().get('summary', 'No activity today.'))
                    st.markdown("</div>", unsafe_allow_html=True)

    else:
        # Display the current canvas data in a styled card
        c_data = st.session_state.canvas_data
        st.markdown("<div class='canvas-card'>", unsafe_allow_html=True)
        st.markdown(f"##### {c_data.get('title', 'Results')}")
        
        if c_data["type"] == "chart":
            st.vega_lite_chart(c_data["spec"], use_container_width=True)
            
            # Allow raw data toggle
            with st.expander("Show Raw Data"):
                df = pd.DataFrame(c_data["spec"]["data"]["values"])
                st.dataframe(df, use_container_width=True)
                csv = df.to_csv(index=False).encode('utf-8')
                st.download_button("⬇️ Download CSV", csv, "chart_data.csv", "text/csv")
                
        elif c_data["type"] == "table":
            df = pd.DataFrame(c_data["data"])
            # Hide index and make it stretch
            st.dataframe(df, use_container_width=True, hide_index=True)
            
            st.markdown("<br/>", unsafe_allow_html=True)
            csv = df.to_csv(index=False).encode('utf-8')
            st.download_button("⬇️ Download CSV", csv, "export.csv", "text/csv")
            
        st.markdown("</div>", unsafe_allow_html=True)
