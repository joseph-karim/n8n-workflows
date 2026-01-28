# Architecture Firm Enrichment Pipeline for n8n

**A production-ready n8n workflow for enriching and scoring 925+ architecture firms with AI-powered intelligence.**

## 🎯 What This Does

Processes architecture firms through a sophisticated enrichment pipeline:

1. **Signal Detection** - Searches for digital transformation, growth, and technology adoption signals
2. **Tiered Enrichment** - Routes firms through light/medium/heavy enrichment based on initial signals
3. **Contact Discovery** - Finds decision-makers and key stakeholders via Apollo.io
4. **AI Analysis** - Uses GPT-4o/GPT-4o-mini to analyze profiles and extract insights
5. **Intelligent Scoring** - Ranks firms 0-100 with P1-P4 priority tiers
6. **Brief Generation** - Creates actionable sales briefs for high-priority targets

## 📦 What's Included

```
├── architecture-firm-enrichment-pipeline.json   # Main n8n workflow
├── database-schema.sql                          # PostgreSQL database schema
├── SETUP-GUIDE.md                               # Detailed setup instructions
├── .env.template                                # Environment variables template
└── sample-architecture-firms.csv                # Example CSV with 20 firms
```

## ⚡ Quick Start

### 1. Prerequisites

```bash
# Install n8n (choose one)
docker run -it --rm --name n8n -p 5678:5678 n8nio/n8n
# OR
npm install n8n -g && n8n start

# Install PostgreSQL
docker run --name postgres-enrichment \
  -e POSTGRES_PASSWORD=yourpassword \
  -e POSTGRES_DB=architecture_enrichment \
  -p 5432:5432 -d postgres:16
```

### 2. Database Setup

```bash
psql -U postgres -d architecture_enrichment -f database-schema.sql
```

### 3. Get API Keys

Required services:
- [OpenAI API](https://platform.openai.com/api-keys) - LLM analysis
- [SerpAPI](https://serpapi.com/manage-api-key) - Search signals
- [Apollo.io](https://app.apollo.io/#/settings/integrations/api) - Contact discovery

Optional:
- [BuiltWith](https://api.builtwith.com/) - Tech stack detection
- Google Sheets OAuth - Output
- Slack Bot Token - Notifications

### 4. Configure n8n

1. Open n8n at `http://localhost:5678`
2. Go to **Settings → Credentials**
3. Add credentials for each service (see SETUP-GUIDE.md for details)

### 5. Import Workflow

1. Click **Workflows → Import from File**
2. Select `architecture-firm-enrichment-pipeline.json`
3. Workflow is now ready!

### 6. Test with Sample Data

```bash
# Use the included sample CSV
# In n8n, execute the "Read CSV File" node with:
# File Path: /path/to/sample-architecture-firms.csv
```

## 🏗️ Workflow Architecture

```
┌─────────────────────────────────────────────────────────┐
│ CSV Upload (925 firms)                                  │
└────────────────┬────────────────────────────────────────┘
                 │
         ┌───────▼────────┐
         │ Normalize Data │
         └───────┬────────┘
                 │
    ┌────────────▼─────────────┐
    │ Signal Detection         │ ← SerpAPI + GPT-4o-mini
    │ - Search Google          │
    │ - Classify signals       │
    │ - Initial scoring (0-100)│
    └────────────┬─────────────┘
                 │
         ┌───────▼────────┐
         │ Router         │ Split by tier
         └───┬────────┬───┘
             │        │
   ┌─────────▼──┐ ┌──▼─────────┐
   │ Light      │ │ Medium     │
   │ (70-80%)   │ │ (20-30%)   │
   │            │ │            │
   │ BuiltWith  │ │ + Apollo   │
   │ Website    │ │   Contacts │
   │ LLM        │ │   Profile  │
   │ Extract    │ │   Analysis │
   └─────────┬──┘ └──┬─────────┘
             │        │
             └───┬────┘
                 │
         ┌───────▼────────┐
         │ Scoring Engine │ Calculate final score
         └───────┬────────┘
                 │
         ┌───────▼────────┐
         │ Brief Gen      │ P1-P3 only (GPT-4o)
         └───────┬────────┘
                 │
     ┌───────────▼───────────┐
     │ Output                │
     │ - PostgreSQL          │
     │ - Google Sheets       │
     │ - Slack notification  │
     └───────────────────────┘
```

## 🎯 Scoring Algorithm

**Total Score = Signal (40) + Enrichment (30) + Contact (30)**

### Signal Score (max 40 points)
- Digital transformation signals: 10pts each
- Growth indicators: 8pts each
- Tech stack signals: 6pts each
- Construction Admin signals: 12pts each
- Target vertical signals: 4pts each

### Enrichment Score (max 30 points)
- Target verticals match: 8pts each
- CA emphasis detected: 15pts
- Modern tech stack: 10pts

### Contact Score (max 30 points)
- Average contact quality: up to 30pts
- Decision-maker bonus: +10pts

### Priority Tiers
- **P1**: 80-100 → Immediate outreach
- **P2**: 65-79 → Nurture campaign
- **P3**: 50-64 → Monitor signals
- **P4**: <50 → Low priority

## 💰 Cost Estimation

### For 925 Firms (Initial Run)

| Service | Usage | Cost |
|---------|-------|------|
| OpenAI (GPT-4o-mini) | ~2M tokens | $15-30 |
| OpenAI (GPT-4o briefs) | ~500K tokens | $50-75 |
| SerpAPI | 925 searches | $50 |
| Apollo.io | Free tier or $49/mo | $0-49 |
| BuiltWith (optional) | 925 lookups | $295/mo |
| **Total** | | **$130-500** |

### Ongoing (Monthly Refresh)
- Signal detection only: ~$15-25/mo
- Re-enrich top 200: ~$40-60/mo

### Cost Reduction Tips
1. Use GPT-4o-mini for everything except briefs → **Save 70%**
2. Skip BuiltWith (use website scraping) → **Save $295/mo**
3. Use OpenAI Batch API (50% discount) → **Save 50%** (24h delay)
4. Process only high-scorers for contact discovery → **Save 60% on Apollo**

## 📊 Expected Output

### Database Tables
- **enriched_companies**: All firms with scores and enrichment data
- **signals**: Time-series signal tracking
- **contacts**: Individual contacts with analysis
- **briefs**: Generated sales briefs

### Views
- `high_priority_leads` - P1-P3 firms ready for outreach
- `signal_summary` - Signal counts by category
- `contact_summary` - Contact quality metrics
- `daily_processing_stats` - Pipeline performance

### Sample Queries

```sql
-- Top 20 priority firms
SELECT * FROM high_priority_leads LIMIT 20;

-- Firms with most signals
SELECT firm_name, COUNT(s.*) as signals
FROM enriched_companies c
JOIN signals s ON c.id = s.company_id
GROUP BY c.firm_name
ORDER BY signals DESC;

-- Ready for outreach (high score + contacts)
SELECT firm_name, total_score, priority,
       jsonb_array_length(contacts) as contact_count
FROM enriched_companies
WHERE total_score >= 70
  AND contacts IS NOT NULL
ORDER BY total_score DESC;
```

## 🔧 Customization

### Adjust Enrichment Thresholds

In the **Enrichment Router** node, modify the IF conditions:

```javascript
// Current: tier === 'heavy' or tier === 'medium'
// Custom: score-based routing
{{ $json.totalScore >= 70 }}  // Heavy enrichment
{{ $json.totalScore >= 40 }}  // Medium enrichment
// Else: Light enrichment
```

### Modify Scoring Weights

In the **Scoring Engine** code node, adjust:

```javascript
// Line ~30: Signal weights
signalScore += digitalTransformationSignals.length * 10;  // Change multiplier
signalScore += caSignals.length * 12;  // Increase CA importance

// Line ~50: Enrichment weights
if (lightEnrichment.caEmphasis) {
  enrichmentScore += 15;  // Adjust CA emphasis weight
}
```

### Change LLM Models

In each LLM node:
- **Light tasks**: `gpt-4o-mini` (cheapest)
- **Heavy analysis**: `gpt-4o-mini` or `gpt-4o`
- **Briefs**: `gpt-4o` (best quality)

### Add Custom Signals

In **LLM: Classify Signals** prompt, add categories:

```
6. Sustainability Initiatives (LEED, net-zero projects)
7. International Expansion (new global offices)
```

## 🚀 Scaling to 10k+ Firms

### Enable Queue Mode

```bash
# Start Redis
docker run -d --name redis -p 6379:6379 redis:latest

# Start n8n workers
docker run --name n8n-worker-1 \
  -e EXECUTIONS_MODE=queue \
  -e QUEUE_BULL_REDIS_HOST=redis \
  -e N8N_CONCURRENCY=10 \
  n8nio/n8n worker

# Repeat for multiple workers
```

### Use Sub-Workflows

Split the monolithic workflow into:
1. `signal-detection-subworkflow.json`
2. `light-enrichment-subworkflow.json`
3. `heavy-enrichment-subworkflow.json`
4. `brief-generation-subworkflow.json`

Call via "Execute Workflow" nodes for better parallelization.

### Add Caching

Before each enrichment step, check PostgreSQL:

```sql
SELECT * FROM enriched_companies
WHERE domain = '{{ $json.domain }}'
  AND last_enriched_at > NOW() - INTERVAL '30 days'
```

Skip enrichment if recent data exists.

## 📈 Monitoring

### Check Progress

```sql
-- Real-time stats
SELECT enrichment_status, COUNT(*)
FROM enriched_companies
GROUP BY enrichment_status;

-- Average processing time
SELECT
  AVG(completed_at - started_at) as avg_duration
FROM enrichment_jobs
WHERE status = 'completed';
```

### n8n Execution Dashboard

- Go to **Executions** tab
- Filter by status: Success/Error
- Review detailed logs for each node

### Set Up Alerts

In the **Slack Notification** node, customize triggers:

```javascript
// Alert for P1 firms only
{{ $json.scoring.priority === 'P1' }}

// Alert for ICP fit + high score
{{ $json.scoring.icpFit && $json.scoring.totalScore >= 80 }}
```

## 🐛 Troubleshooting

### Common Issues

1. **"Authentication failed"**
   - Double-check API keys in Credentials
   - Verify API quota not exceeded

2. **"JSON parse error"**
   - LLM returned non-JSON (despite response_format)
   - Enable "Continue on Fail" and add fallback

3. **"Timeout"**
   - Increase timeout in HTTP Request nodes (Options → Timeout: 30000ms)
   - Some sites block scrapers

4. **"Rate limit exceeded"**
   - Add Wait nodes (1-2 seconds) between API calls
   - Reduce batch size in Split In Batches node

### Enable Debug Logs

In each node → Settings → "Always Output Data"

## 📚 Resources

- [n8n Documentation](https://docs.n8n.io)
- [n8n Queue Mode Guide](https://docs.n8n.io/hosting/scaling/queue-mode/)
- [OpenAI Structured Outputs](https://platform.openai.com/docs/guides/structured-outputs)
- [Apollo API Docs](https://apolloio.github.io/apollo-api-docs/)
- [SerpAPI Docs](https://serpapi.com/docs)

## 🤝 Support

For detailed setup instructions, see [SETUP-GUIDE.md](./SETUP-GUIDE.md)

## 📝 License

This workflow is provided as-is for your use with your 925 architecture firms.

---

**Ready to enrich your architecture firm database!**

Start with the sample CSV (20 firms) to test, then run your full 925 firm dataset.
