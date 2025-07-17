-- Database Performance Optimizations for Grafana Dashboards
-- This script adds indexes and materialized views to improve query performance

-- 1. COMPOSITE INDEXES FOR COMMON QUERY PATTERNS

-- Discord Messages Indexes
CREATE INDEX IF NOT EXISTS idx_discord_messages_author_created_bot 
ON discord_messages(author_id, created_at) WHERE author_is_bot = false;

CREATE INDEX IF NOT EXISTS idx_discord_messages_channel_created 
ON discord_messages(channel_id, created_at) WHERE author_is_bot = false;

CREATE INDEX IF NOT EXISTS idx_discord_messages_guild_created 
ON discord_messages(guild_id, created_at) WHERE author_is_bot = false;

CREATE INDEX IF NOT EXISTS idx_discord_messages_content_gin 
ON discord_messages USING GIN(to_tsvector('english', content)) 
WHERE content IS NOT NULL AND LENGTH(content) > 0;

-- Telegram Messages Indexes
CREATE INDEX IF NOT EXISTS idx_telegram_messages_user_date 
ON telegram_messages(from_user_id, date);

CREATE INDEX IF NOT EXISTS idx_telegram_messages_chat_date 
ON telegram_messages(chat_id, date);

CREATE INDEX IF NOT EXISTS idx_telegram_messages_text_gin 
ON telegram_messages USING GIN(to_tsvector('english', text)) 
WHERE text IS NOT NULL AND LENGTH(text) > 0;

-- Mava Tickets Indexes
CREATE INDEX IF NOT EXISTS idx_mava_tickets_status_priority_created 
ON mava_tickets(status, priority, created_at);

CREATE INDEX IF NOT EXISTS idx_mava_tickets_assigned_created 
ON mava_tickets(assigned_to, created_at) WHERE assigned_to IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_mava_tickets_customer_created 
ON mava_tickets(customer_id, created_at) WHERE customer_id IS NOT NULL;

-- Messages Indexes
CREATE INDEX IF NOT EXISTS idx_mava_messages_ticket_created 
ON mava_messages(ticket_id, created_at);

CREATE INDEX IF NOT EXISTS idx_mava_messages_sender_created 
ON mava_messages(sender, created_at);

-- 2. MATERIALIZED VIEWS FOR FREQUENTLY ACCESSED AGGREGATIONS

-- Daily Discord Statistics
CREATE MATERIALIZED VIEW IF NOT EXISTS daily_discord_stats AS
SELECT 
    DATE(created_at) as date,
    COUNT(*) as total_messages,
    COUNT(DISTINCT author_id) as unique_users,
    COUNT(DISTINCT channel_id) as active_channels,
    COUNT(DISTINCT guild_id) as active_guilds,
    COUNT(CASE WHEN attachments != '[]'::jsonb THEN 1 END) as messages_with_attachments,
    COUNT(CASE WHEN embeds != '[]'::jsonb THEN 1 END) as messages_with_embeds,
    COUNT(CASE WHEN mentions != '{}' THEN 1 END) as messages_with_mentions,
    AVG(LENGTH(content)) as avg_message_length
FROM discord_messages
WHERE author_is_bot = false
GROUP BY DATE(created_at);

CREATE UNIQUE INDEX IF NOT EXISTS idx_daily_discord_stats_date 
ON daily_discord_stats(date);

-- Daily Telegram Statistics
CREATE MATERIALIZED VIEW IF NOT EXISTS daily_telegram_stats AS
SELECT 
    DATE(date) as date,
    COUNT(*) as total_messages,
    COUNT(DISTINCT from_user_id) as unique_users,
    COUNT(DISTINCT chat_id) as active_chats,
    COUNT(CASE WHEN photo IS NOT NULL THEN 1 END) as photo_messages,
    COUNT(CASE WHEN document IS NOT NULL THEN 1 END) as document_messages,
    COUNT(CASE WHEN video IS NOT NULL THEN 1 END) as video_messages,
    AVG(LENGTH(text)) as avg_message_length
FROM telegram_messages
GROUP BY DATE(date);

CREATE UNIQUE INDEX IF NOT EXISTS idx_daily_telegram_stats_date 
ON daily_telegram_stats(date);

-- Weekly User Engagement Statistics
CREATE MATERIALIZED VIEW IF NOT EXISTS weekly_user_engagement AS
SELECT 
    DATE_TRUNC('week', created_at) as week,
    author_id,
    author_username,
    COUNT(*) as message_count,
    COUNT(DISTINCT channel_id) as channels_used,
    COUNT(DISTINCT DATE(created_at)) as active_days,
    COUNT(CASE WHEN mentions != '{}' THEN 1 END) as mentions_given,
    AVG(LENGTH(content)) as avg_message_length,
    -- Engagement score calculation
    (COUNT(*) * 0.3 + 
     COUNT(DISTINCT DATE(created_at)) * 2.0 + 
     COUNT(DISTINCT channel_id) * 1.5 + 
     AVG(LENGTH(content)) * 0.01 + 
     COUNT(CASE WHEN mentions != '{}' THEN 1 END) * 0.5) as engagement_score
FROM discord_messages
WHERE author_is_bot = false
GROUP BY DATE_TRUNC('week', created_at), author_id, author_username;

CREATE INDEX IF NOT EXISTS idx_weekly_user_engagement_week_score 
ON weekly_user_engagement(week, engagement_score DESC);

-- Mava Ticket Summary Statistics
CREATE MATERIALIZED VIEW IF NOT EXISTS daily_ticket_stats AS
SELECT 
    DATE(created_at) as date,
    status,
    priority,
    COUNT(*) as ticket_count,
    COUNT(DISTINCT customer_id) as unique_customers,
    COUNT(DISTINCT assigned_to) as agents_involved,
    AVG(EXTRACT(EPOCH FROM (updated_at - created_at))/3600) as avg_resolution_hours
FROM mava_tickets
WHERE created_at IS NOT NULL
GROUP BY DATE(created_at), status, priority;

CREATE INDEX IF NOT EXISTS idx_daily_ticket_stats_date_status 
ON daily_ticket_stats(date, status);

-- 3. HELPER FUNCTIONS FOR DASHBOARD QUERIES

-- Function to calculate user engagement score
CREATE OR REPLACE FUNCTION calculate_user_engagement_score(
    message_count INTEGER,
    active_days INTEGER,
    channels_used INTEGER,
    avg_message_length DECIMAL,
    mentions_given INTEGER
) RETURNS DECIMAL AS $$
BEGIN
    RETURN (message_count * 0.3 + 
            active_days * 2.0 + 
            channels_used * 1.5 + 
            avg_message_length * 0.01 + 
            mentions_given * 0.5);
END;
$$ LANGUAGE plpgsql;

-- Function to refresh all materialized views
CREATE OR REPLACE FUNCTION refresh_dashboard_views() RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW daily_discord_stats;
    REFRESH MATERIALIZED VIEW daily_telegram_stats;
    REFRESH MATERIALIZED VIEW weekly_user_engagement;
    REFRESH MATERIALIZED VIEW daily_ticket_stats;
END;
$$ LANGUAGE plpgsql;

-- 4. AUTOMATED REFRESH SCHEDULE COMMENTS
-- Note: These would typically be set up as cron jobs or scheduled tasks
-- Example cron entries:
-- # Refresh materialized views every hour
-- 0 * * * * psql -d your_database -c "SELECT refresh_dashboard_views();"

-- 5. PERFORMANCE MONITORING QUERIES

-- Query to monitor index usage
CREATE OR REPLACE VIEW index_usage_stats AS
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_tup_read,
    idx_tup_fetch,
    idx_scan
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;

-- Query to monitor materialized view freshness
CREATE OR REPLACE VIEW materialized_view_freshness AS
SELECT 
    schemaname,
    matviewname,
    hasindexes,
    ispopulated,
    definition
FROM pg_matviews
WHERE schemaname = 'public';

-- Comments for documentation
COMMENT ON MATERIALIZED VIEW daily_discord_stats IS 'Daily aggregated Discord statistics for dashboard performance';
COMMENT ON MATERIALIZED VIEW daily_telegram_stats IS 'Daily aggregated Telegram statistics for dashboard performance';
COMMENT ON MATERIALIZED VIEW weekly_user_engagement IS 'Weekly user engagement metrics with scoring algorithm';
COMMENT ON MATERIALIZED VIEW daily_ticket_stats IS 'Daily Mava ticket statistics by status and priority';

-- 6. CLEANUP COMMANDS (for development/testing)
-- DROP MATERIALIZED VIEW IF EXISTS daily_discord_stats CASCADE;
-- DROP MATERIALIZED VIEW IF EXISTS daily_telegram_stats CASCADE;
-- DROP MATERIALIZED VIEW IF EXISTS weekly_user_engagement CASCADE;
-- DROP MATERIALIZED VIEW IF EXISTS daily_ticket_stats CASCADE;
-- DROP FUNCTION IF EXISTS calculate_user_engagement_score CASCADE;
-- DROP FUNCTION IF EXISTS refresh_dashboard_views CASCADE;