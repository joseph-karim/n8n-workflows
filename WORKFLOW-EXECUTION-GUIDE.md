# Architecture Firms ICP Enrichment - Execution Guide

## 🎯 What This Workflow Does

**Single workflow that intelligently processes 2,146 firms:**

1. **Scores all firms** with existing CSV data (Quick ICP Score)
2. **Routes by score** to optimize API usage:
   - **P1 (75+ score)**: Deep enrichment (website + contacts + AI) → Generate brief
   - **P2 (55-74 score)**: Medium enrichment (website + AI analysis)
   - **P3 (35-54 score)**: Light enrichment (AI research only)
   - **P4 (<35 score)**: No enrichment (save as-is)
3. **Re-scores** after enrichment with new data
4. **Generates briefs** for final P1 firms only
5. **Outputs** to PostgreSQL + Google Sheets

## 📊 Expected Results

From your 2,146 firms:
- **P1 firms**: 150-250 → Full enrichment + briefs
- **P2 firms**: 300-500 → Medium enrichment
- **P3 firms**: 500-800 → Light enrichment
- **P4 firms**: 700-1,200 → Basic scoring only

**Cost Estimate**:
- **P1 enrichment** (250 firms × $0.50): ~$125
- **P2 enrichment** (400 firms × $0.15): ~$60
- **P3 enrichment** (600 firms × $0.05): ~$30
- **P1 briefs** (250 firms × $0.30): ~$75
- **Total**: ~$290-400 for full 2,146 firms

**Time Estimate**: 4-8 hours (depending on API rate limits)

## 🚀 Quick Start

### Step 1: Setup Database

```bash
# Connect to PostgreSQL
psql -U postgres -d architecture_enrichment

# Run schema
\i enriched-firms-schema.sql

# Verify
\dt
\dv
```

### Step 2: Import Workflow to n8n

1. Open n8n at `http://localhost:5678`
2. Click **Workflows** → **Import from File**
3. Select: `architecture-icp-enrichment-workflow.json`
4. Workflow imported!

### Step 3: Configure Credentials

Ensure these credentials are set up in n8n:

#### Required:
- ✅ **OpenAI API** (for AI enrichment + briefs)
- ✅ **PostgreSQL** (to save results)

#### Optional but Recommended:
- 🟡 **Apollo.io API** (for contact discovery on P1 firms)
- 🟡 **Google Sheets OAuth** (for easy viewing)
- 🟡 **Slack API** (for progress notifications)

### Step 4: Set CSV Path

1. In the workflow, click the **"Read CSV"** node
2. Set the file path to your CSV:
   ```
   /Users/josephkarim/n8n-workflows/archtecture_firms_detailed - Sheet1.csv
   ```
   Or:
   ```
   /Users/josephkarim/n8n-workflows/architecture_firms_complete_data.csv
   ```

### Step 5: Execute Workflow

Click **Execute Workflow** button.

Watch it process:
- Quick scoring: ~2 minutes for all 2,146 firms
- Enrichment: 4-8 hours total (runs in background)
- Outputs save continuously

## 📋 Workflow Logic Explained

### Phase 1: Quick ICP Scoring (All Firms)

**Node**: "Quick ICP Score"

Scores every firm based on CSV data only:

```javascript
Score Components:
1. CA Offering (30 pts) - "Yes" with details
2. CA Job Openings (25 pts) - Active postings
3. Headcount Fit (15 pts) - 201-500 ideal
4. Revenue Fit (10 pts) - $50M-$250M ideal
5. CA Tools (10 pts) - Procore mentioned
6. Project Types (10 pts) - Healthcare, data centers, etc.
7. Litigation (-15 to 0) - Contract disputes
8. Geography (5 pts) - US metros

Total: 0-105 points
```

**Output**: Every firm gets an `initialScore` and `enrichmentTier`

### Phase 2: Smart Enrichment (Tiered by Score)

**Node**: "Enrichment Router"

Routes firms to appropriate enrichment:

#### Route 1: P4 Firms (Score <35) → No Enrichment
- Goes straight to database
- No API calls
- Saves cost on low-value prospects

#### Route 2: P3 Firms (Score 35-54) → Light Enrichment
- **AI Research** node only
- Confirms CA offering
- Identifies CA tools
- Extracts project verticals
- Cost: ~$0.05 per firm

#### Route 3: P2 Firms (Score 55-74) → Medium Enrichment
- **Website Scrape** (Jina Reader, free)
- **AI Analysis** of website content
  - Deep CA offering confirmation
  - Technology stack analysis
  - Project portfolio breakdown
  - Team capabilities assessment
  - Pain points identification
  - Digital maturity scoring
- Cost: ~$0.15 per firm

#### Route 4: P1 Firms (Score 75+) → Deep Enrichment
- **Website Scrape** + **AI Analysis** (same as P2)
- **+ Apollo Contact Discovery**
  - Finds 5-10 decision-makers
  - Principals, Partners, Directors, CTOs, CA Managers
- **+ AI Contact Analysis**
  - Scores each contact
  - Identifies pain points
  - Recommends outreach strategy
  - Creates personalized angles
- Cost: ~$0.50 per firm

### Phase 3: Re-scoring (All Enriched Firms)

**Node**: "Re-score After Enrichment"

Recalculates score with enriched data:

```javascript
Bonus Points:
- Confirmed CA offering (+ confidence): +15-20 pts
- CA tools identified: +8-10 pts
- Target verticals confirmed: +8 pts
- High digital maturity: +10 pts
- Pain points found: +5 pts (opportunity!)
- High decision-maker authority: +10-15 pts
- Outreach readiness high: +10 pts

New Final Score = Initial Score + Bonuses
```

**Output**: `finalScore` and `finalPriority` (may change after enrichment!)

### Phase 4: Brief Generation (P1 Only)

**Node**: "Filter for Brief (P1 Only)"

Only firms with `finalPriority = 'P1'` proceed.

**Node**: "Generate Outreach Brief (GPT-4o)"

Creates comprehensive 10-section brief:
1. Executive Summary
2. ICP Fit Analysis
3. Technology & Process Assessment
4. Contact Strategy (with email/LinkedIn sequences)
5. Talking Points (pain point → solution mapping)
6. Competitive Context
7. Case Study Match
8. Warm Intro Paths
9. Key Risks/Objections
10. Supporting Evidence

**Output**: Ready-to-use outreach brief (~1,000-2,000 words)

### Phase 5: Output & Notification

**Nodes**:
- "Save to PostgreSQL" - All firms
- "Export to Google Sheets" - All firms (prioritized view)
- "Slack Notification" - P1/P2 firms only

## 📂 Database Queries

### View All P1 Firms with Briefs

```sql
SELECT * FROM v_p1_priority_firms
WHERE has_brief = true
ORDER BY final_score DESC;
```

### View Enrichment Statistics

```sql
SELECT * FROM v_enrichment_stats;
```

### Export P1 Firms to CSV

```sql
COPY (
  SELECT
    company_name,
    location,
    headcount,
    revenue,
    final_score,
    enriched_data->>'bestContact' as best_contact,
    'Has Brief' as status
  FROM enriched_architecture_firms
  WHERE priority = 'P1' AND brief IS NOT NULL
  ORDER BY final_score DESC
) TO '/tmp/p1_firms_with_briefs.csv' CSV HEADER;
```

### Find Firms Using Procore

```sql
SELECT
    company_name,
    final_score,
    priority,
    enriched_data->'caTools'->'confirmed_tools'
FROM enriched_architecture_firms
WHERE enriched_data->'caTools'->'confirmed_tools' @> '["Procore"]'::jsonb
ORDER BY final_score DESC;
```

### Firms with Pain Points (Opportunities!)

```sql
SELECT
    company_name,
    final_score,
    priority,
    enriched_data->'painPoints'
FROM enriched_architecture_firms
WHERE enriched_data->'painPoints' IS NOT NULL
    AND jsonb_array_length(enriched_data->'painPoints') > 0
ORDER BY final_score DESC;
```

## 📊 Google Sheets Output

The workflow exports to Google Sheets with columns:

| Company Name | Location | Headcount | Revenue | Initial Score | Final Score | Priority | Enrichment Tier | CA Confirmed | CA Tools | Best Contact | Brief Generated | Processed Date |
|--------------|----------|-----------|---------|---------------|-------------|----------|-----------------|--------------|----------|--------------|-----------------|----------------|
| Cushing Terrell | Billings, MT | 201-500 | $100M-$250M | 85 | 103 | P1 | deep | Yes | Procore | John Doe - Dir. Ops | Yes | 2026-01-28 |

**Sheet is automatically sorted by Final Score (descending)**

## 🎛️ Customization Options

### Adjust Score Thresholds

In the **"Quick ICP Score"** node, modify lines 110-120:

```javascript
// Current thresholds
if (score >= 75) priority = 'P1'; // Change to 80 for stricter P1
else if (score >= 55) priority = 'P2'; // Change to 60 for stricter P2
```

### Change Enrichment Routing

In the **"Enrichment Router"** node, adjust conditions:

```javascript
// Example: Only enrich P1 + P2, skip P3
Route 1: enrichmentTier === 'deep'
Route 2: enrichmentTier === 'medium'
Route 3: SKIP (delete this route)
Route 4: Default (everything else → save directly)
```

### Modify AI Prompts

Each AI node has customizable prompts:

- **"AI: Light Research (P3)"** - Line 21-50
- **"AI: Medium Analysis (P2)"** - Line 21-80
- **"AI: Contact Analysis (P1)"** - Line 21-60
- **"Generate Outreach Brief (GPT-4o)"** - Line 21-150

### Change LLM Models

To reduce cost, change all to `gpt-4o-mini`:

1. Click each AI node
2. Change `model` parameter from `gpt-4o` to `gpt-4o-mini`
3. **Trade-off**: Lower quality briefs, save ~60% cost

## ⚠️ Important Notes

### Rate Limiting

If you hit API rate limits:

1. **Reduce batch size**: In "Split In Batches" node, change from 10 to 5
2. **Add Wait nodes**: Insert "Wait" node (1-2 seconds) after API calls
3. **Spread execution**: Run in multiple sessions (P1 firms first, then P2, etc.)

### Error Handling

Each API node has "Continue on Fail" enabled by default:

- Failed enrichments → saved with partial data
- Failed briefs → P1 firm saved without brief (can re-generate later)
- Failed database inserts → logged to n8n execution log

### Resume from Failure

If workflow stops mid-execution:

1. Check database for last processed firm:
   ```sql
   SELECT company_name, processed_at
   FROM enriched_architecture_firms
   ORDER BY processed_at DESC
   LIMIT 1;
   ```
2. Edit CSV to remove already-processed firms
3. Re-run workflow with remaining firms

### Re-run Enrichment

To re-enrich specific firms:

1. Delete from database:
   ```sql
   DELETE FROM enriched_architecture_firms
   WHERE company_name IN ('Firm 1', 'Firm 2');
   ```
2. Create new CSV with just those firms
3. Run workflow

## 📈 Monitoring Progress

### Real-Time Progress

Watch the n8n execution log:
- Green = Success
- Red = Error (check error message)
- Yellow = In progress

### Database Progress Check

```sql
-- Count by priority
SELECT priority, COUNT(*)
FROM enriched_architecture_firms
GROUP BY priority;

-- Recent processing
SELECT company_name, final_score, priority, processed_at
FROM enriched_architecture_firms
ORDER BY processed_at DESC
LIMIT 20;

-- Completion percentage
SELECT
    COUNT(*) as processed,
    (COUNT(*) * 100.0 / 2146) as percentage_complete
FROM enriched_architecture_firms;
```

### Slack Notifications

If Slack is configured, you'll get real-time updates:
- Every P1 firm processed
- Every P2 firm processed
- Batch completion summaries

## 🏆 Success Metrics

After workflow completes, check:

✅ **Total firms processed**: Should be 2,146
✅ **P1 firms identified**: Target 150-250 (7-12%)
✅ **Briefs generated**: Should match P1 count
✅ **Enrichment cost**: Target <$400 total
✅ **Processing time**: 4-8 hours

### Quality Check

Review 5-10 random P1 briefs:
- Are contacts relevant?
- Are pain points accurate?
- Is outreach strategy actionable?
- Does ICP fit analysis make sense?

## 🎯 Next Steps After Workflow Completes

### 1. Export P1 List (Week 1)

```sql
-- Export top 50 P1 firms
COPY (
  SELECT
    company_name,
    location,
    final_score,
    enriched_data->>'bestContact' as contact,
    enriched_data->'caOffering'->>'description' as ca_notes,
    enriched_data->'painPoints' as pain_points
  FROM enriched_architecture_firms
  WHERE priority = 'P1' AND brief IS NOT NULL
  ORDER BY final_score DESC
  LIMIT 50
) TO '/tmp/top_50_p1_firms.csv' CSV HEADER;
```

### 2. Review Briefs

- Read top 10 briefs
- Validate contact info (check LinkedIn)
- Confirm pain points resonate
- Adjust outreach copy if needed

### 3. Launch Outreach (Week 2)

- Load contacts into CRM (HubSpot, Salesforce)
- Set up email sequences (from briefs)
- Connect on LinkedIn (use connection notes from briefs)
- Track responses

### 4. Monitor & Iterate (Ongoing)

- Track response rates by priority tier
- Adjust ICP scoring weights if needed
- Re-enrich P2 firms quarterly (some may become P1)
- Update contact info monthly

### 5. Scale to More Firms (Month 2+)

Once proven with 2,146 firms:
- Add 10k+ firm list
- Run same workflow
- Optimize based on learnings

## 💡 Pro Tips

1. **Test with 50 firms first**: Create a small CSV with 50 mixed-score firms to validate logic
2. **Run overnight**: Let it process while you sleep (4-8 hours)
3. **Check costs mid-run**: OpenAI usage dashboard to ensure on-track
4. **Export to CRM**: Use PostgreSQL → CRM integration (Zapier, Make.com)
5. **A/B test outreach**: Split P1 firms into two groups, test different angles

## 🐛 Troubleshooting

### "Authentication failed" errors
- Check API keys in n8n Credentials
- Verify API quota not exceeded (OpenAI, Apollo)

### "JSON parse error" from LLM
- LLM returned non-JSON despite `response_format`
- Node will continue with partial data
- Check `enriched_data` field for partial results

### Website scraping timeouts
- Some sites block scrapers
- Node will fail gracefully
- Firm saved with available data only

### No contacts found (Apollo)
- Firm may not be in Apollo database
- Try alternative: Hunter.io, ZoomInfo
- Or manually find on LinkedIn

### Workflow very slow
- Reduce batch size (Split In Batches: 10 → 5)
- Check API rate limits (OpenAI: 500 req/min, Apollo: 60 req/min)
- Add Wait nodes between API calls

## 📚 Additional Resources

- **ICP Scoring Criteria**: See `ICP-SCORING-ANALYSIS.md`
- **Database Schema**: See `enriched-firms-schema.sql`
- **Original Workflow**: See `architecture-firm-enrichment-pipeline.json` (for comparison)

---

## 🚀 Ready to Run!

1. ✅ Database schema created
2. ✅ Workflow imported to n8n
3. ✅ Credentials configured
4. ✅ CSV path set
5. ✅ Execute workflow button clicked!

**Your enriched, scored, prioritized list of 2,146 architecture firms will be ready in 4-8 hours.**

Good luck! 🎯
