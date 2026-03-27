# Implementation Plan: Marketing Agent Module

This document outlines the step-by-step technical implementation of the Boons Marketing Agent. Each phase is strictly paired with unit tests to ensure stability, especially regarding data-fetching, SQL safety, and AI prompt formats.

## System-Wide Engineering Standards (Google-Level Quality)
- **Strict Isolated Module**: NEVER modify existing business logic, domains, or database tables. The entire module exists cleanly in its own space (e.g., `boons_text_to_sql_agent/marketing_module/`) and registers standalone FastAPI routes.
- **Strict Clean Architecture**: Absolute separation between `Domain` (pure Python/TypeScript models), `Application` (Use Cases/Ports), `Infrastructure` (DB/LangChain Adapters), and `Interface` (FastAPI Routers/React UI).
- **Latest Open Source**: Utilize cutting-edge, stable open-source libraries (e.g., `langchain`, `sqlglot` for AST parsing, React 18+).
- **Comprehensive Testing**: 100% test coverage for all adapters and use cases. No code is merged without unit and integration tests.

## Phase 1: Domain & Infrastructure Models
**Goal**: Define the core business models and database adapters specifically for the Marketing context.

**Changes**:
- `db/init/02-marketing-schemas.sql`: Define new standalone tables (`marketing_campaigns`, `marketing_merchant_assets`, `marketing_customer_preferences`). NO ALTERING of existing `users` or `restaurants` tables.
- `boons_text_to_sql_agent/marketing_module/domain/models.py`: Create pure Pydantic models with no framework dependencies: `CampaignStrategy`, `CustomerSegment`, `SMSVariation`, and `CampaignOnePager`.
- `boons_text_to_sql_agent/marketing_module/application/ports/`: Define abstract base classes for `MarketingSchemaPort` and `MarketingAiPort`.
- `boons_text_to_sql_agent/marketing_module/infrastructure/db/marketing_schema_provider.py`: Implement the port to strictly fetch (READ-ONLY) from existing tables, and insert strictly into the new `marketing_*` tables.

**Unit Tests (Pytest)**:
- Test serialization/deserialization of domain models.
- Mock MySQL and test the `marketing_schema_provider` mapping.

## Phase 2: Growth Manager Agent (The Strategist)
**Goal**: Build the agent responsible for analyzing SQL data to propose campaign angles.

**Changes**:
- `boons_text_to_sql_agent/marketing_module/infrastructure/llm/growth_manager.py`: Implements the AI port using LangChain. Acts as an autonomous data analyst leveraging the existing `GenerateAndExecuteQueryService` to safely execute exploratory SQL.

**Unit Tests (Pytest)**:
- Test prompt template formatting against prompt injection.
- Mock the SQL query service and ensure parsing into a valid `CampaignStrategy` object.

## Phase 3: Data Analyst Agent (The Segmenter)
**Goal**: Extract the precise list of target customers based on the Strategist's idea.

**Changes**:
- `boons_text_to_sql_agent/marketing_module/infrastructure/llm/data_segmenter.py`: Takes the abstract strategy and generates the final SQL (e.g., `SELECT phone, first_name FROM users ...`).
- Uses `sqlglot` to validate generated AST syntax.

**Unit Tests (Pytest)**:
- Assert that generated SQL correctly includes the `__RLS_MERCHANTS__` security token.
- Pass malicious SQL (`DROP users`) and verify `sqlglot` termination.

## Phase 4: Copywriter Agent (Hyper-Personalization)
**Goal**: Generate the SMS/MMS variations using the merchant's website and gallery images.

**Changes**:
- `boons_text_to_sql_agent/marketing_module/infrastructure/llm/copywriter.py`: Fetches `restaurants.website` and `restaurants.gallery` (strictly READ-ONLY). Or reads custom assets from the new `marketing_merchant_assets` table.
- Implements a basic web scraper to read the homepage `<title>` and `<meta>` descriptions. Formats the final "One-Pager Proposal".

**Unit Tests (Pytest)**:
- Mock HTTP scraping (simulate "Fine Dining" vs "Fast Casual") and assert LLM tone changes.

## Phase 5: FastAPI Integration (The Presentation Layer)
**Goal**: Wire the application use cases to a standalone REST API route, avoiding pollution of existing routes.

**Changes**:
- `boons_text_to_sql_agent/marketing_module/application/use_cases/generate_campaign_service.py`: Orchestrates all 3 agent adapters sequentially.
- `boons_text_to_sql_agent/marketing_module/interface/api/marketing_routes.py`: Expose `POST /api/marketing/generate-campaign`. Attach this single router to the main app in `main.py` without touching existing endpoints.

**Unit Tests (Pytest)**:
- End-to-End Test with `TestClient` to ensure HTTP 200 JSON payload containing the full `CampaignOnePager`.

## Phase 6: React Frontend Application Implementation
**Goal**: Build the user-facing "Boons Lens" UI for the Marketing Agent, strictly separating API logic from React state.

**Changes**:
- `frontend/src/features/marketing/`: Create a feature-sliced directory following clean React architecture.
- `frontend/src/features/marketing/api/marketingApi.ts`: Isolate Axios fetch calls.
- `frontend/src/features/marketing/components/`: Build modern, responsive UI components (e.g., `CampaignProposalCard`, `SMSPhonePreview`, `AudienceInsightChart`).
- **Flow**: Merchant clicks "Discover Campaigns" -> Shows a loading skeleton analyzing data -> Renders the interactive Campaign One-Pager with SMS previews and ROI calculator.

**Unit Tests (Vitest/Jest / React Testing Library)**:
- Test component rendering and ensure `SMSPhonePreview` dynamically updates when selecting different text variations.
- Mock API responses and assert successful state transitions.
