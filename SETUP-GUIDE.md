# Architecture Firm Enrichment Pipeline - Setup Guide

## Overview

This n8n workflow processes architecture firms through a tiered enrichment pipeline:
- **Signal Detection**: Searches for digital transformation, growth, and tech adoption signals
- **Tiered Enrichment**: Light (all) → Medium (promising) → Heavy (high-priority)
- **Contact Discovery**: Finds decision-makers via Apollo.io
- **Scoring & Prioritization**: P1-P4 ranking based on ICP fit
- **Brief Generation**: Creates actionable sales briefs for top prospects

## Prerequisites

### 1. n8n Installation

```bash
# Option A: Docker (recommended)
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n

# Option B: npm
npm install n8n -g
n8n start

# Option C: Self-hosted with queue mode (for scale)
# See: https://docs.n8n.io/hosting/scaling/queue-mode/
```

### 2. PostgreSQL Database

```bash
# Local with Docker
docker run --name postgres-enrichment \
  -e POSTGRES_PASSWORD=yourpassword \
  -e POSTGRES_DB=architecture_enrichment \
  -p 5432:5432 \
  -d postgres:16

# Or use managed PostgreSQL (Supabase, Neon, RDS, etc.)
```

### 3. Required API Keys

You'll need accounts and API keys for:

| Service | Purpose | Free Tier | Paid Plans |
|---------|---------|-----------|------------|
| **OpenAI** | LLM analysis & classification | No | $5/1M tokens (GPT-4o-mini) |
| **SerpAPI** | Google search signals | 100 searches/mo | $50/mo (5k searches) |
| **Apollo.io** | Contact discovery | 60 credits/mo | $49/mo (unlimited) |
| **BuiltWith** | Tech stack detection | No | $295/mo (basic) |
| **Jina AI** (alternative to Firecrawl) | Website scraping | 1M tokens/mo | Free for now |

**Alternatives for cost reduction:**
- **SerpAPI** → Google Custom Search API ($5/1000 queries)
- **BuiltWith** → Wappalyzer API (cheaper)
- **Apollo** → Hunter.io or Clearbit (similar pricing)

## Setup Steps

### Step 1: Database Setup

```bash
# Connect to your PostgreSQL database
psql -U postgres -d architecture_enrichment

# Run the schema
\i database-schema.sql

# Verify tables created
\dt
```

### Step 2: Configure n8n Credentials

Open n8n at `http://localhost:5678` and add credentials:

#### 2.1 OpenAI
- Go to **Settings → Credentials → Add Credential**
- Search "OpenAI"
- Add your API key from https://platform.openai.com/api-keys

#### 2.2 SerpAPI
- Credential type: **HTTP Query Auth**
- Name: `SerpAPI Credentials`
- Query Parameters:
  - Name: `api_key`
  - Value: `your_serpapi_key`

#### 2.3 Apollo.io
- Credential type: **HTTP Header Auth**
- Name: `Apollo API`
- Header:
  - Name: `X-Api-Key`
  - Value: `your_apollo_api_key`

#### 2.4 BuiltWith
- Credential type: **HTTP Header Auth**
- Name: `BuiltWith API`
- Header:
  - Name: `Authorization`
  - Value: `Bearer your_builtwith_key`

#### 2.5 PostgreSQL
- Credential type: **Postgres**
- Host: `localhost` (or your DB host)
- Database: `architecture_enrichment`
- User: `postgres`
- Password: your password
- Port: `5432`

#### 2.6 Google Sheets (Optional Output)
- Credential type: **Google Sheets OAuth2**
- Follow OAuth flow

#### 2.7 Slack (Optional Notifications)
- Credential type: **Slack API**
- Create app at https://api.slack.com/apps
- Add bot token

### Step 3: Import Workflow

1. Open n8n
2. Click **Workflows** → **Import from File**
3. Select `architecture-firm-enrichment-pipeline.json`
4. The workflow will appear in your workflows list

### Step 4: Configure Environment Variables

In n8n, set these environment variables (Settings → Variables):

```bash
GOOGLE_SHEET_ID=your_google_sheet_id
SLACK_CHANNEL=#sales-leads
```

### Step 5: Prepare Your CSV

Your CSV should have these columns (at minimum):
- `company_name` or `name` or `firm_name`
- `website` or `domain`
- `employee_count` or `employees` (optional)
- `linkedin` or `linkedin_url` (optional)

Example CSV:
```csv
firm_name,domain,employee_count,linkedin_url
Gensler,gensler.com,150,https://linkedin.com/company/gensler
HDR Inc,hdrinc.com,200,https://linkedin.com/company/hdr
Perkins&Will,perkinswill.com,180,https://linkedin.com/company/perkins-will
```

### Step 6: Test with Sample Data

1. Create a test CSV with 5-10 firms
2. In n8n, open the workflow
3. Click the **Read CSV File** node
4. Click **Execute Node** and provide your CSV file path
5. Watch the execution flow through the pipeline

## Workflow Logic Explained

### Node Flow

```
CSV → Parse → Split Batches → Normalize Data
  ↓
Signal Detection (SerpAPI + GPT-4o-mini)
  ↓
Enrichment Router (based on signal tier)
  ↓
┌─────────────┬─────────────┬─────────────┐
│ Light       │ Medium      │ Heavy       │
│ (All firms) │ (30%)       │ (10%)       │
├─────────────┼─────────────┼─────────────┤
│ BuiltWith   │ + Apollo    │ + Profile   │
│ Website     │   Contacts  │   Analysis  │
│ Scrape      │             │   (LLM)     │
└─────────────┴─────────────┴─────────────┘
  ↓
Scoring Engine (JavaScript)
  ↓
Brief Generation (P1-P3 only, GPT-4o)
  ↓
Database + Google Sheets + Slack
```

### Scoring Algorithm

The scoring engine in the workflow calculates:

**Total Score = Signal Score (40) + Enrichment Score (30) + Contact Score (30)**

- **Signal Score**: Digital transformation signals (10pts), growth signals (8pts), CA signals (12pts)
- **Enrichment Score**: Target verticals (8pts each), CA emphasis (15pts), tech stack (10pts)
- **Contact Score**: Average contact quality (30pts), decision-maker bonus (10pts)

**Priority Tiers**:
- **P1**: 80-100 (immediate outreach)
- **P2**: 65-79 (nurture campaign)
- **P3**: 50-64 (monitor signals)
- **P4**: <50 (low priority)

## Running at Scale

### For 925 Firms:

**Expected Processing Time**: 4-8 hours (depending on API rate limits)

**Cost Estimate**:
- OpenAI (GPT-4o-mini): ~$15-30
- SerpAPI: ~$50 (if 900+ searches)
- Apollo.io: Free tier (60 credits) or $49/mo
- BuiltWith: $295/mo or skip (optional)
- **Total**: ~$100-400 for initial run

### Optimization Tips

1. **Batch Processing**: The workflow already splits into batches of 10. Adjust in "Split In Batches" node.

2. **Rate Limiting**: Add "Wait" nodes between API calls if hitting rate limits:
   ```
   Wait Node → Time: 1 second (for Apollo, SerpAPI)
   ```

3. **Caching**: For re-runs, add a "Postgres" check before enrichment:
   ```sql
   SELECT * FROM enriched_companies WHERE domain = $domain AND last_enriched_at > NOW() - INTERVAL '7 days'
   ```

4. **Queue Mode** (for 10k+ firms):
   ```bash
   # Start Redis
   docker run -d --name redis -p 6379:6379 redis:latest

   # Start n8n in queue mode
   docker-compose up -d  # (use queue mode docker-compose.yml)
   ```

5. **Error Handling**: Enable "Continue on Fail" in nodes that call external APIs.

## Monitoring & Debugging

### Check Database Progress

```sql
-- Overall stats
SELECT
    enrichment_status,
    priority,
    COUNT(*) as count,
    AVG(total_score) as avg_score
FROM enriched_companies
GROUP BY enrichment_status, priority;

-- Recent processing
SELECT * FROM daily_processing_stats ORDER BY processing_date DESC LIMIT 7;

-- High-priority leads
SELECT * FROM high_priority_leads LIMIT 20;
```

### View n8n Execution Logs

- Go to **Executions** tab in n8n
- Filter by date/status
- Click execution to see detailed flow

### Common Issues

#### 1. "Authentication failed" errors
- Double-check API keys in Credentials
- Verify rate limits not exceeded

#### 2. "JSON parse error" from LLM
- OpenAI sometimes returns non-JSON despite `response_format`
- Add error handling: "Continue on Fail" + fallback values

#### 3. "Timeout" on website scraping
- Increase timeout in HTTP Request node (Options → Timeout: 30000ms)
- Some sites block scrapers → use residential proxies

#### 4. Missing contacts from Apollo
- Domain may not be in Apollo database
- Try alternative: Hunter.io or manual LinkedIn search

## Next Steps

### Phase 1: Initial Run (Week 1)
- [ ] Test with 50 firms
- [ ] Validate scoring logic
- [ ] Review brief quality
- [ ] Adjust LLM prompts

### Phase 2: Full Dataset (Week 2)
- [ ] Process all 925 firms
- [ ] Export to Google Sheets
- [ ] Review P1/P2 briefs
- [ ] Start outreach on top 20 firms

### Phase 3: Ongoing Refresh (Monthly)
- [ ] Re-run signal detection on all firms
- [ ] Deep enrich new high-scoring firms
- [ ] Update contacts (job changes)
- [ ] Track outreach outcomes

### Phase 4: Scale to 10k+ Firms
- [ ] Set up queue mode + workers
- [ ] Enable caching (Redis)
- [ ] Implement incremental updates
- [ ] Add Prometheus monitoring

## Advanced: Sub-Workflows

To make this more modular, split into sub-workflows:

1. **Signal Detection Workflow** (called via "Execute Workflow" node)
2. **Light Enrichment Workflow**
3. **Heavy Enrichment Workflow**
4. **Brief Generation Workflow**

This allows:
- Independent testing
- Parallel processing
- Easier debugging
- Reusability across projects

## Cost Optimization Strategies

### Option 1: Hybrid Approach
- Use GPT-4o-mini for 95% of tasks
- Only use GPT-4o for final briefs (P1/P2 only)
- **Savings**: ~70% on LLM costs

### Option 2: Batch API
- OpenAI Batch API is 50% cheaper
- Trade-off: 24h delay
- Good for weekly/monthly refreshes
- **Savings**: 50% on LLM costs

### Option 3: Open Source LLMs
- Run Llama 3.1 or Mistral locally
- Use for classification/extraction
- OpenAI only for final briefs
- **Savings**: 90% on LLM costs (but need GPU)

### Option 4: Reduce API Calls
- Skip BuiltWith (use website scraping only)
- Use Google Custom Search instead of SerpAPI
- Limit contact discovery to P1/P2 firms only
- **Savings**: 60% on data provider costs

## Support & Resources

- **n8n Docs**: https://docs.n8n.io
- **n8n Community**: https://community.n8n.io
- **OpenAI API Docs**: https://platform.openai.com/docs
- **Apollo API Docs**: https://apolloio.github.io/apollo-api-docs/
- **SerpAPI Docs**: https://serpapi.com/docs

## Troubleshooting Checklist

- [ ] All credentials configured correctly
- [ ] Database schema created
- [ ] CSV file path correct
- [ ] CSV columns match expected format
- [ ] API keys have sufficient credits/quota
- [ ] n8n has internet access (for API calls)
- [ ] PostgreSQL connection works (test query)
- [ ] Environment variables set (for Sheets/Slack)

---

**Ready to process your 925 firms!**

For questions or issues, review the n8n execution logs and database tables for detailed error messages.
