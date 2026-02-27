
import requests
import streamlit as st
import pandas as pd

# FastAPI backend URL
API_URL = "http://localhost:8000/text-to-sql/"

st.set_page_config(page_title="Boons Analytics AI", page_icon="📈", layout="wide", initial_sidebar_state="expanded")

# ==========================================
# CUSTOM CSS INJECTION - MOCKUP STYLE
# ==========================================
st.markdown("""
<style>
/* Base Fonts & Colors */
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap');

html, body, [class*="css"]  {
    font-family: 'Inter', sans-serif;
    background-color: #ffffff;
    color: #333333;
}

/* Base Streamlit App Background */
.stApp {
    background-color: #ffffff;
}

/* Adjust top padding so UI is tighter to the top */
.block-container {
    padding-top: 1rem !important;
    padding-bottom: 2rem !important;
    max-width: 95% !important;
}

/* Header & Deploy Button Mockup */
.header-container {
    display: flex;
    justify-content: flex-end;
    align-items: center;
    padding-bottom: 1rem;
    border-bottom: 1px solid #f0f0f0;
    margin-bottom: 2rem;
}
.deploy-btn {
    background: transparent;
    border: none;
    color: #5f6368;
    font-weight: 500;
    font-size: 0.9rem;
    cursor: pointer;
}

/* Sidebar Customization */
[data-testid="stSidebar"] {
    background-color: #fafbfc;
    border-right: 1px solid #f0f0f0;
}
[data-testid="stSidebar"] h1, 
[data-testid="stSidebar"] h2, 
[data-testid="stSidebar"] h3 {
    color: #202124;
    font-weight: 600;
}

/* Chat Input Styling - Light gray rounded pill */
[data-testid="stChatInput"] {
    border-radius: 20px !important;
    background-color: #f1f3f4 !important;
    border: none !important;
    padding: 2px 10px !important;
}
[data-testid="stChatInput"] textarea {
    background-color: transparent !important;
}

/* Clean, flat metric / canvas cards without heavy shadows */
.canvas-card {
    background: #ffffff;
    padding: 0;
    border-radius: 0;
    box-shadow: none;
    border: none;
    margin-bottom: 1.5rem;
}
.canvas-card-title {
    font-size: 1.25rem;
    font-weight: 600;
    color: #202124;
    margin-bottom: 1rem;
    display: flex;
    align-items: center;
    gap: 8px;
}

/* Clean buttons (Quick Insights & Clear Chat) */
.stButton>button {
    background-color: #ffffff;
    border: 1px solid #dadce0;
    border-radius: 8px;
    color: #5f6368;
    font-weight: 400;
    padding: 0.5rem 1rem;
    width: 100%;
    text-align: left;
    display: flex;
    align-items: flex-start;
    transition: background-color 0.2s;
}
.stButton>button:hover {
    background-color: #f8f9fa;
    border-color: #d2d2d2;
    color: #202124;
}

/* Chat bubble styling */
[data-testid="stChatMessage"]:has([data-testid="stMarkdownContainer"] > div > span > strong:contains("user")) {
    background-color: #f8f9fa !important;
    border-radius: 12px;
    padding: 10px 15px;
    border: 1px solid #f0f0f0;
}

/* Hide Streamlit branding */
#MainMenu {visibility: hidden;}
footer {visibility: hidden;}

</style>
""", unsafe_allow_html=True)

# Top Right Deploy Mockup
st.markdown("""
<div class="header-container" style="margin-bottom: 20px;">
    <span class="deploy-btn">Deploy</span>
</div>
""", unsafe_allow_html=True)

# ==========================================
# STATE MANAGEMENT
# ==========================================
if "show_left_pane" not in st.session_state:
    st.session_state.show_left_pane = True
if "messages" not in st.session_state:
    st.session_state.messages = []
if "canvas_data" not in st.session_state:
    st.session_state.canvas_data = None  # To hold {"type": "chart"|"table"|"text", "data": ...}
if "context_role" not in st.session_state:
    st.session_state.context_role = "internal"
if "context_merchant_ids" not in st.session_state:
    st.session_state.context_merchant_ids = "1, 2"

# ==========================================
# TOP BAR: USER CONTEXT & INSIGHTS (Pinned conceptually at top)
# ==========================================
st.markdown("""
<style>
.small-insight-btn button {
    font-size: 0.85rem !important;
    padding: 2px 10px !important;
    white-space: nowrap !important;
    overflow: hidden !important;
    text-overflow: ellipsis !important;
}
</style>
""", unsafe_allow_html=True)

with st.expander("⚙️ User Context / Settings"):
    col1, col2, col3 = st.columns(3)
    with col1:
        role = st.selectbox("User Role", ["internal", "merchant"], index=0 if st.session_state.context_role == "internal" else 1)
    with col2:
        merchant_ids_str = st.text_input("Merchant IDs (comma separated)", value=st.session_state.context_merchant_ids, disabled=(role == "internal"))
        if role == "merchant":
            st.caption("Required for the 'merchant' role to enforce Row-Level Security.")
    with col3:
        st.markdown("<br/>", unsafe_allow_html=True)
        def clear_chat():
            st.session_state.messages = []
            st.session_state.canvas_data = None
            st.session_state.context_role = role
            st.session_state.context_merchant_ids = merchant_ids_str
            
        if st.button("🗑️ Clear Chat History", use_container_width=True):
            clear_chat()
            st.rerun()

# Auto-clear if context changes natively
if st.session_state.context_role != role or st.session_state.context_merchant_ids != merchant_ids_str:
    clear_chat()
    st.session_state.context_role = role
    st.session_state.context_merchant_ids = merchant_ids_str

def parse_merchant_ids(ids_str):
    if not ids_str.strip():
        return []
    try:
        return [int(x.strip()) for x in ids_str.split(",") if x.strip()]
    except ValueError:
        st.error("Invalid Merchant IDs. Please enter comma-separated numbers.")
        return []

# Define Quick Insights based on Role
merchant_insights = [
    "Top 5 selling items",
    "All cancelled orders",
    "Total revenue today"
]

internal_insights = [
    "Top 5 earning merchants",
    "Order cancellation rate",
    "Most popular menu items"
]

st.markdown("<div class='small-insight-btn'>", unsafe_allow_html=True)
insights_to_show = merchant_insights if role == "merchant" else internal_insights
# Ensure exactly 3 insights (or max 3)
insights_to_show = insights_to_show[:3]

cols = st.columns(3)
for i, insight in enumerate(insights_to_show):
    with cols[i]:
        if st.button(f"💡 {insight}", key=f"insight_{i}", use_container_width=True, help=insight):
            st.session_state.prompt = insight
            st.rerun()
st.markdown("</div>", unsafe_allow_html=True)

st.markdown("<hr style='margin-top: 10px; margin-bottom: 20px; border-top: 1px solid #f0f0f0;'/>", unsafe_allow_html=True)

# ==========================================
# MAIN WORKSPACE: FULL WIDTH CHAT & ANSWERS
# ==========================================
# 1. Render Chat History
st.info("👈 Chat and results will appear below. They naturally scroll while controls stay at the top.")
chat_container = st.container(border=False)
with chat_container:
    for message in st.session_state.messages:
        with st.chat_message(message["role"]):
            if message["role"] == "user":
                st.markdown(message["content"])
            else:
                if "error" in message:
                    st.error(message["error"])
                else:
                    st.markdown(message.get("summary", "I processed that request."))
                    if message.get("has_visual"):
                        st.caption("*(See data results below)*")

# 2. Render the Data / Answer Block
if st.session_state.canvas_data is None:
    # Optionally show a "Daily Briefing" if empty and no chat
    if len(st.session_state.messages) == 0:
        with st.spinner("Loading daily overview..."):
            merchant_ids = parse_merchant_ids(merchant_ids_str) if role == "merchant" else []
            brief_res = requests.post(API_URL, json={
                "role": role, 
                "merchant_ids": merchant_ids, 
                "question": "Give me a one sentence text summary of today's total orders and total revenue. E.g: Your restaurant had a total of 20 orders today, generating a revenue of $400.", 
                "chat_history": []
            })
            st.markdown("<div class='canvas-card' style='margin-top: 20px;'>", unsafe_allow_html=True)
            st.markdown("<div class='canvas-card-title'>📈 Daily Briefing</div>", unsafe_allow_html=True)
            if brief_res.status_code == 200:
                st.markdown(f"<p style='color: #444; font-size: 1rem; line-height: 1.5;'>{brief_res.json().get('summary', 'No activity today.')}</p>", unsafe_allow_html=True)
            else:
                st.markdown("<p style='color: #444; font-size: 1rem;'>Unable to load briefing data.</p>", unsafe_allow_html=True)
            st.markdown("</div>", unsafe_allow_html=True)
    else:
        # We have messages but no visual data (e.g. general conversational response)
        pass

else:
    # Display the current canvas data right below the chat (latest answer on top of the input)
    c_data = st.session_state.canvas_data
    st.markdown("<div class='canvas-card' style='margin-top: 20px;'>", unsafe_allow_html=True)
    st.markdown(f"<div class='canvas-card-title'>📊 {c_data.get('title', 'Results')}</div>", unsafe_allow_html=True)
    
    if c_data["type"] == "chart":
        st.vega_lite_chart(c_data["spec"], use_container_width=True)
        
        with st.expander("Show Raw Data", expanded=False):
            df = pd.DataFrame(c_data["spec"]["data"]["values"])
            st.dataframe(df, use_container_width=True)
            csv = df.to_csv(index=False).encode('utf-8')
            st.download_button("⬇️ Download CSV", csv, "chart_data.csv", "text/csv")
            
    elif c_data["type"] == "table":
        df = pd.DataFrame(c_data["data"])
        
        # Strip columns that contain absolutely no data
        df = df.dropna(axis=1, how='all')
        
        # Make table headers user-friendly (Title Case, no underscores)
        df.columns = [str(col).replace("_", " ").title() for col in df.columns]
        
        st.dataframe(df, use_container_width=True, hide_index=True)
        
        st.markdown("<br/>", unsafe_allow_html=True)
        csv = df.to_csv(index=False).encode('utf-8')
        st.download_button("⬇️ Download CSV", csv, "export.csv", "text/csv")
        
    st.markdown("</div>", unsafe_allow_html=True)


# ==========================================
# GLOBAL CHAT INPUT (Always Visible Bottom)
# ==========================================
chat_input = st.chat_input("Ask a question...")

if getattr(st.session_state, "prompt", None):
    chat_input = st.session_state.prompt
    del st.session_state.prompt

if chat_input:
    # Ensure left pane stays explicitly open or whatever user chose
    st.session_state.messages.append({"role": "user", "content": chat_input})
            
    merchant_ids = parse_merchant_ids(merchant_ids_str) if role == "merchant" else []
    history_to_send = st.session_state.messages[-6:-1]
    history = []
    for m in history_to_send:
        if m["role"] == "user":
            history.append({"role": "user", "content": m["content"]})
        elif m["role"] == "assistant" and m.get("summary"):
            history.append({"role": "assistant", "content": m["summary"]})
            
    payload = {
        "role": role,
        "merchant_ids": merchant_ids,
        "question": chat_input,
        "chat_history": history
    }

    # Generate response
    with st.spinner("Analyzing your business context & gathering insights..."):
        try:
            response = requests.post(API_URL, json=payload)
            if response.status_code == 200:
                data = response.json()
                
                summary_text = data.get("summary") or "Okay, I processed your request."
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
                    st.session_state.canvas_data = {"type": "table", "data": data.get("rows", []), "title": chat_input}
                    has_visual = True
                else:
                    st.session_state.canvas_data = None # Clear previous visual!
                
                st.session_state.messages.append({
                    "role": "assistant",
                    "summary": summary_text,
                    "has_visual": has_visual
                })
            else:
                st.session_state.messages.append({"role": "assistant", "error": f"API Error {response.status_code}: {response.text}"})
        except Exception as e:
            st.session_state.messages.append({"role": "assistant", "error": f"Failed to connect to backend: {str(e)}"})
    
    st.rerun()
