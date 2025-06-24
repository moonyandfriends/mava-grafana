# 🚀 Railway Deployment Guide

## Pre-deployment Checklist

### 1. Supabase Setup
- [ ] Create a Supabase project at [supabase.com](https://supabase.com)
- [ ] Run the provided SQL schema to create the Mava tables
- [ ] Note down your project URL and service role key
- [ ] Verify tables are created correctly

### 2. Repository Preparation
- [ ] Fork this repository to your GitHub account
- [ ] Ensure all files are committed
- [ ] Verify the `railway.json` configuration

### 3. Railway Account Setup
- [ ] Create a Railway account at [railway.app](https://railway.app)
- [ ] Connect your GitHub account to Railway
- [ ] Have your environment variables ready

## Railway Deployment Steps

### Step 1: Connect Repository
1. Login to Railway
2. Click "New Project"
3. Select "Deploy from GitHub repo"
4. Choose your forked `mava-grafana` repository

### Step 2: Configure Environment Variables
In the Railway dashboard, add these environment variables:

```env
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=your-secure-password-here
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=your-service-role-key
```

**⚠️ Important:** 
- Use a strong password for `GRAFANA_ADMIN_PASSWORD`
- Get `SUPABASE_URL` from your Supabase project settings
- Get `SUPABASE_SERVICE_KEY` from Project Settings > API > service_role key

### Step 3: Deploy
1. Railway will automatically detect the `Dockerfile`
2. The build process will take 3-5 minutes
3. Once deployed, Railway will provide a public URL

### Step 4: Access Your Grafana Instance
1. Open the Railway-provided URL
2. Login with your configured admin credentials
3. Verify the Supabase datasource is connected
4. Check that dashboards are loaded

## Post-deployment Configuration

### 1. Verify Data Source Connection
- Navigate to Configuration > Data Sources
- Check that "Supabase" datasource shows green status
- Test the connection

### 2. Dashboard Verification
Check these dashboards are working:
- [ ] Support Ticket Analytics
- [ ] Customer Analytics
- [ ] TestData Demo (for testing)

### 3. Custom Domain (Optional)
1. In Railway dashboard, go to Settings
2. Click "Generate Domain" or add custom domain
3. Configure DNS if using custom domain

## Supabase Database Schema

Run this SQL in your Supabase SQL Editor:

```sql
-- Enable UUID extension for better ID handling
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Customers table
CREATE TABLE IF NOT EXISTS customers (
    id TEXT PRIMARY KEY,
    discord_author_id TEXT,
    client TEXT,
    name TEXT,
    avatar_url TEXT,
    discord_joined_at TIMESTAMP WITH TIME ZONE,
    wallet_address TEXT,
    discord_roles JSONB DEFAULT '[]',
    custom_fields JSONB DEFAULT '[]',
    notes JSONB DEFAULT '[]',
    user_ratings JSONB DEFAULT '[]',
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    version INTEGER,
    raw_data JSONB
);

-- 2. Tickets table
CREATE TABLE IF NOT EXISTS tickets (
    id TEXT PRIMARY KEY,
    customer_id TEXT REFERENCES customers(id),
    client TEXT,
    status TEXT,
    priority TEXT,
    source_type TEXT,
    category TEXT,
    assigned_to TEXT,
    discord_thread_id TEXT,
    interaction_identifier TEXT,
    is_discord_thread_deleted BOOLEAN DEFAULT FALSE,
    discord_users JSONB DEFAULT '[]',
    ai_status TEXT,
    is_ai_enabled_in_flow_root BOOLEAN DEFAULT FALSE,
    is_button_in_flow_root_clicked BOOLEAN DEFAULT FALSE,
    force_button_selection BOOLEAN DEFAULT FALSE,
    is_user_rating_requested BOOLEAN DEFAULT FALSE,
    is_visible BOOLEAN DEFAULT TRUE,
    mentions JSONB DEFAULT '[]',
    first_customer_message_created_at TIMESTAMP WITH TIME ZONE,
    first_agent_message_created_at TIMESTAMP WITH TIME ZONE,
    tags JSONB DEFAULT '[]',
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    version INTEGER,
    disabled BOOLEAN DEFAULT FALSE,
    raw_data JSONB
);

-- 3. Messages table
CREATE TABLE IF NOT EXISTS messages (
    id TEXT PRIMARY KEY,
    ticket_id TEXT REFERENCES tickets(id),
    sender TEXT,
    sender_reference_type TEXT,
    from_customer BOOLEAN DEFAULT FALSE,
    content TEXT,
    is_picture BOOLEAN DEFAULT FALSE,
    is_read BOOLEAN DEFAULT FALSE,
    message_type TEXT,
    message_status TEXT,
    is_edited BOOLEAN DEFAULT FALSE,
    is_deleted BOOLEAN DEFAULT FALSE,
    read_by JSONB DEFAULT '[]',
    mentions JSONB DEFAULT '[]',
    pre_submission_identifier TEXT,
    foreign_identifier TEXT,
    action_log_from TEXT,
    action_log_to TEXT,
    replied_to TEXT,
    client TEXT,
    attachments JSONB DEFAULT '[]',
    reactions JSONB DEFAULT '[]',
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    version INTEGER,
    raw_data JSONB
);

-- 4. Ticket attributes table
CREATE TABLE IF NOT EXISTS ticket_attributes (
    id TEXT PRIMARY KEY,
    ticket_id TEXT REFERENCES tickets(id),
    attribute TEXT,
    content TEXT,
    raw_data JSONB
);

-- 5. Customer attributes table
CREATE TABLE IF NOT EXISTS customer_attributes (
    id TEXT PRIMARY KEY,
    customer_id TEXT REFERENCES customers(id),
    attribute TEXT,
    content TEXT,
    raw_data JSONB
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_tickets_customer_id ON tickets(customer_id);
CREATE INDEX IF NOT EXISTS idx_tickets_status ON tickets(status);
CREATE INDEX IF NOT EXISTS idx_tickets_created_at ON tickets(created_at);
CREATE INDEX IF NOT EXISTS idx_messages_ticket_id ON messages(ticket_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);
CREATE INDEX IF NOT EXISTS idx_ticket_attributes_ticket_id ON ticket_attributes(ticket_id);
CREATE INDEX IF NOT EXISTS idx_customer_attributes_customer_id ON customer_attributes(customer_id);

-- Enable Row Level Security (RLS)
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_attributes ENABLE ROW LEVEL SECURITY;
ALTER TABLE customer_attributes ENABLE ROW LEVEL SECURITY;

-- Create policies for service role access
CREATE POLICY "Service role can manage customers" ON customers
    FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY "Service role can manage tickets" ON tickets
    FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY "Service role can manage messages" ON messages
    FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY "Service role can manage ticket_attributes" ON ticket_attributes
    FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY "Service role can manage customer_attributes" ON customer_attributes
    FOR ALL USING (auth.role() = 'service_role');
```

## Sample Data (Optional)

For testing purposes, you can insert sample data:

```sql
-- Insert sample customer
INSERT INTO customers (id, name, client, discord_author_id, created_at, user_ratings) VALUES 
('cust_1', 'John Doe', 'discord', '123456789', NOW(), '[{"rating": 5, "comment": "Great support!"}]');

-- Insert sample ticket
INSERT INTO tickets (id, customer_id, status, priority, source_type, assigned_to, created_at, first_customer_message_created_at, first_agent_message_created_at) VALUES 
('ticket_1', 'cust_1', 'closed', 'high', 'discord', 'agent_1', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days' + INTERVAL '30 minutes');

-- Insert sample message
INSERT INTO messages (id, ticket_id, sender, from_customer, content, created_at) VALUES 
('msg_1', 'ticket_1', 'cust_1', true, 'I need help with my account', NOW() - INTERVAL '2 days');
```

## Troubleshooting

### Common Issues

**1. Grafana won't start**
- Check environment variables are set correctly
- Verify Railway logs for error messages
- Ensure Supabase URL is accessible

**2. Dashboards show "No data"**
- Verify Supabase datasource connection
- Check if tables exist and have data
- Test SQL queries in Supabase SQL Editor

**3. Permission errors**
- Ensure service role key is correct
- Verify RLS policies are created
- Check table permissions

**4. Railway deployment fails**
- Check Dockerfile syntax
- Verify all files are committed to git
- Review Railway build logs

### Railway-Specific Commands

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Link to existing project
railway link

# Check deployment status
railway status

# View logs
railway logs
```

## Monitoring & Maintenance

### Health Checks
- Railway automatically monitors the `/api/health` endpoint
- Check Railway dashboard for uptime statistics
- Set up Railway notifications for downtime

### Updates
1. Make changes to your forked repository
2. Commit and push to GitHub
3. Railway will automatically redeploy

### Backup Considerations
- Grafana configuration is stored in the container
- Dashboard definitions are in Git (version controlled)
- Supabase handles database backups automatically

## Support

- **Railway Issues**: Check Railway documentation or Discord
- **Grafana Issues**: Consult Grafana documentation
- **Supabase Issues**: Check Supabase documentation or Discord
- **This Template**: Create an issue in the GitHub repository 