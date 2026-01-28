# Architecture Firms: Smart ICP Enrichment System

**Intelligent workflow that enriches 2,146 firms, scores them for ICP fit, and generates outreach briefs for top prospects.**

## 🎯 What This System Does

Takes your existing CSV with 2,146 architecture firms (with "Research with AI" placeholders) and:

1. ✅ **Scores every firm** (0-105 points) based on ICP fit
2. ✅ **Intelligently enriches** only promising firms (saves 60-70% on API costs)
3. ✅ **Finds decision-makers** for top prospects (Apollo.io)
4. ✅ **Generates outreach briefs** for P1 firms (ready to send)
5. ✅ **Outputs priority list** (PostgreSQL + Google Sheets)

## 📊 Expected Output

From your 2,146 firms:

| Priority | Score Range | Count | Action | Enrichment | Brief |
|----------|-------------|-------|--------|------------|-------|
| **P1** | 80-105 | ~150-250 | Immediate outreach | Deep (website + contacts + AI) | ✅ Yes |
| **P2** | 65-79 | ~300-500 | Nurture campaign | Medium (website + AI) | ❌ No |
| **P3** | 50-64 | ~500-800 | Monitor quarterly | Light (AI only) | ❌ No |
| **P4** | <50 | ~700-1,200 | Low priority | None | ❌ No |

**Cost**: ~$300-400 total
**Time**: 4-8 hours
**Output**: 150-250 ready-to-use outreach briefs

## 📂 Files in This System

### Core Workflow
- **`architecture-icp-enrichment-workflow.json`** - Main n8n workflow (import this!)

### Database
- **`enriched-firms-schema.sql`** - PostgreSQL schema for storing results

### Documentation
- **`WORKFLOW-EXECUTION-GUIDE.md`** - Step-by-step execution instructions
- **`ICP-SCORING-ANALYSIS.md`** - Detailed ICP criteria and scoring methodology
- **`README-ICP-ENRICHMENT.md`** - This file

### Your Data
- **`archtecture_firms_detailed - Sheet1.csv`** - Your 2,146 firms
- **`architecture_firms_complete_data.csv`** - Alternative format (same data)

## 🚀 Quick Start (3 Steps)

### 1. Setup Database

```bash
psql -U postgres -d architecture_enrichment -f enriched-firms-schema.sql
```

### 2. Import Workflow to n8n

1. Open n8n: `http://localhost:5678`
2. Workflows → Import → Select `architecture-icp-enrichment-workflow.json`
3. Configure credentials (OpenAI, Apollo, PostgreSQL)

### 3. Execute

1. Set CSV path in "Read CSV" node
2. Click **Execute Workflow**
3. Wait 4-8 hours
4. Check results in PostgreSQL or Google Sheets

## 🏗️ Workflow Architecture

```
CSV (2,146 firms)
       ↓
┌──────────────────────┐
│ Quick ICP Score      │ ← Scores all firms with existing data
│ (0-105 points)       │
└──────────────────────┘
       ↓
┌──────────────────────┐
│ Smart Router         │ ← Routes by score
└──────────────────────┘
       ↓
    ┌──┴───┬───────┬─────────┐
    │      │       │         │
┌───▼──┐ ┌─▼──┐ ┌──▼───┐ ┌──▼───┐
│ P4   │ │ P3 │ │  P2  │ │  P1  │
│      │ │    │ │      │ │      │
│ Skip │ │ AI │ │ Web  │ │ Web  │
│      │ │ Res│ │ +AI  │ │ +AI  │
│      │ │    │ │      │ │ +    │
│      │ │    │ │      │ │ Cont.│
└───┬──┘ └─┬──┘ └──┬───┘ └──┬───┘
    │      │       │         │
    └──────┴───┬───┴─────────┘
               ↓
       ┌───────────────┐
       │ Re-Score      │ ← Adjusts score with enriched data
       └───────────────┘
               ↓
         ┌─────────┐
         │ P1 only │
         └─────────┘
               ↓
       ┌───────────────┐
       │ Generate      │ ← GPT-4o creates comprehensive brief
       │ Brief         │
       └───────────────┘
               ↓
    ┌──────────────────┐
    │ Save Results     │
    │ - PostgreSQL     │
    │ - Google Sheets  │
    │ - Slack notify   │
    └──────────────────┘
```

## 🎯 ICP Scoring Criteria

**Total Score = 105 points max**

| Factor | Max Points | Example |
|--------|------------|---------|
| CA Offering | 30 | "Yes - provides construction administration services" |
| CA Job Openings | 25 | "Construction Administrator" role posted |
| Headcount Fit | 15 | 201-500 employees (ideal) |
| Revenue Fit | 10 | $50M-$250M (sweet spot) |
| CA Tools | 10 | Uses Procore, PlanGrid, BIM360 |
| Project Verticals | 10 | Healthcare, Data Centers, Commercial |
| Litigation | -15 to 0 | Contract disputes = opportunity (or risk) |
| Geography | 5 | US metro areas preferred |

See **`ICP-SCORING-ANALYSIS.md`** for full methodology.

## 💰 Cost Breakdown

**Intelligent routing saves 60-70% vs enriching all firms!**

| Tier | Firms | Cost/Firm | Total |
|------|-------|-----------|-------|
| P1 (deep) | 250 | $0.50 | $125 |
| P2 (medium) | 400 | $0.15 | $60 |
| P3 (light) | 600 | $0.05 | $30 |
| P4 (none) | 896 | $0.00 | $0 |
| **Briefs** | 250 | $0.30 | $75 |
| **Total** | 2,146 | - | **$290** |

If we enriched all 2,146 firms at P1 level: **$1,073** ❌
Smart routing saves: **$783** ✅

## 📋 Sample Output

### P1 Firm Example: Cushing Terrell

```json
{
  "companyName": "Cushing Terrell",
  "location": "Billings, Montana",
  "headcount": "201-500",
  "revenue": "$100M-$250M",
  "initialScore": 85,
  "finalScore": 103,
  "priority": "P1",
  "enrichedData": {
    "caOffering": {
      "confirmed": true,
      "description": "Offers comprehensive CA services across education and commercial projects",
      "confidence": 0.95
    },
    "caTools": {
      "confirmed_tools": ["Procore"],
      "likely_tools": ["BIM360", "Bluebeam"]
    },
    "projectVerticals": [
      {"type": "Commercial", "percentage": 25},
      {"type": "Education", "percentage": 20},
      {"type": "Healthcare", "percentage": 15}
    ],
    "contacts": [
      {
        "name": "John Doe",
        "title": "Director of Operations",
        "decision_authority": 85,
        "ca_involvement": 90,
        "pain_points": ["RFI bottlenecks", "Submittal tracking"],
        "recommended_outreach": "email",
        "personalized_angle": "Reduce your RFI response time from 5 days to 24 hours"
      }
    ]
  },
  "brief": "# Outreach Brief: Cushing Terrell\n\n## Executive Summary\n..."
}
```

### Google Sheets Output

| Company | Location | Score | Priority | CA Confirmed | CA Tools | Best Contact | Brief |
|---------|----------|-------|----------|--------------|----------|--------------|-------|
| Cushing Terrell | Billings, MT | 103 | P1 | Yes | Procore | John Doe - Dir. Ops | Yes |
| KAI Enterprises | St. Louis, MO | 88 | P1 | Yes | Unknown | Jane Smith - Partner | Yes |
| Zyscovich | Miami, FL | 82 | P1 | Yes | Unknown | Bob Johnson - Principal | Yes |

## 🔍 Database Queries

### View All P1 Firms

```sql
SELECT * FROM v_p1_priority_firms
WHERE has_brief = true
ORDER BY final_score DESC;
```

### Export Top 50 for Outreach

```sql
COPY (
  SELECT company_name, location, final_score,
         enriched_data->>'bestContact' as contact
  FROM enriched_architecture_firms
  WHERE priority = 'P1' AND brief IS NOT NULL
  ORDER BY final_score DESC LIMIT 50
) TO '/tmp/top_50_outreach.csv' CSV HEADER;
```

### Firms with Pain Points (Opportunities!)

```sql
SELECT company_name, final_score,
       enriched_data->'painPoints'
FROM enriched_architecture_firms
WHERE enriched_data->'painPoints' IS NOT NULL
ORDER BY final_score DESC;
```

## 📈 Success Metrics

After execution, verify:

✅ **Firms processed**: 2,146 (100%)
✅ **P1 firms identified**: 150-250 (7-12%)
✅ **Briefs generated**: Match P1 count
✅ **Cost**: <$400
✅ **Time**: 4-8 hours
✅ **Brief quality**: Review 5-10 random briefs

## 🎯 Next Steps

### Week 1: Review Results
1. Query P1 firms from database
2. Read top 10 briefs
3. Validate contact info
4. Export to CRM

### Week 2: Launch Outreach
1. Email top 50 P1 firms (use sequences from briefs)
2. Connect on LinkedIn (use connection notes)
3. Track responses

### Month 1: Monitor & Iterate
1. Track response rates by priority
2. A/B test outreach angles
3. Re-enrich P2 firms (may become P1)

### Month 2+: Scale
1. Add 10k+ firm list
2. Run same workflow
3. Optimize based on learnings

## 🐛 Troubleshooting

See **`WORKFLOW-EXECUTION-GUIDE.md`** section: "Troubleshooting"

Common issues:
- API rate limits → Reduce batch size
- JSON parse errors → Continue on fail enabled
- Website timeouts → Fallback to AI research
- No contacts found → Firm not in Apollo DB

## 💡 Pro Tips

1. **Test with 50 firms first** - Create small CSV to validate
2. **Run overnight** - Let it process 4-8 hours
3. **Monitor costs** - Check OpenAI dashboard mid-run
4. **Export to CRM** - Use Zapier/Make.com integration
5. **Refresh quarterly** - Update scores + find new P1s

## 📚 Documentation

| File | Purpose |
|------|---------|
| **WORKFLOW-EXECUTION-GUIDE.md** | Detailed step-by-step guide |
| **ICP-SCORING-ANALYSIS.md** | Scoring methodology + criteria |
| **enriched-firms-schema.sql** | Database schema reference |
| **architecture-icp-enrichment-workflow.json** | n8n workflow (import this) |

## 🏆 What You'll Have After Execution

✅ **2,146 firms scored** for ICP fit
✅ **~500-1,500 firms enriched** with AI research
✅ **150-250 P1 prospects** with deep intelligence
✅ **150-250 outreach briefs** ready to send
✅ **PostgreSQL database** with all enriched data
✅ **Google Sheets** for easy viewing/sharing
✅ **Prioritized outreach list** sorted by score

## 🚀 Ready to Execute?

```bash
# 1. Create database
psql -U postgres -d architecture_enrichment -f enriched-firms-schema.sql

# 2. Start n8n (if not running)
n8n start

# 3. Import workflow
# Open http://localhost:5678
# Workflows → Import → architecture-icp-enrichment-workflow.json

# 4. Execute!
# Click "Execute Workflow" button
```

---

**Questions?** See `WORKFLOW-EXECUTION-GUIDE.md` for detailed instructions.

**Need help?** Check the troubleshooting section or review n8n execution logs.

Good luck! 🎯
