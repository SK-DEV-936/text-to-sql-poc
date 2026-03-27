# Product Requirements Document (PRD): Boons Marketing Agent

## 1. Objective
Build an autonomous multi-agent Marketing Module integrated into the Boons platform. The module will proactively suggest high-conversion SMS campaigns to merchants. It will discover relevant events/holidays, identify the best customer segments (e.g., dormant users, high-value purchasers), generate sample SMS copy, and provide a clear UI showing the campaign size and cost.

## 2. Target Audience
**Merchants** wanting to increase repeat orders without managing complex marketing tools manually.

## 3. Core Capabilities & User Flow
1. **Data-Driven Campaign Ideation**: The Marketing Growth Agent acts as a smart analyst. Instead of relying solely on external calendar events, it dynamically interrogates the merchant's SQL database to spot trends and opportunities. For example:
   - "20% of your customers haven't ordered in 3 weeks. Let's send a 'We miss you' discount."
   - "Customers ordering 'Spicy Tuna Roll' normally order on Fridays. Let's run a Thursday promo."
2. **Segment Extraction**: The agent writes SQL to extract the precise list of target customers for the identified idea, ensuring high conversion potential.
3. **Hyper-Personalized Copy & Flyers**: The AI drafts 3-4 variations of short, engaging MMS/SMS messages. It ingests the restaurant's website context, menu, and stored image assets to ensure the tone is a "personal invite" from the restaurant, rather than a generic ad.
4. **AI-Generated Campaign One-Pager**: For every generated idea, the agent compiles a detailed, one-page strategy brief to "pitch" the campaign to the merchant. The MVP one-pager includes:
   - **The "Why"**: The strict data/logical rationale behind why this exact segment and timing will drive results.
   - **Projected ROI**: An approximate calculation of expected orders based on historical data vs. the cost of sending the SMS.
   - **Target Audience Size**: Total number of reachable customers.
   - **Sample Assets**: 3-4 Sample SMS/MMS messages with attached flyers/images.
   - **Cost Estimate**: Transparent pricing (e.g., Twilio cost + Boons fee).
5. **Campaign Execution (Future phase)**: One-click approval to schedule and send the SMS via a third-party API.

## 4. Multi-Agent Architecture (Proposed)
We propose a **Multi-Agent** workflow orchestrated independently but reusing the existing text-to-SQL logic:
- 🧠 **Growth Manager Agent (The Strategist)**: The brain of the operation. It proactively runs exploratory SQL queries against the database (via the text-to-sql core) to discover hidden sales patterns, popular item trends, or customer dormancy. It uses this pure merchant data to formulate a targeted, dynamic campaign strategy.
- 📊 **Data Analyst Agent (The Segmenter)**: Takes the Strategy from the Growth Manager, finalizes the safe SQL against the `users`/`catering_orders`/`cart` schemas, and returns the strictly counted `target_audience_size`.
- ✍️ **Copywriter Agent (The Creator)**: Understands the restaurant's unique brand (by analyzing their website URL and menu data). It selects appropriate images stored in the DB and drafts hyper-personalized "invites". It also pieces together the final "One-Pager Proposal" document.

## 5. Technical Integration Considerations
- **Isolated Backend Module**: NEVER modify existing business logic or database tables. The entire module exists cleanly in its own space (e.g., `boons_text_to_sql_agent/marketing_module/`) and registers standalone FastAPI routes to prevent polluting the Q&A text-to-sql agent.
- **Frontend**: A newly dedicated "Campaigns" tab in the React Dashboard.
- **External Tools**: 
  - Serper API (Search)
  - Tool to ingest target Merchant Website (for brand voice extraction)
  - Twilio or similar SMS pricing API (for cost calculation)
- **Data/Schema Mapping (From boons.sql)**: 
  - **New Standalone Tables**: Create `marketing_campaigns`, `marketing_merchant_assets`, and `marketing_customer_preferences`. **Absolutely NO `ALTER TABLE` commands on existing schemas**.
  - **Customers**: Perform `READ-ONLY` SQL queries on the existing `users` table for `phone`, `email` and `name` strings to populate the SMS sender list.
  - **Image Assets**: Map to existing `restaurants.gallery` or utilize the new `marketing_merchant_assets` table to generate MMS Flyers.
  - **Orders History**: Perform `READ-ONLY` SQL queries against `catering_orders`/`cart` for predictive ordering data.

## 6. Open Questions & Next Steps
- **SMS Vendor**: Which SMS provider are we using (for cost estimation)? 
- **Trigger/Cadence**: We propose **Daily Proactive Generation**. The agent runs silently every night. If it finds a highly profitable correlation or event, it pushes a "New Campaign Idea" card to the top of the merchant dashboard the next morning.
