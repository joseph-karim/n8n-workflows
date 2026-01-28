# Architecture Firm ICP Scoring & Enrichment Analysis

## Data Overview

**Total Firms**: ~2,146 architecture firms across both CSVs
**Current State**: Mix of confirmed data + "Research with AI" placeholders

## Existing Data Fields

| Field | Status | Completeness |
|-------|--------|--------------|
| Company Name | ✅ Complete | 100% |
| HQ Location | ✅ Complete | 100% |
| Industry | ✅ Complete | 100% (all "Architecture & Planning") |
| Headcount | ✅ Complete | 100% |
| Revenue | ✅ Complete | 100% |
| Offers Construction Admin | 🟡 Partial | ~60% confirmed, 40% "Unclear" |
| CA Management Tools | 🔴 Needs Research | ~2% confirmed, 98% "Research with AI" |
| Construction Litigation | ✅ Mostly Complete | ~95% researched |
| Project Focus Types | 🔴 Needs Research | ~15% confirmed, 85% "Research with AI" |
| Open Job Titles | 🟡 Partial | ~70% researched |

## ICP Criteria (Based on Your Data)

### Tier 1: High-Value Indicators (Critical)

#### 1. **Confirmed Construction Admin Offering** (30 points)
- **"Yes"** with detailed description → 30 points
- **"Yes"** without details → 20 points
- **"Unclear"** → 5 points
- **"No"** → 0 points

**Examples from your data:**
- ✅ **Cushing Terrell**: "Their education and commercial service descriptions include 'construction administration' support" + uses Procore
- ✅ **SMMA**: "mentions 'construction contract administration' and staff providing 'construction administration services'"
- ✅ **Beyer Blinder Belle**: "Careers page lists a 'Project Architect- Construction Administration' role"

#### 2. **Active CA Job Openings** (25 points)
- **Multiple CA roles open** → 25 points
- **1 CA role open** → 15 points
- **CA mentioned in job descriptions** → 10 points
- **No CA roles** → 0 points

**Examples:**
- ✅ **KAI Enterprises**: "Construction Administrator – posted Jan 14, 2026" + "Project Engineer (Construction Administration)"
- ✅ **Zyscovich**: "Senior Construction Administrator, posted Dec 25, 2024"
- ✅ **KFA Architecture**: "CA Supervisor to manage construction administration of projects"

#### 3. **Headcount (20-500)** (15 points)
- **201-500** → 15 points (ideal size)
- **51-200** → 12 points
- **11-50** → 5 points
- **500+** → 3 points (too large, complex sales)

### Tier 2: Strong Indicators (Important)

#### 4. **Revenue Range** (10 points)
- **$50M-$250M** → 10 points (sweet spot)
- **$25M-$50M** → 7 points
- **$10M-$25M** → 4 points
- **$1M-$10M** → 2 points

#### 5. **CA Management Tools** (10 points)
- **Uses Procore, PlanGrid, or similar** → 10 points
- **"Research with AI"** → needs enrichment
- **No mention** → 0 points

**Confirmed users:**
- ✅ **Cushing Terrell**: Procore

#### 6. **Project Focus Types (Target Verticals)** (10 points)
- **Healthcare** → +4 points
- **Data Centers** → +4 points
- **Commercial** → +3 points
- **Education** → +3 points
- **Government/Civic** → +2 points
- **Multi-family residential** → +2 points

**Examples:**
- ✅ **Cushing Terrell**: "commercial (~25%), education (~20%), healthcare (~15%), civic/government (~15%)"

### Tier 3: Risk/Opportunity Indicators

#### 7. **Construction Litigation** (varies)
- **None found** → 0 points (neutral)
- **Contract disputes (1-2)** → -5 points (pain point = opportunity)
- **Multiple disputes** → -10 points (risky)
- **Design defects** → -15 points (very risky)

**Examples of opportunities:**
- 🔍 **BSB Design**: "Vista Holdings, LLC v. BSB Design, Inc. (construction contract dispute)" → Pain point!
- 🔍 **GreenbergFarrow**: "multiple contract disputes/litigation found"
- 🔍 **EVstudio**: "alleged design defects" → High pain = potential for CA solution

#### 8. **Geographic Location** (5 points)
- **US metros (NY, SF, LA, Chicago, Boston)** → +5 points
- **US secondary markets** → +3 points
- **Canada** → +2 points

## Enhanced ICP Scoring Formula

```
TOTAL SCORE = Construction Admin Score (30)
            + Active CA Jobs (25)
            + Headcount Fit (15)
            + Revenue Fit (10)
            + CA Tools (10)
            + Project Verticals (10)
            + Litigation Factor (-15 to 0)
            + Geographic Fit (5)

MAX SCORE: 105 points
```

## Priority Tiers (Refined)

### P1: Hot Prospects (Score 75-105)
**Criteria:**
- ✅ Confirmed CA offering
- ✅ Active CA job openings
- ✅ 51-500 employees
- ✅ $50M-$250M revenue
- ✅ Target verticals (healthcare, data centers, commercial)
- ⚠️ Optional: Construction litigation (indicates pain points)

**Estimated Count**: 150-250 firms
**Action**: Immediate outreach, generate briefs

### P2: Strong Prospects (Score 55-74)
**Criteria:**
- ✅ Likely offers CA (or "Unclear" but other indicators strong)
- ✅ Good fit on headcount + revenue
- 🟡 Some CA job activity or mentions
- 🟡 Some target verticals

**Estimated Count**: 300-500 firms
**Action**: Nurture campaign, monitor for job postings

### P3: Warm Prospects (Score 35-54)
**Criteria:**
- 🟡 "Unclear" on CA offering
- ✅ Right size/revenue
- 🔴 Needs research on verticals/tools

**Estimated Count**: 500-800 firms
**Action**: Quarterly check-ins, signal monitoring

### P4: Cold/Research Needed (Score <35)
**Criteria:**
- 🔴 No confirmed CA offering
- 🔴 Outside ideal size/revenue
- 🔴 Many "Research with AI" fields

**Estimated Count**: 700-1,200 firms
**Action**: Low-touch nurture, annual refresh

## Fields That Need AI Research Enrichment

### Critical to Complete (affects ICP scoring):

1. **CA Management Tools** (98% missing)
   - Search company website + job postings for: Procore, PlanGrid, BIM360, Fieldwire, Buildertrend
   - Check LinkedIn "Skills" section
   - Scan recent project announcements

2. **Project Focus Types** (85% missing)
   - Scrape "Projects" page
   - Analyze case studies
   - Look for keywords: healthcare, data center, commercial office, education, civic, hospitality, multi-family

3. **Technology Stack** (100% missing - new field)
   - BIM software: Revit, ArchiCAD, Vectorworks
   - Rendering: Enscape, Lumion, V-Ray
   - Collaboration: BIM360, ACC (Autodesk Construction Cloud)
   - Documentation: Bluebeam, Procore

### Nice-to-Have (enhances outreach):

4. **Key Contacts**
   - Principals/Partners (decision authority)
   - Directors of Operations
   - CTOs/Technology Directors
   - Construction Administrators
   - BIM Managers

5. **Recent Projects**
   - Project name, type, size, completion date
   - CA involvement mentioned?
   - Technology used

6. **Digital Transformation Signals**
   - BIM adoption level
   - Digital twin projects
   - AI/ML experimentation
   - Sustainability/LEED focus

## Enrichment Strategy

### Phase 1: High-Priority Enrichment (P1 + P2 firms)
**Target**: 450-750 firms
**Time**: 1-2 weeks

For firms scoring 55+, enrich:
1. ✅ Confirm CA offering (if "Unclear")
2. ✅ Find CA tools used
3. ✅ Identify project verticals
4. ✅ Discover 3-5 key contacts
5. ✅ Check for recent CA job postings (real-time)

### Phase 2: Contact Discovery (P1 firms)
**Target**: 150-250 firms
**Time**: 1-2 weeks

For firms scoring 75+:
1. Full contact profiles (Apollo + LinkedIn scraping)
2. LLM analysis of profiles for pain points
3. Generate personalized outreach briefs
4. Warm intro research

### Phase 3: Bulk Light Enrichment (P3 + P4)
**Target**: 1,200-2,000 firms
**Time**: 2-4 weeks

For lower-scoring firms:
1. Website scrape → project types
2. BuiltWith → tech stack
3. Basic signal detection (quarterly)

## Example ICP Matches (From Your Data)

### Perfect ICP Fit (P1):

#### **Cushing Terrell** (Score: ~95)
- ✅ Headcount: 201-500 → 15 pts
- ✅ Revenue: $100M-$250M → 10 pts
- ✅ CA offering: Yes (detailed) → 30 pts
- ✅ CA tools: Procore → 10 pts
- ✅ CA jobs: "BIM Coordinator", "Certified Commissioning Engineer/Agent" → 25 pts
- ✅ Verticals: Healthcare (15%), Education (20%), Commercial (25%) → 10 pts
- ✅ Location: Montana (US) → 3 pts
- ⚠️ Litigation: None found → 0 pts
**Total: 103 points → P1**

#### **KAI Enterprises** (Score: ~88)
- ✅ Headcount: 51-200 → 12 pts
- ✅ Revenue: $50M-$100M → 10 pts
- ✅ CA offering: Unclear (needs research) → 5 pts
- 🔴 CA tools: Research with AI → 0 pts (needs enrichment)
- ✅ CA jobs: "Construction Administrator" + "Project Engineer (Construction Administration)" → 25 pts
- 🔴 Verticals: Research with AI → 0 pts (needs enrichment)
- ✅ Location: St. Louis, MO → 3 pts
- ⚠️ Litigation: One fraud suit → -5 pts
**Current: 50 points → P3**
**After enrichment: Could be 80-90 → P1**

#### **Zyscovich** (Score: ~82)
- ✅ Headcount: 51-200 → 12 pts
- ✅ Revenue: $50M-$100M → 10 pts
- ✅ CA offering: Yes → 30 pts
- 🔴 CA tools: Research with AI → 0 pts
- ✅ CA jobs: "Senior Construction Administrator" → 25 pts
- 🔴 Verticals: Research with AI → 0 pts
- ✅ Location: Miami, FL → 5 pts
- ✅ Litigation: None found → 0 pts
**Current: 82 points → P1**

### Strong Fit (P2):

#### **AVELAR** (Score: ~65)
- ✅ Headcount: 51-200 → 12 pts
- ✅ Revenue: $10M-$25M → 4 pts
- ✅ CA offering: "Construction Contract Administration" → 30 pts
- 🔴 CA tools: Research with AI → 0 pts
- ✅ CA jobs: "Building Defect Construction Technician", "Forensic Building Consultant" → 15 pts
- 🔴 Verticals: Research with AI → 0 pts
- ✅ Location: Walnut Creek, CA → 5 pts
- ⚠️ Litigation: Yes, enforcement action → -5 pts
**Current: 61 points → P2**
**Pain point opportunity**: Litigation = need for better CA processes

### Needs Enrichment (P3 → could be P1):

#### **Adamson Associates Architects** (Score: ~40 → potential 85+)
- ✅ Headcount: 201-500 → 15 pts
- ✅ Revenue: $100M-$250M → 10 pts
- 🔴 CA offering: "Unclear" → 5 pts (**needs research**)
- 🔴 CA tools: Research with AI → 0 pts (**needs research**)
- 🔴 CA jobs: "No current CA/QA/QC/documentation tech roles" → 0 pts
- 🔴 Verticals: Research with AI → 0 pts (**needs research**)
- ✅ Location: Toronto, Canada → 2 pts
- ✅ Litigation: None found → 0 pts
**Current: 32 points → P4**
**After enrichment: Could easily be 70-85 → P1 or P2**

## AI Enrichment Prompts

### Prompt 1: Confirm CA Offering
```
Company: {{ company_name }}
Website: {{ domain }}

Task: Determine if this architecture firm offers Construction Administration (CA) services.

Look for:
1. "Construction Administration" in services
2. CA mentioned in project descriptions
3. Job postings for CA roles
4. Team bios mentioning CA responsibilities

Return JSON:
{
  "offers_ca": true/false,
  "confidence": 0.0-1.0,
  "evidence": ["quote 1", "quote 2"],
  "sources": ["url 1", "url 2"]
}
```

### Prompt 2: Identify CA Tools
```
Company: {{ company_name }}
Search results: {{ scraped_content }}

Task: Identify any Construction Administration or project management tools used.

Target tools: Procore, PlanGrid, BIM360, Fieldwire, Buildertrend, Bluebeam, Autodesk Construction Cloud, Viewpoint, CMiC

Return JSON:
{
  "ca_tools": ["tool1", "tool2"],
  "confidence": 0.0-1.0,
  "evidence": ["source 1"],
  "tech_stack_maturity": "low|medium|high"
}
```

### Prompt 3: Extract Project Verticals
```
Company: {{ company_name }}
Projects page content: {{ content }}

Task: Identify the primary project types/verticals this firm focuses on.

Target verticals: Healthcare, Data Centers, Commercial Office, Education, Government/Civic, Hospitality, Multi-family Residential, Retail, Industrial, Infrastructure

Calculate approximate % breakdown.

Return JSON:
{
  "verticals": [
    {"type": "Healthcare", "percentage": 25},
    {"type": "Commercial", "percentage": 30},
    ...
  ],
  "evidence": ["project 1 example", "project 2 example"]
}
```

## Next Steps

1. **Run ICP scoring** on all 2,146 firms with existing data
2. **Identify P1/P2 firms** (estimated 450-750 firms)
3. **Enrich "Research with AI" fields** for P1/P2 firms first
4. **Generate contact lists** for P1 firms (150-250)
5. **Create briefs** for top 50 P1 firms
6. **Launch outreach** campaign

## Success Metrics

- **P1 firms identified**: Target 150-250 (7-12% of total)
- **Contact discovery rate**: 4-7 contacts per P1 firm
- **Brief quality**: >85% actionable
- **Outreach response rate**: Target 15-25%
- **Cost per enriched firm**: <$0.50
- **Time to enrich P1/P2**: 2-4 weeks

---

**Bottom Line**: You have ~150-250 high-quality prospects (P1) already in your data. The n8n workflow will:
1. Score all 2,146 firms
2. Auto-enrich "Research with AI" fields for P1/P2
3. Find 600-1,750 contacts for P1 firms
4. Generate 150-250 outreach briefs
5. Create a refined ICP list ready for immediate outreach
