import os
import pytest
from dotenv import load_dotenv

# Load local .env just in case, though pytest should ideally use standard env vars from the shell
load_dotenv()

@pytest.mark.asyncio
async def test_gemini_2_5_pro_connectivity():
    """Verify that the ChatGoogleGenerativeAI model can be initialized and can answer a prompt using gemini-2.5-pro."""
    
    # Check for the key first
    api_key = os.environ.get("LLM_API_KEY")
    if not api_key:
        pytest.fail("LLM_API_KEY environment variable is not set. Please set it to run this test.")

    try:
        from langchain_google_genai import ChatGoogleGenerativeAI
    except ImportError:
        pytest.fail("langchain-google-genai is not installed. Run: pip install langchain-google-genai")

    llm = ChatGoogleGenerativeAI(
        model="gemini-2.5-pro",
        google_api_key=api_key,
        temperature=0
    )
    
    try:
        response = await llm.ainvoke("What is 2+2? Reply with just the number.")
        assert "4" in str(response.content)
        print("\nSUCCESS: gemini-2.5-pro connected and responded properly!")
    except Exception as e:
        pytest.fail(f"gemini-2.5-pro connectivity failed: {e}")

def test_gemini_embedding_fallback():
    """Verify if the available gemini-embedding-001 model is accessible with this key.
    This is necessary to know how to build the FAISS vector database locally.
    """
    
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        pytest.skip("Test skipped: GEMINI_API_KEY not found.")

    try:
        from langchain_google_genai import GoogleGenerativeAIEmbeddings
    except ImportError:
        pytest.skip("Test skipped: langchain-google-genai not installed.")

    # We will try the available 'gemini-embedding-001'
    embeddings = GoogleGenerativeAIEmbeddings(
        model="models/gemini-embedding-001",
        google_api_key=api_key
    )
    
    try:
        vector = embeddings.embed_query("Hello world")
        assert len(vector) > 0
        print("\nSUCCESS: models/gemini-embedding-001 worked!")
    except Exception as e:
        pytest.fail(f"Failed to use gemini-embedding-001. Error: {e}")
