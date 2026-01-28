-- Architecture Firms ICP Enrichment - Database Schema
-- Simplified schema for enriched architecture firm data

CREATE TABLE IF NOT EXISTS enriched_architecture_firms (
    id SERIAL PRIMARY KEY,

    -- Basic company info
    company_name VARCHAR(500) NOT NULL,
    location VARCHAR(500),
    headcount VARCHAR(50),
    revenue VARCHAR(50),

    -- Scoring
    initial_score INTEGER,
    final_score INTEGER,
    priority VARCHAR(10), -- P1, P2, P3, P4
    enrichment_tier VARCHAR(20), -- deep, medium, light, none

    -- Enriched data (JSONB for flexibility)
    enriched_data JSONB,

    -- Brief (for P1 firms)
    brief TEXT,

    -- Metadata
    processed_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    CONSTRAINT unique_company UNIQUE(company_name)
);

-- Indexes for performance
CREATE INDEX idx_enriched_firms_priority ON enriched_architecture_firms(priority);
CREATE INDEX idx_enriched_firms_final_score ON enriched_architecture_firms(final_score DESC);
CREATE INDEX idx_enriched_firms_enrichment_tier ON enriched_architecture_firms(enrichment_tier);
CREATE INDEX idx_enriched_firms_processed_at ON enriched_architecture_firms(processed_at DESC);

-- GIN index for JSONB queries
CREATE INDEX idx_enriched_firms_data_gin ON enriched_architecture_firms USING GIN (enriched_data);

-- Update timestamp trigger
CREATE OR REPLACE FUNCTION update_enriched_firms_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_enriched_firms_timestamp
BEFORE UPDATE ON enriched_architecture_firms
FOR EACH ROW EXECUTE FUNCTION update_enriched_firms_timestamp();

-- Views for easy querying

-- P1 Priority Firms (ready for immediate outreach)
CREATE OR REPLACE VIEW v_p1_priority_firms AS
SELECT
    id,
    company_name,
    location,
    headcount,
    revenue,
    final_score,
    enriched_data->>'caOffering' as ca_offering,
    enriched_data->>'caTools' as ca_tools,
    enriched_data->>'bestContact' as best_contact,
    brief IS NOT NULL as has_brief,
    processed_at
FROM enriched_architecture_firms
WHERE priority = 'P1'
ORDER BY final_score DESC;

-- P2 Priority Firms (nurture campaign)
CREATE OR REPLACE VIEW v_p2_priority_firms AS
SELECT
    id,
    company_name,
    location,
    headcount,
    revenue,
    final_score,
    enriched_data->>'caOffering' as ca_offering,
    processed_at
FROM enriched_architecture_firms
WHERE priority = 'P2'
ORDER BY final_score DESC;

-- Enrichment summary stats
CREATE OR REPLACE VIEW v_enrichment_stats AS
SELECT
    priority,
    enrichment_tier,
    COUNT(*) as firm_count,
    AVG(final_score) as avg_score,
    COUNT(CASE WHEN brief IS NOT NULL THEN 1 END) as briefs_generated
FROM enriched_architecture_firms
GROUP BY priority, enrichment_tier
ORDER BY priority;

-- Sample queries

-- Get all P1 firms with briefs
-- SELECT * FROM v_p1_priority_firms WHERE has_brief = true;

-- Get firms with confirmed CA offering
-- SELECT company_name, final_score, priority
-- FROM enriched_architecture_firms
-- WHERE enriched_data->>'caOffering'->>'confirmed' = 'true'
-- ORDER BY final_score DESC;

-- Get firms using specific CA tools
-- SELECT company_name, enriched_data->'caTools'->'confirmed_tools'
-- FROM enriched_architecture_firms
-- WHERE enriched_data->'caTools'->'confirmed_tools' ? 'Procore';

-- Processing statistics
-- SELECT * FROM v_enrichment_stats;
