import os
from abc import ABC, abstractmethod
from typing import List

from langchain_core.documents import Document
from langchain_core.embeddings import Embeddings
from langchain_community.vectorstores import FAISS

from boons_text_to_sql_agent.config import Settings

class VectorStoreProvider(ABC):
    @abstractmethod
    def similarity_search(self, query: str, k: int = 4) -> List[Document]:
        """Retrieve the top k most relevant documents for a query."""
        pass

class LocalFaissProvider(VectorStoreProvider):
    def __init__(self, settings: Settings, index_path: str = "faiss_index"):
        self._settings = settings
        self._index_path = index_path
        self._embeddings = self._init_embeddings()
        self._store = self._init_store()

    def _init_embeddings(self) -> Embeddings:
        from langchain_openai import OpenAIEmbeddings
        return OpenAIEmbeddings(api_key=self._settings.llm_api_key)

    def _init_store(self) -> FAISS | None:
        if os.path.exists(self._index_path):
            return FAISS.load_local(
                self._index_path, 
                self._embeddings,
                allow_dangerous_deserialization=True # Required for local FAISS loading
            )
        return None

    def similarity_search(self, query: str, k: int = 4) -> List[Document]:
        if not self._store:
            # Fallback if knowledge base hasn't been built yet
            return [Document(page_content="No knowledge base found. Please run scripts/build_knowledge_base.py")]
        
        return self._store.similarity_search(query, k=k)

class AwsBedrockKbProvider(VectorStoreProvider):
    def __init__(self, settings: Settings):
        self._settings = settings
        from langchain_aws import AmazonKnowledgeBasesRetriever
        
        # Bedrock Knowledge Base IDs would typically be in settings
        # We are mocking the initialization for the POC architecture
        kb_id = os.getenv("AWS_KB_ID", "mock-kb-id") 
        
        self._retriever = AmazonKnowledgeBasesRetriever(
            knowledge_base_id=kb_id,
            retrieval_config={"vectorSearchConfiguration": {"numberOfResults": 4}},
        )

    def similarity_search(self, query: str, k: int = 4) -> List[Document]:
        # AmazonKnowledgeBasesRetriever doesn't support dynamic 'k' per call in the same way,
        # but the interface matches our needs.
        return self._retriever.invoke(query)

def get_vector_store(settings: Settings) -> VectorStoreProvider:
    if settings.is_aws_environment and not settings.force_local_rag:
        return AwsBedrockKbProvider(settings)
    return LocalFaissProvider(settings)
