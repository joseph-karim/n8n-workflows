-- Architecture Firm Enrichment Pipeline - PostgreSQL Schema
-- Run this to set up your database

-- Main companies table
CREATE TABLE IF NOT EXISTS enriched_companies (
    id SERIAL PRIMARY KEY,
    firm_name VARCHAR(500) NOT NULL,
    domain VARCHAR(255) UNIQUE,
    employee_count INTEGER,
    linkedin_url VARCHAR(500),

    -- Scoring
    total_score INTEGER DEFAULT 0,
    signal_score INTEGER DEFAULT 0,
    enrichment_score INTEGER DEFAULT 0,
    contact_score INTEGER DEFAULT 0,
    priority VARCHAR(10), -- P1, P2, P3, P4
    icp_fit BOOLEAN DEFAULT FALSE,

    -- Enrichment data (JSONB for flexibility)
    signals JSONB,
    enrichment_data JSONB,
    contacts JSONB,
    tech_stack JSONB,

    -- Brief
    brief TEXT,
    brief_generated_at TIMESTAMP,

    -- Metadata
    enrichment_status VARCHAR(50) DEFAULT 'pending', -- pending, in_progress, completed, failed
    enrichment_tier VARCHAR(20), -- light, medium, heavy
    last_enriched_at TIMESTAMP,
    processed_at TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    -- Indexes
    CONSTRAINT valid_priority CHECK (priority IN ('P1', 'P2', 'P3', 'P4'))
);

-- Indexes for performance
CREATE INDEX idx_companies_domain ON enriched_companies(domain);
CREATE INDEX idx_companies_priority ON enriched_companies(priority);
CREATE INDEX idx_companies_total_score ON enriched_companies(total_score DESC);
CREATE INDEX idx_companies_icp_fit ON enriched_companies(icp_fit);
CREATE INDEX idx_companies_enrichment_status ON enriched_companies(enrichment_status);
CREATE INDEX idx_companies_processed_at ON enriched_companies(processed_at DESC);

-- GIN index for JSONB columns (fast JSON queries)
CREATE INDEX idx_companies_signals_gin ON enriched_companies USING GIN (signals);
CREATE INDEX idx_companies_contacts_gin ON enriched_companies USING GIN (contacts);

-- Signals tracking table (for time-series analysis with TimescaleDB)
CREATE TABLE IF NOT EXISTS signals (
    id SERIAL PRIMARY KEY,
    company_id INTEGER REFERENCES enriched_companies(id) ON DELETE CASCADE,
    category VARCHAR(100), -- Digital Transformation, Growth Indicators, etc.
    signal_type VARCHAR(100),
    signal_text TEXT,
    confidence NUMERIC(3,2), -- 0.00 to 1.00
    source_url TEXT,
    detected_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP,

    -- Scoring
    signal_score INTEGER DEFAULT 0
);

CREATE INDEX idx_signals_company_id ON signals(company_id);
CREATE INDEX idx_signals_category ON signals(category);
CREATE INDEX idx_signals_detected_at ON signals(detected_at DESC);

-- Contacts table (normalized)
CREATE TABLE IF NOT EXISTS contacts (
    id SERIAL PRIMARY KEY,
    company_id INTEGER REFERENCES enriched_companies(id) ON DELETE CASCADE,

    -- Basic info
    full_name VARCHAR(255),
    title VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    linkedin_url VARCHAR(500),

    -- Scoring
    contact_score INTEGER DEFAULT 0,
    decision_authority INTEGER DEFAULT 0,
    ca_involvement INTEGER DEFAULT 0,
    tech_adoption INTEGER DEFAULT 0,

    -- Analysis
    pain_points JSONB,
    recommended_outreach VARCHAR(50), -- email, linkedin, phone
    personalized_angle TEXT,

    -- Profile data
    profile_hash VARCHAR(64), -- For caching
    raw_profile_data JSONB,

    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_contacted TIMESTAMP,

    CONSTRAINT unique_contact_per_company UNIQUE(company_id, email)
);

CREATE INDEX idx_contacts_company_id ON contacts(company_id);
CREATE INDEX idx_contacts_contact_score ON contacts(contact_score DESC);
CREATE INDEX idx_contacts_decision_authority ON contacts(decision_authority DESC);
CREATE INDEX idx_contacts_profile_hash ON contacts(profile_hash);

-- Enrichment jobs queue (for tracking processing)
CREATE TABLE IF NOT EXISTS enrichment_jobs (
    id SERIAL PRIMARY KEY,
    company_id INTEGER REFERENCES enriched_companies(id) ON DELETE CASCADE,
    job_type VARCHAR(50), -- signal_detection, light_enrichment, medium_enrichment, heavy_enrichment
    status VARCHAR(50) DEFAULT 'pending', -- pending, in_progress, completed, failed, retrying

    -- Execution details
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    attempts INTEGER DEFAULT 0,
    max_attempts INTEGER DEFAULT 3,

    -- Error handling
    error_message TEXT,
    error_details JSONB,

    -- Results
    result_data JSONB,

    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_enrichment_jobs_company_id ON enrichment_jobs(company_id);
CREATE INDEX idx_enrichment_jobs_status ON enrichment_jobs(status);
CREATE INDEX idx_enrichment_jobs_job_type ON enrichment_jobs(job_type);
CREATE INDEX idx_enrichment_jobs_created_at ON enrichment_jobs(created_at DESC);

-- Briefs table (for versioning and storage)
CREATE TABLE IF NOT EXISTS briefs (
    id SERIAL PRIMARY KEY,
    company_id INTEGER REFERENCES enriched_companies(id) ON DELETE CASCADE,

    -- Brief content
    brief_markdown TEXT,
    brief_html TEXT,

    -- Storage
    s3_path VARCHAR(500),
    google_doc_url VARCHAR(500),

    -- Metadata
    version INTEGER DEFAULT 1,
    generated_by VARCHAR(50), -- gpt-4o, gpt-4o-mini
    generation_cost NUMERIC(10,4), -- USD

    created_at TIMESTAMP DEFAULT NOW(),

    CONSTRAINT unique_brief_version UNIQUE(company_id, version)
);

CREATE INDEX idx_briefs_company_id ON briefs(company_id);
CREATE INDEX idx_briefs_created_at ON briefs(created_at DESC);

-- Processing metrics (for monitoring)
CREATE TABLE IF NOT EXISTS processing_metrics (
    id SERIAL PRIMARY KEY,
    metric_name VARCHAR(100),
    metric_value NUMERIC,
    metric_type VARCHAR(50), -- counter, gauge, histogram
    tags JSONB,
    recorded_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_metrics_name_time ON processing_metrics(metric_name, recorded_at DESC);

-- Views for analytics

-- High-priority leads view
CREATE OR REPLACE VIEW high_priority_leads AS
SELECT
    id,
    firm_name,
    domain,
    employee_count,
    total_score,
    priority,
    icp_fit,
    enrichment_data->>'verticals' as verticals,
    enrichment_data->>'caEmphasis' as ca_emphasis,
    jsonb_array_length(contacts) as contact_count,
    processed_at
FROM enriched_companies
WHERE priority IN ('P1', 'P2', 'P3')
    AND icp_fit = TRUE
ORDER BY total_score DESC;

-- Signal summary view
CREATE OR REPLACE VIEW signal_summary AS
SELECT
    c.id as company_id,
    c.firm_name,
    COUNT(*) as signal_count,
    COUNT(CASE WHEN s.category = 'Digital Transformation' THEN 1 END) as digital_transformation_count,
    COUNT(CASE WHEN s.category = 'Growth Indicators' THEN 1 END) as growth_indicators_count,
    COUNT(CASE WHEN s.category = 'Construction Administration' THEN 1 END) as ca_signals_count,
    AVG(s.confidence) as avg_confidence,
    MAX(s.detected_at) as last_signal_detected
FROM enriched_companies c
LEFT JOIN signals s ON c.id = s.company_id
GROUP BY c.id, c.firm_name;

-- Contact summary view
CREATE OR REPLACE VIEW contact_summary AS
SELECT
    c.company_id,
    ec.firm_name,
    COUNT(*) as total_contacts,
    COUNT(CASE WHEN c.decision_authority >= 70 THEN 1 END) as decision_makers,
    COUNT(CASE WHEN c.ca_involvement >= 60 THEN 1 END) as ca_involved_contacts,
    AVG(c.contact_score) as avg_contact_score,
    MAX(c.contact_score) as max_contact_score
FROM contacts c
JOIN enriched_companies ec ON c.company_id = ec.id
GROUP BY c.company_id, ec.firm_name;

-- Daily processing stats view
CREATE OR REPLACE VIEW daily_processing_stats AS
SELECT
    DATE(processed_at) as processing_date,
    COUNT(*) as companies_processed,
    COUNT(CASE WHEN priority = 'P1' THEN 1 END) as p1_count,
    COUNT(CASE WHEN priority = 'P2' THEN 1 END) as p2_count,
    COUNT(CASE WHEN priority = 'P3' THEN 1 END) as p3_count,
    COUNT(CASE WHEN icp_fit = TRUE THEN 1 END) as icp_fit_count,
    AVG(total_score) as avg_score,
    COUNT(CASE WHEN brief IS NOT NULL THEN 1 END) as briefs_generated
FROM enriched_companies
GROUP BY DATE(processed_at)
ORDER BY processing_date DESC;

-- Update timestamp trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_enriched_companies_updated_at BEFORE UPDATE ON enriched_companies
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contacts_updated_at BEFORE UPDATE ON contacts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_enrichment_jobs_updated_at BEFORE UPDATE ON enrichment_jobs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Optional: Enable TimescaleDB for signals table (if using TimescaleDB extension)
-- Uncomment if you have TimescaleDB installed
-- SELECT create_hypertable('signals', 'detected_at', if_not_exists => TRUE);

-- Sample queries

-- Top 20 priority firms
-- SELECT * FROM high_priority_leads LIMIT 20;

-- Firms with most signals
-- SELECT c.firm_name, COUNT(s.*) as signal_count
-- FROM enriched_companies c
-- JOIN signals s ON c.id = s.company_id
-- GROUP BY c.id, c.firm_name
-- ORDER BY signal_count DESC
-- LIMIT 20;

-- Firms ready for outreach (high score + contacts)
-- SELECT
--     c.firm_name,
--     c.total_score,
--     c.priority,
--     jsonb_array_length(c.contacts) as contact_count,
--     c.enrichment_data->>'verticals' as verticals
-- FROM enriched_companies c
-- WHERE c.total_score >= 70
--     AND c.contacts IS NOT NULL
--     AND jsonb_array_length(c.contacts) > 0
-- ORDER BY c.total_score DESC;
