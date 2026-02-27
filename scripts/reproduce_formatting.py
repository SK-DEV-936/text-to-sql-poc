import asyncio
import json
from boons_text_to_sql_agent.config import load_settings
from boons_text_to_sql_agent.infrastructure.llm.summarizer import LlmSummarizer
from boons_text_to_sql_agent.infrastructure.llm.watcher_agent import LlmWatcherAgent
from boons_text_to_sql_agent.domain import Question, Scope, Role

async def reproduce_formatting():
    settings = load_settings()
    summarizer = LlmSummarizer(settings)
    watcher = LlmWatcherAgent(settings)
    
    question_text = "Give me a brief summary of today's total revenue and total orders."
    scope = Scope(role=Role.INTERNAL, merchant_ids=[])
    question = Question(text=question_text, scope=scope, chat_history=[])
    
    # Fake data mirroring the user's report
    rows = [
        {"grand_total": 12938.00, "order_count": 240}
    ]
    
    print("--- STEP 1: SUMMARIZER ---")
    summary, chart_spec = await summarizer.summarize(question, rows)
    print(f"Draft Summary: '{summary}'")
    
    print("\n--- STEP 2: WATCHER AGENT ---")
    final_summary = await watcher.review_and_correct(question, rows, summary)
    print(f"Final Summary: '{final_summary}'")
    
    print("\n--- FORMATTING ANALYSIS ---")
    if " " not in final_summary:
        print("WARNING: Final summary has NO SPACES!")
    
    print(f"Length: {len(final_summary)}")
    print(f"Representation: {repr(final_summary)}")

if __name__ == "__main__":
    asyncio.run(reproduce_formatting())
